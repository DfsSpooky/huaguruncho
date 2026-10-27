import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/responsible_use_banner.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credencial autenticada. Sincronización en línea habilitada.'),
          backgroundColor: AppColors.yaretaPine,
        ),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.alpineChalk,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AUTENTICACIÓN DE CAMPO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.cordilleraOchre,
              ),
            ),
            Text(
              'Credencial de Expedicionario',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.basaltInk,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.glacialBorder),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(14),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.basaltInk,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.badge_outlined,
                              size: 24,
                              color: AppColors.pureWhite,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'RED DE MONITOREO HUAGURUNCHO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                    color: AppColors.yaretaPine,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Acceso al Servidor Central',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.basaltInk,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Autentica tu cuenta para respaldar actas ambientales en la nube y vincular tu pasaporte de conservación.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.graniteMuted,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (authState.error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.crimsonAlertLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.error),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authState.error!,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const Text(
                        'CORREO ELECTRÓNICO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.basaltInk,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'usuario@correo.pe',
                          prefixIcon: const Icon(Icons.alternate_email_rounded, size: 18),
                          filled: true,
                          fillColor: AppColors.alpineChalk,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.glacialBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.glacialBorder, width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa tu correo electrónico';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Ingresa un correo electrónico válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'CLAVE DE ACCESO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.basaltInk,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                          filled: true,
                          fillColor: AppColors.alpineChalk,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.glacialBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.glacialBorder, width: 1.5),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu contraseña';
                          }
                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cordilleraOchre,
                            foregroundColor: AppColors.pureWhite,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: AppColors.basaltInk, width: 1.5),
                            ),
                          ),
                          child: authState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'AUTENTICAR CREDENCIAL',
                                  style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.6),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glacialBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '¿Primera expedición?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.graniteMuted,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.push('/register'),
                        icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                        label: const Text(
                          'Solicitar Credencial',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.basaltInk,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const ResponsibleUseBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

