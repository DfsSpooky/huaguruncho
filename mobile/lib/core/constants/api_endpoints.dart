class ApiEndpoints {
  ApiEndpoints._();

  // Dominio oficial de producción: https://apih.aquienpasco.com/api/v1
  // Para desarrollo local se puede pasar --dart-define=API_URL=http://127.0.0.1:8000/api/v1
  static const String productionBaseUrl = 'https://apih.aquienpasco.com/api/v1';
  static const String localBaseUrl = 'http://127.0.0.1:8000/api/v1';

  static String baseUrl = const String.fromEnvironment(
    'API_URL',
    defaultValue: productionBaseUrl,
  );

  // Configuración dinámica en runtime
  static void setBaseUrl(String newUrl) {
    baseUrl = newUrl;
  }

  // Auth
  static String get register => '$baseUrl/auth/register/';
  static String get login => '$baseUrl/auth/login/';
  static String get refresh => '$baseUrl/auth/refresh/';
  static String get profile => '$baseUrl/auth/profile/';

  // Tourism
  static String get routes => '$baseUrl/routes/';
  static String routeDetail(String uuid) => '$baseUrl/routes/$uuid/';
  static String routeScenes(String uuid) => '$baseUrl/routes/$uuid/scenes/';
  static String routeOfflinePackage(String uuid) => '$baseUrl/routes/$uuid/offline-package/';
  static String sceneDetail(String uuid) => '$baseUrl/scenes/$uuid/';
  static String sceneHotspots(String uuid) => '$baseUrl/scenes/$uuid/hotspots/';
  static String get safetyRecommendations => '$baseUrl/safety-recommendations/';

  // Biodiversity
  static String get biodiversity => '$baseUrl/biodiversity/';
  static String biodiversityDetail(String uuid) => '$baseUrl/biodiversity/$uuid/';

  // Weather
  static String get weatherStations => '$baseUrl/weather-stations/';
  static String get weatherAlerts => '$baseUrl/weather-alerts/';

  // Audio Guides
  static String get audioGuides => '$baseUrl/audio-guides/';
  static String audioGuideDetail(String uuid) => '$baseUrl/audio-guides/$uuid/';

  // Community & Services
  static String get communityServices => '$baseUrl/community-services/';
  static String get emergencyContacts => '$baseUrl/emergency-contacts/';
  static String get communityPosts => '$baseUrl/community-posts/';
  static String get pointsOfInterest => '$baseUrl/points-of-interest/';
  static String get municipalNotices => '$baseUrl/municipal-notices/';
  static String get expeditions => '$baseUrl/expeditions/';
  static String expeditionCheckout(String uuid) => '$baseUrl/expeditions/$uuid/check-out/';
  static String get serviceReviews => '$baseUrl/service-reviews/';
  static String get badges => '$baseUrl/badges/';
  static String get passportStamps => '$baseUrl/passport-stamps/';

  // Reports
  static String get reports => '$baseUrl/environmental-reports/';
  static String get myReports => '$baseUrl/environmental-reports/me/';
  static String get syncBatch => '$baseUrl/environmental-reports/sync-batch/';
  static String reportEvidences(String uuid) => '$baseUrl/environmental-reports/$uuid/evidences/';

  // Ranger Checkpoint & Solid Waste Return
  static String get checkpointEntries => '$baseUrl/checkpoint-entries/';
  static String checkpointCheckout(String uuid) => '$baseUrl/checkpoint-entries/$uuid/check-out/';
  static String get checkpointSyncBatch => '$baseUrl/checkpoint-entries/sync-batch/';
}
