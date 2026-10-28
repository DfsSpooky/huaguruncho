import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';

/// Muestra un modal Stitch 2.0 indicando que la experiencia interactiva
/// requiere una cuenta registrada de excursionista.
Future<void> showAuthRequiredModal(
  BuildContext context, {
  required String featureName,
  String description =
      'Para usar los mapas con GPS, recorridos en 360°, sellos de visita y avisos de seguridad, inicia sesión o crea tu cuenta gratuita.',
}) {
  HapticFeedback.mediumImpact();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          border: Border(
            top: BorderSide(color: AppColors.basaltInk, width: 2),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glacialBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.basaltInk,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cordilleraOchre,
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.cordilleraOchre,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ACCESO EXCLUSIVO · EXCURSIONISTAS REGISTRADOS',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.cordilleraOchre,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          featureName.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.basaltInk,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.alpineChalk,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.glacialBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.basaltInk,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 14,
                          color: AppColors.yaretaPine,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Tu cuenta guarda tus recorridos, sellos de visita y datos de contacto de emergencia.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.yaretaPine,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.push('/login');
                },
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text('INICIAR SESIÓN CON MI CUENTA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cordilleraOchre,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.basaltInk, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.push('/register');
                },
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('CREAR CUENTA DE EXCURSIONISTA'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.basaltInk,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(color: AppColors.basaltInk, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Vista embebida Stitch 2.0 para pestañas o pantallas que requieren sesión activa
class AuthRequiredView extends StatelessWidget {
  final String featureName;
  final String description;
  final IconData icon;

  const AuthRequiredView({
    super.key,
    required this.featureName,
    required this.description,
    this.icon = Icons.lock_person_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.basaltInk, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: AppColors.basaltInk,
                offset: Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.basaltInk,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cordilleraOchre,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: AppColors.cordilleraOchre,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'REQUIERE CUENTA DE EXCURSIONISTA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.cordilleraOchre,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                featureName.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.basaltInk,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.graniteMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/login'),
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: const Text('INICIAR SESIÓN'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cordilleraOchre,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/register'),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: const Text('REGISTRARME GRATIS'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.basaltInk,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
