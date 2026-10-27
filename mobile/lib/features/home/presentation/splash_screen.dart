import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/storage/secure_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    _navigateToNext();
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
    return Scaffold(
      backgroundColor: AppColors.basaltInk,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Fotografía de Alta Montaña con filtro editorial
          Image.asset(
            'assets/images/huaguruncho_hero.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),

          // 2. Viñeta mineral de alto contraste (Basalt Ink)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.basaltInk.withValues(alpha: 0.72),
                  AppColors.basaltInk.withValues(alpha: 0.45),
                  AppColors.basaltInk.withValues(alpha: 0.94),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // 3. Marco Cartográfico e Instrumentación de Campo 2.0
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cabecera de Telemetría Cartográfica
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.basaltInk.withValues(alpha: 0.82),
                      border: Border.all(color: Colors.white24, width: 1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              color: AppColors.cordilleraOchre,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'SISTEMA CARTOGRÁFICO V2.0',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          '10°31\'48"S · 75°55\'48"W',
                          style: TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Bloque Editorial Central-Inferior Asimétrico
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.basaltInk.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24, width: 1),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          offset: Offset(3, 3),
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.cordilleraOchre,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'ALTITUD CUMBRE: 5,742 M S.N.M.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const Text(
                              'EXPEDICIÓN #24-ALP',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          AppStrings.appName,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.8,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          AppStrings.appSubtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFD6DAD5),
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Divider(color: Colors.white12, height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              AppStrings.locationTitle,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Colors.white70,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.yaretaPine,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'TELEMETRÍA LISTA',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: Color(0xFF6EE7B7),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
