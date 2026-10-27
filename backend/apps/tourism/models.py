from django.conf import settings
from django.db import models
from django.utils import timezone
from django.utils.text import slugify
from apps.common.models import UUIDModel, TimeStampedModel


class Route(UUIDModel, TimeStampedModel):
    class Difficulty(models.TextChoices):
        FACIL = 'facil', 'Fácil'
        MODERADA = 'moderada', 'Moderada'
        DIFICIL = 'dificil', 'Difícil'

    name = models.CharField(
        max_length=200,
        verbose_name='Nombre de la Ruta',
        db_index=True
    )
    slug = models.SlugField(
        max_length=220,
        unique=True,
        blank=True,
        verbose_name='Slug URL'
    )
    description = models.TextField(
        verbose_name='Descripción de la Ruta'
    )
    difficulty = models.CharField(
        max_length=20,
        choices=Difficulty.choices,
        default=Difficulty.MODERADA,
        verbose_name='Nivel de Dificultad'
    )
    distance_km = models.DecimalField(
        max_digits=6,
        decimal_places=2,
        default=0.0,
        blank=True,
        verbose_name='Distancia (km)'
    )
    estimated_duration_minutes = models.PositiveIntegerField(
        default=0,
        blank=True,
        verbose_name='Duración Estimada (minutos)'
    )
    safety_recommendations = models.TextField(
        blank=True,
        verbose_name='Recomendaciones Específicas de la Ruta'
    )
    cover_image = models.ImageField(
        upload_to='routes/covers/',
        blank=True,
        null=True,
        verbose_name='Imagen de Portada'
    )
    gpx_file = models.FileField(
        upload_to='routes/gpx/',
        blank=True,
        null=True,
        verbose_name='Archivo GPX (Wikiloc / Garmin)'
    )
    geojson_track = models.JSONField(
        blank=True,
        null=True,
        verbose_name='Trazo GPS GeoJSON'
    )
    elevation_profile = models.JSONField(
        blank=True,
        null=True,
        verbose_name='Perfil de Elevación (Altimetría)'
    )
    elevation_gain_m = models.DecimalField(
        max_digits=7,
        decimal_places=1,
        default=0.0,
        verbose_name='Desnivel Positivo +D (m)'
    )
    elevation_loss_m = models.DecimalField(
        max_digits=7,
        decimal_places=1,
        default=0.0,
        verbose_name='Desnivel Negativo -D (m)'
    )
    max_altitude_m = models.PositiveIntegerField(
        default=0,
        verbose_name='Cota Máxima (m s.n.m.)'
    )
    min_altitude_m = models.PositiveIntegerField(
        default=0,
        verbose_name='Cota Mínima (m s.n.m.)'
    )
    is_active = models.BooleanField(
        default=True,
        verbose_name='Ruta Activa',
        db_index=True
    )

    class Meta:
        verbose_name = 'Ruta Turística'
        verbose_name_plural = 'Rutas Turísticas'
        ordering = ['name']

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)

        # Auto-procesar GPX: extraer distancias, desniveles, duraciones y dificultad sin requerir ingreso manual
        if self.gpx_file:
            try:
                from apps.tourism.utils.gpx_parser import parse_gpx_content
                self.gpx_file.seek(0)
                content = self.gpx_file.read().decode('utf-8', errors='ignore')
                res = parse_gpx_content(content)
                if res.get('success'):
                    self.geojson_track = res.get('geojson_track')
                    self.elevation_profile = res.get('elevation_profile')
                    self.elevation_gain_m = res.get('elevation_gain_m', 0.0)
                    self.elevation_loss_m = res.get('elevation_loss_m', 0.0)
                    self.max_altitude_m = int(res.get('max_altitude_m', 0))
                    self.min_altitude_m = int(res.get('min_altitude_m', 0))
                    self.distance_km = res.get('total_distance_km', 0.0)
                    if res.get('estimated_duration_minutes'):
                        self.estimated_duration_minutes = res.get('estimated_duration_minutes')
                    if res.get('difficulty'):
                        self.difficulty = res.get('difficulty')
                    if (not self.name or self.name.strip() in ['Nueva Ruta', 'Ruta GPX']) and res.get('track_name'):
                        self.name = res.get('track_name')
            except Exception:
                pass

        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.name} ({self.get_difficulty_display()})"


