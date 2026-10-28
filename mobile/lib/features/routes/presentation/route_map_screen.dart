import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/alpine_topographic_backdrop.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/auth_required_gate.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../reports/presentation/reports_controller.dart';
import '../domain/route_model.dart';
import 'routes_controller.dart';

class RouteMapScreen extends ConsumerStatefulWidget {
  final String routeUuid;
  final RouteModel? initialRoute;

  const RouteMapScreen({
    super.key,
    required this.routeUuid,
    this.initialRoute,
  });

  @override
  ConsumerState<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends ConsumerState<RouteMapScreen> {
  final MapController _mapController = MapController();
  String _currentLayer = 'topo'; // 'topo', 'satellite', 'osm'
  double? _userAltitude;
  LatLng? _userLocation;

  // Fallback coords para Huaguruncho si la ruta no tiene GPX cargado
  static final List<LatLng> _fallbackCoords = [
    const LatLng(-10.551240, -75.981450),
    const LatLng(-10.548910, -75.954120),
    const LatLng(-10.539800, -75.942000),
    const LatLng(-10.531200, -75.932400),
    const LatLng(-10.525500, -75.924000),
    const LatLng(-10.521800, -75.918900),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  Future<void> _fetchUserLocation() async {
    try {
      final loc = ref.read(locationServiceProvider);
      final pos = await loc.getCurrentLocation().timeout(
        const Duration(seconds: 4),
        onTimeout: () => null,
      );
      if (mounted && pos != null) {
        setState(() {
          _userAltitude = pos.altitude;
          _userLocation = LatLng(pos.latitude, pos.longitude);
        });
      }
    } catch (_) {}
  }

  String _getTileUrl() => AlpineTopographicBackdrop.primaryTileUrl(_currentLayer);
  String _getFallbackTileUrl() => AlpineTopographicBackdrop.fallbackTileUrl(_currentLayer);

  void _fitTrailBounds(List<LatLng> points) {
    if (points.isEmpty) return;
    try {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(48),
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final routeAsync = ref.watch(routeDetailProvider(widget.routeUuid));
    final route = routeAsync.value ?? widget.initialRoute;

    final routeName = route?.name ?? 'Ruta Turística Huaguruncho';
    final points = (route?.coordinates.isNotEmpty ?? false)
        ? route!.coordinates
        : _fallbackCoords;

    final startPoint = points.first;
    final endPoint = points.last;
    final elevationProfile = route?.parsedElevationProfile ?? [];

    return Scaffold(
      backgroundColor: AppColors.alpineChalk,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 60,
        shape: const Border(
          bottom: BorderSide(color: AppColors.basaltInk, width: 1.5),
        ),
        leadingWidth: 52,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 10, bottom: 10),
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.alpineChalk,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.basaltInk, width: 1.2),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: AppColors.basaltInk, size: 19),
            ),
          ),
        ),
        titleSpacing: 8,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.basaltInk,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.map_outlined, size: 16, color: AppColors.cordilleraOchre),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'CARTOGRAFÍA SATELITAL · GPX',
                    style: TextStyle(
                      color: AppColors.cordilleraOchre,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    routeName,
                    style: const TextStyle(
                      color: AppColors.basaltInk,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.crimsonAlertLight,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.error, width: 1.2),
              ),
              child: const Icon(Icons.sos_rounded, color: AppColors.error, size: 16),
            ),
            tooltip: 'Centro de Emergencia SOS',
            onPressed: () => context.push('/emergency-sos'),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.alpineChalk,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.basaltInk, width: 1.2),
              ),
              child: const Icon(Icons.refresh_rounded, color: AppColors.basaltInk, size: 16),
            ),
            tooltip: 'Actualizar Ruta',
            onPressed: () => ref.refresh(routeDetailProvider(widget.routeUuid)),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: routeAsync.isLoading && route == null
          ? const Center(child: LoadingIndicator(message: 'Cargando trazo GPS de la ruta...'))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. MAPA INTERACTIVO WIKILOC REAL (FLUTTER_MAP)
                  Container(
                    height: 330,
                    decoration: BoxDecoration(
                      color: AppColors.basaltInk,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.basaltInk, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.basaltInk,
                          blurRadius: 0,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        AlpineTopographicBackdrop(layerMode: _currentLayer),
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            backgroundColor: Colors.transparent,
                            initialCenter: startPoint,
                            initialZoom: 13.0,
                            minZoom: 4.0,
                            maxZoom: 18.0,
                            initialCameraFit: points.isNotEmpty
                                ? CameraFit.bounds(
                                    bounds: LatLngBounds.fromPoints(points),
                                    padding: const EdgeInsets.all(40),
                                  )
                                : null,
                            onMapReady: () {
                              if (points.isNotEmpty) {
                                _fitTrailBounds(points);
                              }
                            },
                          ),
                          children: [
                            // Capa de Cartografía (Topo, Satélite o Calles)
                            TileLayer(
                              urlTemplate: _getTileUrl(),
                              fallbackUrl: _getFallbackTileUrl(),
                              userAgentPackageName: 'pe.gob.huachon.huaguruncho_360',
                              maxZoom: 19,
                              evictErrorTileStrategy: EvictErrorTileStrategy.dispose,
                            ),

                            // Trazo GPX Polyline (Estilo Wikiloc Ocre Cordillera con Sombra)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: points,
                                  strokeWidth: 5.0,
                                  color: AppColors.cordilleraOchre,
                                  borderStrokeWidth: 2.0,
                                  borderColor: AppColors.basaltInk,
                                ),
                              ],
                            ),

                            // Marcadores de Puntos Clave
                            MarkerLayer(
                              markers: [
                                // Marcador Punto de Partida
                                Marker(
                                  point: startPoint,
                                  width: 90,
                                  height: 60,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.yaretaPine,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.white, width: 1),
                                        ),
                                        child: const Text(
                                          'INICIO',
                                          style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                                        ),
                                      ),
                                      const Icon(Icons.location_on, color: AppColors.yaretaPine, size: 24),
                                    ],
                                  ),
                                ),

                                // Marcador Cumbre / Meta
                                Marker(
                                  point: endPoint,
                                  width: 90,
                                  height: 60,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.cordilleraOchre,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.white, width: 1),
                                        ),
                                        child: const Text(
                                          'CUMBRE',
                                          style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                                        ),
                                      ),
                                      const Icon(Icons.flag_rounded, color: AppColors.cordilleraOchre, size: 24),
                                    ],
                                  ),
                                ),

                                // Marcador de Usuario (si GPS disponible)
                                if (_userLocation != null)
                                  Marker(
                                    point: _userLocation!,
                                    width: 32,
                                    height: 32,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.cordilleraOchre,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 3),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),

                        // Selector de Capas Flotante Superior (Topo / Satélite / Calles)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.basaltInk.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildLayerChip('topo', 'TOPO'),
                                _buildLayerChip('satellite', 'SATÉLITE'),
                                _buildLayerChip('osm', 'MAPA'),
                              ],
                            ),
                          ),
                        ),

                        // Botones de Control de Cámara (Derecha)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildMapBtn(
                                icon: Icons.crop_free_rounded,
                                tooltip: 'Encuadrar Toda la Ruta',
                                onTap: () => _fitTrailBounds(points),
                              ),
                              const SizedBox(height: 6),
                              _buildMapBtn(
                                icon: Icons.my_location_rounded,
                                tooltip: 'Mi Ubicación',
                                onTap: () {
                                  if (_userLocation != null) {
                                    _mapController.move(_userLocation!, 15.0);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Buscando señal GPS actual...')),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 6),
                              _buildMapBtn(
                                icon: Icons.add,
                                tooltip: 'Acercar',
                                onTap: () {
                                  final zoom = _mapController.camera.zoom;
                                  _mapController.move(_mapController.camera.center, zoom + 1);
                                },
                              ),
                              const SizedBox(height: 6),
                              _buildMapBtn(
                                icon: Icons.remove,
                                tooltip: 'Alejar',
                                onTap: () {
                                  final zoom = _mapController.camera.zoom;
                                  _mapController.move(_mapController.camera.center, zoom - 1);
                                },
                              ),
                            ],
                          ),
                        ),

                        // Badge inferior con cantidad de puntos del GPX
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.basaltInk.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              'GPX: ${points.length} PTS · ${route?.distanceKm ?? 0} KM',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // BOTÓN PRINCIPAL DE NAVEGACIÓN GPS EN VIVO (STITCH 2.0)
                  InkWell(
                    onTap: () {
                      final isAuth = ref.read(authControllerProvider).isAuthenticated;
                      if (!isAuth) {
                        showAuthRequiredModal(
                          context,
                          featureName: 'Navegación GPS en Vivo',
                        );
                        return;
                      }
                      context.push('/live-trekking/${widget.routeUuid}', extra: route);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.cordilleraOchre,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.basaltInk, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.basaltInk,
                            offset: Offset(2.5, 2.5),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'INICIAR NAVEGACIÓN GPS EN VIVO',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                              letterSpacing: 0.6,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. TARJETA DE METADATOS TÉCNICOS DE LA RUTA
                  Container(
                    padding: const EdgeInsets.all(14),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricCol('Distancia', '${route?.distanceKm ?? 0} km', Icons.straighten_rounded, AppColors.yaretaPine),
                        _buildVerticalDivider(),
                        _buildMetricCol('Cota Máx', '${route?.maxAltitudeM ?? 4796} m', Icons.landscape_rounded, AppColors.cordilleraOchre),
                        _buildVerticalDivider(),
                        _buildMetricCol('Desnivel +D', '+${route?.elevationGainM.toInt() ?? 639} m', Icons.trending_up_rounded, AppColors.yaretaPine),
                        _buildVerticalDivider(),
                        _buildMetricCol('Dificultad', route?.difficultyDisplay ?? 'Fácil', Icons.speed_rounded, AppColors.basaltInk),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. PERFIL TOPOGRÁFICO Y ALTIMETRÍA DINÁMICA
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.basaltInk,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.basaltInk, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cordilleraOchre,
                          blurRadius: 0,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ALTURA Y SUBIDAS DEL CAMINO',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12.5, letterSpacing: 0.5),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Gráfico de elevación a lo largo de la ruta',
                                  style: TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.cordilleraOchre,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                (route?.difficultyDisplay ?? 'Trekking').toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Gráfico Altimétrico con puntos reales
                        SizedBox(
                          height: 130,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: _DynamicElevationPainter(
                              elevationPoints: elevationProfile,
                              minAltitude: (route?.minAltitudeM ?? 3371).toDouble(),
                              maxAltitude: (route?.maxAltitudeM ?? 4796).toDouble(),
                              totalDistance: route?.distanceKm ?? 21.32,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Inicio (${route?.minAltitudeM ?? 3371}m)', style: const TextStyle(color: Colors.white60, fontSize: 10.5)),
                            Text('Cota Máxima (${route?.maxAltitudeM ?? 4796}m)', style: const TextStyle(color: AppColors.cordilleraOchre, fontSize: 10.5, fontWeight: FontWeight.w800)),
                            Text('${route?.distanceKm ?? 0} km', style: const TextStyle(color: Colors.white60, fontSize: 10.5)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. SENSOR DE ALTITUD DEL USUARIO
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.basaltInk, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.yaretaPine.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.terrain_rounded, color: AppColors.yaretaPine, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ALTÍMETRO BAROMÉTRICO / GPS',
                                style: TextStyle(fontSize: 10, color: AppColors.graniteMuted, fontWeight: FontWeight.w800, letterSpacing: 0.6),
                              ),
                              Text(
                                _userAltitude != null
                                    ? '${_userAltitude!.toStringAsFixed(0)} m s.n.m.'
                                    : '3,450 m s.n.m. (Base Huachón)',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.basaltInk),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/safety'),
                          icon: const Icon(Icons.medical_services_outlined, size: 14),
                          label: const Text('PROTOCOLO'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.basaltInk,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLayerChip(String layerKey, String label) {
    final isSelected = _currentLayer == layerKey;
    return GestureDetector(
      onTap: () => setState(() => _currentLayer = layerKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cordilleraOchre : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 9.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  Widget _buildMapBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.basaltInk, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.basaltInk,
            offset: Offset(1.5, 1.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.basaltInk, size: 17),
        tooltip: tooltip,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
        onPressed: onTap,
      ),
    );
  }

  Widget _buildMetricCol(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 32, color: AppColors.border);
  }
}

/// Pintor dinámico de la altimetría basado en datos reales del GPX
class _DynamicElevationPainter extends CustomPainter {
  final List<Map<String, double>> elevationPoints;
  final double minAltitude;
  final double maxAltitude;
  final double totalDistance;

  _DynamicElevationPainter({
    required this.elevationPoints,
    required this.minAltitude,
    required this.maxAltitude,
    required this.totalDistance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveMin = minAltitude > 0 ? minAltitude : 3300.0;
    final effectiveMax = maxAltitude > effectiveMin ? maxAltitude : effectiveMin + 1400.0;
    final altSpan = effectiveMax - effectiveMin;

    final path = Path();
    final fillPath = Path();

    if (elevationPoints.length >= 2) {
      final maxDist = elevationPoints.last['distance_km'] ?? totalDistance;
      final effectiveDist = maxDist > 0 ? maxDist : 1.0;

      for (int i = 0; i < elevationPoints.length; i++) {
        final pt = elevationPoints[i];
        final d = pt['distance_km'] ?? 0.0;
        final a = pt['altitude_m'] ?? effectiveMin;

        final x = (d / effectiveDist) * size.width;
        final y = size.height - ((a - effectiveMin) / altSpan) * (size.height - 20) - 10;

        if (i == 0) {
          path.moveTo(x, y);
          fillPath.moveTo(x, size.height);
          fillPath.lineTo(x, y);
        } else {
          path.lineTo(x, y);
          fillPath.lineTo(x, y);
        }
      }
      fillPath.lineTo(size.width, size.height);
      fillPath.close();
    } else {
      // Perfil sintético estilizado si faltan muestras densas
      path.moveTo(0, size.height - 15);
      path.quadraticBezierTo(size.width * 0.4, size.height * 0.6, size.width * 0.7, size.height * 0.3);
      path.lineTo(size.width, 15);

      fillPath.moveTo(0, size.height);
      fillPath.lineTo(0, size.height - 15);
      fillPath.quadraticBezierTo(size.width * 0.4, size.height * 0.6, size.width * 0.7, size.height * 0.3);
      fillPath.lineTo(size.width, 15);
      fillPath.lineTo(size.width, size.height);
      fillPath.close();
    }

    // Gradiente de relleno
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.glacierTeal.withValues(alpha: 0.45),
          AppColors.glacierTeal.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Línea de perfil
    final strokePaint = Paint()
      ..color = AppColors.glacierTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _DynamicElevationPainter oldDelegate) {
    return oldDelegate.elevationPoints != elevationPoints;
  }
}
