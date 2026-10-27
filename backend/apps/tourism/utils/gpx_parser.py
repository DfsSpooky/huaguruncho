import math
import xml.etree.ElementTree as ET
from typing import Dict, Any, List, Optional, Tuple
from apps.common.rust_bridge import (
    rust_haversine_km,
    rust_estimated_duration_minutes,
    rust_simplify_points_rdp,
    rust_parse_gpx_content,
)


def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calcula la distancia geodésica en kilómetros entre dos coordenadas GPS (Haversine)."""
    rust_val = rust_haversine_km(lat1, lon1, lat2, lon2)
    if rust_val is not None:
        return rust_val

    R = 6371.0  # Radio de la Tierra en km
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (
        math.sin(dlat / 2) ** 2
        + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c


def calculate_estimated_duration_minutes(
    distance_km: float,
    elevation_gain_m: float,
    elevation_loss_m: float = 0.0,
    max_altitude_m: float = 0.0
) -> int:
    """
    Calcula la duración estimada en minutos utilizando la Regla de Naismith Andina (Tobler / MIDE)
    ajustada a la fatiga por altitud (por encima de 3,800m y 4,500m s.n.m.).
    """
    if distance_km <= 0:
        return 30

    rust_mins = rust_estimated_duration_minutes(
        distance_km, elevation_gain_m, elevation_loss_m, max_altitude_m
    )
    if rust_mins is not None:
        return rust_mins

    flat_minutes = (distance_km / 4.0) * 60.0  # Ritmo base de marcha: 4 km/h
    ascent_minutes = (elevation_gain_m / 100.0) * 10.0  # +10 min por cada 100m de ascenso
    descent_minutes = (elevation_loss_m / 100.0) * 4.0  # +4 min por cada 100m de descenso

    # Factor de altitud andina por hipoxia/presión barométrica
    altitude_factor = 1.0
    if max_altitude_m >= 4500:
        altitude_factor = 1.25
    elif max_altitude_m >= 3800:
        altitude_factor = 1.15

    total = (flat_minutes + ascent_minutes + descent_minutes) * altitude_factor
    return max(15, int(round(total)))


def calculate_difficulty_level(
    distance_km: float,
    elevation_gain_m: float,
    max_altitude_m: float = 0.0
) -> str:
    """
    Determina automáticamente el nivel de dificultad montañera según la escala MIDE/FEDME:
    FACIL | MODERADA | DIFICIL | EXPERTO
    """
    if distance_km < 7.0 and elevation_gain_m < 350.0 and max_altitude_m < 3800:
        return "FACIL"
    elif distance_km <= 14.0 and elevation_gain_m <= 750.0 and max_altitude_m < 4200:
        return "MODERADA"
    elif distance_km <= 22.0 and elevation_gain_m <= 1300.0 and max_altitude_m < 4600:
        return "DIFICIL"
    else:
        return "EXPERTO"


def simplify_points_rdp(points: List[List[float]], epsilon: float = 0.00008) -> List[List[float]]:
    """
    Simplificación Ramer-Douglas-Peucker para reducir el tamaño del GeoJSON
    manteniendo la curvatura exacta del sendero sin perder resolución.
    """
    if len(points) <= 2:
        return points

    rust_simplified = rust_simplify_points_rdp(points, epsilon)
    if rust_simplified is not None and len(rust_simplified) >= 2:
        return rust_simplified

    # Distancia perpendicular
    def perpendicular_distance(pt, start, end):
        if start[0] == end[0] and start[1] == end[1]:
            return math.sqrt((pt[0] - start[0])**2 + (pt[1] - start[1])**2)
        n = abs((end[1] - start[1]) * pt[0] - (end[0] - start[0]) * pt[1] + end[0] * start[1] - end[1] * start[0])
        d = math.sqrt((end[1] - start[1])**2 + (end[0] - start[0])**2)
        return n / d if d > 0 else 0.0

    dmax = 0.0
    index = 0
    end = len(points) - 1

    for i in range(1, end):
        d = perpendicular_distance(points[i], points[0], points[end])
        if d > dmax:
            index = i
            dmax = d

    if dmax > epsilon:
        rec_results1 = simplify_points_rdp(points[:index+1], epsilon)
        rec_results2 = simplify_points_rdp(points[index:], epsilon)
        return rec_results1[:-1] + rec_results2
    else:
        return [points[0], points[end]]


def parse_gpx_content(gpx_text: str) -> Dict[str, Any]:
    """
    Parsea un archivo GPX (compatible con Wikiloc, Garmin, Strava, Komoot) y extrae:
    - Distancia geodésica exacta en km
    - Desnivel positivo (+D) y negativo (-D)
    - Cota mínima y cota máxima (m s.n.m.)
    - Duración estimada calculada (minutos)
    - Dificultad técnica clasificada (FACIL, MODERADA, DIFICIL, EXPERTO)
    - Título y descripción interna del track si existen
    - Geometría GeoJSON simplificada (LineString)
    - Perfil de elevación suave (Altimetría)
    - Waypoints / Puntos de control (POIs)
    """
    rust_res = rust_parse_gpx_content(gpx_text)
    if rust_res is not None:
        return rust_res

    try:
        import gpxpy
        gpx = gpxpy.parse(gpx_text)
        return _parse_with_gpxpy(gpx)
    except Exception:
        return _parse_with_element_tree(gpx_text)


def _parse_with_gpxpy(gpx) -> Dict[str, Any]:
    track_points: List[List[float]] = []
    elevation_profile: List[Dict[str, Any]] = []
    total_dist_km = 0.0
    uphill = 0.0
    downhill = 0.0
    prev_point = None
    min_elev = 99999.0
    max_elev = -99999.0

    track_name = gpx.name or ""
    track_desc = gpx.description or ""

    for track in gpx.tracks:
        if not track_name and track.name:
            track_name = track.name
        if not track_desc and track.description:
            track_desc = track.description

        for segment in track.segments:
            for pt in segment.points:
                lat = float(pt.latitude)
                lon = float(pt.longitude)
                ele = float(pt.elevation) if pt.elevation is not None else 0.0

                if prev_point is not None:
                    d = haversine_distance(prev_point[0], prev_point[1], lat, lon)
                    total_dist_km += d
                    ele_diff = ele - prev_point[2]
                    if ele_diff > 0:
                        uphill += ele_diff
                    else:
                        downhill += abs(ele_diff)

                min_elev = min(min_elev, ele)
                max_elev = max(max_elev, ele)

                track_points.append([lon, lat, round(ele, 1)])
                elevation_profile.append({
                    "distance_km": round(total_dist_km, 3),
                    "altitude_m": round(ele, 1),
                })
                prev_point = (lat, lon, ele)

    if not track_points and gpx.routes:
        for route in gpx.routes:
            if not track_name and route.name:
                track_name = route.name
            for pt in route.points:
                lat = float(pt.latitude)
                lon = float(pt.longitude)
                ele = float(pt.elevation) if pt.elevation is not None else 0.0
                if prev_point is not None:
                    d = haversine_distance(prev_point[0], prev_point[1], lat, lon)
                    total_dist_km += d
                    ele_diff = ele - prev_point[2]
                    if ele_diff > 0:
                        uphill += ele_diff
                    else:
                        downhill += abs(ele_diff)

                min_elev = min(min_elev, ele)
                max_elev = max(max_elev, ele)
                track_points.append([lon, lat, round(ele, 1)])
                elevation_profile.append({
                    "distance_km": round(total_dist_km, 3),
                    "altitude_m": round(ele, 1),
                })
                prev_point = (lat, lon, ele)

    waypoints: List[Dict[str, Any]] = []
    for wpt in gpx.waypoints:
        waypoints.append({
            "name": wpt.name or "Punto de Control",
            "latitude": float(wpt.latitude),
            "longitude": float(wpt.longitude),
            "altitude_m": round(float(wpt.elevation), 1) if wpt.elevation is not None else 0.0,
            "description": wpt.description or wpt.comment or "",
            "symbol": wpt.symbol or "",
        })

    start_alt = track_points[0][2] if track_points else 0.0
    min_altitude = round(min_elev if min_elev != 99999.0 else start_alt, 1)
    max_altitude = round(max_elev if max_elev != -99999.0 else start_alt, 1)
    dist_km = round(total_dist_km, 2)
    gain_m = round(uphill, 1)
    loss_m = round(downhill, 1)

    duration_min = calculate_estimated_duration_minutes(dist_km, gain_m, loss_m, max_altitude)
    diff_level = calculate_difficulty_level(dist_km, gain_m, max_altitude)

    # GeoJSON simplificado para payload ligero
    simplified_coords = simplify_points_rdp(track_points) if len(track_points) > 300 else track_points

    return {
        "success": True,
        "track_name": track_name.strip(),
        "track_description": track_desc.strip(),
        "total_distance_km": dist_km,
        "elevation_gain_m": gain_m,
        "elevation_loss_m": loss_m,
        "min_altitude_m": min_altitude,
        "max_altitude_m": max_altitude,
        "start_altitude_m": round(start_alt, 1),
        "estimated_duration_minutes": duration_min,
        "difficulty": diff_level,
        "point_count": len(track_points),
        "simplified_point_count": len(simplified_coords),
        "geojson_track": {
            "type": "Feature",
            "geometry": {
                "type": "LineString",
                "coordinates": simplified_coords,
            },
            "properties": {
                "distance_km": dist_km,
                "elevation_gain_m": gain_m,
                "elevation_loss_m": loss_m,
                "max_altitude_m": max_altitude,
                "min_altitude_m": min_altitude,
                "estimated_duration_minutes": duration_min,
                "difficulty": diff_level,
            },
        },
        "elevation_profile": _sample_profile(elevation_profile, max_points=120),
        "waypoints": waypoints,
    }


def _parse_with_element_tree(gpx_text: str) -> Dict[str, Any]:
    try:
        root = ET.fromstring(gpx_text)
    except Exception as e:
        return {"success": False, "error": f"Formato GPX inválido: {str(e)}"}

    namespace = ""
    if root.tag.startswith("{"):
        namespace = root.tag.split("}")[0] + "}"

    track_points: List[List[float]] = []
    elevation_profile: List[Dict[str, Any]] = []
    total_dist_km = 0.0
    uphill = 0.0
    downhill = 0.0
    prev_point = None
    min_elev = 99999.0
    max_elev = -99999.0

    name_el = root.find(f".//{namespace}trk/{namespace}name") or root.find(f".//{namespace}name")
    desc_el = root.find(f".//{namespace}trk/{namespace}desc") or root.find(f".//{namespace}desc")
    track_name = name_el.text if name_el is not None and name_el.text else ""
    track_desc = desc_el.text if desc_el is not None and desc_el.text else ""

    for trkpt in root.findall(f".//{namespace}trkpt"):
        lat = float(trkpt.attrib["lat"])
        lon = float(trkpt.attrib["lon"])
        ele_elem = trkpt.find(f"{namespace}ele")
        ele = float(ele_elem.text) if ele_elem is not None and ele_elem.text else 0.0

        if prev_point is not None:
            d = haversine_distance(prev_point[0], prev_point[1], lat, lon)
            total_dist_km += d
            diff = ele - prev_point[2]
            if diff > 0:
                uphill += diff
            else:
                downhill += abs(diff)

        min_elev = min(min_elev, ele)
        max_elev = max(max_elev, ele)

        track_points.append([lon, lat, round(ele, 1)])
        elevation_profile.append({
            "distance_km": round(total_dist_km, 3),
            "altitude_m": round(ele, 1),
        })
        prev_point = (lat, lon, ele)

    waypoints: List[Dict[str, Any]] = []
    for wpt in root.findall(f".//{namespace}wpt"):
        lat = float(wpt.attrib["lat"])
        lon = float(wpt.attrib["lon"])
        w_name = wpt.find(f"{namespace}name")
        w_desc = wpt.find(f"{namespace}desc")
        ele_el = wpt.find(f"{namespace}ele")
        ele = float(ele_el.text) if ele_el is not None and ele_el.text else 0.0

        waypoints.append({
            "name": w_name.text if w_name is not None and w_name.text else "Punto de Control",
            "latitude": lat,
            "longitude": lon,
            "altitude_m": round(ele, 1),
            "description": w_desc.text if w_desc is not None and w_desc.text else "",
        })

    start_alt = track_points[0][2] if track_points else 0.0
    min_altitude = round(min_elev if min_elev != 99999.0 else start_alt, 1)
    max_altitude = round(max_elev if max_elev != -99999.0 else start_alt, 1)
    dist_km = round(total_dist_km, 2)
    gain_m = round(uphill, 1)
    loss_m = round(downhill, 1)

    duration_min = calculate_estimated_duration_minutes(dist_km, gain_m, loss_m, max_altitude)
    diff_level = calculate_difficulty_level(dist_km, gain_m, max_altitude)

    simplified_coords = simplify_points_rdp(track_points) if len(track_points) > 300 else track_points

    return {
        "success": True,
        "track_name": track_name.strip(),
        "track_description": track_desc.strip(),
        "total_distance_km": dist_km,
        "elevation_gain_m": gain_m,
        "elevation_loss_m": loss_m,
        "min_altitude_m": min_altitude,
        "max_altitude_m": max_altitude,
        "start_altitude_m": round(start_alt, 1),
        "estimated_duration_minutes": duration_min,
        "difficulty": diff_level,
        "point_count": len(track_points),
        "simplified_point_count": len(simplified_coords),
        "geojson_track": {
            "type": "Feature",
            "geometry": {
                "type": "LineString",
                "coordinates": simplified_coords,
            },
            "properties": {
                "distance_km": dist_km,
                "elevation_gain_m": gain_m,
                "elevation_loss_m": loss_m,
                "max_altitude_m": max_altitude,
                "min_altitude_m": min_altitude,
                "estimated_duration_minutes": duration_min,
                "difficulty": diff_level,
            },
        },
        "elevation_profile": _sample_profile(elevation_profile, max_points=120),
        "waypoints": waypoints,
    }


def _sample_profile(profile: List[Dict[str, Any]], max_points: int = 120) -> List[Dict[str, Any]]:
    if len(profile) <= max_points:
        return profile
    step = len(profile) / max_points
    sampled = [profile[int(i * step)] for i in range(max_points)]
    if profile and (not sampled or sampled[-1] != profile[-1]):
        sampled.append(profile[-1])
    return sampled