class TourScene(UUIDModel, TimeStampedModel):
    route = models.ForeignKey(
        Route,
        on_delete=models.CASCADE,
        related_name='scenes',
        verbose_name='Ruta Perteneciente'
    )
    title = models.CharField(
        max_length=200,
        verbose_name='Título del Punto / Escena'
    )
    description = models.TextField(
        blank=True,
        verbose_name='Descripción del Punto'
    )
    panorama_image = models.ImageField(
        upload_to='panoramas/',
        verbose_name='Imagen Panorámica 360° (Equirectangular)'
    )
    thumbnail = models.ImageField(
        upload_to='panoramas/thumbnails/',
        blank=True,
        null=True,
        verbose_name='Miniatura'
    )
    latitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        blank=True,
        null=True,
        verbose_name='Latitud GPS'
    )
    longitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        blank=True,
        null=True,
        verbose_name='Longitud GPS'
    )
    altitude_masl = models.IntegerField(
        blank=True,
        null=True,
        verbose_name='Altitud del Nodo (m s.n.m.)'
    )
    heading = models.FloatField(
        default=0.0,
        verbose_name='Orientación / Rumbo Norte (0° - 360°)'
    )
    initial_yaw = models.FloatField(
        default=0.0,
        verbose_name='Yaw Inicial / Ángulo de Inicio (-180° a +180°)'
    )
    initial_pitch = models.FloatField(
        default=0.0,
        verbose_name='Pitch Inicial (-90° a +90°)'
    )
    is_control_point = models.BooleanField(
        default=False,
        verbose_name='Es Punto de Control / Waypoint'
    )
    sequence = models.PositiveIntegerField(
        default=1,
        verbose_name='Orden en la Ruta',
        db_index=True
    )
    is_active = models.BooleanField(
        default=True,
        verbose_name='Activo',
        db_index=True
    )

    class Meta:
        verbose_name = 'Escena 360°'
        verbose_name_plural = 'Escenas 360°'
        ordering = ['route', 'sequence']

    def __str__(self):
        return f"{self.route.name} - Escena {self.sequence}: {self.title}"

    def save(self, *args, **kwargs):
        # Auto-extraer GPS y rumbo de la imagen si no fueron especificados manualmente
        if self.panorama_image and (self.latitude is None or self.longitude is None or not self.heading):
            try:
                from apps.tourism.utils.exif_reader import extract_panorama_metadata
                meta = extract_panorama_metadata(self.panorama_image)
                if self.latitude is None and meta.get('latitude') is not None:
                    self.latitude = meta['latitude']
                if self.longitude is None and meta.get('longitude') is not None:
                    self.longitude = meta['longitude']
                if self.altitude_masl is None and meta.get('altitude_masl') is not None:
                    self.altitude_masl = meta['altitude_masl']
                if (not self.heading or self.heading == 0.0) and meta.get('heading') is not None:
                    self.heading = meta['heading']
            except Exception:
                pass
        super().save(*args, **kwargs)


class Hotspot(UUIDModel, TimeStampedModel):
    class HotspotType(models.TextChoices):
        NAVIGATION = 'navigation', 'Navegación (Paso Street View)'
        INFORMATION = 'information', 'Información Turística'
        PHOTO_POI = 'photo_poi', 'Fotografía / Hito de Interés'
        AUDIO_GUIDE = 'audio_guide', 'Audioguía / Relato Cultural'
        WARNING = 'warning', 'Advertencia / Peligro de Alta Montaña'

    source_scene = models.ForeignKey(
        TourScene,
        on_delete=models.CASCADE,
        related_name='hotspots',
        verbose_name='Escena de Origen'
    )
    target_scene = models.ForeignKey(
        TourScene,
        on_delete=models.SET_NULL,
        blank=True,
        null=True,
        related_name='incoming_hotspots',
        verbose_name='Escena de Destino (Solo Navegación)'
    )
    type = models.CharField(
        max_length=20,
        choices=HotspotType.choices,
        default=HotspotType.NAVIGATION,
        verbose_name='Tipo de Hotspot'
    )
    yaw = models.FloatField(
        default=0.0,
        verbose_name='Yaw / Giro Horizontal (-180° a +180°)'
    )
    pitch = models.FloatField(
        default=0.0,
        verbose_name='Pitch / Inclinación Vertical (-90° a +90°)'
    )
    target_yaw = models.FloatField(
        default=0.0,
        verbose_name='Ángulo de Llegada a la siguiente escena (-180° a +180°)'
    )
    target_pitch = models.FloatField(
        default=0.0,
        verbose_name='Inclinación de Llegada (-90° a +90°)'
    )
    title = models.CharField(
        max_length=150,
        verbose_name='Título del Hotspot'
    )
    content = models.TextField(
        blank=True,
        verbose_name='Contenido o Mensaje Explicativo'
    )
    media_image = models.ImageField(
        upload_to='hotspots/media/',
        blank=True,
        null=True,
        verbose_name='Fotografía Detallada del POI'
    )
    audio_url = models.URLField(
        blank=True,
        null=True,
        verbose_name='Audioguía URL / Audio MP3'
    )
    icon = models.CharField(
        max_length=50,
        default='arrow_forward',
        verbose_name='Icono Material'
    )

    class Meta:
        verbose_name = 'Hotspot 360°'
        verbose_name_plural = 'Hotspots 360°'
        ordering = ['source_scene', 'id']

    def __str__(self):
        return f"{self.source_scene.title} -> {self.title} ({self.get_type_display()})"


class PointOfInterest(UUIDModel, TimeStampedModel):
    class POICategory(models.TextChoices):
        LAGUNA = 'laguna', 'Laguna Glaciar'
        MIRADOR = 'mirador', 'Mirador Panorámico'
        CAMPAMENTO = 'campamento', 'Zona de Campamento'
        QUEBRADA = 'quebrada', 'Quebrada / Valle'
        SITIO_SAGRADO = 'sitio_sagrado', 'Sitio Sagrado / Apacheta'
        FLORA_RODAL = 'flora_rodal', 'Rodal de Puya Raimondi / Bosque'

    route = models.ForeignKey(
        Route,
        on_delete=models.SET_NULL,
        blank=True,
        null=True,
        related_name='points_of_interest',
        verbose_name='Ruta Asociada'
    )
    name = models.CharField(
        max_length=200,
        verbose_name='Nombre del Punto de Interés'
    )
    category = models.CharField(
        max_length=30,
        choices=POICategory.choices,
        default=POICategory.MIRADOR,
        verbose_name='Categoría'
    )
    altitude_masl = models.PositiveIntegerField(
        verbose_name='Altitud (m s.n.m.)'
    )
    latitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        verbose_name='Latitud GPS'
    )
    longitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        verbose_name='Longitud GPS'
    )
    description = models.TextField(
        blank=True,
        verbose_name='Descripción'
    )
    image = models.ImageField(
        upload_to='poi/images/',
        blank=True,
        null=True,
        verbose_name='Fotografía'
    )
    order = models.PositiveIntegerField(
        default=0,
        verbose_name='Orden'
    )
    is_active = models.BooleanField(
        default=True,
        verbose_name='Activo'
    )

    class Meta:
        verbose_name = 'Punto de Interés (POI)'
        verbose_name_plural = 'Puntos de Interés (POIs)'
        ordering = ['order', 'name']

    def __str__(self):
        return f"{self.name} ({self.altitude_masl}m) - {self.get_category_display()}"


