from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    EnvironmentalReportViewSet,
    MyReportsListView,
    SyncBatchView,
    ReportEvidenceCreateView,
    AdminReportViewSet,
)

app_name = 'environmental_reports'

router = DefaultRouter()
router.register(r'environmental-reports', EnvironmentalReportViewSet, basename='reports')
router.register(r'admin/environmental-reports', AdminReportViewSet, basename='admin-reports')

urlpatterns = [
    path('environmental-reports/me/', MyReportsListView.as_view(), name='my-reports'),
    path('environmental-reports/sync-batch/', SyncBatchView.as_view(), name='sync-batch'),
    path('environmental-reports/<uuid:uuid>/evidences/', ReportEvidenceCreateView.as_view(), name='report-evidence-create'),
    path('', include(router.urls)),
]
