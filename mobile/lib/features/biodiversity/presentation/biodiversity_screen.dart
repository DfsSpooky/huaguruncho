import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../domain/species_model.dart';
import 'biodiversity_controller.dart';

class BiodiversityScreen extends ConsumerStatefulWidget {
  const BiodiversityScreen({super.key});

  @override
  ConsumerState<BiodiversityScreen> createState() => _BiodiversityScreenState();
}

class _BiodiversityScreenState extends ConsumerState<BiodiversityScreen> {
  final List<String> _categories = [
    'Todos',
    'Flora Nativa',
    'Fauna Silvestre',
    'Aves de Altura',
    'Endémicas',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedBiodiversityCategoryProvider);
    final speciesAsync = ref.watch(biodiversityListProvider);

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
            Text(
              'Biodiversidad Altoandina',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: AppColors.basaltInk,
              ),
            ),
            Text(
              'HERBARIO Y FAUNA ENDÉMICA · ECORREGIÓN PUNA HÚMEDA',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: AppColors.graniteMuted,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.alpineChalk,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.basaltInk),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                size: 16,
                color: AppColors.basaltInk,
              ),
            ),
            tooltip: 'Actualizar Catálogo',
            onPressed: () => ref.refresh(biodiversityListProvider),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // Banner Didáctico de Conservación 2.0
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.basaltInk,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.basaltInk, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.yaretaPine,
                  offset: Offset(2.5, 2.5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.eco_outlined, color: Color(0xFF6EE7B7), size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RESERVA DE BIODIVERSIDAD GLACIAR · HUAGURUNCHO',
                        style: TextStyle(
                          color: Color(0xFF6EE7B7),
                          fontWeight: FontWeight.w900,
                          fontSize: 9.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Los bofedales y bosques de Polylepis (Quenual) almacenan el agua del glaciar. Observa a más de 15 metros sin alterar su hábitat.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Selector de Categorías 2.0
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = selectedCategory == cat;
                return InkWell(
                  onTap: () {
                    ref.read(selectedBiodiversityCategoryProvider.notifier).state =
                        cat;
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.basaltInk
                          : AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.basaltInk,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      cat.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.basaltInk,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 6),

          // Lista de Especies
          Expanded(
            child: speciesAsync.when(
              loading: () => const LoadingIndicator(
                message: 'Consultando catálogo de biodiversidad...',
              ),
              error: (err, _) => ErrorView(
                message: 'No se pudo cargar la biodiversidad.',
                onRetry: () => ref.refresh(biodiversityListProvider),
              ),
              data: (speciesList) {
                if (speciesList.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay especies registradas en esta categoría.',
                      style: TextStyle(
                        color: AppColors.graniteMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(biodiversityListProvider),
                  color: AppColors.yaretaPine,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
                    itemCount: speciesList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final species = speciesList[index];
                      return _SpeciesCard(
                        species: species,
                        onTap: () => _showSpeciesDetailSheet(context, species),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSpeciesDetailSheet(BuildContext context, SpeciesModel species) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.80,
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(color: AppColors.basaltInk, width: 1.5),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.basaltInk,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSpeciesImage(species, size: 74),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  species.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.basaltInk,
                                  ),
                                ),
                                if (species.quechuaName.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'QUECHUA: ${species.quechuaName.toUpperCase()}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.yaretaPine,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 2),
                                Text(
                                  species.scientificName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.graniteMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildStatusBadge(
                            species.conservationStatusDisplay.isNotEmpty
                                ? species.conservationStatusDisplay
                                : species.conservationStatus,
                          ),
                          if (species.isEndemic)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.cordilleraOchre,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '★ ESPECIE ENDÉMICA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 9.5,
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.alpineChalk,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.basaltInk),
                            ),
                            child: Text(
                              species.altitudeRange.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.basaltInk,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: AppColors.glacialBorder),
                      const Text(
                        'FICHA TAXONÓMICA Y MORFOLOGÍA',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.basaltInk,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        species.summary,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.basaltInk,
                          height: 1.45,
                        ),
                      ),
                      if (species.ecologicalRole.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'ROL ECOLÓGICO E HÍDRICO EN LA PUNA',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.yaretaPine,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          species.ecologicalRole,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.basaltInk,
                            height: 1.4,
                          ),
                        ),
                      ],
                      if (species.conservationTip.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.alpineChalk,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.basaltInk),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.shield_outlined,
                                color: AppColors.cordilleraOchre,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'PROTOCOLO DE AVISTAMIENTO NO DEJE RASTRO',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 10.5,
                                        color: AppColors.basaltInk,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      species.conservationTip,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.graniteMuted,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(
                            Icons.report_problem_outlined,
                            color: Color(0xFFB91C1C),
                            size: 17,
                          ),
                          label: const Text(
                            'REPORTAR AMENAZA O AVISTAMIENTO EN RUTA',
                            style: TextStyle(
                              color: Color(0xFFB91C1C),
                              fontWeight: FontWeight.w900,
                              fontSize: 11.5,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFB91C1C),
                              width: 1.4,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/create-report');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpeciesImage(SpeciesModel species, {required double size}) {
    final url = species.imageUrl;
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('assets/')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackAvatar(species, size),
          ),
        );
      } else if (url.startsWith('http')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackAvatar(species, size),
          ),
        );
      }
    }
    return _buildFallbackAvatar(species, size);
  }

  Widget _buildFallbackAvatar(SpeciesModel species, double size) {
    IconData icon;
    switch (species.category) {
      case 'flora':
        icon = Icons.local_florist_rounded;
        break;
      case 'aves':
        icon = Icons.flight_takeoff_rounded;
        break;
      case 'fauna':
        icon = Icons.pets_rounded;
        break;
      default:
        icon = Icons.eco_rounded;
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.alpineChalk,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.basaltInk),
      ),
      child: Icon(icon, color: AppColors.yaretaPine, size: size * 0.45),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    if (status.contains('Peligro') ||
        status.contains('EN') ||
        status.contains('CR')) {
      bg = const Color(0xFFB91C1C);
    } else if (status.contains('Vulnerable') || status.contains('VU')) {
      bg = AppColors.cordilleraOchre;
    } else {
      bg = AppColors.yaretaPine;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 9.5,
        ),
      ),
    );
  }
}

