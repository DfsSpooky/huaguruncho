import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../../features/auth/presentation/auth_controller.dart';
import 'auth_required_gate.dart';

class MainShellScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScaffold({
    super.key,
    required this.navigationShell,
  });

  void _onItemTapped(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = navigationShell.currentIndex;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: _AndeanBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        onCenterActionTap: () {
          if (!authState.isAuthenticated) {
            showAuthRequiredModal(
              context,
              featureName: 'Reporte Ambiental Georreferenciado',
              description:
                  'Inicia sesión o crea tu cuenta de excursionista para capturar incidencias ambientales con foto y coordenadas GPS.',
            );
            return;
          }
          context.push('/create-report');
        },
      ),
    );
  }
}

class _AndeanBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCenterActionTap;

  const _AndeanBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.onCenterActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        border: Border(
          top: BorderSide(color: AppColors.glacialBorder, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A14171A),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 6,
        bottom: bottomPadding > 0 ? bottomPadding : 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Tab 0: Inicio
          _NavBarItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Inicio',
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),

          // Tab 1: Rutas
          _NavBarItem(
            icon: Icons.alt_route_outlined,
            activeIcon: Icons.alt_route_rounded,
            label: 'Rutas',
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),

          // Botón Central Táctico Animado "Huella Cero / Reportar" (Stitch 2.0)
          _TacticalReportButton(
            onTap: onCenterActionTap,
          ),

          // Tab 2: Tour 360°
          _NavBarItem(
            icon: Icons.view_in_ar_outlined,
            activeIcon: Icons.view_in_ar_rounded,
            label: 'Tour 360°',
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
          ),

          // Tab 3: Reportes
          _NavBarItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment_rounded,
            label: 'Reportes',
            isSelected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.cordilleraOchre : AppColors.graniteMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Micro línea indicadora superior para el estado activo (Stitch 2.0)
            Container(
              height: 2,
              width: 18,
              margin: const EdgeInsets.only(bottom: 3),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.cordilleraOchre : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón Central Táctico "Reportar" con:
/// 1. Respuesta mecánica física (hunde la sombra sólida de 2px a 0px al presionar + vibración háptica).
/// 2. Pulso sutil de radar perimetral en color Ocre Cordillera.
/// 3. Latido periódico del obturador de cámara y micro-LED de telemetría activa.
class _TacticalReportButton extends StatefulWidget {
  final VoidCallback onTap;

  const _TacticalReportButton({
    required this.onTap,
  });

  @override
  State<_TacticalReportButton> createState() => _TacticalReportButtonState();
}

class _TacticalReportButtonState extends State<_TacticalReportButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _radarScale;
  late final Animation<double> _radarOpacity;
  late final Animation<double> _cameraHeartbeat;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Onda de radar exterior que se expande y se desvanece suavemente
    _radarScale = Tween<double>(begin: 1.0, end: 1.16).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _radarOpacity = Tween<double>(begin: 0.55, end: 0.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
      ),
    );

    // Latido sutil del ícono de cámara (doble pulso suave tipo obturador/radar)
    _cameraHeartbeat = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.18)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.18, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 56,
      ),
    ]).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isPressed) {
      HapticFeedback.lightImpact();
      setState(() => _isPressed = true);
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  Future<void> _handleTap() async {
    HapticFeedback.mediumImpact();
    if (!_isPressed && mounted) {
      setState(() => _isPressed = true);
    }
    // Breve pausa para que el hundimiento mecánico del botón sea visible antes de abrir la pantalla
    await Future<void>.delayed(const Duration(milliseconds: 115));
    if (mounted) {
      setState(() => _isPressed = false);
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pressOffset = _isPressed ? 2.0 : 0.0;
          final shadowOffset = _isPressed ? 0.0 : 2.0;

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Anillo de radar táctico perimetral (se oculta al presionar)
              if (!_isPressed)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Transform.scale(
                      scaleX: _radarScale.value,
                      scaleY: 1.0 + ((_radarScale.value - 1.0) * 1.45),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: AppColors.cordilleraOchre
                                .withValues(alpha: _radarOpacity.value),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Cuerpo del pulsador mecánico
              AnimatedContainer(
                duration: const Duration(milliseconds: 95),
                curve: Curves.easeOutCubic,
                transform: Matrix4.translationValues(pressOffset, pressOffset, 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _isPressed
                      ? const Color(0xFFC04B29) // Ocre ligeramente más profundo al hundirse
                      : AppColors.cordilleraOchre,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.basaltInk, width: 1.3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.basaltInk,
                      offset: Offset(shadowOffset, shadowOffset),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícono de cámara con latido periódico + LED de estado
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Transform.scale(
                          scale: _isPressed ? 0.92 : _cameraHeartbeat.value,
                          child: const Icon(
                            Icons.photo_camera_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        Positioned(
                          top: -1.5,
                          right: -2,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Color.lerp(
                                const Color(0xFFFEF08A),
                                const Color(0xFF34D399),
                                _radarOpacity.value,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.basaltInk,
                                width: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Reportar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

