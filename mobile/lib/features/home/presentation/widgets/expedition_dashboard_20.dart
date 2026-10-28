import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/widgets/auth_required_gate.dart';
import '../../../weather/presentation/widgets/animated_weather_effects.dart';

/// Huaguruncho 360 · Interfaz 2.0 (Google Stitch)
/// "Alpine Field Instrument & Editorial Expedition Journal"
class ExpeditionDashboard20 extends StatefulWidget {
  final VoidCallback? onSosPressed;
  final VoidCallback? onRangerStationPressed;
  final String weatherSummary;
  final bool isOnline;
  final bool isAuthenticated;
  final bool isRangerOrAdmin;

  const ExpeditionDashboard20({
    super.key,
    this.onSosPressed,
    this.onRangerStationPressed,
    this.weatherSummary = '-2°C SENS. · UV 11',
    this.isOnline = false,
    this.isAuthenticated = false,
    this.isRangerOrAdmin = false,
  });

  @override
  State<ExpeditionDashboard20> createState() => _ExpeditionDashboard20State();
}

class _TelemetrySpot {
  final String label;
  final String tempSummary;
  final String pressure;
  final String conditionBadge;
  final String weatherIcon;
  final double tempCelsius;
  final double windKmh;

  const _TelemetrySpot({
    required this.label,
    required this.tempSummary,
    required this.pressure,
    required this.conditionBadge,
    required this.weatherIcon,
    required this.tempCelsius,
    required this.windKmh,
  });
}

class _ExpeditionDashboard20State extends State<ExpeditionDashboard20> {
  final SecureStorageService _storage = SecureStorageService();
  int _wasteBagsCount = 4;
  int _activeSpotIndex = 0;

  static const List<_TelemetrySpot> _telemetrySpots = [
    _TelemetrySpot(
      label: 'CUMBRE GLACIAR · 5,742 M',
      tempSummary: '-4°C NIEVE · UV 14',
      pressure: '490 hPa',
      conditionBadge: 'VENTISCA NIVAL',
      weatherIcon: 'ac_unit',
      tempCelsius: -4.0,
      windKmh: 45.0,
    ),
    _TelemetrySpot(
      label: 'HUACHÓN PUEBLO · 3,400 M',
      tempSummary: '14°C SOL · UV 9',
      pressure: '690 hPa',
      conditionBadge: 'SOL ANDINO',
      weatherIcon: 'wb_sunny',
      tempCelsius: 14.0,
      windKmh: 12.0,
    ),
    _TelemetrySpot(
      label: 'HUASCACOCHA · 4,250 M',
      tempSummary: '5°C VIENTO · UV 12',
      pressure: '600 hPa',
      conditionBadge: 'BRISA DE PUNA',
      weatherIcon: 'air',
      tempCelsius: 5.0,
      windKmh: 28.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadWasteCount();
  }

  Future<void> _loadWasteCount() async {
    final saved = await _storage.getWasteBagsCount(defaultValue: 4);
    if (mounted) {
      setState(() => _wasteBagsCount = saved);
    }
  }

  void _cycleTelemetrySpot() {
    HapticFeedback.selectionClick();
    setState(() {
      _activeSpotIndex = (_activeSpotIndex + 1) % _telemetrySpots.length;
    });
  }

  void _requireAuth(
    BuildContext context,
    String featureName,
    VoidCallback action,
  ) {
    if (!widget.isAuthenticated) {
      showAuthRequiredModal(context, featureName: featureName);
      return;
    }
    action();
  }

  void _updateWasteCount(int delta) {
    if (!widget.isAuthenticated) {
      showAuthRequiredModal(
        context,
        featureName: 'Contador de Bolsas Huella Cero',
      );
      return;
    }
    final next = (_wasteBagsCount + delta).clamp(0, 99);
    if (next != _wasteBagsCount) {
      HapticFeedback.selectionClick();
      setState(() => _wasteBagsCount = next);
      _storage.saveWasteBagsCount(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ==========================================
        // 1. BARRA DE TELEMETRÍA Y AMBIENTAL ANIMADA
        // ==========================================
        _buildTelemetryBar(context),

        const SizedBox(height: 14),

        // ==========================================
        // 2. PÓSTER FOTOGRÁFICO EDITORIAL DE EXPEDICIÓN
        // ==========================================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildExpeditionHeroPoster(context),
        ),

        const SizedBox(height: 12),

        // ==========================================
        // 3. CONSOLA TÁCTICA SOS & GUARDAPARQUES
        // ==========================================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildStatusSosConsole(context),
        ),

        const SizedBox(height: 18),

        // ==========================================
        // 4. ENCABEZADO SECCIÓN 01 // GUÍAS Y HERRAMIENTAS
        // ==========================================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildSectionHeader(
            index: '01',
            title: 'GUÍAS Y HERRAMIENTAS',
            subtitle: 'Todo lo que necesitas para tu visita y el cuidado del nevado',
          ),
        ),

