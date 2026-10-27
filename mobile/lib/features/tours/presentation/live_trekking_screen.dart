import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/alpine_topographic_backdrop.dart';
import '../../../core/rust/rust_core_service.dart';
import '../../routes/domain/route_model.dart';
import '../../routes/presentation/routes_controller.dart';

/// Huaguruncho 360 · Interfaz 2.0 (Google Stitch)
/// "Alpine Field Instrument & Editorial Expedition Journal"
/// Pantalla de Navegación GPS en Vivo y Telemetría de Sendero
class LiveTrekkingScreen extends ConsumerStatefulWidget {
  final String routeUuid;
  final String routeName;
  final double totalDistanceKm;
  final int maxAltitudeM;
  final RouteModel? initialRoute;

  const LiveTrekkingScreen({
    super.key,
    required this.routeUuid,
    this.routeName = 'Camino al Nevado Huaguruncho',
    this.totalDistanceKm = 22.0,
    this.maxAltitudeM = 4796,
    this.initialRoute,
  });

  @override
  ConsumerState<LiveTrekkingScreen> createState() => _LiveTrekkingScreenState();
}

class _LiveTrekkingScreenState extends ConsumerState<LiveTrekkingScreen> {
  final MapController _mapController = MapController();
  String _currentLayer = 'topo'; // 'topo', 'satellite', 'osm'
  bool _showElevationDrawer = false;
  bool _followHiker = true;

  // GPS State
  double _currentLatitude = -10.55159;
  double _currentLongitude = -75.930389;
  double _currentAltitudeM = 4332.0;
  double _currentSpeedKmh = 3.8;
  double _distanceCoveredKm = 0.0;
  double _distanceToTrailM = 0.0; // Metros de desvío del sendero oficial
  double _currentHeading = 45.0;
  double _gpsAccuracyM = 3.2;

  bool _isOffTrailAlert = false; // > 50 metros
  bool _isUsingRealGps = false;
  StreamSubscription<Position>? _positionSubscription;

  // Track GPX por defecto para Huaguruncho si la ruta no tiene GPX cargado
  static final List<LatLng> _fallbackCoords = [
    const LatLng(-10.551590, -75.930389),
    const LatLng(-10.548910, -75.954120),
    const LatLng(-10.539800, -75.942000),
    const LatLng(-10.531200, -75.932400),
    const LatLng(-10.525500, -75.924000),
    const LatLng(-10.521800, -75.918900),
  ];

