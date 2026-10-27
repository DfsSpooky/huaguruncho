from django.db import models


class LandingHeroConfig(models.Model):
    """
    Configuración central y personalizable del Hero y Descargas de la Landing Page.
    """
    title_line_1 = models.CharField(
        max_length=120,
        default="Explora el Apu Sagrado.",
        verbose_name="Título Principal (Línea 1)"
    )
    title_line_2 = models.CharField(
        max_length=120,
        default="En la Palma de tu Mano.",
        verbose_name="Título Destacado (Línea 2)"
    )
    subtitle = models.TextField(
        default="Descubre los glaciares milenarios y lagunas turquesas del Nevado Huaguruncho (5,742 m) con mapas que funcionan sin internet, visitas virtuales en 360° y asistencia médica para la altura.",
        verbose_name="Subtítulo / Descripción"
    )
    season_badge = models.CharField(
        max_length=150,
        default="Descubre la Joya Glaciar de Pasco • Temporada 2026",
        verbose_name="Insignia de Temporada"
    )
    hero_background_image = models.ImageField(
        upload_to="landing/hero/",
        null=True,
        blank=True,
        verbose_name="Imagen de Fondo del Nevado",
        help_text="Fotografía de alta resolución del Nevado Huaguruncho. Si se deja vacía, se usará la imagen por defecto."
    )
    enable_snow_effect = models.BooleanField(
        default=True,
        verbose_name="Activar Efecto de Partículas de Nieve",
        help_text="Muestra suaves copos de nieve animados en el fondo del Hero."
    )
    
    # Enlaces de Tiendas y Archivos
    app_store_url = models.URLField(
        max_length=500,
        default="https://apple.com/app-store",
        blank=True,
        verbose_name="Enlace de Apple App Store"
    )
    google_play_url = models.URLField(
        max_length=500,
        default="https://play.google.com/store/apps",
        blank=True,
        verbose_name="Enlace de Google Play Store"
    )
    ios_testflight_url = models.URLField(
        max_length=500,
        blank=True,
        verbose_name="Enlace de iOS TestFlight"
    )
    apk_file = models.FileField(
        upload_to="landing/apk/",
        null=True,
        blank=True,
        verbose_name="Archivo APK de Instalación Directa",
        help_text="Sube el archivo .apk firmado para descarga directa de usuarios Android."
    )
    apk_version = models.CharField(
        max_length=30,
        default="v1.0.4",
        verbose_name="Versión de la App"
    )
    apk_size_mb = models.CharField(
        max_length=30,
        default="48 MB",
        verbose_name="Tamaño del Paquete (e.g. 48 MB)"
    )
    qr_code_image = models.ImageField(
        upload_to="landing/qr/",
        null=True,
        blank=True,
        verbose_name="Imagen de Código QR Personalizado",
        help_text="Sube tu código QR de descarga o déjalo vacío para generarlo automáticamente."
    )
    
    # Estado de la configuración
    is_active = models.BooleanField(
        default=True,
        verbose_name="Configuración Activa"
    )
    updated_at = models.DateTimeField(auto_now=True, verbose_name="Última Modificación")

    class Meta:
        verbose_name = "Configuración Principal (Hero & Tiendas)"
        verbose_name_plural = "Configuraciones Principales"

    def __str__(self):
        return f"Configuración Hero ({self.title_line_1})"


class LandingMetric(models.Model):
    """
    Contadores y métricas destacadas de gran escala (e.g. 5,742 m, 100% Offline).
    """
    value = models.CharField(max_length=50, verbose_name="Valor de la Métrica (e.g. 5,742 m)")
    label = models.CharField(max_length=120, verbose_name="Etiqueta Descriptiva")
    color_class = models.CharField(
        max_length=60,
        default="text-white",
        verbose_name="Clase de Color",
        help_text="Opciones: text-white, text-apple-blue, text-apple-gold, text-emerald-400"
    )
    order = models.PositiveIntegerField(default=0, verbose_name="Orden de Aparición")
    is_active = models.BooleanField(default=True, verbose_name="¿Activo?")

    class Meta:
        ordering = ['order']
        verbose_name = "Métrica Destacada"
        verbose_name_plural = "Métricas Destacadas"

    def __str__(self):
        return f"{self.value} - {self.label}"


