from django.urls import path
from .views import (
    LandingPageView,
    HTMXRouteFilterView,
    HTMXSafetyAdvisorView,
    HTMXWeatherTelemetryView,
    HTMXTourSceneView,
    HTMXSubscribeView,
    HTMXGuardianStampView,
)

app_name = 'landing'

urlpatterns = [
    path('', LandingPageView.as_view(), name='index'),
    path('htmx/routes/', HTMXRouteFilterView.as_view(), name='htmx-routes'),
    path('htmx/safety-check/', HTMXSafetyAdvisorView.as_view(), name='htmx-safety-check'),
    path('htmx/weather-telemetry/', HTMXWeatherTelemetryView.as_view(), name='htmx-weather-telemetry'),
    path('htmx/tour-scene/', HTMXTourSceneView.as_view(), name='htmx-tour-scene'),
    path('htmx/subscribe/', HTMXSubscribeView.as_view(), name='htmx-subscribe'),
    path('htmx/guardian-stamp/', HTMXGuardianStampView.as_view(), name='htmx-guardian-stamp'),
]
