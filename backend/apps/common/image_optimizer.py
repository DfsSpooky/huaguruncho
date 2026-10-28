"""
Utilidades de optimización y compresión inteligente de imágenes para HUAGURUNCHO 360.

Funcionalidades:
1. optimize_panorama_image: Optimiza panoramas equirectangulares 360° para WebGL / Pannellum.
   - Preserva relación de aspecto 2:1.
   - Limita a 4096px de ancho (estándar seguro WebGL para GPUs móviles y desktop, evitando MAX_TEXTURE_SIZE crash).
   - Compresión JPEG progresiva de calidad 86 (visualmente idéntica al original, reduce tamaño de ~30MB a ~1.5MB).
2. generate_panorama_thumbnail: Genera miniaturas ultrarrápidas de 640x320 para listados y selector de escenas.
3. optimize_standard_image: Optimiza portadas de rutas, evidencias de reportes ambientales y fotos de POIs (máx 1920px).
"""

import io
import os
import logging
from PIL import Image, ImageOps
from django.core.files.base import ContentFile

logger = logging.getLogger(__name__)

# Estándar seguro WebGL para texturas esféricas (2:1 -> 4096 x 2048)
MAX_PANORAMA_WIDTH = 4096
PANORAMA_QUALITY = 86

# Miniaturas para carruseles, selector y vista móvil
THUMBNAIL_WIDTH = 640
THUMBNAIL_HEIGHT = 320
THUMBNAIL_QUALITY = 80

# Imágenes estándar (portadas, evidencias de reportes, fauna/flora)
MAX_IMAGE_DIMENSION = 1920
IMAGE_QUALITY = 85


def _open_image_safely(image_input):
    """
    Abre una imagen de manera segura desde un archivo Django, archivo en memoria,
    ruta del sistema o descriptor de archivo.
    """
    if hasattr(image_input, 'seek'):
        try:
            image_input.seek(0)
        except Exception:
            pass

    # Si es un FieldFile de Django y no está abierto
    if hasattr(image_input, 'open') and not hasattr(image_input, 'read'):
        try:
            image_input.open('rb')
        except Exception:
            pass

    img = Image.open(image_input)
    # Aplicar orientación EXIF si está presente
    try:
        img = ImageOps.exif_transpose(img)
    except Exception:
        pass

    return img


def optimize_panorama_image(image_input, max_width=MAX_PANORAMA_WIDTH, quality=PANORAMA_QUALITY):
    """
    Optimiza un panorama 360° equirectangular sin pérdida de calidad visual perceptible.
    Retorna: (ContentFile, str filename)
    """
    try:
        img = _open_image_safely(image_input)
        orig_w, orig_h = img.size

        # Si el ancho excede el máximo permitido para WebGL en dispositivos móviles, redimensionar
        target_w = min(orig_w, max_width)
        if target_w < orig_w:
            ratio = orig_w / orig_h if orig_h > 0 else 2.0
            target_h = int(round(target_w / ratio))
            # Garantizar dimensiones pares para decodificadores GPU
            if target_h % 2 != 0:
                target_h += 1
            img = img.resize((target_w, target_h), Image.Resampling.LANCZOS)
            logger.info("Panorama redimensionado de (%dx%d) a (%dx%d)", orig_w, orig_h, target_w, target_h)

        # Convertir a RGB si está en RGBA, CMYK o P
        if img.mode != 'RGB':
            img = img.convert('RGB')

        # Codificar en JPEG progresivo y optimizado
        buffer = io.BytesIO()
        img.save(
            buffer,
            format='JPEG',
            quality=quality,
            optimize=True,
            progressive=True
        )
        buffer.seek(0)

        # Determinar nombre de archivo limpio
        original_name = getattr(image_input, 'name', 'panorama.jpg') or 'panorama.jpg'
        base_name = os.path.basename(original_name)
        root_name, _ = os.path.splitext(base_name)
        out_name = f"{root_name}.jpg"

        content_file = ContentFile(buffer.getvalue(), name=out_name)
        return content_file, out_name

    except Exception as e:
        logger.error("Error optimizando panorama 360: %s", e)
        # Si falla, retornar el archivo original si es posible
        if hasattr(image_input, 'seek'):
            try:
                image_input.seek(0)
            except Exception:
                pass
        return None, None


def generate_panorama_thumbnail(image_input, width=THUMBNAIL_WIDTH, height=THUMBNAIL_HEIGHT, quality=THUMBNAIL_QUALITY):
    """
    Genera una miniatura panorámica de 640x320 para selector de escenas y carga rápida.
    Retorna: (ContentFile, str filename)
    """
    try:
        img = _open_image_safely(image_input)
        if img.mode != 'RGB':
            img = img.convert('RGB')

        thumb = img.resize((width, height), Image.Resampling.LANCZOS)
        buffer = io.BytesIO()
        thumb.save(
            buffer,
            format='JPEG',
            quality=quality,
            optimize=True
        )
        buffer.seek(0)

        original_name = getattr(image_input, 'name', 'thumb.jpg') or 'thumb.jpg'
        base_name = os.path.basename(original_name)
        root_name, _ = os.path.splitext(base_name)
        thumb_name = f"thumb_{root_name}.jpg"

        return ContentFile(buffer.getvalue(), name=thumb_name), thumb_name

    except Exception as e:
        logger.error("Error generando miniatura de panorama: %s", e)
        return None, None


def optimize_standard_image(image_input, max_dimension=MAX_IMAGE_DIMENSION, quality=IMAGE_QUALITY):
    """
    Optimiza imágenes estándar (portadas de rutas, fotos de reporte ambiental, POIs).
    Asegura que la dimensión mayor no sobrepase `max_dimension` y comprime a JPEG progresivo.
    Retorna: (ContentFile, str filename)
    """
    try:
        img = _open_image_safely(image_input)
        w, h = img.size

        # Redimensionar si sobrepasa la dimensión máxima
        max_current = max(w, h)
        if max_current > max_dimension:
            scale = max_dimension / float(max_current)
            new_w = int(round(w * scale))
            new_h = int(round(h * scale))
            img = img.resize((new_w, new_h), Image.Resampling.LANCZOS)
            logger.info("Imagen redimensionada de (%dx%d) a (%dx%d)", w, h, new_w, new_h)

        if img.mode != 'RGB':
            img = img.convert('RGB')

        buffer = io.BytesIO()
        img.save(
            buffer,
            format='JPEG',
            quality=quality,
            optimize=True,
            progressive=True
        )
        buffer.seek(0)

        original_name = getattr(image_input, 'name', 'image.jpg') or 'image.jpg'
        base_name = os.path.basename(original_name)
        root_name, _ = os.path.splitext(base_name)
        out_name = f"{root_name}.jpg"

        return ContentFile(buffer.getvalue(), name=out_name), out_name

    except Exception as e:
        logger.error("Error optimizando imagen estándar: %s", e)
        return None, None