        const SizedBox(height: 10),

        // ==========================================
        // 5. CUADRÍCULA MODULAR ASIMÉTRICA BENTO (8 MÓDULOS)
        // ==========================================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildBentoModularGrid(context),
        ),

        const SizedBox(height: 18),

        // ==========================================
        // 6. FICHA TOPOGRÁFICA DE RUTA DESTACADA
        // ==========================================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildActiveRouteCard(context),
        ),

        const SizedBox(height: 14),

        // ==========================================
        // 7. CUADERNO DE CAMPO & BITÁCORA TÉCNICA
        // ==========================================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildFieldNotesCard(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String index,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.basaltInk,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      index,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.basaltInk,
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.graniteMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 1. Barra de Telemetría Superior con Animación Climática (Copos de Nieve, Sol Andino, Viento)
  Widget _buildTelemetryBar(BuildContext context) {
    final spot = _telemetrySpots[_activeSpotIndex];
    final atmosphere = resolveAtmosphereType(
      weatherIcon: spot.weatherIcon,
      tempCelsius: spot.tempCelsius,
    );

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.basaltInk,
        border: Border(
          bottom: BorderSide(color: AppColors.glacialBorder, width: 1),
        ),
      ),
      child: AnimatedWeatherBackdrop(
        atmosphere: atmosphere,
        windSpeedKmh: spot.windKmh,
        compact: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Estado en línea con pulso satelital + selector de piso térmico
                  Flexible(
                    child: InkWell(
                      onTap: _cycleTelemetrySpot,
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LiveTelemetryPulseDot(
                            color: widget.isOnline
                                ? const Color(0xFF34D399)
                                : AppColors.cordilleraOchre,
                            size: 6.5,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.isOnline
                                ? 'CONEXIÓN EN LÍNEA'
                                : 'MODO SIN INTERNET',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: widget.isOnline
                                  ? const Color(0xFF6EE7B7)
                                  : const Color(0xFFFDBA74),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '|',
                            style: TextStyle(fontSize: 10, color: Colors.white24),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.09),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.18),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.swap_vert_rounded,
                                    size: 11,
                                    color: AppColors.cordilleraOchre,
                                  ),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      spot.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 9.0,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                      ),
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
                  const SizedBox(width: 8),
                  // Indicador animado de clima (Copo / Sol / Viento) -> abre pantalla de Clima
                  InkWell(
                    onTap: () => context.push('/weather'),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedWeatherEmblem(
                            weatherIcon: spot.weatherIcon,
                            tempCelsius: spot.tempCelsius,
                            size: 14,
                            showContainer: false,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            spot.tempSummary,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            spot.pressure,
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. Póster Fotográfico Editorial de Expedición (Con Fotografía Real de Huaguruncho)
  Widget _buildExpeditionHeroPoster(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.basaltInk,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.basaltInk, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.basaltInk,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ventana Fotográfica Asimétrica con Retícula Cartográfica
          SizedBox(
            height: 225,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/huaguruncho_hero.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
                // Gradiente mineral editorial
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.basaltInk.withValues(alpha: 0.55),
                        AppColors.basaltInk.withValues(alpha: 0.15),
                        AppColors.basaltInk.withValues(alpha: 0.94),
                      ],
                      stops: const [0.0, 0.42, 1.0],
                    ),
                  ),
                ),
                // Marca de agua de altitud gigante
                Positioned(
                  right: 10,
                  bottom: 50,
                  child: IgnorePointer(
                    child: Text(
                      '5,742M',
                      style: TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withValues(alpha: 0.11),
                        letterSpacing: -2.5,
                      ),
                    ),
                  ),
                ),
                // Barra superior de coordenadas dentro del visor
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.cordilleraOchre,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NEVADO HUAGURUNCHO',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.basaltInk.withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Text(
                          '10°31\'48"S · 75°55\'48"W',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Titular Editorial e Instrumentos de Acción Rápida
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CORDILLERA ORIENTAL · HUACHÓN, PASCO',
                        style: TextStyle(
                          color: Color(0xFFFDBA74),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.9,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Nevado Huaguruncho',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.6,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _requireAuth(
                                context,
                                'Visor Panorámico 360° VR',
                                () => context.go('/tour-360'),
                              ),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.cordilleraOchre,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.view_in_ar_rounded, size: 15, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text(
                                      'VISOR 360° VR',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () => _requireAuth(
                                context,
                                'Audioguías y Relatos Quechua',
                                () => context.push('/audio-guides'),
                              ),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.pureWhite.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.white38),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.headphones_rounded, size: 15, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text(
                                      'RELATOS QUECHUA',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Franja Inferior de Luz Solar y Estado
          Container(
            color: AppColors.pureWhite,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HORAS DE LUZ',
                        style: TextStyle(
                          fontSize: 8.5,
                          color: AppColors.graniteMuted,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '05:48 - 18:04 HRS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.basaltInk,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESTADO DEL TIEMPO',
                        style: TextStyle(
                          fontSize: 8.5,
                          color: AppColors.graniteMuted,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'DESPEJADO · APTO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.yaretaPine,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'SEÑAL GPS',
                        style: TextStyle(
                          fontSize: 8.5,
                          color: AppColors.graniteMuted,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'CONECTADO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cordilleraOchre,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Consola Táctica SOS & Seguridad / Guardaparques
  Widget _buildStatusSosConsole(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: InkWell(
            onTap: widget.isRangerOrAdmin
                ? (widget.onRangerStationPressed ?? () => context.push('/ranger-checkpoint'))
                : () => context.push('/safety'),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.yaretaPine,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      widget.isRangerOrAdmin ? Icons.verified_user_rounded : Icons.health_and_safety_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isRangerOrAdmin ? 'CONTROL GUARDAPARQUES' : 'GUÍA DE SEGURIDAD',
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.graniteMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.isRangerOrAdmin ? 'PUESTO HUACHÓN' : 'CONSEJOS PARA LA ALTURA',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.basaltInk,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Botón SOS de Ayuda
        Expanded(
          flex: 5,
          child: InkWell(
            onTap: widget.onSosPressed ?? () => context.push('/emergency-sos'),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cordilleraOchre,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.basaltInk, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.basaltInk,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emergency_share_outlined, color: Colors.white, size: 17),
                  SizedBox(width: 6),
                  Text(
                    'PEDIR AYUDA SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 4. Ficha de Ruta Activa & Perfil Altimétrico
  Widget _buildActiveRouteCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.basaltInk, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.basaltInk,
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Franja de acento superior
          Container(height: 4, width: double.infinity, color: AppColors.cordilleraOchre),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Etiqueta de ruta y dificultad
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.north_east_rounded, size: 14, color: AppColors.cordilleraOchre),
                        SizedBox(width: 4),
                        Text(
                          'MAPA Y ALTURA DE LA RUTA',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.cordilleraOchre,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.basaltInk,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'NIVEL: MODERADO',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Laguna Tauricocha → Campo Base Nevado',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.basaltInk,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Caminata por el valle, cruce de senderos rocosos y paso por hermosas lagunas y bofedales andinos.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.graniteMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                // Rejilla de datos de 4 columnas
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.alpineChalk,
                    border: Border.all(color: AppColors.glacialBorder, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      _TelemetryColumn(label: 'DISTANCIA', value: '8.4 km'),
                      _TelemetryDivider(),
                      _TelemetryColumn(label: 'SUBIDA', value: '+720 m', valueColor: AppColors.cordilleraOchre),
                      _TelemetryDivider(),
                      _TelemetryColumn(label: 'TIEMPO APROX.', value: '4h 30m'),
                      _TelemetryDivider(),
                      _TelemetryColumn(label: 'ALTURA MÁX.', value: '4,680 m'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Gráfico vectorial de elevación
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    border: Border.all(color: AppColors.glacialBorder, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.show_chart_rounded, size: 14, color: AppColors.basaltInk),
                              SizedBox(width: 4),
                              Text(
                                'SUBIDAS Y BAJADAS DEL CAMINO',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.basaltInk,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'PENDIENTE: 14%',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.graniteMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 70,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: _ElevationGraphPainter(),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Divider(color: AppColors.glacialBorder, height: 1),
                      const SizedBox(height: 6),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('● L. Tauricocha (Km 0)', style: TextStyle(fontSize: 8.5, color: AppColors.graniteMuted)),
                          Text('● Campamento 1 (Km 5.2)', style: TextStyle(fontSize: 8.5, color: AppColors.graniteMuted)),
                          Text(
                            '▲ Campo Base (Km 8.4)',
                            style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: AppColors.basaltInk),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Botón Acción Primaria
                InkWell(
                  onTap: () => _requireAuth(
                    context,
                    'Navegación GPS en Vivo',
                    () => context.push('/live-trekking'),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.basaltInk,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.gps_fixed_rounded, size: 15, color: AppColors.cordilleraOchre),
                        SizedBox(width: 8),
                        Text(
                          'ABRIR MAPA Y SEGUIMIENTO EN VIVO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5. Cuadrícula Modular Asimétrica Bento (8 Módulos Completos)
  Widget _buildBentoModularGrid(BuildContext context) {
    return Column(
      children: [
        // FILA 1: Tours 360° + Control de Basura
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildBentoCard(
                context: context,
                tag: 'VISTA 360°',
                badgeText: 'FOTOS 360°',
                tagColor: AppColors.cordilleraOchre,
                title: 'Miradores 360°',
                subtitle: 'Mira fotos panorámicas de lagunas y glaciares.',
                contentWidget: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.basaltInk),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/huaguruncho_cover.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: AppColors.basaltInk.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'FOTO PANORÁMICA',
                      style: TextStyle(color: Colors.white, fontSize: 7.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                actionLabel: 'VER EN 360°',
                onTap: () => _requireAuth(
                  context,
                  'Miradores Esféricos 360°',
                  () => context.go('/tour-360'),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBentoCard(
                context: context,
                tag: 'CUIDADO AMBIENTAL',
                badgeText: 'SIN BASURA',
                tagColor: AppColors.yaretaPine,
                title: 'Control de Basura',
                subtitle: 'Anota cuántas bolsas de residuos bajas.',
                contentWidget: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.alpineChalk,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.glacialBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'BOLSAS\nRETORNADAS',
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.graniteMuted),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _updateWasteCount(-1),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: AppColors.pureWhite,
                                border: Border.all(color: AppColors.basaltInk),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.remove, size: 12, color: AppColors.basaltInk),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              _wasteBagsCount.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.basaltInk),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _updateWasteCount(1),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: AppColors.pureWhite,
                                border: Border.all(color: AppColors.basaltInk),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.add, size: 12, color: AppColors.cordilleraOchre),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actionLabel: widget.isRangerOrAdmin ? 'CONTROL GUARDAPARQUES' : 'CÓDIGO DE CUIDADO',
                onTap: () => context.push(widget.isRangerOrAdmin ? '/ranger-checkpoint' : '/responsible-use'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // FILA 2: Clima + Flora y Fauna
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildBentoCard(
                context: context,
                tag: 'CLIMA',
                badgeText: 'TIEMPO',
                tagColor: AppColors.basaltInk,
                title: 'Clima y Nevado',
                subtitle: 'Temperatura, viento, lluvia y sol.',
                contentWidget: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.alpineChalk,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.glacialBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.ac_unit_rounded, size: 16, color: AppColors.basaltInk),
                      Flexible(
                        child: Text(
                          widget.weatherSummary,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.basaltInk),
                        ),
                      ),
                    ],
                  ),
                ),
                actionLabel: 'VER EL CLIMA',
                onTap: () => context.push('/mountain-weather'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBentoCard(
                context: context,
                tag: 'NATURALEZA',
                badgeText: 'LOCAL',
                tagColor: AppColors.yaretaPine,
                title: 'Flora y Fauna',
                subtitle: 'Puya Raimondi, cóndor, taruca y más.',
                contentWidget: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.alpineChalk,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.glacialBorder),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.eco_outlined, size: 16, color: AppColors.yaretaPine),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'FOTOS DE PLANTAS Y ANIMALES',
                          style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800, color: AppColors.basaltInk),
                        ),
                      ),
                    ],
                  ),
                ),
                actionLabel: 'VER ESPECIES',
                onTap: () => context.push('/biodiversity'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // FILA 3: Mochila y Ropa + Sellos de Visita
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildBentoCard(
                context: context,
                tag: 'EQUIPAJE',
                badgeText: 'ROPA',
                tagColor: AppColors.cordilleraOchre,
                title: '¿Qué llevar?',
                subtitle: 'Lista de ropa abrigadora y cosas útiles.',
                contentWidget: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.alpineChalk,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.glacialBorder),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('CONSEJO:', style: TextStyle(fontSize: 8, color: AppColors.graniteMuted, fontWeight: FontWeight.w700)),
                      Text('LLEVA ROPA DE FRÍO', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.basaltInk)),
                    ],
                  ),
                ),
                actionLabel: 'VER LISTA DE EQUIPO',
                onTap: () => _requireAuth(
                  context,
                  'Mochila y Cosas que Llevar',
                  () => context.push('/trekking-checklist'),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBentoCard(
                context: context,
                tag: 'RECUERDOS',
                badgeText: 'LOGROS',
                tagColor: AppColors.basaltInk,
                title: 'Sellos de Visita',
                subtitle: 'Sellos digitales y compromiso ambiental.',
                contentWidget: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.alpineChalk,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.glacialBorder),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('NIVEL:', style: TextStyle(fontSize: 8, color: AppColors.graniteMuted, fontWeight: FontWeight.w700)),
                      Text('AMIGO DEL NEVADO', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.yaretaPine)),
                    ],
                  ),
                ),
                actionLabel: 'VER MIS SELLOS',
                onTap: () => _requireAuth(
                  context,
                  'Pasaporte de Sellos',
                  () => context.push('/guardian-passport'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // FILA 4: Mapa en Vivo + Reporte Ambiental
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildBentoCard(
                context: context,
                tag: 'MAPA EN VIVO',
                badgeText: 'GPS',
                tagColor: AppColors.basaltInk,
                title: 'Seguir el Camino',
                subtitle: 'Mira tu posición en el mapa para no perderte.',
                contentWidget: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.alpineChalk,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.glacialBorder),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: const LinearProgressIndicator(
                      value: 0.65,
                      minHeight: 5,
                      backgroundColor: AppColors.glacialBorder,
                      valueColor: AlwaysStoppedAnimation(AppColors.cordilleraOchre),
                    ),
                  ),
                ),
                actionLabel: 'ABRIR MAPA EN VIVO',
                onTap: () => _requireAuth(
                  context,
                  'Mapa GPS en Vivo',
                  () => context.push('/live-trekking'),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBentoCard(
                context: context,
                tag: 'CUIDAR EL LUGAR',
                badgeText: 'AVISO',
                tagColor: AppColors.cordilleraOchre,
                title: 'Reportar Problema',
                subtitle: 'Avisa con foto si ves basura o caminos dañados.',
                contentWidget: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.alpineChalk,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.glacialBorder),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 14, color: AppColors.cordilleraOchre),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'FOTO + LUGAR EXACTO',
                          style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.basaltInk),
                        ),
                      ),
                    ],
                  ),
                ),
                actionLabel: 'CREAR REPORTE',
                onTap: () => _requireAuth(
                  context,
                  'Reportar Problema Ambiental',
                  () => context.push('/create-report'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required BuildContext context,
    required String tag,
    required String badgeText,
    required Color tagColor,
    required String title,
    required String subtitle,
    required Widget contentWidget,
    required String actionLabel,
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
                Flexible(
                  child: Text(
                    tag,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: tagColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.alpineChalk,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.glacialBorder),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.basaltInk,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: AppColors.basaltInk,
                height: 1.15,
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
            const SizedBox(height: 8),
            contentWidget,
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    actionLabel,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: tagColor,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Icon(Icons.north_east_rounded, size: 12, color: tagColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 6. Consejos y Recomendaciones Útiles para la Visita
  Widget _buildFieldNotesCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glacialBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: AppColors.basaltInk),
                  SizedBox(width: 6),
                  Text(
                    'CONSEJOS ÚTILES PARA EL CAMINO',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.basaltInk,
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ),
              Text(
                'MUNICIPALIDAD DE HUACHÓN',
                style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: AppColors.graniteMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildFieldNoteRow(
            code: '01 / TERRENO',
            text: 'Hay zonas con piedras sueltas sobre los 4,500 m. Camina con buen calzado y a paso firme.',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(color: AppColors.glacialBorder, height: 1),
          ),
          _buildFieldNoteRow(
            code: '02 / CUIDA EL AGUA',
            text: 'Las lagunas de Tauricocha y Huascacocha son fuentes de vida. Por favor no arrojes basura ni uses jabón en el agua.',
          ),
        ],
      ),
    );
  }

  Widget _buildFieldNoteRow({required String code, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 82,
          child: Text(
            code,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              color: AppColors.cordilleraOchre,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.basaltInk,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _TelemetryColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _TelemetryColumn({
    required this.label,
    required this.value,
    this.valueColor = AppColors.basaltInk,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: AppColors.graniteMuted,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TelemetryDivider extends StatelessWidget {
  const _TelemetryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.glacialBorder,
    );
  }
}

class _ElevationGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.glacialBorder
      ..strokeWidth = 0.8;

    canvas.drawLine(Offset(0, size.height * 0.25), Offset(size.width, size.height * 0.25), gridPaint);
    canvas.drawLine(Offset(0, size.height * 0.6), Offset(size.width, size.height * 0.6), gridPaint);

    final path = Path()
      ..moveTo(0, size.height * 0.88)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.82,
        size.width * 0.35,
        size.height * 0.55,
        size.width * 0.58,
        size.height * 0.44,
      )
      ..cubicTo(
        size.width * 0.75,
        size.height * 0.36,
        size.width * 0.88,
        size.height * 0.18,
        size.width,
        size.height * 0.12,
      );

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.cordilleraOchre.withValues(alpha: 0.28),
          AppColors.cordilleraOchre.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    final strokePaint = Paint()
      ..color = AppColors.cordilleraOchre
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, strokePaint);

    final pointPaint = Paint()
      ..color = AppColors.basaltInk
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(0, size.height * 0.88), 3, pointPaint);
    canvas.drawCircle(Offset(size.width * 0.58, size.height * 0.44), 3.5, pointPaint);
    canvas.drawCircle(Offset(size.width, size.height * 0.12), 4, Paint()..color = AppColors.cordilleraOchre);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