class SafetyRecommendation(models.Model):
    class Category(models.TextChoices):
        EQUIPAMIENTO = 'equipamiento', 'Equipamiento y Ropa'
        SALUD = 'salud', 'Aclimatación y Salud'
        HIDRATACION = 'hidratacion', 'Hidratación y Alimentación'
        SEGURIDAD = 'seguridad', 'Seguridad y Orientación'
        AMBIENTE = 'ambiente', 'Cuidado y Protección Ambiental'
        BATERIA = 'bateria', 'Batería y Conectividad'

    category = models.CharField(
        max_length=20,
        choices=Category.choices,
        verbose_name='Categoría',
        db_index=True
    )
    title = models.CharField(
        max_length=200,
        verbose_name='Título de la Recomendación'
    )
    description = models.TextField(
        verbose_name='Detalle de la Recomendación'
    )
    order = models.PositiveIntegerField(
        default=0,
        verbose_name='Orden de Visualización',
        db_index=True
    )
    is_active = models.BooleanField(
        default=True,
        verbose_name='Activo'
    )

    class Meta:
        verbose_name = 'Recomendación de Seguridad'
        verbose_name_plural = 'Recomendaciones de Seguridad'
        ordering = ['category', 'order']

    def __str__(self):
        return f"[{self.get_category_display()}] {self.title}"


class BiodiversitySpecies(UUIDModel, TimeStampedModel):
    class Category(models.TextChoices):
        FLORA = 'flora', 'Flora Nativa'
        FAUNA = 'fauna', 'Fauna Silvestre'
        AVES = 'aves', 'Aves de Altura'
        ENDEMICAS = 'endemicas', 'Especies Endémicas'

    class ConservationStatus(models.TextChoices):
        CRITICO = 'CR', 'En Peligro Crítico (CR)'
        PELIGRO = 'EN', 'En Peligro (EN)'
        VULNERABLE = 'VU', 'Vulnerable (VU)'
        CASI_AMENAZADO = 'NT', 'Casi Amenazado (NT)'
        PREOCUPACION_MENOR = 'LC', 'Preocupación Menor (LC)'

    name = models.CharField(
        max_length=150,
        verbose_name='Nombre Común',
        db_index=True
    )
    quechua_name = models.CharField(
        max_length=150,
        blank=True,
        verbose_name='Nombre en Quechua / Originario'
    )
    scientific_name = models.CharField(
        max_length=150,
        verbose_name='Nombre Científico'
    )
    category = models.CharField(
        max_length=20,
        choices=Category.choices,
        default=Category.FLORA,
        verbose_name='Categoría',
        db_index=True
    )
    altitude_range = models.CharField(
        max_length=100,
        default='3,500 - 4,800 m s.n.m.',
        verbose_name='Rango Altitudinal'
    )
    conservation_status = models.CharField(
        max_length=10,
        choices=ConservationStatus.choices,
        default=ConservationStatus.PREOCUPACION_MENOR,
        verbose_name='Estado de Conservación (UICN / SERFOR)',
        db_index=True
    )
    is_endemic = models.BooleanField(
        default=False,
        verbose_name='¿Es Especie Endémica?'
    )
    image = models.ImageField(
        upload_to='biodiversity/',
        blank=True,
        null=True,
        verbose_name='Fotografía de la Especie'
    )
    summary = models.TextField(
        verbose_name='Descripción / Resumen de la Especie'
    )
    ecological_role = models.TextField(
        blank=True,
        verbose_name='Rol Ecológico e Hídrico en la Puna'
    )
    conservation_tip = models.TextField(
        blank=True,
        verbose_name='Pauta de Conservación (No Deje Rastro)'
    )
    order = models.PositiveIntegerField(
        default=0,
        verbose_name='Orden de Visualización',
        db_index=True
    )
    is_active = models.BooleanField(
        default=True,
        verbose_name='Activo',
        db_index=True
    )

    class Meta:
        verbose_name = 'Especie de Biodiversidad'
        verbose_name_plural = 'Catálogo de Biodiversidad'
        ordering = ['order', 'name']

    def __str__(self):
        return f"{self.name} ({self.scientific_name}) - [{self.get_conservation_status_display()}]"


