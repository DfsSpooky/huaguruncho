import io
import json
import zipfile
import hashlib
from django.core.files.base import ContentFile
from .models import OfflinePackage
from apps.tourism.models import BiodiversitySpecies, AudioGuide, PointOfInterest


def generate_package_manifest(route, request=None):
    """
    Generates a structured manifest for a Route, including scenes, hotspots, altimetry and POIs.
    """
    scenes_data = []
    total_size = 0

    for scene in route.scenes.filter(is_active=True).prefetch_related('hotspots').order_by('sequence'):
        hotspots_data = []
        for h in scene.hotspots.all():
            media_image_url = None
            if h.media_image and hasattr(h.media_image, 'url'):
                media_image_url = request.build_absolute_uri(h.media_image.url) if request else h.media_image.url
            hotspots_data.append({
                'uuid': str(h.uuid),
                'source_scene_uuid': str(scene.uuid),
                'type': h.type,
                'yaw': float(h.yaw),
                'pitch': float(h.pitch),
                'target_yaw': float(h.target_yaw) if h.target_yaw else 0.0,
                'target_pitch': float(h.target_pitch) if h.target_pitch else 0.0,
                'title': h.title,
                'content': h.content,
                'media_image_url': media_image_url,
                'audio_url': h.audio_url or '',
                'icon': h.icon,
                'target_scene_uuid': str(h.target_scene.uuid) if h.target_scene else None,
            })

        panorama_url = None
        if scene.panorama_image and hasattr(scene.panorama_image, 'url'):
            panorama_url = request.build_absolute_uri(scene.panorama_image.url) if request else scene.panorama_image.url
            try:
                total_size += scene.panorama_image.size
            except Exception:
                total_size += 1024 * 1024  # Fallback estimate 1MB

        thumbnail_url = None
        if scene.thumbnail and hasattr(scene.thumbnail, 'url'):
            thumbnail_url = request.build_absolute_uri(scene.thumbnail.url) if request else scene.thumbnail.url

        scenes_data.append({
            'uuid': str(scene.uuid),
            'title': scene.title,
            'description': scene.description,
            'sequence': scene.sequence,
            'latitude': float(scene.latitude) if scene.latitude else None,
            'longitude': float(scene.longitude) if scene.longitude else None,
            'altitude_masl': scene.altitude_masl,
            'heading': float(scene.heading) if scene.heading else 0.0,
            'initial_yaw': float(scene.initial_yaw) if scene.initial_yaw else 0.0,
            'initial_pitch': float(scene.initial_pitch) if scene.initial_pitch else 0.0,
            'panorama_image_url': panorama_url,
            'thumbnail_url': thumbnail_url,
            'hotspots': hotspots_data
        })

    pois_data = []
    for poi in route.points_of_interest.filter(is_active=True).order_by('order'):
        pois_data.append({
            'uuid': str(poi.uuid),
            'name': poi.name,
            'category': poi.category,
            'altitude_masl': poi.altitude_masl,
            'latitude': float(poi.latitude) if poi.latitude else None,
            'longitude': float(poi.longitude) if poi.longitude else None,
            'description': poi.description,
            'order': poi.order,
        })

    manifest = {
        'route': {
            'uuid': str(route.uuid),
            'name': route.name,
            'slug': route.slug,
            'description': route.description,
            'difficulty': route.difficulty,
            'difficulty_display': route.get_difficulty_display(),
            'distance_km': float(route.distance_km),
            'estimated_duration_minutes': route.estimated_duration_minutes,
            'elevation_gain_m': float(route.elevation_gain_m),
            'elevation_loss_m': float(route.elevation_loss_m),
            'max_altitude_m': route.max_altitude_m,
            'min_altitude_m': route.min_altitude_m,
            'safety_recommendations': route.safety_recommendations,
            'geojson_track': route.geojson_track,
            'elevation_profile': route.elevation_profile,
        },
        'scenes': scenes_data,
        'points_of_interest': pois_data,
    }

    return manifest, total_size


def update_or_create_offline_package(route, request=None):
    manifest, total_size = generate_package_manifest(route, request)
    package, created = OfflinePackage.objects.get_or_create(
        route=route,
        defaults={
            'version': 1,
            'manifest_json': manifest,
            'size_bytes': total_size,
            'is_published': True
        }
    )
    if not created:
        package.manifest_json = manifest
        package.size_bytes = total_size
        package.version += 1
        package.save()
    return package


