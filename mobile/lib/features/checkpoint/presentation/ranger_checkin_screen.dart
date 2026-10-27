import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';
import 'checkpoint_controller.dart';

class RangerCheckinScreen extends ConsumerStatefulWidget {
  const RangerCheckinScreen({super.key});

  @override
  ConsumerState<RangerCheckinScreen> createState() => _RangerCheckinScreenState();
}

class _RangerCheckinScreenState extends ConsumerState<RangerCheckinScreen> {
  final _formKey = GlobalKey<FormState>();

  final _visitorNameController = TextEditingController();
  final _documentNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _guideNameController = TextEditingController();
  final _otherWasteController = TextEditingController();

  String _documentType = 'DNI';
  int _groupSize = 1;
  String _routeName = 'Huachón – Mirador Nevado Huaguruncho';

  final List<String> _routeOptions = [
    'Huachón – Mirador Nevado Huaguruncho',
    'Ruta Laguna Huascacocha y Glaciar',
    'Travesía Completa Cordillera Huaguruncho',
    'Circuito Quebrada Añilcocha',
    'Otro Sendero / Exploración',
  ];

  // Residuos declarados en ascenso
  int _bottlesIn = 2;
  int _cansIn = 0;
  int _wrappersIn = 3;
  int _bagsIn = 2;
  int _batteriesIn = 0;
  int _gasIn = 0;

  @override
  void dispose() {
    _visitorNameController.dispose();
    _documentNumberController.dispose();
    _phoneController.dispose();
    _guideNameController.dispose();
    _otherWasteController.dispose();
    super.dispose();
  }

