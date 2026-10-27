import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/sync/sync_controller.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/domain/user_model.dart';
import '../../routes/presentation/routes_controller.dart';
import '../../routes/domain/route_model.dart';
import '../../weather/presentation/weather_controller.dart';
import '../../weather/domain/weather_model.dart';
import '../domain/municipal_notice_model.dart';
import 'municipal_notices_controller.dart';
import '../../safety/presentation/expedition_controller.dart';
import '../../safety/presentation/register_expedition_dialog.dart';
import '../../../core/widgets/auth_required_gate.dart';
import 'widgets/expedition_dashboard_20.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<Map<String, dynamic>> _municipalNotices = [
    {
      'id': 'vial_01',
      'title': 'Mantenimiento Preventivo Vía Huachón – Pampa Chichuraque',
      'subtitle': 'Paso restringido de 07:00 a 12:00 hrs por perfilado de vía.',
      'category': 'ALERTA VIAL',
      'categoryColor': AppColors.cordilleraOchre,
      'icon': Icons.warning_amber_rounded,
      'date': 'HOY · COEL HUACHÓN',
      'department': 'Gerencia de Infraestructura y Transporte Huachón',
      'image': 'assets/images/huachon_village.jpg',
      'priority': 'PRIORIDAD ALTA',
      'fullText':
          'La Municipalidad Distrital de Huachón informa a los operadores turísticos, transportistas y visitantes que se ejecutan trabajos de perfilado y afirmado en el tramo comprendido entre Huachón y Pampa Chichuraque. Se recomienda transitar con precaución.',
      'recommendations':
          'Vehículos 4x4 recomendados. Salidas sugeridas antes de las 06:30 hrs o después de las 13:00 hrs.',
    },
    {
      'id': 'tour_02',
      'title': 'Salidas Oficiales Guiadas a Lagunas Glaciares',
      'subtitle': 'Asociación de Guías y Arrieros de Huachón · DIRCETUR Pasco.',
      'category': 'OPERACIÓN TURÍSTICA',
      'categoryColor': AppColors.yaretaPine,
      'icon': Icons.compass_calibration_rounded,
      'date': 'TEMPORADA SECA',
      'department': 'Oficina de Turismo y Desarrollo Económico Huachón',
      'image': 'assets/images/huaguruncho_trekking.jpg',
      'priority': 'INFORMATIVO',
      'fullText':
          'En coordinación con la Asociación de Guías y Arrieros de Huachón y la DIRCETUR Pasco, se habilitan salidas guiadas hacia la Laguna Huascacocha y Mirador Huaguruncho con tarifa comunal.',
      'recommendations':
          'Contratar únicamente guías acreditados con carnet DIRCETUR. Incluye servicio de acémilas y botiquín de altura.',
    },
    {
      'id': 'comunal_03',
      'title': 'Jornada Comunal de Conservación de Puya Raimondi',
      'subtitle': 'Campaña ambiental "Huaguruncho Limpio" con guardaparques.',
      'category': 'CONSERVACIÓN',
      'categoryColor': AppColors.yaretaPine,
      'icon': Icons.eco_rounded,
      'date': 'SERNANP · HUACHÓN',
      'department': 'Subgerencia de Medio Ambiente y Recursos Naturales',
      'image': 'assets/images/huaguruncho_hero.jpg',
      'priority': 'COMUNITARIO',
      'fullText':
          'Convocatoria abierta a comuneros y montañistas voluntarios para la jornada de recojo de residuos y delimitación de senderos en los rodales de Puya Raimondi en la quebrada de Huachón.',
      'recommendations':
          'Llevar guantes de protección. Punto de encuentro: Plaza Principal de Huachón a las 08:00 AM.',
    },
    {
      'id': 'clima_04',
      'title': 'Alerta de Heladas Nocturnas (-5°C) en Zonas Glaciares',
      'subtitle': 'Defensa Civil recomienda pernoctar sólo en campamentos autorizados.',
      'category': 'CLIMA & SEGURIDAD',
      'categoryColor': AppColors.basaltInk,
      'icon': Icons.ac_unit_rounded,
      'date': 'SENAMHI · COEL',
      'department': 'Centro de Operaciones de Emergencia Huachón (COEL)',
      'image': 'assets/images/huaguruncho_hero.jpg',
      'priority': 'PRECAUCIÓN',
      'fullText':
          'Se pronostica descenso térmico en altitudes superiores a los 4,000 m s.n.m. Es obligatorio el porte de equipo térmico de 3 capas y carpa 4 estaciones para campamento de montaña.',
      'recommendations':
          'Registrar su expedición en la garita de turismo de Huachón antes de iniciar el ascenso.',
    },
  ];

  Map<String, dynamic> _noticeToMap(MunicipalNoticeModel m) {
    Color catColor = AppColors.basaltInk;
    IconData iconData = Icons.campaign_rounded;

    switch (m.category.toLowerCase()) {
      case 'vial':
        catColor = AppColors.cordilleraOchre;
        iconData = Icons.warning_amber_rounded;
        break;
      case 'turismo':
        catColor = AppColors.yaretaPine;
        iconData = Icons.compass_calibration_rounded;
        break;
      case 'conservacion':
        catColor = AppColors.yaretaPine;
        iconData = Icons.eco_rounded;
        break;
      case 'clima':
        catColor = AppColors.basaltInk;
        iconData = Icons.ac_unit_rounded;
        break;
    }

    return {
      'id': m.uuid,
      'title': m.title,
      'subtitle': m.subtitle,
      'category': m.categoryDisplay.toUpperCase(),
      'categoryColor': catColor,
      'icon': iconData,
      'date': 'OFICIAL · HUACHÓN',
      'department': m.department,
      'image': 'assets/images/huachon_village.jpg',
      'priority': m.priorityDisplay.toUpperCase(),
      'fullText': m.fullText,
      'recommendations': m.recommendations.isNotEmpty
          ? m.recommendations
          : 'Seguir indicaciones del personal de control.',
    };
  }

  void _showNoticeDetail(Map<String, dynamic> notice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          border: Border(
            top: BorderSide(color: AppColors.basaltInk, width: 2),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glacialBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: notice['categoryColor'] as Color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(notice['icon'] as IconData, size: 12, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          notice['category'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.alpineChalk,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.glacialBorder),
                    ),
                    child: Text(
                      notice['priority'] as String,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.basaltInk,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                notice['title'] as String,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: AppColors.basaltInk,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${notice['department']} · ${notice['date']}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.graniteMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.alpineChalk,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.glacialBorder),
                ),
                child: Text(
                  notice['fullText'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.basaltInk,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cordilleraOchre.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cordilleraOchre.withValues(alpha: 0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.cordilleraOchre),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notice['recommendations'] as String,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.basaltInk,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/community-services');
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.basaltInk,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cordilleraOchre,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.storefront_rounded, size: 16, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'DIRECTORIO DE SERVICIOS DE HUACHÓN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSelectorDialog(BuildContext context, WidgetRef ref, AppLanguage currentLang) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.basaltInk, width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(Icons.language_rounded, color: AppColors.cordilleraOchre, size: 20),
              SizedBox(width: 8),
              Text(
                'IDIOMA / SIMI / LANGUAGE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.basaltInk,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppLanguage.values.map((lang) {
              final isSelected = lang == currentLang;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.alpineChalk : AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.basaltInk : AppColors.glacialBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: ListTile(
                  dense: true,
                  leading: Text(lang.flagEmoji, style: const TextStyle(fontSize: 20)),
                  title: Text(
                    lang.displayName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      color: AppColors.basaltInk,
                      fontSize: 13,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.cordilleraOchre, size: 18)
                      : null,
                  onTap: () {
                    ref.read(languageProvider.notifier).setLanguage(lang);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Idioma cambiado a ${lang.displayName}'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: AppColors.basaltInk,
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final routesAsync = ref.watch(routesListProvider);
    final weatherAsync = ref.watch(weatherStationsProvider);
    final noticesAsync = ref.watch(municipalNoticesProvider);
    final activeExpedition = ref.watch(activeExpeditionProvider).valueOrNull;

    final activeNotices = noticesAsync.when(
      data: (items) => items.isNotEmpty ? items.map(_noticeToMap).toList() : _municipalNotices,
      loading: () => _municipalNotices,
      error: (_, __) => _municipalNotices,
    );

    final stations = weatherAsync.valueOrNull ?? [];
    final nevadoStation = stations.cast<WeatherStationModel?>().firstWhere(
          (s) => s?.name.contains('Cumbre') == true || s?.name.contains('Huaguruncho') == true,
          orElse: () => stations.isNotEmpty ? stations.last : null,
        );
    final heroWeatherText = nevadoStation != null
        ? '${nevadoStation.tempDayCelsius.toStringAsFixed(0)}°C · UV ${nevadoStation.uvIndex.toStringAsFixed(0)}'
        : '-2°C SENS. · UV 11';

    return Scaffold(
      backgroundColor: AppColors.alpineChalk,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.basaltInk,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.terrain_rounded,
                size: 16,
                color: AppColors.cordilleraOchre,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'HUAGURUNCHO 360',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                    letterSpacing: 0.4,
                    color: AppColors.basaltInk,
                  ),
                ),
                Text(
                  'INTERFAZ 2.0 · 5,742 M · PASCO',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.graniteMuted,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final activeLang = ref.watch(languageProvider);
              return IconButton(
                icon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.alpineChalk,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.basaltInk),
                  ),
                  child: Text(
                    activeLang.flagEmoji,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                tooltip: 'Cambiar Idioma (Español / Quechua / English)',
                onPressed: () => _showLanguageSelectorDialog(context, ref, activeLang),
              );
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.cordilleraOchre,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.basaltInk),
              ),
              child: const Icon(
                Icons.sos_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            tooltip: 'Centro SOS de Emergencia',
            onPressed: () => context.push('/emergency-sos'),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.alpineChalk,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.basaltInk),
              ),
              child: Icon(
                authState.isAuthenticated ? Icons.person : Icons.person_outline,
                color: AppColors.basaltInk,
                size: 17,
              ),
            ),
            tooltip: 'Mi Perfil',
            onPressed: () => context.push('/profile'),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(routesListProvider);
          ref.invalidate(weatherStationsProvider);
          ref.invalidate(municipalNoticesProvider);
          ref.invalidate(activeExpeditionProvider);
          await ref.read(syncControllerProvider.notifier).syncNow();
        },
        color: AppColors.cordilleraOchre,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 105),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==========================================
              // MÓDULO EXCLUSIVO DE GUARDAPARQUES / AUTORIDAD
              // ==========================================
              if (authState.isAuthenticated && (authState.user?.isRangerOrAdmin ?? false))
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: _buildRangerCheckpointCard(context, authState.user!),
                ),

              // ==========================================
              // HUAGURUNCHO 360 · INTERFAZ 2.0 DASHBOARD PRINCIPAL
              // ==========================================
              ExpeditionDashboard20(
                onSosPressed: () => context.push('/emergency-sos'),
                onRangerStationPressed: () => context.push('/ranger-checkpoint'),
                weatherSummary: heroWeatherText,
                isOnline: syncState.isOnline,
                isAuthenticated: authState.isAuthenticated,
                isRangerOrAdmin: authState.isAuthenticated && (authState.user?.isRangerOrAdmin ?? false),
              ),

              const SizedBox(height: 18),

              // ==========================================
              // SECCIÓN 02 // GARITA DIGITAL DE ASCENSO (COEL HUACHÓN)
              // ==========================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildExpeditionCheckinSection(
                  context,
                  activeExpedition,
                  authState.isAuthenticated,
                ),
              ),

              const SizedBox(height: 20),

              // ==========================================
              // SECCIÓN 03 // CATÁLOGO DE SENDEROS OFICIALES (LIVE PROVIDER)
              // ==========================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildRoutesSection(context, routesAsync),
              ),

              const SizedBox(height: 20),

              // ==========================================
              // SECCIÓN 04 // DESPACHOS OFICIALES DE CAMPO (HUACHÓN)
              // ==========================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildDispatchesSection(context, activeNotices),
              ),

              const SizedBox(height: 20),

              // ==========================================
              // SECCIÓN 05 // LOGÍSTICA & COMUNIDAD ALTOANDINA
              // ==========================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildCommunityLogisticsSection(context, authState.isAuthenticated),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tarjeta de Autoridad Guardabosques 2.0
  Widget _buildRangerCheckpointCard(BuildContext context, UserModel user) {
    return InkWell(
      onTap: () => context.push('/ranger-checkpoint'),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.basaltInk,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.yaretaPine, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.yaretaPine,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CONSOLA OFICIAL GUARDABOSQUES',
                    style: TextStyle(
                      color: Color(0xFF6EE7B7),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Operador: ${user.fullName} · Garita Huachón',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  // Sección 02: Garita Digital COEL (Registro de Expedición)
  Widget _buildExpeditionCheckinSection(
    BuildContext context,
    dynamic activeExpedition,
    bool isAuthenticated,
  ) {
    if (isAuthenticated && activeExpedition != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.basaltInk,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.yaretaPine, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: AppColors.yaretaPine,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'EXPEDICIÓN ACTIVA EN RUTA · COEL',
                      style: TextStyle(
                        color: Color(0xFF6EE7B7),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${activeExpedition.groupSize} MONTAÑISTAS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              activeExpedition.routeName as String,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Contacto SOS: ${activeExpedition.emergencyContactName} (${activeExpedition.emergencyContactPhone})',
              style: const TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await ref
                          .read(activeExpeditionProvider.notifier)
                          .checkOut(activeExpedition.uuid as String);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Retorno seguro confirmado en Garita Digital Huachón.'),
                            backgroundColor: AppColors.yaretaPine,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                    label: const Text('CONFIRMAR RETORNO SEGURO'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yaretaPine,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => context.push('/emergency-sos'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.cordilleraOchre,
                    side: const BorderSide(color: AppColors.cordilleraOchre),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  ),
                  child: const Text('SOS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () {
        if (!isAuthenticated) {
          showAuthRequiredModal(
            context,
            featureName: 'Garita Digital de Ascenso COEL',
            description:
                'Inicia sesión o regístrate como excursionista para declarar tu ruta de ascenso, integrantes y contacto SOS ante Defensa Civil Huachón.',
          );
          return;
        }
        showDialog(
          context: context,
          builder: (_) => const RegisterExpeditionDialog(),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.basaltInk, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.basaltInk,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.alpineChalk,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.basaltInk),
              ),
              child: const Icon(Icons.fact_check_outlined, color: AppColors.cordilleraOchre, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '02 // GARITA DIGITAL DE ASCENSO (COEL)',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppColors.cordilleraOchre,
                      letterSpacing: 0.6,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Registrar Salida de Montaña',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.basaltInk,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Protocolo preventivo de Defensa Civil Huachón antes de ascender.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.graniteMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.basaltInk,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'CHECK-IN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sección 03: Catálogo de Senderos Oficiales (Alimentado por routesListProvider)
  Widget _buildRoutesSection(BuildContext context, AsyncValue<List<RouteModel>> routesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.basaltInk,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    '03',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                const Text(
                  'SENDEROS CARTOGRAFIADOS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.basaltInk,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => context.go('/routes'),
              child: const Text(
                'CATÁLOGO COMPLETO →',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.cordilleraOchre,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        routesAsync.when(
          loading: () => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.glacialBorder),
            ),
            child: const Center(
              child: Text(
                'Sincronizando cartas topográficas de rutas...',
                style: TextStyle(fontSize: 12, color: AppColors.graniteMuted, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (routes) {
            final topRoutes = routes.take(3).toList();
            return Column(
              children: topRoutes.asMap().entries.map((entry) {
                final idx = entry.key;
                final r = entry.value;
                final img = idx % 2 == 0
                    ? 'assets/images/huaguruncho_trekking.jpg'
                    : 'assets/images/huaguruncho_hero.jpg';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildRouteSheetItem(context, r, img, idx + 1),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRouteSheetItem(BuildContext context, RouteModel r, String fallbackAsset, int number) {
    return InkWell(
      onTap: () => context.push('/routes/${r.uuid}'),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.basaltInk, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1814171A),
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Miniatura fotográfica lateral con sello de índice
            SizedBox(
              width: 100,
              height: 108,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: (r.coverImageUrl != null && r.coverImageUrl!.startsWith('http'))
                        ? NetworkImage(r.coverImageUrl!) as ImageProvider
                        : AssetImage(
                            (r.coverImageUrl != null && r.coverImageUrl!.startsWith('assets/'))
                                ? r.coverImageUrl!
                                : fallbackAsset,
                          ),
                    fit: BoxFit.cover,
                  ),
                  Container(color: AppColors.basaltInk.withValues(alpha: 0.28)),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.basaltInk,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'R-0$number',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  if (r.scenesCount > 0)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.cordilleraOchre,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '${r.scenesCount} 360°',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Datos técnicos del sendero
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          r.difficultyDisplay.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.cordilleraOchre,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'ALT MÁX ${r.maxAltitudeM > 0 ? r.maxAltitudeM : 4796}M',
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.graniteMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.basaltInk,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.graniteMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildMiniPill('${r.distanceKm} km'),
                        const SizedBox(width: 6),
                        _buildMiniPill('${r.estimatedDurationMinutes ~/ 60}h ${r.estimatedDurationMinutes % 60}m'),
                        const Spacer(),
                        const Text(
                          'FICHA →',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.basaltInk,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.alpineChalk,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.glacialBorder),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: AppColors.basaltInk,
        ),
      ),
    );
  }

  // Sección 04: Despachos Oficiales de Campo (Municipalidad de Huachón)
  Widget _buildDispatchesSection(BuildContext context, List<Map<String, dynamic>> notices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.basaltInk,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                '04',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 7),
            const Expanded(
              child: Text(
                'DESPACHOS OFICIALES · MUNICIPALIDAD DE HUACHÓN',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.basaltInk,
                  letterSpacing: 0.6,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...notices.take(3).map((notice) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => _showNoticeDetail(notice),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.glacialBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (notice['categoryColor'] as Color).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        notice['icon'] as IconData,
                        size: 18,
                        color: notice['categoryColor'] as Color,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                notice['category'] as String,
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  color: notice['categoryColor'] as Color,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                notice['date'] as String,
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.graniteMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            notice['title'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.basaltInk,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            notice['subtitle'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.graniteMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.north_east_rounded, size: 14, color: AppColors.graniteMuted),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // Sección 05: Logística & Comunidad Altoandina
  Widget _buildCommunityLogisticsSection(BuildContext context, bool isAuthenticated) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.basaltInk,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                '05',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 7),
            const Text(
              'LOGÍSTICA & COMUNIDAD HUACHÓN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.basaltInk,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildLogisticsCard(
                icon: Icons.handshake_outlined,
                tag: 'ARRIEROS & GUÍAS',
                title: 'Servicios Locales',
                subtitle: 'Hospedaje rural, acémilas y gastronomía en Huachón.',
                onTap: () => context.push('/community-services'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildLogisticsCard(
                icon: Icons.forum_outlined,
                tag: 'BITÁCORA SOCIAL',
                title: 'Muro Centinelas',
                subtitle: 'Crónicas y avisos de montañistas en ruta.',
                onTap: () {
                  if (!isAuthenticated) {
                    showAuthRequiredModal(
                      context,
                      featureName: 'Muro Social de Centinelas',
                    );
                    return;
                  }
                  context.push('/community-wall');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () {
            if (!isAuthenticated) {
              showAuthRequiredModal(
                context,
                featureName: 'Gestor de Paquetes 100% Offline',
              );
              return;
            }
            context.push('/offline-manager');
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.basaltInk,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.basaltInk),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cordilleraOchre,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.download_for_offline_outlined, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MEMORIA CARTOGRÁFICA AUTÓNOMA',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFDBA74),
                          letterSpacing: 0.6,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Gestor de Paquetes 100% Offline',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogisticsCard({
    required IconData icon,
    required String tag,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.basaltInk, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1814171A),
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.yaretaPine,
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(icon, size: 15, color: AppColors.basaltInk),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: AppColors.basaltInk,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.graniteMuted,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
