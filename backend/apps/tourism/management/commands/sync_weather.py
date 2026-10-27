from django.core.management.base import BaseCommand
from apps.tourism.services.weather_service import sync_weather_stations


class Command(BaseCommand):
    help = 'Sincroniza las estaciones meteorológicas de montaña con datos en tiempo real de Open-Meteo (Yanacancha -5.5°C)'

    def add_arguments(self, parser):
        parser.add_argument(
            '--force',
            action='store_true',
            help='Forzar actualización ignorando la caché de 15 minutos'
        )

    def handle(self, *args, **options):
        force = options.get('force', False)
        self.stdout.write(self.style.NOTICE("Iniciando sincronización meteorológica de alta montaña..."))
        result = sync_weather_stations(force_refresh=force)
        self.stdout.write(
            self.style.SUCCESS(
                f"✔ Sincronización exitosa:\n"
                f"  - Estaciones actualizadas: {result['stations_count']}\n"
                f"  - Temperatura base Yanacancha: {result['base_temperature_yanacancha']}°C\n"
                f"  - Temperatura calibrada Nevado Huaguruncho: {result['nevado_temperature_celsius']}°C\n"
                f"  - Offset aplicado en el nevado: {result['nevado_offset_applied']}°C\n"
                f"  - Fecha/Hora: {result['synced_at']}"
            )
        )
