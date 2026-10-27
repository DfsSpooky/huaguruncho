import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/checkpoint_model.dart';
import 'checkpoint_controller.dart';

class RangerCheckoutDialog extends ConsumerStatefulWidget {
  final CheckpointModel entry;

  const RangerCheckoutDialog({
    super.key,
    required this.entry,
  });

  @override
  ConsumerState<RangerCheckoutDialog> createState() =>
      _RangerCheckoutDialogState();
}

class _RangerCheckoutDialogState extends ConsumerState<RangerCheckoutDialog> {
  late int _bottlesOut;
  late int _cansOut;
  late int _wrappersOut;
  late int _bagsOut;
  late int _batteriesOut;
  late int _gasOut;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bottlesOut = 0;
    _cansOut = 0;
    _wrappersOut = 0;
    _bagsOut = 0;
    _batteriesOut = 0;
    _gasOut = 0;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _autofillAllReturned() {
    setState(() {
      _bottlesOut = widget.entry.plasticBottlesIn;
      _cansOut = widget.entry.cansIn;
      _wrappersOut = widget.entry.plasticWrappersIn;
      _bagsOut = widget.entry.plasticBagsIn;
      _batteriesOut = widget.entry.batteriesIn;
      _gasOut = widget.entry.gasCanistersIn;
    });
  }

  int get _totalOut =>
      _bottlesOut + _cansOut + _wrappersOut + _bagsOut + _batteriesOut + _gasOut;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final totalIn = entry.totalItemsIn;
    final totalOut = _totalOut;
    final isCompliant = totalOut == totalIn && totalIn > 0;
    final isExtra = totalOut > totalIn;
    final isMissing = totalOut < totalIn;

    final controllerState = ref.watch(checkpointControllerProvider);

