import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import 'reports_controller.dart';

class CreateReportScreen extends ConsumerStatefulWidget {
  final String? routeUuid;

  const CreateReportScreen({super.key, this.routeUuid});

  @override
  ConsumerState<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();

  String _selectedCategory = 'basura';
  String? _selectedImagePath;
  double? _latitude;
  double? _longitude;
  double? _accuracy;
  bool _isLocating = false;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _categories = const [
    {'value': 'basura', 'label': 'RESIDUOS SÓLIDOS', 'icon': Icons.delete_outline_rounded},
    {'value': 'incendio', 'label': 'FOCO DE FUEGO / QUEMA', 'icon': Icons.local_fire_department_rounded},
    {'value': 'accidente', 'label': 'ACCIDENTE / EMERGENCIA', 'icon': Icons.medical_services_rounded},
    {'value': 'senalizacion_danada', 'label': 'SEÑALÉTICA DAÑADA', 'icon': Icons.signpost_rounded},
    {'value': 'flora_fauna_afectada', 'label': 'FLORA / FAUNA VULNERABLE', 'icon': Icons.nature_people_rounded},
    {'value': 'otro', 'label': 'OTRO INCIDENTE', 'icon': Icons.report_problem_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _fetchGpsLocation();
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _fetchGpsLocation() async {
    setState(() {
      _isLocating = true;
    });

    final locService = ref.read(locationServiceProvider);
    final result = await locService.getCurrentLocation();

    if (mounted) {
      setState(() {
        _isLocating = false;
        if (result != null) {
          _latitude = result.latitude;
          _longitude = result.longitude;
          _accuracy = result.accuracy;
        }
      });
    }
  }

  Future<void> _takePhoto() async {
    final cameraService = ref.read(cameraServiceProvider);
    final path = await cameraService.takePhoto();
    if (path != null && mounted) {
      setState(() {
        _selectedImagePath = path;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final cameraService = ref.read(cameraServiceProvider);
    final path = await cameraService.pickFromGallery();
    if (path != null && mounted) {
      setState(() {
        _selectedImagePath = path;
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final repo = ref.read(reportsRepositoryProvider);
      await repo.createReport(
        category: _selectedCategory,
        description: _descController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        accuracyMeters: _accuracy,
        tempImagePath: _selectedImagePath,
        routeUuid: widget.routeUuid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Eco-Reporte registrado en memoria local! Se sincronizará automáticamente al detectar red.'),
            backgroundColor: AppColors.yaretaPine,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alpineChalk,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ACTA DE INCIDENCIA AMBIENTAL',
              style: TextStyle(
                color: AppColors.basaltInk,
                fontWeight: FontWeight.w900,
                fontSize: 14.5,
                letterSpacing: 0.4,
              ),
            ),
            Text(
              'PROTOCOLO SERNANP · MEMORIA OFFLINE',
              style: TextStyle(
                color: AppColors.graniteMuted,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Sello de Almacenamiento Autónomo
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.basaltInk,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.yaretaPine, width: 1.5),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.satellite_alt_rounded, color: Color(0xFF6EE7B7), size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'MODO AUTÓNOMO ACTIVO: Esta acta se cifra en SQLite local con coordenadas satelitales y se despacha al puesto de Huachón al recuperar señal.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 2. Tipología del Incidente
                const Text(
                  '01 // TIPOLOGÍA DEL INCIDENTE AMBIENTAL *',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.basaltInk,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((c) {
                    final isSelected = _selectedCategory == c['value'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = c['value'] as String;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.basaltInk : AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.cordilleraOchre : AppColors.basaltInk,
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? const [
                                  BoxShadow(
                                    color: AppColors.cordilleraOchre,
                                    offset: Offset(2, 2),
                                    blurRadius: 0,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              c['icon'] as IconData,
                              size: 14,
                              color: isSelected ? AppColors.cordilleraOchre : AppColors.basaltInk,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              c['label'] as String,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: isSelected ? Colors.white : AppColors.basaltInk,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 18),

                // 3. Descripción Técnica del Hallazgo
                const Text(
                  '02 // DESCRIPCIÓN TÉCNICA DEL HALLAZGO *',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.basaltInk,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.basaltInk),
                  decoration: InputDecoration(
                    hintText: 'Detalla la magnitud del impacto, hitos cercanos o requerimiento de intervención...',
                    fillColor: AppColors.pureWhite,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.basaltInk),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.basaltInk),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Ingresa una descripción del incidente';
                    }
                    if (val.trim().length < 5) {
                      return 'La descripción debe tener al menos 5 caracteres';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // 4. Telemetría GPS Satelital
                const Text(
                  '03 // UBICACIÓN GPS DEL LUGAR',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.basaltInk,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.basaltInk, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: _latitude != null ? AppColors.yaretaPine : AppColors.cordilleraOchre,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _latitude != null ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _isLocating
                            ? const Text(
                                'Adquiriendo efemérides satelitales GPS...',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.basaltInk),
                              )
                            : _latitude != null
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'LAT ${_latitude!.toStringAsFixed(5)} · LNG ${_longitude!.toStringAsFixed(5)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.basaltInk,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'PRECISIÓN: ±${_accuracy?.toStringAsFixed(1) ?? "?"} M (SEÑAL FIJADA)',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.yaretaPine,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'Sin fijación GPS activa. Pulsa recalibrar.',
                                    style: TextStyle(fontSize: 12, color: AppColors.graniteMuted),
                                  ),
                      ),
                      IconButton(
                        icon: _isLocating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cordilleraOchre),
                              )
                            : const Icon(Icons.refresh_rounded, color: AppColors.basaltInk),
                        tooltip: 'Recalibrar GPS',
                        onPressed: _isLocating ? null : _fetchGpsLocation,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 5. Evidencia Fotográfica de Campo
                const Text(
                  '04 // REGISTRO FOTOGRÁFICO DE CAMPO',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.basaltInk,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
                if (_selectedImagePath != null) ...[
                  Container(
                    height: 190,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.basaltInk, width: 1.5),
                      image: DecorationImage(
                        image: FileImage(File(_selectedImagePath!)),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 10,
                          right: 10,
                          child: InkWell(
                            onTap: () => setState(() => _selectedImagePath = null),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.basaltInk,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.yaretaPine,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'CAPTURA ADJUNTADA',
                              style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _takePhoto,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: AppColors.pureWhite,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.basaltInk, width: 1.2),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_outlined, size: 16, color: AppColors.cordilleraOchre),
                                SizedBox(width: 6),
                                Text(
                                  'CÁMARA',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.basaltInk,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: _pickFromGallery,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: AppColors.pureWhite,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.basaltInk, width: 1.2),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo_library_outlined, size: 16, color: AppColors.basaltInk),
                                SizedBox(width: 6),
                                Text(
                                  'GALERÍA',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.basaltInk,
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

                const SizedBox(height: 26),

                // 6. Botón Táctico de Sellado de Acta
                InkWell(
                  onTap: _isSaving ? null : _submitReport,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: AppColors.cordilleraOchre,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.basaltInk, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.basaltInk,
                          offset: Offset(2.5, 2.5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isSaving)
                          const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        else ...[
                          const Icon(Icons.verified_outlined, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'SELLAR Y GUARDAR ACTA AMBIENTAL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