class MountainWeatherStation(UUIDModel, TimeStampedModel):
    class RiskLevel(models.TextChoices):
        BAJO = 'bajo', 'Bajo'
        MODERADO = 'moderado', 'Moderado'
        HELADAS = 'heladas', 'Heladas Nocturnas'
        EXTREMO = 'extremo', 'Alto Riesgo / Extremo Albedo'
        VENTISCA = 'ventisca', 'Ventisca y Congelamiento'

    name = models.CharField(
        max_length=150,
        verbose_name='Nombre de la Estación / Sector',
        db_index=True
    )
    altitude_masl = models.PositiveIntegerField(
        verbose_name='Altitud (m s.n.m.)',
        db_index=True
    )
    temp_day_celsius = models.DecimalField(
        max_digits=4,
        decimal_places=1,
        verbose_name='Temperatura Diurna (°C)'
    )
    temp_night_celsius = models.DecimalField(
        max_digits=4,
        decimal_places=1,
        verbose_name='Temperatura Nocturna (°C)'
    )
    condition = models.CharField(
        max_length=100,
        default='Despejado / Frío Intenso',
        verbose_name='Condición Climática'
    )
    weather_icon = models.CharField(
        max_length=50,
        default='wb_sunny',
        verbose_name='Icono Material'
    )
    wind_kmh = models.DecimalField(
        max_digits=5,
        decimal_places=1,
        default=15.0,
        verbose_name='Viento Promedio (km/h)'
    )
    wind_gusts_kmh = models.DecimalField(
        max_digits=5,
        decimal_places=1,
        default=25.0,
        verbose_name='Ráfagas de Viento (km/h)'
    )
    wind_chill_celsius = models.DecimalField(
        max_digits=4,
        decimal_places=1,
        default=5.0,
        verbose_name='Sensación Térmica (°C)'
    )
    uv_index = models.DecimalField(
        max_digits=4,
        decimal_places=1,
        default=10.0,
        verbose_name='Índice UV'
    )
    uv_level = models.CharField(
        max_length=50,
        default='Muy Alto',
        verbose_name='Nivel Radiación UV'
    )
    humidity_percentage = models.PositiveIntegerField(
        default=50,
        verbose_name='Humedad Relativa (%)'
    )
    pressure_hpa = models.PositiveIntegerField(
        default=620,
        verbose_name='Presión Atmosférica (hPa)'
    )
    risk_level = models.CharField(
        max_length=20,
        choices=RiskLevel.choices,
        default=RiskLevel.BAJO,
        verbose_name='Nivel de Riesgo',
        db_index=True
    )
    alert_advisory = models.TextField(
        blank=True,
        verbose_name='Aviso de Seguridad / Recomendación Activa'
    )
    order = models.PositiveIntegerField(
        default=0,
        verbose_name='Orden por Altitud',
        db_index=True
    )
    is_active = models.BooleanField(
        default=True,
        verbose_name='Activo',
        db_index=True
    )

    class Meta:
        verbose_name = 'Estación Meteorológica de Montaña'
        verbose_name_plural = 'Monitoreo Meteorológico de Montaña'
        ordering = ['altitude_masl', 'order']

    def __str__(self):
        return f"{self.name} ({self.altitude_masl}m) - {self.temp_day_celsius}°C / {self.temp_night_celsius}°C"


class WeatherAlert(UUIDModel, TimeStampedModel):
    class Severity(models.TextChoices):
        INFO = 'info', 'Informativo / Clima Favorable'
        PRECAUCION = 'precaucion', 'Precaución / Vientos Fuertes'
        PELIGRO = 'peligro', 'Peligro / Tormenta Glaciar / Nieve'

    title = models.CharField(
        max_length=200,
        verbose_name='Título de la Alerta'
    )
    severity = models.CharField(
        max_length=20,
        choices=Severity.choices,
        default=Severity.PRECAUCION,
        verbose_name='Severidad'
    )
    description = models.TextField(
        verbose_name='Detalle de la Alerta Meteorológica'
    )
    affected_sector = models.CharField(
        max_length=150,
        blank=True,
        verbose_name='Sector o Rango de Altitud Afectado'
    )
    valid_from = models.DateTimeField(
        verbose_name='Válido Desde'
    )
    valid_until = models.DateTimeField(
        verbose_name='Válido Hasta'
    )
    is_active = models.BooleanField(
        default=True,
        verbose_name='Alerta Activa',
        db_index=True
    )

    class Meta:
        verbose_name = 'Alerta Meteorológica'
        verbose_name_plural = 'Alertas Meteorológicas de Montaña'
        ordering = ['-valid_from']

    def __str__(self):
        return f"[{self.get_severity_display()}] {self.title}"


class AudioGuide(UUIDModel, TimeStampedModel):
    class Category(models.TextChoices):
        MITOLOGIA = 'mitologia', 'Mitología Andina y Cosmovisión'
        HIDROLOGIA = 'hidrologia', 'Hidrología Sagrada y Lagunas'
        FLORA_FAUNA = 'flora_fauna', 'Flora y Fauna Milenaria'
        HISTORIA = 'historia', 'Historia Comunal y Tradiciones'

    title_es = models.CharField(
        max_length=200,
        verbose_name='Título en Español'
    )
    title_qu = models.CharField(
        max_length=200,
        blank=True,
        verbose_name='Título en Quechua (Runa Simi)'
    )
    category = models.CharField(
        max_length=30,
        choices=Category.choices,
        default=Category.MITOLOGIA,
        verbose_name='Categoría Temática',
        db_index=True
    )
    location_name = models.CharField(
        max_length=150,
        verbose_name='Ubicación / Sector (ej. Laguna Huascacocha 4,250m)'
    )
    duration_formatted = models.CharField(
        max_length=50,
        default='3:30 min',
        verbose_name='Duración (ej. 3:45 min)'
    )
    audio_file = models.FileField(
        upload_to='audio_guides/',
        blank=True,
        null=True,
        verbose_name='Archivo de Audio (MP3 / AAC / WAV)'
    )
    audio_url = models.URLField(
        blank=True,
        verbose_name='URL Externa de Audio (Opcional)'
    )
    transcript_es = models.TextField(
        verbose_name='Transcripción en Español'
    )
    transcript_qu = models.TextField(
        blank=True,
        verbose_name='Transcripción en Quechua'
    )
    didactic_glossary = models.TextField(
        blank=True,
        verbose_name='Glosario Didáctico Andino'
    )
    order = models.PositiveIntegerField(
        default=0,
        verbose_name='Orden de Reproducción',
        db_index=True
    )
    is_active = models.BooleanField(
        default=True,
        verbose_name='Activo',
        db_index=True
    )

    class Meta:
        verbose_name = 'Audioguía / Relato Cultural'
        verbose_name_plural = 'Audioguías y Relatos Culturales'
        ordering = ['order', 'title_es']

    def __str__(self):
        return f"{self.title_es} ({self.location_name}) - [{self.duration_formatted}]"


