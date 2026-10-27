from apps.tourism.models import (
    Route,
    TourScene,
    BiodiversitySpecies,
    MountainWeatherStation,
    CommunityService,
    AudioGuide,
    EmergencyContact,
)
from apps.environmental_reports.models import EnvironmentalReport


def admin_dashboard_stats(request):
    """
    Inyecta estadísticas en tiempo real del sistema HUAGURUNCHO 360
    para el panel de administración de Django.
    """
    if not request.path.startswith('/admin/'):
        return {}

    try:
        total_reports = EnvironmentalReport.objects.count()
        pending_reports = EnvironmentalReport.objects.filter(
            status__in=[EnvironmentalReport.Status.PENDIENTE, EnvironmentalReport.Status.RECIBIDO]
        ).count()
        in_review_reports = EnvironmentalReport.objects.filter(
            status=EnvironmentalReport.Status.EN_REVISION
        ).count()
        resolved_reports = EnvironmentalReport.objects.filter(
            status=EnvironmentalReport.Status.ATENDIDO
        ).count()

        total_routes = Route.objects.filter(is_active=True).count()
        total_scenes = TourScene.objects.filter(is_active=True).count()
        total_species = BiodiversitySpecies.objects.filter(is_active=True).count()
        total_stations = MountainWeatherStation.objects.filter(is_active=True).count()
        total_services = CommunityService.objects.filter(is_active=True).count()
        total_audios = AudioGuide.objects.filter(is_active=True).count()
        total_emergency = EmergencyContact.objects.filter(is_active=True).count()

        return {
            'dashboard_stats': {
                'total_reports': total_reports,
                'pending_reports': pending_reports,
                'in_review_reports': in_review_reports,
                'resolved_reports': resolved_reports,
                'total_routes': total_routes,
                'total_scenes': total_scenes,
                'total_species': total_species,
                'total_stations': total_stations,
                'total_services': total_services,
                'total_audios': total_audios,
                'total_emergency': total_emergency,
            }
        }
    except Exception:
        return {}
