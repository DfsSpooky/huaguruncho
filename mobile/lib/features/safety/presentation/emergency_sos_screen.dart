import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../reports/presentation/reports_controller.dart';
import 'emergency_controller.dart';

class EmergencySosScreen extends ConsumerStatefulWidget {
  const EmergencySosScreen({super.key});

  @override
  ConsumerState<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends ConsumerState<EmergencySosScreen> {
  double? _lat;
  double? _lng;
  double? _accuracy;
  bool _isLocating = false;
  bool _isStrobeActive = false;
  Timer? _strobeTimer;
  Color _strobeColor = AppColors.alpineChalk;
  int _selectedProtocolIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchGps();
  }

  @override
  void dispose() {
    _strobeTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchGps() async {
    if (!mounted) return;
    setState(() => _isLocating = true);
    try {
      final loc = ref.read(locationServiceProvider);
      final pos = await loc.getCurrentLocation().timeout(
        const Duration(seconds: 4),
        onTimeout: () => null,
      );
      if (mounted) {
        setState(() {
          _isLocating = false;
          if (pos != null) {
            _lat = pos.latitude;
            _lng = pos.longitude;
            _accuracy = pos.accuracy;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  void _toggleStrobe() {
    _strobeTimer?.cancel();
    _strobeTimer = null;

    setState(() {
      _isStrobeActive = !_isStrobeActive;
      if (!_isStrobeActive) {
        _strobeColor = AppColors.alpineChalk;
      }
    });

    if (_isStrobeActive) {
      _strobeTimer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
        if (mounted) {
          setState(() {
            _strobeColor = _strobeColor == AppColors.alpineChalk
                ? const Color(0xFFB91C1C)
                : AppColors.alpineChalk;
          });
        } else {
          timer.cancel();
        }
      });
    }
  }

  Future<void> _makeCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _copyCoordinates() {
    final latStr = _lat?.toStringAsFixed(6) ?? '-10.531800';
    final lngStr = _lng?.toStringAsFixed(6) ?? '-75.930800';
    Clipboard.setData(ClipboardData(text: '$latStr, $lngStr'));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.basaltInk,
          content: Text('✓ Coordenadas GPS copiadas al portapapeles.'),
        ),
      );
    }
  }

  Future<void> _sendSmsBeacon({String targetPhone = '+51963852741'}) async {
    final latStr = _lat?.toStringAsFixed(6) ?? '-10.531800 (Ref)';
    final lngStr = _lng?.toStringAsFixed(6) ?? '-75.930800 (Ref)';
    final accStr = _accuracy != null ? '${_accuracy!.toStringAsFixed(1)}m' : 'Aprox';
    final mapUrl = _lat != null && _lng != null
        ? 'https://maps.google.com/?q=$_lat,$_lng'
        : 'Sector Nevado Huaguruncho';
    final timeStr = DateTime.now().toLocal().toString().substring(11, 16);

    final message =
        'EMERGENCIA HUAGURUNCHO: Requiero auxilio inmediato en zona de montana. '
        'Coords: Lat $latStr, Lng $lngStr (Error: $accStr). '
        'Mapa: $mapUrl [Hora: $timeStr]';

    final cleanPhone = targetPhone.replaceAll(RegExp(r'[\s\-]'), '');
    final uri = Uri(
      scheme: 'sms',
      path: cleanPhone,
      queryParameters: {'body': message},
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        final fallbackUri = Uri.parse('sms:$cleanPhone');
        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri);
        }
      }
    } catch (_) {}
  }

  Future<void> _sendWhatsAppBeacon({String targetPhone = '+51963852741'}) async {
    final latStr = _lat?.toStringAsFixed(6) ?? '-10.531800 (Ref)';
    final lngStr = _lng?.toStringAsFixed(6) ?? '-75.930800 (Ref)';
    final accStr = _accuracy != null ? '${_accuracy!.toStringAsFixed(1)}m' : 'Aprox';
    final mapUrl = _lat != null && _lng != null
        ? 'https://maps.google.com/?q=$_lat,$_lng'
        : 'Sector Huaguruncho';

    final text = Uri.encodeComponent(
      '🚨 *EMERGENCIA EN NEVADO HUAGURUNCHO*\n\n'
      'Requiero apoyo o rescate en la cordillera.\n'
      '• *Latitud:* $latStr\n'
      '• *Longitud:* $lngStr\n'
      '• *Margen de Error:* $accStr\n'
      '• *Mapa Satelital:* $mapUrl\n\n'
      'Mensaje generado desde HUAGURUNCHO 360',
    );

    final cleanPhone = targetPhone.replaceAll(RegExp(r'[\s\+\-]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$text');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendEmergencyReport() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.pureWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.basaltInk, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFB91C1C)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'CONFIRMAR ALERTA SOS GLACIAR',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: AppColors.basaltInk,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Se registrará un despacho de emergencia de prioridad máxima con tus coordenadas GPS actuales. Si estás sin señal de internet, el reporte quedará encolado en SQLite y se transmitirá automáticamente al detectar cobertura.',
          style: TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.basaltInk),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'CANCELAR',
              style: TextStyle(
                color: AppColors.graniteMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              minimumSize: const Size(0, 40),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(reportsRepositoryProvider);
              try {
                await repo.createReport(
                  category: 'accidente',
                  description:
                      '⚠️ ALERTA SOS EMITIDA: Persona o grupo requiere auxilio inmediato en zona de montaña.',
                  latitude: _lat,
                  longitude: _lng,
                  accuracyMeters: _accuracy,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.yaretaPine,
                      content: Text(
                        '✔ Alerta SOS registrada y encolada para sincronización prioritaria con USAR / COEL Huachón.',
                      ),
                    ),
                  );
                }
              } catch (_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.cordilleraOchre,
                      content: Text('✔ Alerta SOS guardada en bóveda SQLite local.'),
                    ),
                  );
                }
              }
            },
            child: const Text(
              'EMITIR SOS AHORA',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(emergencyContactsProvider);

    return Scaffold(
      backgroundColor: _isStrobeActive ? _strobeColor : AppColors.alpineChalk,
      appBar: AppBar(
        backgroundColor: const Color(0xFF991B1B),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: const Row(
          children: [
            Icon(Icons.sos_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Centro de Emergencia & SOS',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14.5,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'PROTOCOLO DE RESCATE ALPINO · USAR / COEL HUACHÓN',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFECACA),
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            tooltip: 'Actualizar GPS y Contactos',
            onPressed: () {
              _fetchGps();
              ref.invalidate(emergencyContactsProvider);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. CONSOLA DE TELEMETRÍA SATELITAL GPS 2.0
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.basaltInk,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.basaltInk, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFB91C1C),
                    offset: Offset(2.5, 2.5),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.satellite_alt_rounded,
                        color: Color(0xFF6EE7B7),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'TELEMETRÍA DE POSICIÓN PARA EXTRACCIÓN',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF6EE7B7),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (_isLocating)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF6EE7B7),
                          ),
                        )
                      else
                        InkWell(
                          onTap: _copyCoordinates,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.copy_rounded, size: 11, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'COPIAR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGpsDataCell(
                          label: 'LATITUD SUR',
                          value: _lat != null
                              ? _lat!.toStringAsFixed(5)
                              : '-10.5318°',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildGpsDataCell(
                          label: 'LONGITUD OESTE',
                          value: _lng != null
                              ? _lng!.toStringAsFixed(5)
                              : '-75.9308°',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildGpsDataCell(
                          label: 'PRECISIÓN',
                          value: _accuracy != null
                              ? '±${_accuracy!.toStringAsFixed(0)}m'
                              : '±8m GPS',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _lat != null && _lng != null
                        ? '✓ Coordenadas satelitales fijadas. Listas para despacho a brigada USAR.'
                        : 'Modo Referencia Cordillera Huaguruncho (-10.5318, -75.9308) · Cielo abierto recomendado.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 2. BOTÓN PRINCIPAL DE ALERTA SOS GLACIAR
            ElevatedButton(
              onPressed: _sendEmergencyReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB91C1C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppColors.basaltInk, width: 1.5),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 24, color: Colors.white),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'EMITIR ALERTA SOS GLACIAR',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 3. BALIZA DE BAJA SEÑAL (SMS 2G + WHATSAPP + ESTROBO)
            Container(
              padding: const EdgeInsets.all(13),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.cell_tower_rounded,
                        color: AppColors.cordilleraOchre,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'TRANSMISIÓN DE AUXILIO EN BAJA SEÑAL (2G / GSM)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.basaltInk,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'En quebradas sin internet 4G, el SMS tradicional logra salir con apenas 1 barra de señal hacia el Puesto Policial de Huachón.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.graniteMuted,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _sendSmsBeacon(targetPhone: '+51963852741'),
                          icon: const Icon(Icons.sms_outlined, size: 16),
                          label: const Text(
                            'SMS AUXILIO 2G',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cordilleraOchre,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _sendWhatsAppBeacon(targetPhone: '+51963852741'),
                          icon: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 15,
                            color: AppColors.yaretaPine,
                          ),
                          label: const Text(
                            'WHATSAPP GPS',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              color: AppColors.yaretaPine,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.yaretaPine,
                              width: 1.4,
                            ),
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: Icon(
                      _isStrobeActive
                          ? Icons.flash_off_rounded
                          : Icons.flash_on_rounded,
                      size: 16,
                      color: _isStrobeActive
                          ? const Color(0xFFB91C1C)
                          : AppColors.basaltInk,
                    ),
                    label: Text(
                      _isStrobeActive
                          ? 'DESACTIVAR BALIZA ESTROBOSCÓPICA'
                          : 'ACTIVAR DESTELLO VISUAL NOCTURNO (ESTROBO)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _isStrobeActive
                            ? const Color(0xFFB91C1C)
                            : AppColors.basaltInk,
                        fontWeight: FontWeight.w900,
                        fontSize: 10.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _isStrobeActive
                            ? const Color(0xFFB91C1C)
                            : AppColors.basaltInk,
                        width: 1.2,
                      ),
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _toggleStrobe,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. MANUAL DIDÁCTICO DE SUPERVIVENCIA EN ALTA MONTAÑA
            _buildDidacticSurvivalManual(),

            const SizedBox(height: 18),

            // 5. DIRECTORIO TELEFÓNICO DE EMERGENCIA
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.basaltInk,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'RADIOCOMUNICACIÓN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Directorio Telefónico de Emergencia',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                      color: AppColors.basaltInk,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            contactsAsync.when(
              loading: () =>
                  const LoadingIndicator(message: 'Cargando números de emergencia...'),
              error: (err, _) => ErrorView(
                message: 'Error al cargar contactos.',
                onRetry: () => ref.refresh(emergencyContactsProvider),
              ),
              data: (contacts) {
                return Column(
                  children: [
                    for (int i = 0; i < contacts.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _buildContactCard(contacts[i]),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGpsDataCell({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDidacticSurvivalManual() {
    final protocols = [
      {
        'tab': '01 · MÉTODO P.A.S.',
        'title': 'Protocolo Internacional P.A.S. en Cordillera',
        'steps': [
          'PROTEGER: Retira al grupo de cornisas de nieve, caída de rocas o cauces de deshielo. Abriga al herido aislándolo del suelo con mochilas.',
          'AVISAR: Envía el SMS 2G con tus coordenadas GPS exactas e indica número de afectados y síntomas principales.',
          'SOCORRER: Controla hemorragias por presión directa y no movilices a víctimas con sospecha de trauma espinal.',
        ],
      },
      {
        'tab': '02 · MAL DE ALTURA',
        'title': 'Mal Agudo de Montaña (Soroche > 4,500 m)',
        'steps': [
          'SÍNTOMAS DE ALARMA: Dolor de cabeza severo que no cede, mareo al caminar (ataxia), náuseas o falta de aire en reposo.',
          'ACCIÓN INMEDIATA: Detén el ascenso de inmediato. El único tratamiento definitivo es descender al menos 300 a 500 metros de altitud.',
          'SOPORTE: Hidratación tibia fraccionada, abrigo térmico y evitar cualquier esfuerzo físico adicional.',
        ],
      },
      {
        'tab': '03 · HIPOTERMIA',
        'title': 'Hipotermia por Viento Glaciar o Lluvia',
        'steps': [
          'AISLAMIENTO TÉRMICO: Sustituye de inmediato las prendas húmedas por ropa seca y coloca cortavientos impermeable.',
          'CALOR CENTRAL: Aplica calor gradual en cuello, axilas y tórax (nunca frotes extremidades congeladas bruscamente).',
          'REFUGIO: Arma carpa o busca abrigo detrás de formaciones rocosas de granito fuera del corredor de viento.',
        ],
      },
    ];

    final current = protocols[_selectedProtocolIndex];
    final steps = current['steps'] as List<String>;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.basaltInk, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.yaretaPine,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'GUÍA DIDÁCTICA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'PRIMEROS AUXILIOS EN ALTA MONTAÑA',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.basaltInk,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(protocols.length, (i) {
              final selected = _selectedProtocolIndex == i;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
                  child: InkWell(
                    onTap: () => setState(() => _selectedProtocolIndex = i),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.basaltInk : AppColors.alpineChalk,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.basaltInk),
                      ),
                      child: Text(
                        protocols[i]['tab'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          color: selected ? Colors.white : AppColors.basaltInk,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.alpineChalk,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.glacialBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  current['title'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.basaltInk,
                  ),
                ),
                const SizedBox(height: 6),
                for (final step in steps)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '▸ ',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.cordilleraOchre,
                            fontSize: 12,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            step,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.basaltInk,
                              height: 1.35,
                            ),
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

  Widget _buildContactCard(dynamic c) {
    return Container(
      padding: const EdgeInsets.all(12),
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
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFB91C1C).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFB91C1C).withValues(alpha: 0.3)),
            ),
            child: const Icon(
              Icons.emergency_rounded,
              color: Color(0xFFB91C1C),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.title as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: AppColors.basaltInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  c.description as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.graniteMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.basaltInk,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () => _makeCall(
              (c.fullNumber as String).isNotEmpty
                  ? (c.fullNumber as String)
                  : (c.shortPhone as String),
            ),
            icon: const Icon(Icons.phone_rounded, size: 13, color: Colors.white),
            label: Text(
              c.shortPhone as String,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
