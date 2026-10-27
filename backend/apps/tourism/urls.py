from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    RouteViewSet,
    TourSceneViewSet,
    HotspotViewSet,
    PointOfInterestViewSet,
    SafetyRecommendationListView,
    BiodiversitySpeciesViewSet,
    MountainWeatherStationViewSet,
    WeatherAlertViewSet,
    AudioGuideViewSet,
    CommunityServiceViewSet,
    EmergencyContactViewSet,
    CommunityPostViewSet,
    GuardianBadgeViewSet,
    TrailPassportStampViewSet,
    MunicipalNoticeViewSet,
    TrekkingExpeditionViewSet,
    CommunityServiceReviewViewSet,
    CheckpointVisitorLogViewSet,
    CheckpointSyncBatchView,
    AnalyticsOverviewAPIView,
)

app_name = 'tourism'

router = DefaultRouter()
router.register(r'routes', RouteViewSet, basename='routes')
router.register(r'scenes', TourSceneViewSet, basename='scenes')
router.register(r'hotspots', HotspotViewSet, basename='hotspots')
router.register(r'points-of-interest', PointOfInterestViewSet, basename='points-of-interest')
router.register(r'biodiversity', BiodiversitySpeciesViewSet, basename='biodiversity')
router.register(r'weather-stations', MountainWeatherStationViewSet, basename='weather-stations')
router.register(r'weather-alerts', WeatherAlertViewSet, basename='weather-alerts')
router.register(r'audio-guides', AudioGuideViewSet, basename='audio-guides')
router.register(r'community-services', CommunityServiceViewSet, basename='community-services')
router.register(r'emergency-contacts', EmergencyContactViewSet, basename='emergency-contacts')
router.register(r'community-posts', CommunityPostViewSet, basename='community-posts')
router.register(r'badges', GuardianBadgeViewSet, basename='badges')
router.register(r'passport-stamps', TrailPassportStampViewSet, basename='passport-stamps')
router.register(r'municipal-notices', MunicipalNoticeViewSet, basename='municipal-notices')
router.register(r'expeditions', TrekkingExpeditionViewSet, basename='expeditions')
router.register(r'service-reviews', CommunityServiceReviewViewSet, basename='service-reviews')
router.register(r'checkpoint-entries', CheckpointVisitorLogViewSet, basename='checkpoint-entries')

urlpatterns = [
    path('analytics/overview/', AnalyticsOverviewAPIView.as_view(), name='analytics-overview'),
    path('safety-recommendations/', SafetyRecommendationListView.as_view(), name='safety-recommendations'),
    path('checkpoint-entries/sync-batch/', CheckpointSyncBatchView.as_view(), name='checkpoint-sync-batch'),
    path('', include(router.urls)),
]