class _SpeciesCard extends StatelessWidget {
  final SpeciesModel species;
  final VoidCallback onTap;

  const _SpeciesCard({required this.species, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            _buildThumb(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          species.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.basaltInk,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (species.isEndemic)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cordilleraOchre,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ENDÉMICA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (species.quechuaName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Quechua: ${species.quechuaName}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.yaretaPine,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  Text(
                    species.scientificName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: AppColors.graniteMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.terrain_rounded,
                        size: 13,
                        color: AppColors.cordilleraOchre,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          species.altitudeRange,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.basaltInk,
                          ),
                        ),
                      ),
                      const Text(
                        'FICHA →',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.basaltInk,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumb() {
    final url = species.imageUrl;
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('assets/')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            url,
            width: 58,
            height: 58,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildThumbIcon(),
          ),
        );
      } else if (url.startsWith('http')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            width: 58,
            height: 58,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildThumbIcon(),
          ),
        );
      }
    }
    return _buildThumbIcon();
  }

  Widget _buildThumbIcon() {
    IconData icon;
    switch (species.category) {
      case 'flora':
        icon = Icons.local_florist_rounded;
        break;
      case 'aves':
        icon = Icons.flight_takeoff_rounded;
        break;
      case 'fauna':
        icon = Icons.pets_rounded;
        break;
      default:
        icon = Icons.eco_rounded;
    }
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.alpineChalk,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.basaltInk),
      ),
      child: Icon(icon, color: AppColors.yaretaPine, size: 26),
    );
  }
}
