from django.urls import path
from .views import RouteOfflinePackageView, RouteOfflinePackageDownloadView

app_name = 'offline_packages'

urlpatterns = [
    path('routes/<uuid:uuid>/offline-package/', RouteOfflinePackageView.as_view(), name='route-offline-package'),
    path('routes/<uuid:uuid>/offline-package/download/', RouteOfflinePackageDownloadView.as_view(), name='route-offline-download'),
]

