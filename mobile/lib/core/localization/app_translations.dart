import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage {
  es('Español', 'PE', '🇵🇪'),
  qu('Runasimi (Quechua)', 'PE', '🏔️'),
  en('English', 'US', '🌐');

  final String displayName;
  final String countryCode;
  final String flagEmoji;
  const AppLanguage(this.displayName, this.countryCode, this.flagEmoji);
}

class AppTranslations {
  static final Map<AppLanguage, Map<String, String>> _localizedValues = {
    AppLanguage.es: {
      'app_title': 'Aquí en Huaguruncho',
      'app_subtitle': 'Ecoturismo Comunitario & Alta Montaña',
      'home_welcome': 'Allillanchu! Bienvenido a Huaguruncho',
      'tab_routes': 'Rutas 360°',
      'tab_biodiversity': 'Biodiversidad',
      'tab_weather': 'Clima Glaciar',
      'tab_community': 'Muro Comunal',
      'tab_passport': 'Pasaporte Glacial',
      'tab_offline': 'Modo Offline',
      'tab_sos': 'Emergencia SOS',
      'btn_explore_360': 'Iniciar Paseo 360°',
      'btn_download_offline': 'Descargar Paquete Offline',
      'btn_report_env': 'Emitir Reporte Ambiental',
      'guardian_level': 'Nivel Guardián Glacial',
      'guardian_xp': 'Puntos de Experiencia (XP)',
      'stamps_title': 'Sellos del Pasaporte de Montaña',
      'badges_title': 'Medallas de Sostenibilidad',
      'weather_temp': 'Temperatura',
      'weather_wind': 'Viento',
      'weather_uv': 'Índice UV',
      'weather_risk': 'Nivel de Riesgo',
      'sos_title': 'Centro de Emergencias y Rescate',
      'sos_strobe': 'Luz Estroboscópica de Niebla',
      'offline_ready': 'Paquete listo para navegación sin señal',
      'lnt_verified': 'Verificado No Deje Rastro',
      'notices_municipal_title': 'Avisos Oficiales de la Municipalidad',
      'expedition_active': 'Expedición en Curso en la Montaña',
      'expedition_checkout': 'Marcar Retorno Seguro (Check-out)',
      'expedition_register': 'Registrar Salida a Montaña',
      'btn_sos_sms': 'Baliza SOS por SMS Satelital (Sin Internet)',
      'btn_sos_whatsapp': 'Compartir Coordenadas vía WhatsApp',
      'passport_gps_validate': 'Validar Sellos con Satélite GPS',
      'service_reviews_title': 'Reseñas Comunitarias',
      'service_add_review': 'Calificar y Dejar Reseña',
      'service_reviews_count': 'opiniones',
      'lang_selector_title': 'Idioma de la Aplicación',
    },
    AppLanguage.qu: {
      'app_title': 'Kaypi Huaguruncho',
      'app_subtitle': 'Ayllu Karu Purikuy & Hatun Urqukuna',
      'home_welcome': 'Allillanchu! Huaguruncho Apu Sumaq Chaski',
      'tab_routes': 'Ñankuna 360°',
      'tab_biodiversity': 'Kawsaykuna',
      'tab_weather': 'Wayra Pachamamam',
      'tab_community': 'Ayllu Pirqa',
      'tab_passport': 'Guardián Pasaporte',
      'tab_offline': 'Mana Llikayuq Modo',
      'tab_sos': 'Sasachakuy Yanapay (SOS)',
      'btn_explore_360': '360° Purikuy Qallariy',
      'btn_download_offline': 'Mana Llikayuq Apachikuy',
      'btn_report_env': 'Pachamama Waqaychay Willay',
      'guardian_level': 'Hatun Guardián Pata',
      'guardian_xp': 'Kallpa Tupuykuna (XP)',
      'stamps_title': 'Urqu Ñan Sellokuna',
      'badges_title': 'Allin Kawsay Medallakuna',
      'weather_temp': 'Chiriy / Ruphay',
      'weather_wind': 'Wayra',
      'weather_uv': 'Inti Kanchay (UV)',
      'weather_risk': 'Manchay Pata',
      'sos_title': 'Utqaylla Yanapakuy Wasi',
      'sos_strobe': 'Phuyu Kanchay Akchi',
      'offline_ready': 'Mana internetwan allichisqa',
      'lnt_verified': 'Pachamama Allin Waqaychasqa (LNT)',
      'notices_municipal_title': 'Huachón Ayllu Kamachiq Willakuykuna',
      'expedition_active': 'Urqupi Purichkaq Expedición',
      'expedition_checkout': 'Allin Kutiyta Willay (Check-out)',
      'expedition_register': 'Urquman Lluqsiy Qillqay',
      'btn_sos_sms': 'SMS Satelital Yanapay Baliza (Mana Llikawan)',
      'btn_sos_whatsapp': 'Tupuy Chaskita WhatsApp-wan Willay',
      'passport_gps_validate': 'GPS Satélite-wan Sellokunata Qillqay',
      'service_reviews_title': 'Ayllu Riqsichiy Willakuykuna',
      'service_add_review': 'Chaninchay & Willakuy Qillqay',
      'service_reviews_count': 'willaykuna',
      'lang_selector_title': 'App Simi Akllay',
    },
    AppLanguage.en: {
      'app_title': 'Here at Huaguruncho',
      'app_subtitle': 'Community Ecotourism & High Mountain',
      'home_welcome': 'Welcome to Mount Huaguruncho Expedition',
      'tab_routes': '360° Trails',
      'tab_biodiversity': 'Biodiversity',
      'tab_weather': 'Glacial Weather',
      'tab_community': 'Community Wall',
      'tab_passport': 'Glacial Passport',
      'tab_offline': 'Offline Mode',
      'tab_sos': 'SOS Emergency',
      'btn_explore_360': 'Start 360° Virtual Tour',
      'btn_download_offline': 'Download Offline Package',
      'btn_report_env': 'Submit Eco Report',
      'guardian_level': 'Glacial Guardian Level',
      'guardian_xp': 'Experience Points (XP)',
      'stamps_title': 'Mountain Passport Stamps',
      'badges_title': 'Sustainability Badges',
      'weather_temp': 'Temperature',
      'weather_wind': 'Wind Speed',
      'weather_uv': 'UV Index',
      'weather_risk': 'Risk Level',
      'sos_title': 'Emergency & Rescue Center',
      'sos_strobe': 'Mountain Fog Optical Strobe',
      'offline_ready': 'Package cached for offline wilderness use',
      'lnt_verified': 'Leave No Trace (LNT) Verified',
      'notices_municipal_title': 'Huachón Municipality Official Notices',
      'expedition_active': 'Ongoing Wilderness Expedition',
      'expedition_checkout': 'Mark Safe Return (Check-out)',
      'expedition_register': 'Register Mountain Expedition',
      'btn_sos_sms': 'Satellite SMS SOS Beacon (Zero Cellular Data)',
      'btn_sos_whatsapp': 'Share GPS Coordinates via WhatsApp',
      'passport_gps_validate': 'Validate Stamps with GPS Satellite',
      'service_reviews_title': 'Community Testimonials & Ratings',
      'service_add_review': 'Rate and Leave Review',
      'service_reviews_count': 'reviews',
      'lang_selector_title': 'Application Language',
    },
  };

  static String tr(AppLanguage lang, String key) {
    return _localizedValues[lang]?[key] ?? _localizedValues[AppLanguage.es]?[key] ?? key;
  }
}

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.es);

  void setLanguage(AppLanguage lang) {
    state = lang;
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});