    return Dialog(
      backgroundColor: AppColors.pureWhite,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.basaltInk, width: 1.5),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header 2.0
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.basaltInk,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.recycling_rounded,
                      color: Color(0xFF6EE7B7),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AUDITORÍA DE RETORNO DE RESIDUOS',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.basaltInk,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${entry.visitorName} · ${entry.documentType}: ${entry.documentNumber}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.graniteMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close_rounded, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Botón de Autocompletado Rápido
              OutlinedButton.icon(
                onPressed: _autofillAllReturned,
                icon: const Icon(
                  Icons.done_all_rounded,
                  size: 16,
                  color: AppColors.yaretaPine,
                ),
                label: const Text(
                  'MARCAR 100% CONFORME (RETORNÓ TODO LO DECLARADO)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.yaretaPine,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.yaretaPine, width: 1.2),
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Steppers de categorías de residuos
              _buildStepper(
                icon: Icons.local_drink_rounded,
                title: 'Botellas PET',
                declaredIn: entry.plasticBottlesIn,
                value: _bottlesOut,
                onChanged: (v) => setState(() => _bottlesOut = v),
              ),
              _buildStepper(
                icon: Icons.soup_kitchen_rounded,
                title: 'Latas / Conservas',
                declaredIn: entry.cansIn,
                value: _cansOut,
                onChanged: (v) => setState(() => _cansOut = v),
              ),
              _buildStepper(
                icon: Icons.cookie_rounded,
                title: 'Envoltorios de snacks',
                declaredIn: entry.plasticWrappersIn,
                value: _wrappersOut,
                onChanged: (v) => setState(() => _wrappersOut = v),
              ),
              _buildStepper(
                icon: Icons.shopping_bag_outlined,
                title: 'Bolsas plásticas',
                declaredIn: entry.plasticBagsIn,
                value: _bagsOut,
                onChanged: (v) => setState(() => _bagsOut = v),
              ),
              _buildStepper(
                icon: Icons.battery_charging_full_rounded,
                title: 'Pilas / Baterías',
                declaredIn: entry.batteriesIn,
                value: _batteriesOut,
                onChanged: (v) => setState(() => _batteriesOut = v),
              ),
              _buildStepper(
                icon: Icons.propane_tank_rounded,
                title: 'Balones de gas / camping',
                declaredIn: entry.gasCanistersIn,
                value: _gasOut,
                onChanged: (v) => setState(() => _gasOut = v),
              ),
              const SizedBox(height: 8),

              // Campo de notas / acta
              TextField(
                controller: _notesController,
                maxLines: 2,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Observaciones del Acta (Opcional)',
                  hintText: isMissing
                      ? 'Indica motivo si faltan residuos por retornar...'
                      : 'Estado físico del grupo, novedades en ruta...',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Compliance Badge Preview 2.0
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isExtra || isCompliant
                      ? AppColors.yaretaPine.withValues(alpha: 0.1)
                      : totalIn == 0
                          ? AppColors.alpineChalk
                          : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isExtra || isCompliant
                        ? AppColors.yaretaPine
                        : totalIn == 0
                            ? AppColors.glacialBorder
                            : AppColors.error,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isExtra
                          ? Icons.military_tech_rounded
                          : isCompliant
                              ? Icons.verified_rounded
                              : totalIn == 0
                                  ? Icons.info_outline_rounded
                                  : Icons.warning_amber_rounded,
                      color: isExtra || isCompliant
                          ? AppColors.yaretaPine
                          : totalIn == 0
                              ? AppColors.graniteMuted
                              : AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isExtra
                                ? '★ RETORNO MERITORIO (+ RESIDUOS EXTRA)'
                                : isCompliant
                                    ? '✓ HUELLA CERO CUMPLIDA (100% RETORNADO)'
                                    : totalIn == 0
                                        ? 'SIN RESIDUOS DECLARADOS EN ASCENSO'
                                        : '⚠ ALERTA: FALTAN ${totalIn - totalOut} RESIDUOS POR RETORNAR',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: isExtra || isCompliant
                                  ? AppColors.yaretaPine
                                  : totalIn == 0
                                      ? AppColors.basaltInk
                                      : AppColors.error,
                            ),
                          ),
                          Text(
                            'Declarado en subida: $totalIn · Contabilizado en bajada: $totalOut',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.graniteMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Submit Button
              ElevatedButton(
                onPressed: controllerState.isSaving
                    ? null
                    : () async {
                        final success = await ref
                            .read(checkpointControllerProvider.notifier)
                            .registerCheckout(
                              localUuid: entry.localUuid,
                              plasticBottlesOut: _bottlesOut,
                              cansOut: _cansOut,
                              plasticWrappersOut: _wrappersOut,
                              plasticBagsOut: _bagsOut,
                              batteriesOut: _batteriesOut,
                              gasCanistersOut: _gasOut,
                              notes: _notesController.text.trim().isNotEmpty
                                  ? _notesController.text.trim()
                                  : null,
                            );

                        if (context.mounted && success) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '✓ Acta de descenso cerrada y guardada en SQLite local.',
                              ),
                              backgroundColor: AppColors.yaretaPine,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.basaltInk,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: controllerState.isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'FINALIZAR VISITA Y CERRAR ACTA (OFFLINE)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper({
    required IconData icon,
    required String title,
    required int declaredIn,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    final hasDiscrepancy = value != declaredIn;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: hasDiscrepancy
            ? AppColors.cordilleraOchre.withValues(alpha: 0.08)
            : AppColors.alpineChalk,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasDiscrepancy
              ? AppColors.cordilleraOchre
              : AppColors.glacialBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.basaltInk),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.basaltInk,
                  ),
                ),
                Text(
                  'Subió con: $declaredIn',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: hasDiscrepancy
                        ? AppColors.cordilleraOchre
                        : AppColors.graniteMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.basaltInk),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 14),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  onPressed: value > 0 ? () => onChanged(value - 1) : null,
                ),
                SizedBox(
                  width: 22,
                  child: Text(
                    '$value',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.basaltInk,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 14),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  onPressed: () => onChanged(value + 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
