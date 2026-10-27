import logging
import os
from PIL import Image, ExifTags
from apps.common.rust_bridge import rust_extract_exif_file

logger = logging.getLogger(__name__)

def _get_exif_data(image):
    try:
        exif = image.get_exif()
        if not exif:
            return {}
        return {
            ExifTags.TAGS.get(tag_id, tag_id): value
            for tag_id, value in exif.items()
        }
    except Exception as e:
        logger.debug("No se pudo obtener EXIF: %s", e)
        return {}


def _get_gps_info(exif_data):
    gps_info_raw = exif_data.get('GPSInfo')
    if not gps_info_raw:
        return {}
    gps_data = {}
    for key, val in gps_info_raw.items():
        sub_tag = ExifTags.GPSTAGS.get(key, key)
        gps_data[sub_tag] = val
    return gps_data


def _convert_dms_to_decimal(dms, ref):
    try:
        degrees = float(dms[0])
        minutes = float(dms[1])
        seconds = float(dms[2])
        decimal = degrees + (minutes / 60.0) + (seconds / 3600.0)
        if ref in ['S', 'W']:
            decimal = -decimal
        return round(decimal, 6)
    except Exception:
        return None


def extract_panorama_metadata(image_file):
    """
    Extrae latitud, longitud, altitud y orientación magnética (heading)
    de una imagen panorámica 360° si cuenta con metadatos EXIF / GPS.
    Retorna un diccionario con los campos encontrados:
    {
        'latitude': float or None,
        'longitude': float or None,
        'altitude_masl': int or None,
        'heading': float or None,
    }
    """
    result = {
        'latitude': None,
        'longitude': None,
        'altitude_masl': None,
        'heading': None,
    }

    try:
        file_path = None
        if isinstance(image_file, (str, os.PathLike)):
            file_path = str(image_file)
        elif hasattr(image_file, 'path'):
            try:
                file_path = image_file.path
            except Exception:
                file_path = None

        if file_path and os.path.exists(file_path):
            rust_meta = rust_extract_exif_file(file_path)
            if rust_meta and any(rust_meta.get(k) is not None for k in ('latitude', 'longitude', 'altitude_masl', 'heading')):
                return rust_meta

        # Abrir imagen preservando puntero si es archivo en memoria / django file
        if hasattr(image_file, 'seek'):
            image_file.seek(0)

        with Image.open(image_file) as img:
            exif = _get_exif_data(img)
            gps_info = _get_gps_info(exif)

            # 1. Latitud y Longitud
            lat_dms = gps_info.get('GPSLatitude')
            lat_ref = gps_info.get('GPSLatitudeRef')
            lon_dms = gps_info.get('GPSLongitude')
            lon_ref = gps_info.get('GPSLongitudeRef')

            if lat_dms and lat_ref:
                result['latitude'] = _convert_dms_to_decimal(lat_dms, lat_ref)
            if lon_dms and lon_ref:
                result['longitude'] = _convert_dms_to_decimal(lon_dms, lon_ref)

            # 2. Altitud
            alt = gps_info.get('GPSAltitude')
            if alt is not None:
                try:
                    result['altitude_masl'] = int(float(alt))
                except Exception:
                    pass

            # 3. Orientación / Rumbo (GPSImgDirection)
            heading = gps_info.get('GPSImgDirection')
            if heading is not None:
                try:
                    result['heading'] = round(float(heading), 1)
                except Exception:
                    pass

        if hasattr(image_file, 'seek'):
            image_file.seek(0)
    except Exception as e:
        logger.debug("Error leyendo metadatos de panorama: %s", e)

    return result
