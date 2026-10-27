import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/sync/sync_controller.dart';
import '../../auth/presentation/auth_controller.dart';

class TrekkingChecklistScreen extends ConsumerStatefulWidget {
  const TrekkingChecklistScreen({super.key});

  @override
  ConsumerState<TrekkingChecklistScreen> createState() =>
      _TrekkingChecklistScreenState();
}

class _TrekkingChecklistScreenState extends ConsumerState<TrekkingChecklistScreen> {
  final List<Map<String, dynamic>> _checklist = [
    {
      'category': '01 · SISTEMA DE VESTIMENTA EN 3 CAPAS',
      'subtitle':
          'Regla térmica alpina: jamás uses algodón en contacto con la piel.',
      'icon': Icons.dry_cleaning_rounded,
      'color': AppColors.basaltInk,
      'items': [
        {
          'key': 'pack_01_base_layer',
          'title': '1ra Capa (Base): Polo sintético o lana merino transpirable',
          'weight': 0.25,
          'checked': true,
          'essential': true,
        },
        {
          'key': 'pack_01_mid_layer',
          'title': '2da Capa (Aislante): Casaca de plumas o polar térmico',
          'weight': 0.45,
          'checked': true,
          'essential': true,
        },
        {
          'key': 'pack_01_shell_layer',
          'title': '3ra Capa (Escudo): Cortaviento impermeable membrana',
          'weight': 0.50,
          'checked': true,
          'essential': true,
        },
        {
          'key': 'pack_01_pants',
          'title': 'Pantalón de trekking de secado rápido',
          'weight': 0.35,
          'checked': true,
          'essential': true,
        },
        {
          'key': 'pack_01_gloves_hat',
          'title': 'Guantes térmicos cortaviento y gorro / chullo andino',
          'weight': 0.15,
          'checked': false,
          'essential': true,
        },
        {
          'key': 'pack_01_boots',
          'title': 'Botas de caña media con suela de alto agarre en roca',
          'weight': 1.10,
          'checked': true,
          'essential': true,
        },
      ],
    },
    {
      'category': '02 · BOTIQUÍN DE ALTURA Y ACLIMATACIÓN',
      'subtitle': 'Prevención de hipoxia, radiación UV extrema y enfriamiento.',
      'icon': Icons.medical_services_outlined,
      'color': const Color(0xFFB91C1C),
      'items': [
        {
          'key': 'pack_02_altitude_meds',
          'title': 'Medicación para mal de altura (según indicación médica)',
          'weight': 0.05,
          'checked': true,
          'essential': true,
        },
        {
          'key': 'pack_02_electrolytes',
          'title': 'Sales de rehidratación oral para esfuerzo en puna',
          'weight': 0.08,
          'checked': true,
          'essential': true,
        },
        {
          'key': 'pack_02_thermal_blanket',
          'title': 'Manta térmica aluminizada de supervivencia',
          'weight': 0.06,
          'checked': false,
          'essential': true,
        },
        {
          'key': 'pack_02_water_tabs',
          'title': 'Pastillas potabilizadoras o filtro para agua glaciar',
          'weight': 0.03,
          'checked': false,
          'essential': false,
        },
        {
          'key': 'pack_02_sunscreen',
          'title': 'Bloqueador solar FPS 50+ y protector labial UV',
          'weight': 0.12,
          'checked': true,
          'essential': true,
        },
      ],
    },
    {
      'category': '03 · EQUIPO TÉCNICO Y NAVEGACIÓN OFFLINE',
      'subtitle': 'Instrumentos esenciales ante neblina súbita o noche.',
      'icon': Icons.explore_outlined,
      'color': AppColors.yaretaPine,
      'items': [
        {
          'key': 'pack_03_poles',
          'title': 'Bastones telescópicos de trekking (protegen rodillas)',
          'weight': 0.55,
          'checked': true,
          'essential': true,
        },
        {
          'key': 'pack_03_headlamp',
          'title': 'Linterna frontal con batería cargada',
          'weight': 0.18,
          'checked': false,
          'essential': true,
        },
        {
          'key': 'pack_03_powerbank',
          'title': 'Batería externa (Powerbank 10,000 mAh) protegida del frío',
          'weight': 0.28,
          'checked': false,
          'essential': true,
        },
        {
          'key': 'pack_03_sunglasses',
          'title': 'Lentes de sol filtro UV400 Categoría 3 o 4 (albedo nieve)',
          'weight': 0.08,
          'checked': true,
          'essential': true,
        },
        {
          'key': 'pack_03_offline_map',
          'title': 'Cartografía offline Huaguruncho descargada en la App',
          'weight': 0.00,
          'checked': true,
          'essential': true,
        },
      ],
    },
    {
      'category': '04 · HIDRATACIÓN Y RETORNO DE RESIDUOS',
      'subtitle': 'Energía calórica rápida y compromiso Huella Cero.',
      'icon': Icons.water_drop_outlined,
      'color': AppColors.cordilleraOchre,
      'items': [
        {
          'key': 'pack_04_water_bottle',
          'title': 'Cantimplora térmica o camelbak (mínimo 1.5 L)',
          'weight': 1.50,
          'checked': true,
          'essential': true,
        },
        {
          'key': 'pack_04_nuts',
          'title': 'Frutos secos, pasas y raciones de marcha (300 g)',
          'weight': 0.30,
          'checked': true,
          'essential': true,
        },
        {
          'key': 'pack_04_chocolate',
          'title': 'Chocolate amargo o barras energéticas de cacao',
          'weight': 0.20,
          'checked': false,
          'essential': false,
        },
        {
          'key': 'pack_04_waste_bag',
          'title': 'Bolsa hermética para retornar el 100% de residuos a Huachón',
          'weight': 0.05,
          'checked': true,
          'essential': true,
        },
      ],
    },
  ];

