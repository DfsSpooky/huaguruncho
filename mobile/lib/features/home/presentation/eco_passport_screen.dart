import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../reports/presentation/reports_controller.dart';

class EcoPassportScreen extends ConsumerStatefulWidget {
  const EcoPassportScreen({super.key});

  @override
  ConsumerState<EcoPassportScreen> createState() => _EcoPassportScreenState();
}

class _EcoPassportScreenState extends ConsumerState<EcoPassportScreen> {
  bool _hasSignedPledge = true;

  final List<Map<String, dynamic>> _badges = const [
    {
      'title': 'Centinela Ambiental',
      'icon': Icons.shield_rounded,
      'color': AppColors.mountainGreen,
      'isUnlocked': true,
      'category': 'Conservación',
      'description': 'Por registrar tu primer eco-reporte geolocalizado en los senderos de Huachón.',
      'didacticFact': 'Los reportes ciudadanos permiten a la municipalidad limpiar micro-basurales antes de que contaminen las fuentes de agua dulce.',
    },
    {
      'title': 'Guardián de Huascacocha',
      'icon': Icons.water_drop_rounded,
      'color': AppColors.glacierTeal,
      'isUnlocked': true,
      'category': 'Recursos Hídricos',
      'description': 'Por explorar el circuito de lagunas glaciares a más de 4,200 m s.n.m.',
      'didacticFact': 'La laguna Huascacocha se alimenta del deshielo del Nevado Huaguruncho y abastece de agua a todo el valle agrícola de Huachón.',
    },
    {
      'title': 'Protector del Queñual',
      'icon': Icons.forest_rounded,
      'color': Color(0xFF2D6A4F),
      'isUnlocked': true,
      'category': 'Flora Nativa',
      'description': 'Por respetar los bosques relícticos de Polylepis (árbol de papel) en altura.',
      'didacticFact': 'Los queñuales capturan la niebla andina y regulan el caudal hídrico de la cuenca, evitando deslizamientos.',
    },
    {
      'title': 'Vigía de la Puya Raimondi',
      'icon': Icons.local_florist_rounded,
      'color': AppColors.sunGold,
      'isUnlocked': false,
      'category': 'Botánica Andina',
      'description': 'Desbloqueable al visitar el rodal de Puyas en la quebrada de Huachón.',
      'didacticFact': 'La Puya Raimondi vive hasta 100 años y florece una sola vez en su vida con más de 8,000 flores.',
    },
    {
      'title': 'Cóndor de la Cordillera',
      'icon': Icons.flight_takeoff_rounded,
      'color': AppColors.twilightNavy,
      'isUnlocked': false,
      'category': 'Fauna Silvestre',
      'description': 'Desbloqueable al completar los 3 miradores 360° del Nevado Huaguruncho.',
      'didacticFact': 'El cóndor andino vuela a más de 5,000 metros aprovechando las corrientes térmicas ascendentes del cañón.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final reportsStream = ref.watch(myReportsStreamProvider);
    final reportsCount = reportsStream.asData?.value.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.mountainGreen,
        elevation: 0,
        title: const Text(
          'Pasaporte del Guardián',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Tarjeta de Rango del Guardián
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.ecoGuardianGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mountainGreen.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.workspace_premium_rounded, color: AppColors.sunGold, size: 36),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Guardián Glacial Nivel II',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Distrito Ecoturístico de Huachón',
                              style: TextStyle(
                                color: AppColors.lightSand,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Barra de progreso de nivel
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Progreso a Apu Protector', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600)),
                          Text('60% • 3/5 Insignias', style: TextStyle(color: AppColors.sunGold, fontSize: 11.5, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          value: 0.6,
                          minHeight: 8,
                          backgroundColor: Colors.black26,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.sunGold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 2. Métricas de Impacto
            Row(
              children: [
                Expanded(
                  child: _ImpactCounterCard(
                    number: '$reportsCount',
                    label: 'Eco-Reportes',
                    subtext: 'Incidentes registrados',
                    icon: Icons.assignment_turned_in_rounded,
                    color: AppColors.mountainGreen,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: _ImpactCounterCard(
                    number: '14.5',
                    label: 'Km Explorados',
                    subtext: 'Senderos limpios',
                    icon: Icons.directions_walk_rounded,
                    color: AppColors.glacierTeal,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: _ImpactCounterCard(
                    number: '3',
                    label: 'Miradores',
                    subtext: 'Vistas 360° visitadas',
                    icon: Icons.visibility_rounded,
                    color: AppColors.twilightNavy,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // 3. Colección de Insignias Didácticas
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Insignias Ecológicas de Alta Montaña',
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                Text(
                  'Toca para aprender',
                  style: TextStyle(fontSize: 11.5, color: AppColors.glacierTeal, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ..._badges.map((b) => _BadgeListCard(badge: b)),

            const SizedBox(height: 20),

            // 4. Juramento del Guardián Ecológico (Didáctico)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.handshake_rounded, color: AppColors.mountainGreen, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Compromiso con el Nevado Huaguruncho',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '«Prometo no dejar rastro de mi visita, no extraer flora nativa, respetar la tranquilidad de la fauna andina y proteger las aguas de Huascacocha para las futuras generaciones de Huachón.»',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontStyle: FontStyle.italic, height: 1.35),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _hasSignedPledge,
                        activeColor: AppColors.mountainGreen,
                        onChanged: (val) {
                          setState(() => _hasSignedPledge = val ?? true);
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'He leído y firmado mi juramento ecológico digital.',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _ImpactCounterCard extends StatelessWidget {
  final String number;
  final String label;
  final String subtext;
  final IconData icon;
  final Color color;

  const _ImpactCounterCard({
    required this.number,
    required this.label,
    required this.subtext,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            number,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BadgeListCard extends StatelessWidget {
  final Map<String, dynamic> badge;

  const _BadgeListCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    final bool isUnlocked = badge['isUnlocked'] as bool;
    final Color color = badge['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white : const Color(0xFFF0F3F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnlocked ? color.withValues(alpha: 0.3) : AppColors.border,
          width: isUnlocked ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.twilightNavy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                title: Row(
                  children: [
                    Icon(badge['icon'] as IconData, color: color, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        badge['title'] as String,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      badge['description'] as String,
                      style: const TextStyle(color: AppColors.lightSand, fontSize: 13, height: 1.35),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.school_rounded, color: AppColors.sunGold, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              badge['didacticFact'] as String,
                              style: const TextStyle(color: Colors.white, fontSize: 11.5, height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Comprendido', style: TextStyle(color: AppColors.glacierTeal, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isUnlocked ? color.withValues(alpha: 0.12) : Colors.black12,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    badge['icon'] as IconData,
                    color: isUnlocked ? color : Colors.black38,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Text(
                            badge['title'] as String,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: isUnlocked ? AppColors.textPrimary : AppColors.textMuted,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isUnlocked ? color.withValues(alpha: 0.1) : Colors.black12,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge['category'] as String,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: isUnlocked ? color : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        badge['description'] as String,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isUnlocked ? AppColors.textSecondary : AppColors.textMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  isUnlocked ? Icons.verified_rounded : Icons.lock_outline_rounded,
                  color: isUnlocked ? color : AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