class CommunityService(UUIDModel, TimeStampedModel):
    class ServiceCategory(models.TextChoices):
        GUIA = 'guia', 'Guía Oficial de Alta Montaña'
        ARRIERO = 'arriero', 'Transporte y Carga (Red de Arrieros)'
        HOSPEDAJE = 'hospedaje', 'Hospedaje / Albergue Comunitario'
        CAMPAMENTO = 'campamento', 'Zona de Campamento Eco-Lodge'
        GASTRONOMIA = 'gastronomia', 'Gastronomía Típica Andina'
        ARTESANIA = 'artesania', 'Artesanía y Textiles Locales'

    name = models.CharField(
        max_length=200,
        verbose_name='Nombre del Emprendimiento / Prestador de Servicio',
        db_index=True
    )
    category = models.CharField(
        max_length=30,
        choices=ServiceCategory.choices,
        default=ServiceCategory.GUIA,
        verbose_name='Categoría de Servicio',
        db_index=True
    )
    contact_phone = models.CharField(
        max_length=50,
        blank=True,
        verbose_name='Teléfono de Llamadas'
    )
    whatsapp_number = models.CharField(
        max_length=50,
        blank=True,
        verbose_name='Número de WhatsApp (+51...)'
    )
    location_address = models.CharField(
        max_length=250,
        blank=True,
        verbose_name='Ubicación / Dirección en Huachón'
    )
    price_range = models.CharField(
        max_length=100,
        blank=True,
        verbose_name='Tarifas / Precios Referenciales'
    )
    badge_text = models.CharField(
        max_length=100,
        blank=True,
        verbose_name='Distintivo / Certificación (ej. DIRCETUR Acreditado)'
    )
    experience_years = models.CharField(
        max_length=100,
        blank=True,
        verbose_name='Experiencia / Origen'
    )
    services_description = models.TextField(
        verbose_name='Descripción de Servicios Ofrecidos'
    )
    image = models.ImageField(
        upload_to='community/services/',
        blank=True,
        null=True,
        verbose_name='Fotografía / Logotipo'
    )
    order = models.PositiveIntegerField(
        default=0,
        verbose_name='Orden de Visualización',
        db_index=True
    )
    is_active = models.BooleanField(
        default=True,
        verbose_name='Activo',
        db_index=True
    )

    class Meta:
        verbose_name = 'Servicio Comunitario'
        verbose_name_plural = 'Directorio de Servicios y Emprendimientos'
        ordering = ['category', 'order', 'name']

    def __str__(self):
        return f"[{self.get_category_display()}] {self.name}"


class EmergencyContact(UUIDModel, TimeStampedModel):
    title = models.CharField(
        max_length=200,
        verbose_name='Nombre de la Institución / Brigada',
        db_index=True
    )
    short_phone = models.CharField(
        max_length=30,
        verbose_name='Número Corto / Central (ej. 105)'
    )
    full_number = models.CharField(
        max_length=50,
        blank=True,
        verbose_name='Celular Directo / WhatsApp (+51...)'
    )
    description = models.TextField(
        verbose_name='Especialidad y Protocolo de Atención'
    )
    icon = models.CharField(
        max_length=50,
        default='local_police_rounded',
        verbose_name='Icono Material'
    )
    priority_order = models.PositiveIntegerField(
        default=1,
        verbose_name='Orden de Prioridad',
        db_index=True
    )
    is_active = models.BooleanField(
        default=True,
        verbose_name='Activo',
        db_index=True
    )

    class Meta:
        verbose_name = 'Contacto de Emergencia SOS'
        verbose_name_plural = 'Contactos de Emergencia SOS y Rescate'
        ordering = ['priority_order', 'title']

    def __str__(self):
        return f"{self.title} - Tel: {self.short_phone}"


