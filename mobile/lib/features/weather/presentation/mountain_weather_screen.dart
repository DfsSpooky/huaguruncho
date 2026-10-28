import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../domain/weather_model.dart';
import 'weather_controller.dart';
import 'widgets/animated_weather_effects.dart';

class MountainWeatherScreen extends ConsumerStatefulWidget {
  const MountainWeatherScreen({super.key});

  @override
  ConsumerState<MountainWeatherScreen> createState() =>
      _MountainWeatherScreenState();
}

class _MountainWeatherScreenState extends ConsumerState<MountainWeatherScreen> {
  @override
  Widget build(BuildContext context) {
    final stationsAsync = ref.watch(weatherStationsProvider);
    final alertsAsync = ref.watch(weatherAlertsProvider);
    final selectedIndex = ref.watch(selectedWeatherStationIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.alpineChalk,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clima y Monitoreo Glaciar',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: AppColors.basaltInk,
              ),
            ),
            Text(
              'GRADIENTE TÉRMICO CORDILLERA ORIENTAL · SENAMHI / SERNANP',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: AppColors.graniteMuted,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.alpineChalk,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.basaltInk),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                size: 16,
                color: AppColors.basaltInk,
              ),
            ),
            tooltip: 'Actualizar Clima',
            onPressed: () {
              ref.invalidate(weatherStationsProvider);
              ref.invalidate(weatherAlertsProvider);
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: stationsAsync.when(
        loading: () => const LoadingIndicator(
          message: 'Consultando estaciones meteorológicas...',
        ),
        error: (err, _) => ErrorView(
          message: 'Error al conectar con las estaciones de montaña.',
          onRetry: () {
            ref.invalidate(weatherStationsProvider);
            ref.invalidate(weatherAlertsProvider);
          },
        ),
        data: (stations) {
          if (stations.isEmpty) {
            return const Center(
              child: Text('No hay datos meteorológicos disponibles.'),
            );
          }

          final safeIndex = selectedIndex < stations.length ? selectedIndex : 0;
          final currentStation = stations[safeIndex];

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(weatherStationsProvider);
              ref.invalidate(weatherAlertsProvider);
            },
            color: AppColors.cordilleraOchre,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Alerta activa de montaña (si existe)
                  alertsAsync.when(
                    data: (alerts) {
                      if (alerts.isEmpty) return const SizedBox.shrink();
                      final alert = alerts.first;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB91C1C).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFB91C1C),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFB91C1C),
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alert.title.toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFFB91C1C),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11.5,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    alert.description,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.basaltInk,
                                      height: 1.35,
                                    ),
                                  ),
                                  if (alert.affectedSector.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'SECTOR: ${alert.affectedSector.toUpperCase()}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFB91C1C),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  // Banner de Telemetría Satelital Glaciar en Vivo 2.0 con Partículas Animadas
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.basaltInk,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.basaltInk, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cordilleraOchre,
                          offset: Offset(2.5, 2.5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: AnimatedWeatherBackdrop(
                      atmosphere: resolveAtmosphereType(
                        weatherIcon: currentStation.weatherIcon,
                        tempCelsius: currentStation.tempDayCelsius,
                      ),
                      windSpeedKmh: currentStation.windKmh,
                      borderRadius: BorderRadius.circular(8.5),
                      compact: true,
                      child: Padding(
                        padding: const EdgeInsets.all(13),
                        child: Row(
                          children: [
                            const LiveTelemetryPulseDot(
                              color: Color(0xFF34D399),
                              size: 9.0,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PRONÓSTICO DEL CLIMA EN VIVO',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF6EE7B7),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'El frío aumenta a medida que subes hacia el nevado. Lleva ropa de abrigo y protección contra el viento.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            AnimatedWeatherEmblem(
                              weatherIcon: currentStation.weatherIcon,
                              tempCelsius: currentStation.tempDayCelsius,
                              size: 18,
                              showContainer: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Selector de Pisos Altitudinales
                  const Row(
                    children: [
                      Icon(
                        Icons.terrain_rounded,
                        size: 16,
                        color: AppColors.cordilleraOchre,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'SELECCIONA ESTACIÓN ALTITUDINAL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.basaltInk,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  SizedBox(
                    height: 54,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: stations.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final st = stations[index];
                        final isSelected = index == safeIndex;
                        return InkWell(
                          onTap: () {
                            ref
                                .read(selectedWeatherStationIndexProvider.notifier)
                                .state = index;
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.basaltInk
                                  : AppColors.pureWhite,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.basaltInk,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  st.name,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w900,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.basaltInk,
                                  ),
                                ),
                                Text(
                                  '${st.altitudeMasl} m · ${st.tempDayCelsius.toStringAsFixed(0)}°C',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? const Color(0xFF6EE7B7)
                                        : AppColors.graniteMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Tarjeta Principal de Clima Actual en la Estación
                  _MainWeatherCard(station: currentStation),

                  const SizedBox(height: 14),

                  // Cuadrícula de Métricas de Alta Montaña (Viento, UV, Humedad, Presión)
                  _MetricsGrid(station: currentStation),

                  const SizedBox(height: 14),

                  // Recomendación Didáctica del Guardaparque
                  if (currentStation.alertAdvisory.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.basaltInk, width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1414171A),
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.cordilleraOchre.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.shield_outlined,
                              color: AppColors.cordilleraOchre,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'RECOMENDACIÓN TÉCNICA PARA ESTE PISO',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                    color: AppColors.basaltInk,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentStation.alertAdvisory,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.graniteMuted,
                                    height: 1.35,
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
            ),
          );
        },
      ),
    );
  }
}

class _MainWeatherCard extends StatelessWidget {
  final WeatherStationModel station;

  const _MainWeatherCard({required this.station});

  @override
  Widget build(BuildContext context) {
    final atmosphere = resolveAtmosphereType(
      weatherIcon: station.weatherIcon,
      tempCelsius: station.tempDayCelsius,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.basaltInk,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.basaltInk, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.yaretaPine,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: AnimatedWeatherBackdrop(
        atmosphere: atmosphere,
        windSpeedKmh: station.windKmh,
        borderRadius: BorderRadius.circular(10.5),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'COTA OFICIAL: ${station.altitudeMasl} M S.N.M.',
                          style: const TextStyle(
                            color: Color(0xFF6EE7B7),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedWeatherEmblem(
                    weatherIcon: station.weatherIcon,
                    tempCelsius: station.tempDayCelsius,
                    size: 26,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${station.tempDayCelsius.toStringAsFixed(0)}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (station.tempDayCelsius <= 0)
                          Container(
                            margin: const EdgeInsets.only(bottom: 3),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF38BDF8).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF38BDF8)),
                            ),
                            child: const Text(
                              '❄️ CONGELACIÓN GLACIAR',
                              style: TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        Text(
                          'Mínima nocturna: ${station.tempNightCelsius.toStringAsFixed(0)}°C',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Sensación térmica: ${station.windChillCelsius.toStringAsFixed(0)}°C',
                          style: const TextStyle(
                            color: AppColors.cordilleraOchre,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      station.condition.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildRiskBadge(station.riskLevel, station.riskLevelDisplay),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskBadge(String riskLevel, String display) {
    Color color;
    switch (riskLevel) {
      case 'bajo':
        color = AppColors.yaretaPine;
        break;
      case 'moderado':
        color = AppColors.cordilleraOchre;
        break;
      case 'heladas':
      case 'extremo':
      case 'ventisca':
        color = const Color(0xFFB91C1C);
        break;
      default:
        color = AppColors.graniteMuted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        (display.isNotEmpty ? display : riskLevel).toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final WeatherStationModel station;

  const _MetricsGrid({required this.station});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.65,
      children: [
        _MetricCard(
          icon: Icons.air_rounded,
          iconColor: AppColors.yaretaPine,
          title: 'VIENTO GLACIAR',
          value: '${station.windKmh.toStringAsFixed(0)} km/h',
          subtitle: 'Ráfagas ${station.windGustsKmh.toStringAsFixed(0)} km/h',
        ),
        _MetricCard(
          icon: Icons.wb_sunny_outlined,
          iconColor: AppColors.cordilleraOchre,
          title: 'RADIACIÓN UV',
          value: 'IUV ${station.uvIndex.toStringAsFixed(0)}',
          subtitle: station.uvLevel,
        ),
        _MetricCard(
          icon: Icons.water_drop_outlined,
          iconColor: const Color(0xFF0284C7),
          title: 'HUMEDAD REL.',
          value: '${station.humidityPercentage}%',
          subtitle: 'Aire seco de puna',
        ),
        _MetricCard(
          icon: Icons.speed_rounded,
          iconColor: const Color(0xFFB91C1C),
          title: 'PRESIÓN BAR.',
          value: '${station.pressureHpa} hPa',
          subtitle: 'Hipoxia de altura',
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.basaltInk, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1414171A),
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 15),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: AppColors.graniteMuted,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.basaltInk,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.graniteMuted,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