  String _scopedKey(String baseKey) {
    final userId = ref.read(authControllerProvider).user?.id ?? 'guest';
    return '${userId}_$baseKey';
  }

  @override
  void initState() {
    super.initState();
    _loadPersistedChecklist();
  }

  Future<void> _loadPersistedChecklist() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final saved = await db.getChecklist();
      if (saved.isEmpty) return;

      final Map<String, bool> savedMap = {
        for (final entry in saved) entry.recommendationKey: entry.isChecked,
      };

      if (mounted) {
        setState(() {
          for (final cat in _checklist) {
            final items = cat['items'] as List<Map<String, dynamic>>;
            for (final item in items) {
              final key = _scopedKey(item['key'] as String);
              if (savedMap.containsKey(key)) {
                item['checked'] = savedMap[key]!;
              }
            }
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleItem(Map<String, dynamic> item) async {
    final bool newVal = !(item['checked'] as bool);
    final String key = _scopedKey(item['key'] as String);
    HapticFeedback.selectionClick();
    setState(() {
      item['checked'] = newVal;
    });
    try {
      await ref.read(appDatabaseProvider).toggleChecklistItem(key, newVal);
    } catch (_) {}
  }

  Future<void> _markAll() async {
    HapticFeedback.mediumImpact();
    setState(() {
      for (final cat in _checklist) {
        final items = cat['items'] as List<Map<String, dynamic>>;
        for (final item in items) {
          item['checked'] = true;
        }
      }
    });
    try {
      final db = ref.read(appDatabaseProvider);
      for (final cat in _checklist) {
        final items = cat['items'] as List<Map<String, dynamic>>;
        for (final item in items) {
          await db.toggleChecklistItem(_scopedKey(item['key'] as String), true);
        }
      }
    } catch (_) {}
  }

  double get _totalWeight {
    double total = 0.8;
    for (var cat in _checklist) {
      final items = cat['items'] as List<Map<String, dynamic>>;
      for (var item in items) {
        if (item['checked'] == true) {
          total += (item['weight'] as num).toDouble();
        }
      }
    }
    return total;
  }

  int get _totalItemsCount {
    int count = 0;
    for (var cat in _checklist) {
      count += (cat['items'] as List).length;
    }
    return count;
  }

  int get _checkedItemsCount {
    int count = 0;
    for (var cat in _checklist) {
      final items = cat['items'] as List<Map<String, dynamic>>;
      for (var item in items) {
        if (item['checked'] == true) count++;
      }
    }
    return count;
  }

  double get _readinessPercent =>
      _totalItemsCount == 0 ? 0.0 : _checkedItemsCount / _totalItemsCount;

  @override
  Widget build(BuildContext context) {
    final double weight = _totalWeight;
    final double percent = _readinessPercent;
    final int percentInt = (percent * 100).round();

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
              'Mochila Virtual de Trekking',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14.5,
                color: AppColors.basaltInk,
              ),
            ),
            Text(
              'SIMULADOR DE PESO Y EQUIPO TÉCNICO · 4,800 M S.N.M.',
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
          TextButton(
            onPressed: _markAll,
            child: const Text(
              'MARCAR TODO',
              style: TextStyle(
                color: AppColors.cordilleraOchre,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Consola de Telemetría de Carga 2.0
            Container(
              padding: const EdgeInsets.all(15),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.backpack_outlined,
                          color: AppColors.cordilleraOchre,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Peso Estimado Mochila',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${weight.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: percentInt == 100
                              ? AppColors.yaretaPine
                              : AppColors.cordilleraOchre,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$percentInt% LISTO',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentInt == 100
                            ? const Color(0xFF6EE7B7)
                            : AppColors.cordilleraOchre,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '$_checkedItemsCount/$_totalItemsCount ítems empacados',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          weight > 7.0
                              ? '⚠ Carga alta (>7 kg)'
                              : '✓ Carga óptima de marcha',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: weight > 7.0
                                ? AppColors.cordilleraOchre
                                : const Color(0xFF6EE7B7),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 2. Listas por Categorías 2.0
            ..._checklist.map((cat) {
              final items = cat['items'] as List<Map<String, dynamic>>;
              final Color color = cat['color'] as Color;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(13),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              cat['icon'] as IconData,
                              color: color,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat['category'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.basaltInk,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                if (cat['subtitle'] != null)
                                  Text(
                                    cat['subtitle'] as String,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      color: AppColors.graniteMuted,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.glacialBorder),
                    ...items.map((item) {
                      final bool isChecked = item['checked'] as bool;
                      final double itemW = (item['weight'] as num).toDouble();
                      final bool isEssential = item['essential'] as bool;

                      return InkWell(
                        onTap: () => _toggleItem(item),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isChecked
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                color: isChecked
                                    ? AppColors.yaretaPine
                                    : AppColors.graniteMuted,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] as String,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: isChecked
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: isChecked
                                            ? AppColors.basaltInk
                                            : AppColors.graniteMuted,
                                      ),
                                    ),
                                    if (itemW > 0 || isEssential)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Wrap(
                                          spacing: 6,
                                          children: [
                                            if (itemW > 0)
                                              Text(
                                                '+${itemW.toStringAsFixed(2)} kg',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors.graniteMuted,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            if (isEssential)
                                              const Text(
                                                '· OBLIGATORIO ALTA MONTAÑA',
                                                style: TextStyle(
                                                  fontSize: 9.5,
                                                  color: AppColors.cordilleraOchre,
                                                  fontWeight: FontWeight.w900,
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
                    }),
                  ],
                ),
              );
            }),

            const SizedBox(height: 6),

            // 3. Botón de Confirmar Mochila
            ElevatedButton.icon(
              onPressed: () {
                if (percentInt < 80) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Recomendación: Empaca al menos el 80% del equipo obligatorio de alta montaña.',
                      ),
                      backgroundColor: AppColors.cordilleraOchre,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '✓ Mochila verificada para ascender a la cordillera Huaguruncho.',
                      ),
                      backgroundColor: AppColors.yaretaPine,
                    ),
                  );
                  context.push('/routes');
                }
              },
              icon: const Icon(Icons.hiking_rounded, size: 18),
              label: const Text(
                'CONFIRMAR EQUIPO Y EXPLORAR RUTAS',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yaretaPine,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.basaltInk, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
