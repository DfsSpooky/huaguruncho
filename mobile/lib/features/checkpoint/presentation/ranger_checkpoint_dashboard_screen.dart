import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/checkpoint_model.dart';
import 'checkpoint_controller.dart';
import 'ranger_checkout_dialog.dart';

class RangerCheckpointDashboardScreen extends ConsumerStatefulWidget {
  const RangerCheckpointDashboardScreen({super.key});

  @override
  ConsumerState<RangerCheckpointDashboardScreen> createState() =>
      _RangerCheckpointDashboardScreenState();
}

class _RangerCheckpointDashboardScreenState
    extends ConsumerState<RangerCheckpointDashboardScreen> {
  String _searchQuery = '';
  int _selectedFilterIndex = 0; // 0: En Montaña, 1: Auditados, 2: Todos
  bool _showDidacticGuide = true;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatElapsed(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inHours > 0) {
      return 'HACE ${diff.inHours}H ${diff.inMinutes % 60}M';
    } else if (diff.inMinutes > 0) {
      return 'HACE ${diff.inMinutes}M';
    } else {
      return 'RECIENTE';
    }
  }

  Widget _buildRestrictedAccessScaffold(BuildContext context, bool isAuthenticated) {
    return Scaffold(
      backgroundColor: AppColors.alpineChalk,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'GARITA GUARDAPARQUES · HUACHÓN',
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
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.basaltInk, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.basaltInk,
                  offset: Offset(2.5, 2.5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.error,
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    color: AppColors.error,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ACCESO RESTRINGIDO · PERSONAL AUTORIZADO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: AppColors.basaltInk,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'El módulo de Puesto de Control y Custodia de Residuos es de uso exclusivo para Guardaparques SERNANP y operadores acreditados de la Municipalidad de Huachón.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.graniteMuted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                if (!isAuthenticated)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/login'),
                      icon: const Icon(Icons.badge_outlined, size: 18),
                      label: const Text('INICIAR SESIÓN COMO GUARDAPARQUE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cordilleraOchre,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (!isAuthenticated) const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.canPop() ? context.pop() : context.go('/'),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('VOLVER AL PANEL DE EXPEDICIÓN'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final isAuthorized =
        authState.isAuthenticated && (user?.isRangerOrAdmin ?? false);

    if (!isAuthorized) {
      return _buildRestrictedAccessScaffold(context, authState.isAuthenticated);
    }

    final controllerState = ref.watch(checkpointControllerProvider);
    final allEntriesAsync = ref.watch(allCheckpointStreamProvider);
    final operatorLabel = user!.fullName;

    return Scaffold(
      backgroundColor: AppColors.alpineChalk,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.shield_outlined, color: AppColors.yaretaPine, size: 16),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'GARITA GUARDAPARQUES · HUACHÓN',
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
              '$operatorLabel · Control SERNANP',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.graniteMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Guía didáctica del protocolo',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _showDidacticGuide
                    ? AppColors.cordilleraOchre.withValues(alpha: 0.15)
                    : AppColors.alpineChalk,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _showDidacticGuide
                      ? AppColors.cordilleraOchre
                      : AppColors.basaltInk,
                ),
              ),
              child: Icon(
                Icons.school_outlined,
                color: _showDidacticGuide
                    ? AppColors.cordilleraOchre
                    : AppColors.basaltInk,
                size: 16,
              ),
            ),
            onPressed: () =>
                setState(() => _showDidacticGuide = !_showDidacticGuide),
          ),
          IconButton(
            tooltip: 'Sincronizar lote con servidor',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.alpineChalk,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.basaltInk),
              ),
              child: controllerState.isSyncing
                  ? const SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                        color: AppColors.cordilleraOchre,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.sync_rounded, color: AppColors.basaltInk, size: 16),
            ),
            onPressed: controllerState.isSyncing
                ? null
                : () async {
                    await ref.read(checkpointControllerProvider.notifier).syncNow();
                    final updatedState = ref.read(checkpointControllerProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            updatedState.successMessage ??
                                updatedState.error ??
                                'Sincronización procesada.',
                          ),
                          backgroundColor: updatedState.error != null
                              ? AppColors.error
                              : AppColors.yaretaPine,
                        ),
                      );
                    }
                  },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: allEntriesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.cordilleraOchre),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error cargando registros locales: $err'),
          ),
        ),
        data: (allEntries) {
          final inMountain = allEntries.where((e) => e.isInMountain).toList();
          final completed = allEntries.where((e) => e.isCompleted).toList();
          final pendingSyncCount = allEntries.where((e) => !e.isSynced).length;
          final totalWasteInTransit =
              inMountain.fold<int>(0, (sum, e) => sum + e.totalItemsIn);

          List<CheckpointModel> displayedList;
          if (_selectedFilterIndex == 0) {
            displayedList = inMountain;
          } else if (_selectedFilterIndex == 1) {
            displayedList = completed;
          } else {
            displayedList = allEntries;
          }

          if (_searchQuery.trim().isNotEmpty) {
            final q = _searchQuery.toLowerCase().trim();
            displayedList = displayedList.where((e) {
              return e.visitorName.toLowerCase().contains(q) ||
                  e.documentNumber.toLowerCase().contains(q) ||
                  e.routeName.toLowerCase().contains(q) ||
                  e.phoneNumber.toLowerCase().contains(q);
            }).toList();
          }

          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Panel de Telemetría de Garita 2.0
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.basaltInk,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.basaltInk, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.cordilleraOchre,
                              offset: Offset(2.5, 2.5),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.storage_rounded,
                                  size: 13,
                                  color: Color(0xFF6EE7B7),
                                ),
                                const SizedBox(width: 6),
                                const Expanded(
                                  child: Text(
                                    'MOTOR SQLITE DRIFT · CUSTODIA OFFLINE',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: pendingSyncCount > 0
                                        ? AppColors.cordilleraOchre
                                        : AppColors.yaretaPine,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    pendingSyncCount > 0
                                        ? '$pendingSyncCount POR SINCRONIZAR'
                                        : 'SINCRONIZADO',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMetricTile(
                                    title: 'EN MONTAÑA',
                                    value: '${inMountain.length}',
                                    subtitle:
                                        '${inMountain.fold<int>(0, (s, e) => s + e.groupSize)} PERSONAS',
                                    accent: const Color(0xFF6EE7B7),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildMetricTile(
                                    title: 'RESIDUOS ARRIBA',
                                    value: '$totalWasteInTransit',
                                    subtitle: 'EN CUSTODIA',
                                    accent: AppColors.cordilleraOchre,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildMetricTile(
                                    title: 'AUDITADOS',
                                    value: '${completed.length}',
                                    subtitle: 'DESCENDIDOS',
                                    accent: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 2. Tarjeta Didáctica del Flujo SERNANP Huella Cero
                      if (_showDidacticGuide) ...[
                        const SizedBox(height: 12),
                        _buildDidacticProtocolCard(context),
                      ],

                      const SizedBox(height: 12),

                      // 3. Buscador y Pestañas de Filtrado
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.basaltInk, width: 1.2),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.basaltInk,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Buscar por DNI, visitante o ruta...',
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              size: 18,
                              color: AppColors.cordilleraOchre,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 17),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 11,
                              horizontal: 12,
                            ),
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildFilterChip('EN MONTAÑA (${inMountain.length})', 0),
                          const SizedBox(width: 6),
                          _buildFilterChip('AUDITADOS (${completed.length})', 1),
                          const SizedBox(width: 6),
                          _buildFilterChip('TODOS (${allEntries.length})', 2),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Lista de Actas de Control
              if (displayedList.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.glacialBorder),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.fact_check_outlined,
                            size: 40,
                            color: AppColors.cordilleraOchre,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'SIN COINCIDENCIAS PARA "$_searchQuery"'
                                : _selectedFilterIndex == 0
                                    ? 'SIN GRUPOS ACTIVOS EN ASCENSO'
                                    : 'BANDEJA DE ACTAS VACÍA',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.basaltInk,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Prueba con otro número de documento o nombre.'
                                : _selectedFilterIndex == 0
                                    ? 'Registra el acta de ingreso y custodia de residuos de una expedición antes de su ascenso al glaciar.'
                                    : 'Cuando audites el descenso de un grupo en montaña, su acta aparecerá aquí.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.graniteMuted,
                              height: 1.4,
                            ),
                          ),
                          if (_searchQuery.isEmpty && _selectedFilterIndex == 0) ...[
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  context.push('/ranger-checkpoint/checkin'),
                              icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                              label: const Text('NUEVO CHECK-IN'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.basaltInk,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 38),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = displayedList[index];
                        return _buildVisitorCard(context, entry);
                      },
                      childCount: displayedList.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.cordilleraOchre,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.basaltInk, width: 1.5),
        ),
        onPressed: () => context.push('/ranger-checkpoint/checkin'),
        icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
        label: const Text(
          'REGISTRAR INGRESO',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 11.5,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDidacticProtocolCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
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
                  color: AppColors.cordilleraOchre,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'GUÍA DIDÁCTICA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '¿CÓMO FUNCIONA EL CONTROL HUELLA CERO?',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.basaltInk,
                  ),
                ),
              ),
              InkWell(
                onTap: () => setState(() => _showDidacticGuide = false),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColors.graniteMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepColumn(
                step: '01 · SUBIDA',
                title: 'Declarar Envases',
                desc: 'Registra DNI, ruta y cuenta plásticos, latas y pilas que ingresan.',
                color: AppColors.cordilleraOchre,
              ),
              const SizedBox(width: 8),
              _buildStepColumn(
                step: '02 · CUMBRE',
                title: 'Custodia Offline',
                desc: 'El acta queda en SQLite local aunque no exista señal en la quebrada.',
                color: AppColors.basaltInk,
              ),
              const SizedBox(width: 8),
              _buildStepColumn(
                step: '03 · BAJADA',
                title: 'Auditar 100%',
                desc: 'Verifica el retorno físico de cada empaque al bajar a Huachón.',
                color: AppColors.yaretaPine,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepColumn({
    required String step,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.alpineChalk,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.glacialBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              step,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                color: AppColors.basaltInk,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: const TextStyle(
                fontSize: 9.5,
                color: AppColors.graniteMuted,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedFilterIndex = index),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.basaltInk : AppColors.pureWhite,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.basaltInk,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: isSelected ? Colors.white : AppColors.basaltInk,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisitorCard(BuildContext context, CheckpointModel entry) {
    final isInMountain = entry.isInMountain;
    final totalIn = entry.totalItemsIn;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.basaltInk,
          width: isInMountain ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1814171A),
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isInMountain
                      ? AppColors.cordilleraOchre
                      : AppColors.yaretaPine,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  isInMountain
                      ? Icons.terrain_rounded
                      : Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.visitorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.basaltInk,
                      ),
                    ),
                    Text(
                      '${entry.documentType}: ${entry.documentNumber} · ${entry.groupSize} PERS.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.graniteMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isInMountain
                      ? AppColors.basaltInk
                      : entry.wasteComplianceStatus == 'missing_waste'
                          ? AppColors.error
                          : AppColors.yaretaPine,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isInMountain
                      ? 'EN MONTAÑA'
                      : entry.wasteComplianceStatus == 'compliant'
                          ? '✓ 100% RETORNADO'
                          : entry.wasteComplianceStatus == 'extra_collected'
                              ? '★ + RESIDUOS'
                              : '⚠ INFRACCIÓN',
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.explore_outlined,
                size: 13,
                color: AppColors.cordilleraOchre,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  entry.routeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.basaltInk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatElapsed(entry.entryDateTime),
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.graniteMuted,
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: AppColors.glacialBorder),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: [
                    if (entry.plasticBottlesIn > 0)
                      _buildWastePill('BOTELLAS: ${entry.plasticBottlesIn}'),
                    if (entry.cansIn > 0)
                      _buildWastePill('LATAS: ${entry.cansIn}'),
                    if (entry.plasticWrappersIn > 0)
                      _buildWastePill('SNACKS: ${entry.plasticWrappersIn}'),
                    if (entry.plasticBagsIn > 0)
                      _buildWastePill('BOLSAS: ${entry.plasticBagsIn}'),
                    if (entry.gasCanistersIn > 0)
                      _buildWastePill('GAS: ${entry.gasCanistersIn}'),
                    if (entry.batteriesIn > 0)
                      _buildWastePill('PILAS: ${entry.batteriesIn}'),
                    if (totalIn == 0)
                      _buildWastePill('SIN RESIDUOS DECLARADOS'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.alpineChalk,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.glacialBorder),
                ),
                child: Text(
                  'TOTAL: $totalIn',
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.basaltInk,
                  ),
                ),
              ),
            ],
          ),
          if (isInMountain) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => RangerCheckoutDialog(entry: entry),
                );
              },
              icon: const Icon(Icons.checklist_rtl_rounded, size: 16),
              label: const Text(
                'AUDITAR RETORNO / CHECK-OUT',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yaretaPine,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.alpineChalk,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.glacialBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: AppColors.yaretaPine,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'RETORNARON ${entry.totalItemsOut} DE $totalIn EMPAQUES',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.basaltInk,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    entry.isSynced ? '✓ SYNC' : 'SQLITE LOCAL',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: entry.isSynced
                          ? AppColors.yaretaPine
                          : AppColors.graniteMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWastePill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.alpineChalk,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.glacialBorder),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          color: AppColors.basaltInk,
        ),
      ),
    );
  }
}
