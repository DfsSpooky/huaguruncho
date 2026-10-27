import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).register(
          _emailController.text.trim(),
          _passwordController.text,
          _fullNameController.text.trim(),
          _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credencial de Guardián creada exitosamente.'),
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
              'ALTA DE GUARDIÁN AMBIENTAL',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.yaretaPine,
              ),
            ),
            Text(
              'Nueva Credencial',
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
                      const Text(
                        'REGISTRO EN BRIGADA ECOTURÍSTICA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: AppColors.cordilleraOchre,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Únete a la red de vigilancia ambiental del Nevado Huaguruncho',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.basaltInk,
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (authState.error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.crimsonAlertLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.error),
                          ),
                          child: Text(
                            authState.error!,
                            style: const TextStyle(color: AppColors.error, fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre y Apellidos *',
                          prefixIcon: Icon(Icons.person_outline, size: 18),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa tu nombre completo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo Electrónico *',
                          prefixIcon: Icon(Icons.alternate_email_rounded, size: 18),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa tu correo';
                          }
                          if (!value.contains('@')) {
                            return 'Correo no válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono / Radio / WhatsApp (Opcional)',
                          prefixIcon: Icon(Icons.phone_outlined, size: 18),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña * (Mín. 8 caracteres)',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
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
                            return 'Ingresa una contraseña';
                          }
                          if (value.length < 8) {
                            return 'La contraseña debe tener al menos 8 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.yaretaPine,
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
                                  'EMITIR CREDENCIAL DE CAMPO',
                                  style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.6),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    '¿Ya tienes credencial activa? Autenticar sesión',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.basaltInk),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

