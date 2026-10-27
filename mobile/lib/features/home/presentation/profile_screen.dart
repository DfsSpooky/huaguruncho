import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_translations.dart';
import '../../auth/presentation/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final isRangerOrAdmin = authState.isAuthenticated && (user?.isRangerOrAdmin ?? false);

    return Scaffold(
      backgroundColor: AppColors.alpineChalk,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: AppColors.basaltInk, width: 1.5),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CREDENCIAL DE EXPEDICIONARIO',
              style: TextStyle(
                color: AppColors.basaltInk,
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
            Text(
              'PERFIL OFICIAL · HUAGURUNCHO 360',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Credencial de Expedicionario 2.0
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.basaltInk, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.basaltInk,
                    offset: Offset(2.5, 2.5),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: authState.isAuthenticated && user != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isRangerOrAdmin ? AppColors.yaretaPine : AppColors.cordilleraOchre,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ROL: ${user.role.toUpperCase()}',
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            const Text(
                              'ID ACTIVO · HUACHÓN',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.graniteMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.basaltInk,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isRangerOrAdmin ? Icons.verified_user_rounded : Icons.badge_outlined,
                                size: 28,
                                color: isRangerOrAdmin ? const Color(0xFF6EE7B7) : AppColors.cordilleraOchre,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.fullName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.basaltInk,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.email,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.graniteMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.basaltInk,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'MODALIDAD VISITANTE (OFFLINE)',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const Icon(Icons.shield_outlined, size: 16, color: AppColors.cordilleraOchre),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Explorador de Montaña',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.basaltInk,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Inicia sesión o regístrate para respaldar tus eco-reportes, sellos de conservación y bitácoras de ascenso en la plataforma oficial de Huachón.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.graniteMuted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => context.push('/login'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.cordilleraOchre,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('INICIAR SESIÓN'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => context.push('/register'),
                                child: const Text('REGISTRARME'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 20),

            // 2. Módulos de Configuración e Instrumentos
            const Text(
              '01 // PREFERENCIAS & MEMORIA DE CAMPO',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                color: AppColors.basaltInk,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.basaltInk, width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.basaltInk,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language_rounded, color: AppColors.cordilleraOchre),
                    title: const Text(
                      'Idioma / Simi / Language',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                    ),
                    subtitle: Text(
                      ref.watch(languageProvider).displayName,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.graniteMuted),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.basaltInk),
                    onTap: () => _showLanguageDialog(context, ref),
                  ),
                  const Divider(height: 1, color: AppColors.glacialBorder),
                  ListTile(
                    leading: const Icon(Icons.download_for_offline_outlined, color: AppColors.yaretaPine),
                    title: const Text(
                      'Gestión de Paquetes Offline',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                    ),
                    subtitle: const Text(
                      'Mapas, rutas y panoramas 360° en almacenamiento local',
                      style: TextStyle(fontSize: 11.5, color: AppColors.graniteMuted),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.basaltInk),
                    onTap: () => context.push('/offline-packages'),
                  ),
                  if (isRangerOrAdmin) ...[
                    const Divider(height: 1, color: AppColors.glacialBorder),
                    ListTile(
                      leading: const Icon(Icons.verified_user_rounded, color: AppColors.yaretaPine),
                      title: const Text(
                        'Puesto de Control Guardaparques (Garita)',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                      ),
                      subtitle: const Text(
                        'Auditoría exclusiva de ingreso y retorno de residuos',
                        style: TextStyle(fontSize: 11.5, color: AppColors.graniteMuted),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.basaltInk),
                      onTap: () => context.push('/ranger-checkpoint'),
                    ),
                  ],
                  const Divider(height: 1, color: AppColors.glacialBorder),
                  ListTile(
                    leading: const Icon(Icons.gavel_rounded, color: AppColors.graniteMuted),
                    title: const Text(
                      'Código de Uso Responsable (No Deje Rastro)',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.basaltInk),
                    onTap: () => context.push('/responsible-use'),
                  ),
                ],
              ),
            ),

            if (authState.isAuthenticated) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sesión cerrada correctamente')),
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text('CERRAR SESIÓN ACTIVA', style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                ),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final currentLang = ref.read(languageProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.pureWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.basaltInk, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.language_rounded, color: AppColors.cordilleraOchre, size: 20),
            SizedBox(width: 8),
            Text('SELECCIONAR IDIOMA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values.map((lang) {
            final isSelected = lang == currentLang;
            return ListTile(
              leading: Text(lang.flagEmoji, style: const TextStyle(fontSize: 22)),
              title: Text(
                lang.displayName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: AppColors.basaltInk,
                ),
              ),
              trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.cordilleraOchre) : null,
              onTap: () {
                ref.read(languageProvider.notifier).setLanguage(lang);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