def get_or_generate_offline_zip(route, force=False):
    """
    Generates and persists an offline ZIP archive on disk for a Route:
    - manifest.json
    - track.geojson
    - README_OFFLINE.txt
    - SHA256 checksum
    - Panoramic 360 images (streamed directly without full RAM buffering)
    Caches the file on disk to avoid re-compression on repeated downloads.
    """
    import os
    from pathlib import Path
    from django.conf import settings
    media_root = str(settings.MEDIA_ROOT) if getattr(settings, 'MEDIA_ROOT', None) else 'media'
    packages_dir = Path(media_root) / 'offline_packages'
    packages_dir.mkdir(parents=True, exist_ok=True)
    zip_path = packages_dir / f"package_{route.uuid}.zip"
    checksum_path = packages_dir / f"package_{route.uuid}.sha256"

    # Reutilizar archivo si ya existe y la ruta no ha cambiado
    if not force and zip_path.exists() and checksum_path.exists():
        try:
            zip_mtime = zip_path.stat().st_mtime
            route_mtime = route.updated_at.timestamp()
            if zip_mtime >= route_mtime:
                with open(checksum_path, 'r', encoding='utf-8') as cf:
                    sha256 = cf.read().strip()
                return zip_path, sha256
        except Exception:
            pass

    manifest, _ = generate_package_manifest(route)
    manifest_str = json.dumps(manifest, indent=2, ensure_ascii=False)
    manifest_bytes = manifest_str.encode('utf-8')
    manifest_sha256 = hashlib.sha256(manifest_bytes).hexdigest()

    readme_text = f"""=====================================================
HUAGURUNCHO 360 - PAQUETE OFFLINE PARA ALTA MONTAÑA
Ruta: {route.name}
Distancia: {route.distance_km} km | Desnivel: +{route.elevation_gain_m}m D+
Comunidad Campesina de Huachón - Pasco, Perú
=====================================================
Este paquete contiene los datos completos, geometrías GPS y
escenas 360° para navegación autónoma sin conexión a internet.
Integridad SHA-256: {manifest_sha256}
"""

    track_geojson_str = json.dumps(route.geojson_track, indent=2) if route.geojson_track else None
    panoramas_input = []
    for scene in route.scenes.filter(is_active=True):
        if scene.panorama_image and hasattr(scene.panorama_image, 'path'):
            try:
                if os.path.exists(scene.panorama_image.path):
                    panoramas_input.append({
                        'file_path': scene.panorama_image.path,
                        'arcname': f"panoramas/scene_{scene.sequence}_{str(scene.uuid)[:8]}.jpg",
                    })
            except Exception:
                pass

    from apps.common.rust_bridge import rust_build_offline_zip
    rust_zip_res = rust_build_offline_zip(
        output_zip_path=str(zip_path),
        manifest_json=manifest_str,
        readme_text=readme_text,
        track_geojson=track_geojson_str,
        panoramas=panoramas_input,
    )

    if rust_zip_res and rust_zip_res.get('success'):
        manifest_sha256 = rust_zip_res.get('manifest_sha256', manifest_sha256)
        with open(checksum_path, 'w', encoding='utf-8') as cf:
            cf.write(manifest_sha256)
        return zip_path, manifest_sha256

    temp_zip_path = packages_dir / f"temp_{route.uuid}.zip"
    with zipfile.ZipFile(temp_zip_path, 'w', zipfile.ZIP_DEFLATED) as zf:
        zf.writestr('manifest.json', manifest_bytes)
        zf.writestr('README_OFFLINE.txt', readme_text.encode('utf-8'))
        zf.writestr('checksum.sha256', f"{manifest_sha256}  manifest.json\n".encode('utf-8'))

        if track_geojson_str:
            zf.writestr('track.geojson', track_geojson_str.encode('utf-8'))

        # Incluir imágenes panorámicas transmitiendo desde disco sin saturar RAM
        for p in panoramas_input:
            try:
                zf.write(p['file_path'], arcname=p['arcname'])
            except Exception:
                pass

    # Renombrar atómicamente
    temp_zip_path.replace(zip_path)
    with open(checksum_path, 'w', encoding='utf-8') as cf:
        cf.write(manifest_sha256)

    return zip_path, manifest_sha256


def generate_offline_zip_archive(route):
    """
    Compatibility wrapper returning (open_file_handle, sha256)
    """
    zip_path, sha256 = get_or_generate_offline_zip(route)
    return open(zip_path, 'rb'), sha256

