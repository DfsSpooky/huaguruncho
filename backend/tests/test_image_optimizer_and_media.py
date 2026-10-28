"""
Tests para el pipeline de compresión y optimización de imágenes (360 y estándar)
y para el servicio seguro de archivos multimedia en producción.
"""
import io
from PIL import Image
from django.test import TestCase, Client
from django.core.files.base import ContentFile
from django.contrib.auth import get_user_model
from apps.common.image_optimizer import (
    optimize_panorama_image,
    generate_panorama_thumbnail,
    optimize_standard_image,
)
from apps.tourism.models import Route, TourScene

User = get_user_model()


class ImageOptimizerTests(TestCase):
    def setUp(self):
        self.route = Route.objects.create(
            name="Ruta Test Compresión",
            description="Ruta para verificar compresión sin pérdida visual"
        )

    def test_panorama_optimization_resizes_and_preserves_2_to_1(self):
        # Crear imagen equirectangular simulada gigante (5000 x 2500, ratio 2:1)
        img = Image.new('RGB', (5000, 2500), color=(120, 180, 240))
        buf = io.BytesIO()
        img.save(buf, format='JPEG', quality=95)
        buf.seek(0)

        raw_size = len(buf.getvalue())
        content_file = ContentFile(buf.getvalue(), name="large_panorama.jpg")

        optimized_cf, filename = optimize_panorama_image(content_file, max_width=4096, quality=86)

        self.assertIsNotNone(optimized_cf)
        self.assertEqual(filename, "large_panorama.jpg")

        # Verificar dimensiones del resultado optimizado
        with Image.open(optimized_cf) as out_img:
            w, h = out_img.size
            self.assertLessEqual(w, 4096)
            self.assertEqual(w, 4096)
            self.assertEqual(h, 2048)
            self.assertEqual(out_img.format, 'JPEG')

        # Verificar que redujo tamaño en bytes
        opt_size = len(optimized_cf.read())
        self.assertLess(opt_size, raw_size)

    def test_panorama_thumbnail_generation(self):
        img = Image.new('RGB', (2048, 1024), color=(60, 120, 180))
        buf = io.BytesIO()
        img.save(buf, format='JPEG', quality=90)
        buf.seek(0)

        content_file = ContentFile(buf.getvalue(), name="scene_sample.jpg")
        thumb_cf, thumb_name = generate_panorama_thumbnail(content_file, width=640, height=320)

        self.assertIsNotNone(thumb_cf)
        self.assertEqual(thumb_name, "thumb_scene_sample.jpg")

        with Image.open(thumb_cf) as thumb_img:
            self.assertEqual(thumb_img.size, (640, 320))
            self.assertEqual(thumb_img.format, 'JPEG')

    def test_standard_image_optimization(self):
        # Imagen vertical no 360 (ej: 3000 x 4000)
        img = Image.new('RGB', (3000, 4000), color=(200, 100, 50))
        buf = io.BytesIO()
        img.save(buf, format='JPEG', quality=95)
        buf.seek(0)

        content_file = ContentFile(buf.getvalue(), name="evidence_photo.jpg")
        opt_cf, opt_name = optimize_standard_image(content_file, max_dimension=1920, quality=85)

        self.assertIsNotNone(opt_cf)
        with Image.open(opt_cf) as out_img:
            w, h = out_img.size
            self.assertLessEqual(max(w, h), 1920)
            self.assertEqual(h, 1920)

    def test_tour_scene_auto_optimizes_and_creates_thumbnail_on_save(self):
        img = Image.new('RGB', (1024, 512), color=(100, 150, 200))
        buf = io.BytesIO()
        img.save(buf, format='JPEG', quality=90)
        buf.seek(0)

        scene = TourScene(
            route=self.route,
            title="Escena de Test",
            sequence=1,
        )
        scene.panorama_image.save("test_pano.jpg", ContentFile(buf.getvalue()), save=True)

        self.assertTrue(bool(scene.panorama_image))
        self.assertTrue(bool(scene.thumbnail))
        self.assertIn("thumb_test_pano", scene.thumbnail.name)


class MediaServingTests(TestCase):
    def setUp(self):
        self.client = Client()

    def test_media_serve_view_headers(self):
        # Crear archivo temporal en storage de media
        img = Image.new('RGB', (100, 100), color=(50, 100, 150))
        buf = io.BytesIO()
        img.save(buf, format='JPEG')
        buf.seek(0)

        scene = TourScene.objects.create(
            route=Route.objects.create(name="Ruta Media"),
            title="Escena Media",
            sequence=1
        )
        scene.panorama_image.save("media_test.jpg", ContentFile(buf.getvalue()), save=True)

        url = scene.panorama_image.url
        response = self.client.get(url, HTTP_HOST='apih.aquienpasco.com')

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response['Access-Control-Allow-Origin'], '*')
        self.assertEqual(response['Cache-Control'], 'public, max-age=86400')
        self.assertEqual(response['Content-Type'], 'image/jpeg')