class CommunityPost(UUIDModel, TimeStampedModel):
    class PostCategory(models.TextChoices):
        FOTOGRAFIA = 'fotografia', 'Fotografía de Alta Montaña'
        AVISTAMIENTOS = 'avistamientos', 'Avistamientos de Flora y Fauna'
        CONSEJOS = 'consejos', 'Consejos de Ruta y Seguridad'
        ACCION_ECOLOGICA = 'accion_ecologica', 'Acción Ecológica y Limpieza'

    author_name = models.CharField(
        max_length=150,
        verbose_name='Nombre del Autor',
        db_index=True
    )
    author_role = models.CharField(
        max_length=100,
        default='Centinela Ambiental',
        verbose_name='Rol / Nivel de Centinela'
    )
    category = models.CharField(
        max_length=30,
        choices=PostCategory.choices,
        default=PostCategory.FOTOGRAFIA,
        verbose_name='Categoría',
        db_index=True
    )
    location_name = models.CharField(
        max_length=150,
        verbose_name='Ubicación (ej. Laguna Huascacocha)'
    )
    content = models.TextField(
        verbose_name='Contenido / Relato'
    )
    image = models.ImageField(
        upload_to='community/posts/',
        blank=True,
        null=True,
        verbose_name='Fotografía Adjunta'
    )
    munay_count = models.PositiveIntegerField(
        default=0,
        verbose_name='Aprecios / Munay'
    )
    lnt_verified = models.BooleanField(
        default=True,
        verbose_name='Verificado No Deje Rastro (LNT)'
    )
    is_approved = models.BooleanField(
        default=True,
        verbose_name='Publicación Aprobada por Moderación',
        db_index=True
    )
    is_active = models.BooleanField(
        default=True,
        verbose_name='Activo',
        db_index=True
    )

    class Meta:
        verbose_name = 'Publicación del Muro Comunitario'
        verbose_name_plural = 'Muro Comunitario y Centinelas'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.author_name} - [{self.get_category_display()}] ({self.location_name})"


class GuardianBadge(UUIDModel, TimeStampedModel):
    """
    Logro o Medalla ecológica obtenida por el turista o centinela ambiental.
    """
    class BadgeTier(models.TextChoices):
        BRONCE = 'bronce', 'Bronce'
        PLATA = 'plata', 'Plata'
        ORO = 'oro', 'Oro'
        DIAMANTE = 'diamante', 'Diamante Glacial'

    slug = models.SlugField(max_length=100, unique=True, verbose_name='Slug')
    title = models.CharField(max_length=150, verbose_name='Título de la Medalla')
    quechua_title = models.CharField(max_length=150, blank=True, verbose_name='Título en Quechua')
    description = models.TextField(verbose_name='Descripción / Criterio para obtenerla')
    tier = models.CharField(max_length=20, choices=BadgeTier.choices, default=BadgeTier.BRONCE, verbose_name='Nivel')
    icon = models.CharField(max_length=50, default='military_tech', verbose_name='Ícono / Emoji')
    xp_points = models.PositiveIntegerField(default=50, verbose_name='Puntos de Guardián (XP)')
    order = models.PositiveIntegerField(default=1, verbose_name='Orden en Repisa')
    is_active = models.BooleanField(default=True, verbose_name='Activo', db_index=True)

    class Meta:
        verbose_name = 'Medalla Guardián Glacial'
        verbose_name_plural = 'Gamificación: Medallas y Logros'
        ordering = ['order', 'tier']

    def __str__(self):
        return f"{self.title} ({self.get_tier_display()})"


class TrailPassportStamp(UUIDModel, TimeStampedModel):
    """
    Sello digital del Pasaporte de Montaña Huaguruncho.
    """
    route = models.ForeignKey(
        Route,
        on_delete=models.CASCADE,
        related_name='passport_stamps',
        verbose_name='Ruta Asociada'
    )
    name = models.CharField(max_length=150, verbose_name='Nombre del Sello')
    quechua_name = models.CharField(max_length=150, blank=True, verbose_name='Nombre en Quechua')
    altitude_masl = models.PositiveIntegerField(verbose_name='Altitud del Hito (m s.n.m.)')
    latitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        blank=True,
        null=True,
        verbose_name='Latitud GPS del Hito'
    )
    longitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        blank=True,
        null=True,
        verbose_name='Longitud GPS del Hito'
    )
    landmark_icon = models.CharField(max_length=50, default='landscape', verbose_name='Ícono del Hito')
    secret_code = models.CharField(max_length=50, blank=True, verbose_name='Código de Validación / QR')
    order = models.PositiveIntegerField(default=1, verbose_name='Orden en Pasaporte')
    is_active = models.BooleanField(default=True, verbose_name='Activo', db_index=True)

    class Meta:
        verbose_name = 'Sello del Pasaporte de Montaña'
        verbose_name_plural = 'Gamificación: Sellos de Pasaporte'
        ordering = ['order']

    def __str__(self):
        return f"{self.name} - {self.altitude_masl}m ({self.route.name})"


class MunicipalNotice(UUIDModel, TimeStampedModel):
    class Category(models.TextChoices):
        VIAL = 'vial', 'Alerta Vial / Accesos'
        TURISMO = 'turismo', 'Tours & Promoción Turística'
        CONSERVACION = 'conservacion', 'Conservación y Medio Ambiente'
        CLIMA = 'clima', 'Clima y Seguridad de Montaña'
        COMUNAL = 'comunal', 'Actividad Comunal'

    class Priority(models.TextChoices):
        ALTA = 'alta', 'Prioridad Alta / Urgente'
        PRECAUCION = 'precaucion', 'Precaución'
        INFORMATIVO = 'informativo', 'Informativo'
        COMUNITARIO = 'comunitario', 'Comunitario'

    title = models.CharField(max_length=200, verbose_name='Título del Aviso', db_index=True)
    subtitle = models.CharField(max_length=250, verbose_name='Subtítulo / Resumen Corto')
    category = models.CharField(max_length=30, choices=Category.choices, default=Category.COMUNAL, verbose_name='Categoría')
    priority = models.CharField(max_length=30, choices=Priority.choices, default=Priority.INFORMATIVO, verbose_name='Nivel de Prioridad')
    department = models.CharField(max_length=200, default='Municipalidad Distrital de Huachón', verbose_name='Área / Gerencia Emisora')
    icon = models.CharField(max_length=60, default='info_outline', verbose_name='Ícono Material')
    image = models.ImageField(upload_to='municipal/notices/', blank=True, null=True, verbose_name='Fotografía / Comunicado')
    full_text = models.TextField(verbose_name='Texto Completo del Comunicado')
    recommendations = models.TextField(blank=True, verbose_name='Recomendaciones Oficiales')
    published_at = models.DateTimeField(default=timezone.now, verbose_name='Fecha de Publicación')
    valid_until = models.DateTimeField(blank=True, null=True, verbose_name='Válido Hasta')
    is_active = models.BooleanField(default=True, verbose_name='Publicación Activa', db_index=True)

    class Meta:
        verbose_name = 'Aviso Oficial Municipal'
        verbose_name_plural = 'Avisos Oficiales de la Municipalidad'
        ordering = ['-published_at']

    def __str__(self):
        return f"[{self.get_category_display()}] {self.title}"


