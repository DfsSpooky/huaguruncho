import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/storage/secure_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final _storage = SecureStorageService();
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );
    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _controller.forward();
    _navigateToNext();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    final done = await _storage.hasCompletedOnboarding();
    if (mounted) {
      context.go(done ? '/home' : '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFFFBFBFD),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFBFBFD),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Halo ambiental radial minimalista estilo Apple
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.0, -0.12),
                    radius: 0.85,
                    colors: [
                      Colors.white,
                      const Color(0xFFF5F5F7).withValues(alpha: 0.65),
                      const Color(0xFFFBFBFD),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        children: [
                          const Spacer(flex: 5),

                          // Ícono Minimalista en Squircle (Superelipse Continua estilo iOS)
                          Container(
                            width: 88,
                            height: 88,
                            decoration: ShapeDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF1D1D1F),
                                  Color(0xFF121316),
                                ],
                              ),
                              shape: ContinuousRectangleBorder(
                                borderRadius: BorderRadius.circular(44),
                                side: BorderSide(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  width: 0.8,
                                ),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: const Color(0xFF1D1D1F).withValues(alpha: 0.12),
                                  blurRadius: 32,
                                  offset: const Offset(0, 14),
                                ),
                                BoxShadow(
                                  color: const Color(0xFF1D1D1F).withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  top: 22,
                                  right: 24,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.cordilleraOchre,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.landscape_rounded,
                                  color: Colors.white,
                                  size: 42,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Tipografía limpia y minimalista estilo Apple
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Huaguruncho',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D1D1F),
                                  letterSpacing: -0.7,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                margin: const EdgeInsets.only(top: 3),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1D1D1F).withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  '360°',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.cordilleraOchre,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Nevado Huaguruncho · Pasco, Perú',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF86868B),
                              letterSpacing: -0.1,
                            ),
                          ),

                          const Spacer(flex: 6),

                          // Barra de carga progresiva minimalista estilo Apple Boot
                          SizedBox(
                            width: 44,
                            height: 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _progressAnimation.value,
                                backgroundColor: const Color(0xFFE8E8ED),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF1D1D1F),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'Huachón',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFAEAEB2),
                              letterSpacing: 0.4,
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