  @override
  void initState() {
    super.initState();
    _startGpsTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startGpsTracking() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.always || perm == LocationPermission.whileInUse) {
          _positionSubscription = Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 3,
            ),
          ).listen((pos) {
            if (!mounted) return;
            setState(() {
              _isUsingRealGps = true;
              _currentLatitude = pos.latitude;
              _currentLongitude = pos.longitude;
              if (pos.altitude > 0) {
                _currentAltitudeM = pos.altitude;
              }
              if (pos.accuracy > 0) {
                _gpsAccuracyM = pos.accuracy;
              }
              _currentSpeedKmh = (pos.speed * 3.6).clamp(0.0, 40.0);
              if (pos.heading >= 0) {
                _currentHeading = pos.heading;
              }
              _calculateCrossTrackDistance();
            });

            if (_followHiker) {
              _mapController.move(LatLng(_currentLatitude, _currentLongitude), _mapController.camera.zoom);
            }
          }, onError: (_) {});
          return;
        }
      }
    } catch (_) {}
  }

  void _calculateCrossTrackDistance() {
    final route = ref.read(routeDetailProvider(widget.routeUuid)).value ?? widget.initialRoute;
    final points = (route?.coordinates.isNotEmpty ?? false) ? route!.coordinates : _fallbackCoords;
    final totalDist = route?.distanceKm ?? widget.totalDistanceKm;
    final maxAlt = (route?.maxAltitudeM ?? widget.maxAltitudeM).toDouble();

    final telemetry = RustCoreService.instance.evaluateLiveTelemetry(
      currentLat: _currentLatitude,
      currentLon: _currentLongitude,
      currentAltM: _currentAltitudeM,
      maxAltM: maxAlt,
      totalDistanceKm: totalDist,
      trailLatLon: points.map((pt) => [pt.latitude, pt.longitude]).toList(),
    );

    _distanceToTrailM = telemetry.distanceToTrailM;
    _isOffTrailAlert = telemetry.isOffTrailAlert;

    if (points.isNotEmpty && !_isOffTrailAlert) {
      _distanceCoveredKm = telemetry.distanceCoveredKm;
    }
  }

  void _centerOnHiker() {
    HapticFeedback.selectionClick();
    setState(() => _followHiker = true);
    try {
      _mapController.move(
        LatLng(_currentLatitude, _currentLongitude),
        _mapController.camera.zoom < 14.5 ? 15.0 : _mapController.camera.zoom,
      );
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

  String _formatCardinalHeading(double deg) {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SO', 'O', 'NO'];
    final idx = ((deg % 360) / 45).round() % 8;
    return '${deg.toStringAsFixed(0).padLeft(3, '0')}° ${dirs[idx]}';
  }

  void _copyCoordinates() {
    final coordText = '${_currentLatitude.toStringAsFixed(5)}, ${_currentLongitude.toStringAsFixed(5)} (${_currentAltitudeM.toStringAsFixed(0)}m)';
    Clipboard.setData(ClipboardData(text: coordText));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.basaltInk,
          content: Text('Coordenadas satelitales copiadas al portapapeles.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeAsync = ref.watch(routeDetailProvider(widget.routeUuid));
    final route = routeAsync.value ?? widget.initialRoute;

    final routeName = route?.name ?? widget.routeName;
    final totalDistance = (route != null && route.distanceKm > 0) ? route.distanceKm : widget.totalDistanceKm;
    final maxAltitude = (route != null && route.maxAltitudeM > 0) ? route.maxAltitudeM : widget.maxAltitudeM;
    final points = (route?.coordinates.isNotEmpty ?? false) ? route!.coordinates : _fallbackCoords;

    final progressPercent = (totalDistance > 0 ? _distanceCoveredKm / totalDistance : 0.0).clamp(0.0, 1.0);
    final distanceRemainingKm = (totalDistance - _distanceCoveredKm).clamp(0.0, totalDistance);

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
              child: Icon(
                Icons.explore_outlined,
                size: 16,
                color: _isOffTrailAlert ? AppColors.error : AppColors.cordilleraOchre,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isUsingRealGps ? AppColors.yaretaPine : AppColors.cordilleraOchre,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          _isUsingRealGps
                              ? 'NAVEGACIÓN GPS EN VIVO · SATELITAL'
                              : 'NAVEGACIÓN GPS EN VIVO · MODO CAMPO',
                          style: TextStyle(
                            color: _isUsingRealGps ? AppColors.yaretaPine : AppColors.cordilleraOchre,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    routeName,
                    style: const TextStyle(
                      color: AppColors.basaltInk,
                      fontSize: 13.5,
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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => context.push('/emergency-sos'),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.error,
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sos_rounded, color: Colors.white, size: 15),
                    SizedBox(width: 4),
                    Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
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
      ),
      body: Column(
        children: [
          // 0. BARRA DE TELEMETRÍA SATELITAL Y COORDENADAS (STITCH 2.0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: const BoxDecoration(
              color: AppColors.basaltInk,
              border: Border(
                bottom: BorderSide(color: AppColors.glacialBorder, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: GestureDetector(
                    onTap: _copyCoordinates,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.satellite_alt_rounded,
                          size: 12,
                          color: AppColors.cordilleraOchre,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'LAT ${_currentLatitude.toStringAsFixed(4)}° · LON ${_currentLongitude.toStringAsFixed(4)}° (±${_gpsAccuracyM.toStringAsFixed(1)}m)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.explore_rounded, size: 10, color: AppColors.cordilleraOchre),
                      const SizedBox(width: 4),
                      Text(
                        _formatCardinalHeading(_currentHeading),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Banner de Alerta de Desvío de Sendero Oficial (>50 metros)
          if (_isOffTrailAlert)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.crimsonAlertLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error, width: 1.5),
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
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ALERTA DE DESVÍO DE SENDERO (>50M)',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Desvío actual: ${_distanceToTrailM.toStringAsFixed(1)} m del eje oficial. Retorna al vector demarcado.',
                          style: const TextStyle(
                            color: AppColors.basaltInk,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // 1. ÁREA DE MAPA INTERACTIVO TÁCTICO 2.0
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: AppColors.basaltInk,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isOffTrailAlert ? AppColors.error : AppColors.basaltInk,
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.basaltInk,
                    offset: Offset(2.5, 2.5),
                    blurRadius: 0,
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
                      initialCenter: LatLng(_currentLatitude, _currentLongitude),
                      initialZoom: 14.5,
                      minZoom: 4.0,
                      maxZoom: 18.0,
                      initialCameraFit: points.isNotEmpty
                          ? CameraFit.bounds(
                              bounds: LatLngBounds.fromPoints(points),
                              padding: const EdgeInsets.all(48),
                            )
                          : null,
                    ),
                    children: [
                      // Capa Cartográfica
                      TileLayer(
                        urlTemplate: _getTileUrl(),
                        fallbackUrl: _getFallbackTileUrl(),
                        userAgentPackageName: 'pe.gob.huachon.huaguruncho_360',
                        maxZoom: 19,
                        evictErrorTileStrategy: EvictErrorTileStrategy.dispose,
                      ),

                      // Trazo GPX Polyline
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

                      // Marcadores Inicio, Meta y Senderista
                      MarkerLayer(
                        markers: [
                          // Marcador Inicio
                          Marker(
                            point: startPoint,
                            width: 84,
                            height: 55,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.yaretaPine,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.white, width: 1.2),
                                  ),
                                  child: const Text(
                                    'INICIO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.location_on, color: AppColors.yaretaPine, size: 20),
                              ],
                            ),
                          ),

                          // Marcador Meta
                          Marker(
                            point: endPoint,
                            width: 84,
                            height: 55,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.cordilleraOchre,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.white, width: 1.2),
                                  ),
                                  child: const Text(
                                    'CUMBRE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.flag_rounded, color: AppColors.cordilleraOchre, size: 20),
                              ],
                            ),
                          ),

                          // Marcador Senderista GPS con Aro de Precisión 2.0
                          Marker(
                            point: LatLng(_currentLatitude, _currentLongitude),
                            width: 46,
                            height: 46,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (_isOffTrailAlert ? AppColors.error : AppColors.cordilleraOchre)
                                        .withValues(alpha: 0.25),
                                    border: Border.all(
                                      color: (_isOffTrailAlert ? AppColors.error : AppColors.cordilleraOchre)
                                          .withValues(alpha: 0.6),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isOffTrailAlert ? AppColors.error : AppColors.cordilleraOchre,
                                    border: Border.all(color: AppColors.pureWhite, width: 2.5),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: AppColors.basaltInk,
                                        offset: Offset(1, 1),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Transform.rotate(
                                    angle: _currentHeading * (math.pi / 180.0),
                                    child: const Icon(Icons.navigation, color: Colors.white, size: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // HUD Superior Izquierdo: Estado Vectorial + Selector Rápido de Capas
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.basaltInk.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _isOffTrailAlert ? AppColors.error : Colors.white24,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.gps_fixed_rounded,
                                color: _isOffTrailAlert ? AppColors.error : AppColors.cordilleraOchre,
                                size: 13,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isOffTrailAlert
                                    ? 'DESVÍO (${_distanceToTrailM.toStringAsFixed(0)}M)'
                                    : 'VECTOR EN RUTA OFICIAL',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Selector de Capas Cartográficas 2.0
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: AppColors.pureWhite.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.basaltInk, width: 1.2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildLayerPill('topo', 'TOPO'),
                              _buildLayerPill('satellite', 'SAT'),
                              _buildLayerPill('osm', 'MAPA'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Controles Tácticos Flotantes Derecha (HUD 2.0)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFloatingBtn(
                          icon: _followHiker ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
                          isActive: _followHiker,
                          tooltip: 'Seguir Mi Posición',
                          onTap: () {
                            setState(() => _followHiker = !_followHiker);
                            _mapController.move(LatLng(_currentLatitude, _currentLongitude), 15.0);
                          },
                        ),
                        const SizedBox(height: 6),
                        _buildFloatingBtn(
                          icon: Icons.crop_free_rounded,
                          tooltip: 'Encuadrar Ruta Completa',
                          onTap: () {
                            setState(() => _followHiker = false);
                            _fitTrailBounds(points);
                          },
                        ),
                        const SizedBox(height: 6),
                        _buildFloatingBtn(
                          icon: Icons.terrain_rounded,
                          isActive: _showElevationDrawer,
                          tooltip: 'Perfil Altimétrico en Vivo',
                          onTap: () => setState(() => _showElevationDrawer = !_showElevationDrawer),
                        ),
                        const SizedBox(height: 6),
                        _buildFloatingBtn(
                          icon: Icons.layers_outlined,
                          tooltip: 'Alternar Capa Cartográfica',
                          onTap: _cycleMapLayer,
                        ),
                      ],
                    ),
                  ),

                  // Drawer Altimétrico Flotante Inferior (Diseño 2.0 sobre tarjeta sólida)
                  if (_showElevationDrawer)
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.show_chart_rounded, size: 14, color: AppColors.cordilleraOchre),
                                    SizedBox(width: 5),
                                    Text(
                                      'CORTE TOPOGRÁFICO EN TIEMPO REAL',
                                      style: TextStyle(
                                        color: AppColors.basaltInk,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => _showElevationDrawer = false),
                                  child: const Icon(Icons.close_rounded, color: AppColors.basaltInk, size: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 58,
                              width: double.infinity,
                              child: CustomPaint(
                                painter: _LiveElevationMiniPainter(
                                  elevationPoints: elevationProfile,
                                  currentDistanceKm: _distanceCoveredKm,
                                  totalDistanceKm: totalDistance,
                                  minAlt: (route?.minAltitudeM ?? 3371).toDouble(),
                                  maxAlt: maxAltitude.toDouble(),
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

          // 2. CONSOLA DE INSTRUMENTACIÓN DE CAMPO 2.0 (INFERIOR)
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: const BoxDecoration(
              color: AppColors.pureWhite,
              border: Border(
                top: BorderSide(color: AppColors.basaltInk, width: 1.5),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cabecera de Progreso GPX + Botón Mecánico de Simulación (Sin emojis)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.basaltInk,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: const Text(
                                '01',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'TRACK GPX: ${_distanceCoveredKm.toStringAsFixed(1)} / ${totalDistance.toStringAsFixed(1)} KM (${(progressPercent * 100).toStringAsFixed(0)}%)',
                                style: const TextStyle(
                                  color: AppColors.basaltInk,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _centerOnHiker,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _followHiker ? AppColors.yaretaPine : AppColors.alpineChalk,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.basaltInk, width: 1.2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.my_location_rounded,
                                size: 12,
                                color: _followHiker ? Colors.white : AppColors.cordilleraOchre,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'CENTRAR GPS',
                                style: TextStyle(
                                  color: _followHiker ? Colors.white : AppColors.basaltInk,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Barra de Progreso Táctica con Borde Mineral
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.alpineChalk,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: AppColors.basaltInk, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        minHeight: 5,
                        backgroundColor: AppColors.glacialBorder,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isOffTrailAlert ? AppColors.error : AppColors.cordilleraOchre,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Rejilla de 4 Métricas de Telemetría Senderista 2.0
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          label: 'Altitud Actual',
                          value: '${_currentAltitudeM.toStringAsFixed(0)} m',
                          subtext: 'Cumbre: $maxAltitude m',
                          icon: Icons.landscape_rounded,
                          accentColor: AppColors.cordilleraOchre,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricTile(
                          label: 'Distancia Faltante',
                          value: '${distanceRemainingKm.toStringAsFixed(1)} km',
                          subtext: 'Paso: ${_currentSpeedKmh.toStringAsFixed(1)} km/h',
                          icon: Icons.flag_rounded,
                          accentColor: AppColors.basaltInk,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          label: 'Desvío Sendero',
                          value: '${_distanceToTrailM.toStringAsFixed(0)} m',
                          subtext: _isOffTrailAlert ? 'Fuera de trazo' : 'Vector nominal',
                          icon: Icons.alt_route_rounded,
                          accentColor: _isOffTrailAlert ? AppColors.error : AppColors.yaretaPine,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricTile(
                          label: 'Desnivel +D',
                          value: '+${route?.elevationGainM.toInt() ?? 639} m',
                          subtext: 'Capa: ${_currentLayer.toUpperCase()}',
                          icon: Icons.trending_up_rounded,
                          accentColor: AppColors.yaretaPine,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Acciones Rápidas de Campo (Eco-Reporte + Visor 360°)
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => context.push('/create-report?routeUuid=${widget.routeUuid}'),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppColors.alpineChalk,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.basaltInk, width: 1.2),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_outlined, size: 14, color: AppColors.cordilleraOchre),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'REPORTAR INCIDENCIA',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.basaltInk,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.4,
                                    ),
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
                          onTap: () => context.push('/routes/${widget.routeUuid}/tour-360'),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppColors.basaltInk,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.basaltInk, width: 1.2),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.view_in_ar_rounded, size: 14, color: AppColors.cordilleraOchre),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'MIRADORES 360°',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.4,
                                    ),
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
          ),
        ],
      ),
    );
  }

  void _cycleMapLayer() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_currentLayer == 'topo') {
        _currentLayer = 'satellite';
      } else if (_currentLayer == 'satellite') {
        _currentLayer = 'osm';
      } else {
        _currentLayer = 'topo';
      }
    });
  }

  Widget _buildLayerPill(String layerKey, String label) {
    final isSelected = _currentLayer == layerKey;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _currentLayer = layerKey);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.basaltInk : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.basaltInk,
            fontSize: 8.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? AppColors.cordilleraOchre : AppColors.pureWhite.withValues(alpha: 0.95),
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
        icon: Icon(
          icon,
          color: isActive ? Colors.white : AppColors.basaltInk,
          size: 17,
        ),
        tooltip: tooltip,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
        onPressed: onTap,
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String subtext,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.alpineChalk,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.basaltInk, width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1814171A),
            offset: Offset(1.5, 1.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.glacialBorder, width: 1),
            ),
            child: Icon(icon, color: accentColor, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.graniteMuted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accentColor == AppColors.error ? AppColors.error : AppColors.basaltInk,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  subtext,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.graniteMuted,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pintor mini de altimetría 2.0 con marcador de posición del senderista
class _LiveElevationMiniPainter extends CustomPainter {
  final List<Map<String, double>> elevationPoints;
  final double currentDistanceKm;
  final double totalDistanceKm;
  final double minAlt;
  final double maxAlt;

  _LiveElevationMiniPainter({
    required this.elevationPoints,
    required this.currentDistanceKm,
    required this.totalDistanceKm,
    required this.minAlt,
    required this.maxAlt,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.glacialBorder
      ..strokeWidth = 0.8;

    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), gridPaint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), gridPaint);

    final effectiveMin = minAlt > 0 ? minAlt : 3300.0;
    final effectiveMax = maxAlt > effectiveMin ? maxAlt : effectiveMin + 1400.0;
    final altSpan = effectiveMax - effectiveMin;

    final path = Path();
    final fillPath = Path();

    if (elevationPoints.length >= 2) {
      final maxDist = elevationPoints.last['distance_km'] ?? totalDistanceKm;
      final effectiveDist = maxDist > 0 ? maxDist : 1.0;

      for (int i = 0; i < elevationPoints.length; i++) {
        final pt = elevationPoints[i];
        final d = pt['distance_km'] ?? 0.0;
        final a = pt['altitude_m'] ?? effectiveMin;

        final x = (d / effectiveDist) * size.width;
        final y = size.height - ((a - effectiveMin) / altSpan) * (size.height - 10) - 5;

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
      path.moveTo(0, size.height - 10);
      path.quadraticBezierTo(size.width * 0.4, size.height * 0.5, size.width, 10);
      fillPath.moveTo(0, size.height);
      fillPath.lineTo(0, size.height - 10);
      fillPath.quadraticBezierTo(size.width * 0.4, size.height * 0.5, size.width, 10);
      fillPath.lineTo(size.width, size.height);
      fillPath.close();
    }

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
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    canvas.drawPath(path, strokePaint);

    // Marcador actual del senderista sobre la altimetría
    final progress = (totalDistanceKm > 0 ? currentDistanceKm / totalDistanceKm : 0.0).clamp(0.0, 1.0);
    final markerX = progress * size.width;
    final markerY = size.height * (0.85 - 0.65 * progress);

    final borderPaint = Paint()..color = AppColors.basaltInk;
    final dotPaint = Paint()..color = AppColors.cordilleraOchre;
    canvas.drawCircle(Offset(markerX, markerY), 5.5, borderPaint);
    canvas.drawCircle(Offset(markerX, markerY), 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _LiveElevationMiniPainter oldDelegate) {
    return oldDelegate.currentDistanceKm != currentDistanceKm;
  }
}