class LandingFeature(models.Model):
    """
    Tarjetas de beneficios del Bento Grid (Mapas Offline, Soroche, Pasaporte, etc.).
    """
    icon_name = models.CharField(
        max_length=60,
        default="map-pin",
        verbose_name="Nombre de Icono Lucide",
        help_text="Ejemplos: map-pin, heart-pulse, award, compass, shield, database, camera"
    )
    icon_color = models.CharField(
        max_length=40,
        default="text-apple-blue",
        verbose_name="Color de Icono",
        help_text="Opciones: text-apple-blue, text-apple-gold, text-emerald-400, text-rose-400"
    )
    title = models.CharField(max_length=120, verbose_name="Título del Beneficio")
    description = models.TextField(verbose_name="Descripción para el Usuario")
    badge_text = models.CharField(
        max_length=120,
        blank=True,
        verbose_name="Texto de la Insignia Inferior"
    )
    badge_color = models.CharField(
        max_length=60,
        default="emerald",
        verbose_name="Color de la Insignia",
        help_text="emerald, gold, blue, rose"
    )
    order = models.PositiveIntegerField(default=0, verbose_name="Orden de Aparición")
    is_active = models.BooleanField(default=True, verbose_name="¿Activo?")

    class Meta:
        ordering = ['order']
        verbose_name = "Tarjeta de Beneficio (Bento)"
        verbose_name_plural = "Tarjetas de Beneficios (Bento Grid)"

    def __str__(self):
        return self.title


class LandingWaypoint(models.Model):
    """
    Hitos del perfil de elevación interactivo (Huachón, Queñuales, Huascacocha, Mirador Glaciar, Cumbre).
    """
    name = models.CharField(max_length=100, verbose_name="Nombre del Hito")
    altitude_m = models.PositiveIntegerField(verbose_name="Altitud (msnm)")
    distance_km = models.DecimalField(max_digits=5, decimal_places=1, verbose_name="Distancia desde Huachón (km)")
    description = models.CharField(max_length=200, verbose_name="Descripción Breve")
    badge_color = models.CharField(
        max_length=40,
        default="text-apple-blue",
        verbose_name="Color del Texto de Altitud",
        help_text="text-apple-blue, text-apple-gold, text-rose-400, text-emerald-400"
    )
    order = models.PositiveIntegerField(default=0, verbose_name="Orden de la Ruta")

    class Meta:
        ordering = ['order']
        verbose_name = "Hito de Altimetría"
        verbose_name_plural = "Perfil de Altimetría (Hitos)"

    def __str__(self):
        return f"{self.name} ({self.altitude_m} m)"


class LandingExperience(models.Model):
    """
    Gastronomía, hospedajes comunitarios y cultura viva de Huachón.
    """
    icon_or_emoji = models.CharField(max_length=20, default="🍲", verbose_name="Emoji o Icono")
    title = models.CharField(max_length=120, verbose_name="Título de la Experiencia")
    description = models.TextField(verbose_name="Descripción")
    highlight_tag = models.CharField(max_length=120, verbose_name="Etiqueta Destacada (e.g. ⭐ Apoyo local)")
    tag_color = models.CharField(max_length=40, default="text-apple-gold", verbose_name="Color de la Etiqueta")
    order = models.PositiveIntegerField(default=0, verbose_name="Orden de Aparición")
    is_active = models.BooleanField(default=True, verbose_name="¿Activo?")

    class Meta:
        ordering = ['order']
        verbose_name = "Experiencia / Gastronomía de Huachón"
        verbose_name_plural = "Cultura Viva & Gastronomía"

    def __str__(self):
        return self.title


class LandingFAQ(models.Model):
    """
    Preguntas frecuentes para turistas y montañistas.
    """
    question = models.CharField(max_length=250, verbose_name="Pregunta Frecuente")
    answer = models.TextField(verbose_name="Respuesta Detallada")
    order = models.PositiveIntegerField(default=0, verbose_name="Orden de Aparición")
    is_active = models.BooleanField(default=True, verbose_name="¿Activo?")

    class Meta:
        ordering = ['order']
        verbose_name = "Pregunta Frecuente (FAQ)"
        verbose_name_plural = "Preguntas Frecuentes (FAQ)"

    def __str__(self):
        return self.question


class LandingAudioGuide(models.Model):
    """
    Audioguía andina y relatos orales del Apu Huaguruncho.
    """
    title = models.CharField(max_length=150, default="Leyenda del Apu Huaguruncho", verbose_name="Título del Relato")
    narrator = models.CharField(max_length=150, default="Don Eustaquio • Anciano de Huachón", verbose_name="Narrador / Autor")
    languages = models.CharField(max_length=100, default="Quechua Central & Español", verbose_name="Idiomas")
    duration_text = models.CharField(max_length=20, default="03:45", verbose_name="Duración (e.g. 03:45)")
    audio_file = models.FileField(
        upload_to="landing/audio/",
        null=True,
        blank=True,
        verbose_name="Archivo de Audio (MP3 / WAV)",
        help_text="Opcional: sube un archivo de audio real para reproducir en la landing."
    )
    transcript = models.TextField(blank=True, verbose_name="Transcripción del Relato")
    is_active = models.BooleanField(default=True, verbose_name="¿Activo?")

    class Meta:
        verbose_name = "Audioguía Andina"
        verbose_name_plural = "Audioguías Andinas"

    def __str__(self):
        return self.title
