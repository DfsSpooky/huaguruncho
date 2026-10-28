import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';
import 'expedition_controller.dart';

class RegisterExpeditionDialog extends ConsumerStatefulWidget {
  const RegisterExpeditionDialog({super.key});

  @override
  ConsumerState<RegisterExpeditionDialog> createState() => _RegisterExpeditionDialogState();
}

class _RegisterExpeditionDialogState extends ConsumerState<RegisterExpeditionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _guideController = TextEditingController();
  final _healthController = TextEditingController();

  int _groupSize = 2;
  int _estimatedHours = 6;
  bool _checklistAccepted = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    if (user != null) {
      if (user.fullName.trim().isNotEmpty) {
        _nameController.text = user.fullName.trim();
      }
      final phone = user.phone?.trim() ?? '';
      if (phone.isNotEmpty) {
        _phoneController.text = phone;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _guideController.dispose();
    _healthController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_checklistAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes confirmar que revisaste el checklist de seguridad de montaña.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final now = DateTime.now();
    final expectedReturn = now.add(Duration(hours: _estimatedHours));

    final success = await ref.read(activeExpeditionProvider.notifier).registerExpedition(
      touristName: _nameController.text.trim(),
      touristPhone: _phoneController.text.trim(),
      emergencyContactName: _emergencyNameController.text.trim(),
      emergencyContactPhone: _emergencyPhoneController.text.trim(),
      groupSize: _groupSize,
      guideName: _guideController.text.trim(),
      departureDatetime: now,
      expectedReturnDatetime: expectedReturn,
      healthNotes: _healthController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.yaretaPine,
            content: Text('Salida registrada con éxito. ¡Que disfrutes tu visita a Huaguruncho!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Error al registrar la expedición. Intenta nuevamente.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.basaltInk, width: 2),
      ),
      backgroundColor: AppColors.pureWhite,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header 2.0
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.basaltInk,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.hiking_rounded, color: AppColors.pureWhite, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GARITA DIGITAL COEL • HUACHÓN',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            letterSpacing: 1.0,
                            color: AppColors.cordilleraOchre,
                          ),
                        ),
                        Text(
                          'Registro de Expedición',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppColors.basaltInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: AppColors.basaltInk),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.stoneSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.glacialBorder, width: 1.2),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.yaretaPine, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Los guardaparques y guías de Huachón están atentos a tu registro para ayudarte si ocurre cualquier retraso o emergencia.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.basaltInk, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Inputs
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre Completo del Líder *',
                  hintText: 'Ej. Carlos Mendoza',
                  prefixIcon: const Icon(Icons.person_outline, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa tu nombre' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Teléfono / WhatsApp *',
                  hintText: 'Ej. 987654321',
                  prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa tu teléfono' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emergencyNameController,
                      decoration: InputDecoration(
                        labelText: 'Contacto Familiar *',
                        hintText: 'Ej. Familiar',
                        prefixIcon: const Icon(Icons.contact_phone_outlined, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _emergencyPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Tel. Emergencia *',
                        hintText: '955112233',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Grupo y Horas estimadas
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'N° EXCURSIONISTAS',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.graniteMuted),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColors.alpineChalk,
                            border: Border.all(color: AppColors.glacialBorder, width: 1.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButton<int>(
                            value: _groupSize,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: [1, 2, 3, 4, 5, 6, 8, 10, 15].map((n) {
                              return DropdownMenuItem(value: n, child: Text('$n personas'));
                            }).toList(),
                            onChanged: (v) => setState(() => _groupSize = v ?? 2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RETORNO ESTIMADO',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.graniteMuted),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColors.alpineChalk,
                            border: Border.all(color: AppColors.glacialBorder, width: 1.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButton<int>(
                            value: _estimatedHours,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: [3, 5, 6, 8, 12, 24, 48].map((h) {
                              return DropdownMenuItem(value: h, child: Text('$h horas'));
                            }).toList(),
                            onChanged: (v) => setState(() => _estimatedHours = v ?? 6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _guideController,
                decoration: InputDecoration(
                  labelText: 'Guía o Arriero Acompañante',
                  hintText: 'Ej. Don Carlos Huamán o Sin guía',
                  prefixIcon: const Icon(Icons.badge_outlined, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _healthController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Salud, Aclimatación y Alergias',
                  hintText: 'Medicamentos que portas o alergias',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.yaretaPine,
                value: _checklistAccepted,
                onChanged: (v) => setState(() => _checklistAccepted = v ?? true),
                title: const Text(
                  'Confirmo portar abrigo térmico de 3 capas, agua (mín. 2L) y cartografía offline activa.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.basaltInk, fontWeight: FontWeight.w600),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 14),

              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cordilleraOchre,
                  foregroundColor: AppColors.pureWhite,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppColors.basaltInk, width: 1.5),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'CONFIRMAR Y REGISTRAR SALIDA',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, letterSpacing: 0.5),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