  int get _totalIn =>
      _bottlesIn + _cansIn + _wrappersIn + _bagsIn + _batteriesIn + _gasIn;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(checkpointControllerProvider.notifier);
    final success = await controller.registerCheckin(
      visitorName: _visitorNameController.text.trim(),
      documentType: _documentType,
      documentNumber: _documentNumberController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      groupSize: _groupSize,
      routeName: _routeName,
      guideName: _guideNameController.text.trim().isNotEmpty
          ? _guideNameController.text.trim()
          : null,
      plasticBottlesIn: _bottlesIn,
      cansIn: _cansIn,
      plasticWrappersIn: _wrappersIn,
      plasticBagsIn: _bagsIn,
      batteriesIn: _batteriesIn,
      gasCanistersIn: _gasIn,
      otherWasteDetailsIn: _otherWasteController.text.trim().isNotEmpty
          ? _otherWasteController.text.trim()
          : null,
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Acta de ascenso registrada en SQLite local (Offline).'),
          backgroundColor: AppColors.yaretaPine,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isAuthorized =
        authState.isAuthenticated && (authState.user?.isRangerOrAdmin ?? false);

    if (!isAuthorized) {
      return Scaffold(
        backgroundColor: AppColors.alpineChalk,
        appBar: AppBar(
          backgroundColor: AppColors.pureWhite,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'ACTA DE INGRESO & CUSTODIA',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
              color: AppColors.basaltInk,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_person_rounded,
                  color: AppColors.error,
                  size: 40,
                ),
                const SizedBox(height: 12),
                const Text(
                  'ACCESO RESTRINGIDO A GUARDAPARQUES',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.basaltInk,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/'),
                  child: const Text('VOLVER'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final controllerState = ref.watch(checkpointControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.alpineChalk,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fact_check_outlined, color: AppColors.cordilleraOchre, size: 16),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'ACTA DE INGRESO & CUSTODIA',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                      color: AppColors.basaltInk,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Garita Huachón · Protocolo SERNANP Huella Cero',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.graniteMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner Didáctico Offline 2.0
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.basaltInk,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.basaltInk, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cordilleraOchre,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.storage_rounded, color: Color(0xFF6EE7B7), size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REGISTRO LOCAL SQLITE DRIFT · 100% OFFLINE',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF6EE7B7),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Esta acta registra al grupo que asciende al glaciar y contabiliza cada empaque plástico o batería que debe retornar obligatoriamente al descender.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.white,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // SECCIÓN 01: IDENTIFICACIÓN DEL EXPEDICIONARIO
              _buildSectionCard(
                stepBadge: '01',
                title: 'IDENTIFICACIÓN DEL LÍDER DE EXPEDICIÓN',
                subtitle: 'Responsable legal del grupo ante la Garita Huachón.',
                children: [
                  TextFormField(
                    controller: _visitorNameController,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(
                      labelText: 'Nombre Completo del Responsable *',
                      hintText: 'Ej. Mateo Quispe Condori',
                      prefixIcon: Icon(Icons.person_outline_rounded, size: 19),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Ingresa el nombre del responsable'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: DropdownButtonFormField<String>(
                          initialValue: _documentType,
                          isExpanded: true,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.basaltInk,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Tipo Doc.',
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'DNI', child: Text('DNI')),
                            DropdownMenuItem(value: 'Pasaporte', child: Text('Pasap.')),
                            DropdownMenuItem(value: 'C.E.', child: Text('C.E.')),
                          ],
                          onChanged: (v) => setState(() => _documentType = v ?? 'DNI'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 6,
                        child: TextFormField(
                          controller: _documentNumberController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                          decoration: const InputDecoration(
                            labelText: 'N° Documento *',
                            hintText: 'Ej. 72849102',
                            prefixIcon: Icon(Icons.badge_outlined, size: 18),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Ingresa el documento'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          decoration: const InputDecoration(
                            labelText: 'Celular / Emergencia',
                            hintText: '+51 9XX XXX XXX',
                            prefixIcon: Icon(Icons.phone_outlined, size: 18),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.alpineChalk,
                            border: Border.all(color: AppColors.basaltInk),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'INTEGRANTES',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.graniteMuted,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: _groupSize > 1
                                        ? () => setState(() => _groupSize--)
                                        : null,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.pureWhite,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: AppColors.glacialBorder),
                                      ),
                                      child: const Icon(Icons.remove, size: 14),
                                    ),
                                  ),
                                  Text(
                                    '$_groupSize',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      color: AppColors.basaltInk,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => setState(() => _groupSize++),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.pureWhite,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: AppColors.glacialBorder),
                                      ),
                                      child: const Icon(Icons.add, size: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // SECCIÓN 02: CORREDOR DE ASCENSO
              _buildSectionCard(
                stepBadge: '02',
                title: 'SECTOR Y CORREDOR DE ASCENSO',
                subtitle: 'Permite triangular la ruta en caso de operativo de búsqueda.',
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _routeName,
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.basaltInk,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Corredor Oficial Seleccionado',
                      prefixIcon: Icon(Icons.terrain_rounded, size: 18),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                    items: _routeOptions
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(
                              r,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12.5),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _routeName = v ?? _routeOptions.first),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _guideNameController,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(
                      labelText: 'Guía Local o Arriero Acreditado (Opcional)',
                      prefixIcon: Icon(Icons.hiking_rounded, size: 18),
                      hintText: 'Ej. Asociación de Arrieros Huachón',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // SECCIÓN 03: INVENTARIO DE RESIDUOS SÓLIDOS (RETORNO OBLIGATORIO)
              _buildSectionCard(
                stepBadge: '03',
                title: 'DECLARACIÓN DE EMPAQUES (HUELLA CERO)',
                subtitle:
                    'A 4,800 m s.n.m. el plástico tarda +400 años en degradarse. Cuenta todo envase que sube con el grupo.',
                children: [
                  _buildWasteRow(
                    icon: Icons.local_drink_rounded,
                    title: 'Botellas PET (Agua, rehidratantes)',
                    impactNote: 'Riesgo de microplásticos en bofedales',
                    value: _bottlesIn,
                    onChanged: (v) => setState(() => _bottlesIn = v),
                  ),
                  _buildWasteRow(
                    icon: Icons.soup_kitchen_rounded,
                    title: 'Latas y Conservas (Atún, bebidas)',
                    impactNote: 'Oxidación lenta en morrenas glaciares',
                    value: _cansIn,
                    onChanged: (v) => setState(() => _cansIn = v),
                  ),
                  _buildWasteRow(
                    icon: Icons.cookie_rounded,
                    title: 'Envoltorios metalizados (Barras, snacks)',
                    impactNote: 'Peligro de ingesta por fauna altoandina',
                    value: _wrappersIn,
                    onChanged: (v) => setState(() => _wrappersIn = v),
                  ),
                  _buildWasteRow(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Bolsas plásticas y empaques',
                    impactNote: 'Dispersión por vientos de cumbre',
                    value: _bagsIn,
                    onChanged: (v) => setState(() => _bagsIn = v),
                  ),
                  _buildWasteRow(
                    icon: Icons.battery_charging_full_rounded,
                    title: 'Pilas y baterías de litio',
                    impactNote: 'Alta toxicidad para aguas de Huascacocha',
                    value: _batteriesIn,
                    onChanged: (v) => setState(() => _batteriesIn = v),
                  ),
                  _buildWasteRow(
                    icon: Icons.propane_tank_rounded,
                    title: 'Balones de gas / cartuchos camping',
                    impactNote: 'Residuo presurizado de retorno estricto',
                    value: _gasIn,
                    onChanged: (v) => setState(() => _gasIn = v),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _otherWasteController,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      labelText: 'Otros envases o equipo descartable (Opcional)',
                      hintText: 'Ej. Envase de vidrio, cartón, cinta...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Totalizador Táctico 2.0
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.basaltInk,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.basaltInk),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'COMPROMISO DE RETORNO OBLIGATORIO',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Protocolo Leave No Trace (No Deje Rastro)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.cordilleraOchre,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$_totalIn ÍTEMS',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Botón Guardar 2.0
              ElevatedButton(
                onPressed: controllerState.isSaving ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yaretaPine,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.basaltInk, width: 1.5),
                  ),
                  elevation: 0,
                ),
                child: controllerState.isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_outlined, size: 18),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'REGISTRAR ASCENSO EN CUSTODIA LOCAL',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String stepBadge,
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.basaltInk, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1414171A),
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.basaltInk,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  stepBadge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.basaltInk,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.graniteMuted,
                height: 1.3,
              ),
            ),
          ],
          const Divider(height: 18, color: AppColors.glacialBorder),
          ...children,
        ],
      ),
    );
  }

  Widget _buildWasteRow({
    required IconData icon,
    required String title,
    required String impactNote,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.alpineChalk,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.glacialBorder),
            ),
            child: Icon(icon, size: 17, color: AppColors.basaltInk),
          ),
          const SizedBox(width: 10),
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
                  impactNote,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.graniteMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.alpineChalk,
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
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: value > 0 ? () => onChanged(value - 1) : null,
                ),
                SizedBox(
                  width: 24,
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
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
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