class TrekkingExpedition(UUIDModel, TimeStampedModel):
    class Status(models.TextChoices):
        PLANIFICADA = 'planificada', 'Planificada'
        EN_CURSO = 'en_curso', 'En Curso / En la Montaña'
        RETORNADA = 'retornada', 'Retornada con Éxito (Check-out)'
        RETRASADA = 'retrasada', 'Retrasada / Posible Emergencia'
        ALERTA_SOS = 'alerta_sos', 'Alerta SOS Activada'

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        blank=True,
        null=True,
        related_name='expeditions',
        verbose_name='Usuario Registrado'
    )
    tourist_name = models.CharField(max_length=150, verbose_name='Líder de Expedición')
    tourist_phone = models.CharField(max_length=50, verbose_name='Teléfono / WhatsApp')
    emergency_contact_name = models.CharField(max_length=150, verbose_name='Contacto de Emergencia Familiar')
    emergency_contact_phone = models.CharField(max_length=50, verbose_name='Teléfono de Emergencia Familiar')
    route = models.ForeignKey(
        Route,
        on_delete=models.SET_NULL,
        blank=True,
        null=True,
        related_name='expeditions',
        verbose_name='Ruta a Recorrer'
    )
    group_size = models.PositiveIntegerField(default=1, verbose_name='Número de Excursionistas')
    guide_name = models.CharField(max_length=150, blank=True, verbose_name='Guía o Arriero Acompañante')
    departure_datetime = models.DateTimeField(default=timezone.now, verbose_name='Fecha y Hora de Salida')
    expected_return_datetime = models.DateTimeField(verbose_name='Fecha y Hora Estimada de Retorno')
    actual_return_datetime = models.DateTimeField(blank=True, null=True, verbose_name='Fecha y Hora Real de Check-out')
    status = models.CharField(max_length=30, choices=Status.choices, default=Status.EN_CURSO, verbose_name='Estado de la Expedición', db_index=True)
    health_notes = models.TextField(blank=True, verbose_name='Declaración de Salud / Alergias / Medicamentos')
    gear_checklist_verified = models.BooleanField(default=True, verbose_name='Checklist de Seguridad Verificado')
    admin_notes = models.TextField(blank=True, verbose_name='Notas de Guardaparques / COEL')

    class Meta:
        verbose_name = 'Bitácora de Expedición'
        verbose_name_plural = 'Bitácora y Registro de Expediciones'
        ordering = ['-departure_datetime']

    def __str__(self):
        return f"{self.tourist_name} ({self.group_size} pers.) - {self.get_status_display()}"


class CommunityServiceReview(UUIDModel, TimeStampedModel):
    service = models.ForeignKey(
        CommunityService,
        on_delete=models.CASCADE,
        related_name='reviews',
        verbose_name='Servicio / Prestador'
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        blank=True,
        null=True,
        related_name='service_reviews',
        verbose_name='Usuario'
    )
    author_name = models.CharField(max_length=150, verbose_name='Nombre del Reseñante')
    rating = models.PositiveSmallIntegerField(default=5, verbose_name='Puntuación (1 a 5 Estrellas)')
    comment = models.TextField(verbose_name='Comentario / Testimonio')
    is_approved = models.BooleanField(default=True, verbose_name='Aprobado por Moderación', db_index=True)

    class Meta:
        verbose_name = 'Reseña de Servicio Comunitario'
        verbose_name_plural = 'Reseñas de Servicios Comunitarios'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.author_name} - {self.rating}★ a {self.service.name}"


class CheckpointVisitorLog(UUIDModel, TimeStampedModel):
    """
    Registro offline-first del Puesto de Control de Guardaparques / Guardabosques en el Nevado Huaguruncho.
    Controla el ascenso de visitantes y el inventario de retorno de residuos sólidos (Huella Cero).
    """
    class WasteStatus(models.TextChoices):
        PENDING = 'pending_checkout', 'En Montaña (Pendiente de Retorno)'
        COMPLIANT = 'compliant', 'Conforme (Retornó 100% de Residuos)'
        EXTRA_COLLECTED = 'extra_collected', 'Meritorio (Recogió Residuos Extras en Sendero)'
        INFRACTION = 'infraction_missing', 'Infracción (Faltan Residuos / Abandono)'

    class Status(models.TextChoices):
        EN_MONTANA = 'en_montana', 'En Montaña / Ascendiendo'
        RETORNADO = 'completado', 'Descenso Completado / Verificado'
        ALERTA_RETRASO = 'alerta_retraso', 'Alerta de Retraso'

    local_uuid = models.CharField(
        max_length=64,
        unique=True,
        db_index=True,
        verbose_name='UUID Local (Drift SQLite)'
    )
    checkpoint_name = models.CharField(
        max_length=150,
        default='Garita de Control Huaguruncho - Abra Huachón',
        verbose_name='Puesto de Control'
    )
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        blank=True,
        null=True,
        related_name='checkpoint_entries',
        verbose_name='Guardaparque que Registró'
    )
    visitor_name = models.CharField(
        max_length=150,
        verbose_name='Nombre del Visitante / Líder de Grupo',
        db_index=True
    )
    document_type = models.CharField(
        max_length=30,
        default='DNI',
        verbose_name='Tipo de Documento'
    )
    document_number = models.CharField(
        max_length=50,
        verbose_name='N° Documento',
        db_index=True
    )
    phone = models.CharField(
        max_length=50,
        blank=True,
        verbose_name='Teléfono / WhatsApp'
    )
    group_size = models.PositiveIntegerField(
        default=1,
        verbose_name='Número de Personas'
    )
    route_name = models.CharField(
        max_length=200,
        default='Nevado Huaguruncho - Ruta Glaciar',
        verbose_name='Ruta o Destino'
    )
    guide_name = models.CharField(
        max_length=150,
        blank=True,
        verbose_name='Guía o Arriero Acompañante'
    )
    entry_datetime = models.DateTimeField(
        default=timezone.now,
        verbose_name='Fecha y Hora de Entrada'
    )
    entry_ranger_name = models.CharField(
        max_length=150,
        blank=True,
        verbose_name='Guardabosques de Entrada'
    )

    # --- Residuos Declarados al Subir (Input) ---
    plastic_bottles_in = models.PositiveIntegerField(default=0, verbose_name='Botellas Plásticas (Subida)')
    cans_in = models.PositiveIntegerField(default=0, verbose_name='Latas / Conservas (Subida)')
    plastic_wrappers_in = models.PositiveIntegerField(default=0, verbose_name='Envoltorios Snacks (Subida)')
    plastic_bags_in = models.PositiveIntegerField(default=0, verbose_name='Bolsas Plásticas (Subida)')
    batteries_in = models.PositiveIntegerField(default=0, verbose_name='Pilas / Baterías (Subida)')
    gas_canisters_in = models.PositiveIntegerField(default=0, verbose_name='Envases de Gas / Camping (Subida)')
    other_waste_details_in = models.TextField(blank=True, verbose_name='Otros Residuos Declarados')
    total_items_in = models.PositiveIntegerField(default=0, verbose_name='Total Residuos que Suben')

    # --- Inspección y Retorno de Residuos al Bajar (Output / Check-out) ---
    exit_datetime = models.DateTimeField(
        blank=True,
        null=True,
        verbose_name='Fecha y Hora de Salida'
    )
    exit_ranger_name = models.CharField(
        max_length=150,
        blank=True,
        verbose_name='Guardabosques de Salida'
    )
    plastic_bottles_out = models.PositiveIntegerField(default=0, verbose_name='Botellas Plásticas Retornadas')
    cans_out = models.PositiveIntegerField(default=0, verbose_name='Latas / Conservas Retornadas')
    plastic_wrappers_out = models.PositiveIntegerField(default=0, verbose_name='Envoltorios Snacks Retornados')
    plastic_bags_out = models.PositiveIntegerField(default=0, verbose_name='Bolsas Plásticas Retornadas')
    batteries_out = models.PositiveIntegerField(default=0, verbose_name='Pilas / Baterías Retornadas')
    gas_canisters_out = models.PositiveIntegerField(default=0, verbose_name='Envases Gas Retornados')
    total_items_out = models.PositiveIntegerField(default=0, verbose_name='Total Residuos Retornados')

    waste_compliance_status = models.CharField(
        max_length=30,
        choices=WasteStatus.choices,
        default=WasteStatus.PENDING,
        verbose_name='Cumplimiento de Residuos (Huella Cero)',
        db_index=True
    )
    status = models.CharField(
        max_length=30,
        choices=Status.choices,
        default=Status.EN_MONTANA,
        verbose_name='Estado de la Visita',
        db_index=True
    )
    notes = models.TextField(blank=True, verbose_name='Observaciones / Actas de Infracción')

    class Meta:
        verbose_name = 'Control de Visitante y Residuos (Guardaparque)'
        verbose_name_plural = 'Puesto de Control: Visitantes y Retorno de Residuos'
        ordering = ['-entry_datetime']

    def __str__(self):
        return f"{self.visitor_name} ({self.document_number}) - {self.get_waste_compliance_status_display()}"

    def calculate_total_in(self):
        return (
            self.plastic_bottles_in +
            self.cans_in +
            self.plastic_wrappers_in +
            self.plastic_bags_in +
            self.batteries_in +
            self.gas_canisters_in
        )

    def calculate_total_out(self):
        return (
            self.plastic_bottles_out +
            self.cans_out +
            self.plastic_wrappers_out +
            self.plastic_bags_out +
            self.batteries_out +
            self.gas_canisters_out
        )

    def save(self, *args, **kwargs):
        if not self.total_items_in:
            self.total_items_in = self.calculate_total_in()
        if self.exit_datetime and not self.total_items_out:
            self.total_items_out = self.calculate_total_out()
        super().save(*args, **kwargs)




