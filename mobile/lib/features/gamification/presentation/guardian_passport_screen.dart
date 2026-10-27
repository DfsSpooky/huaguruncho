import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_translations.dart';
import '../data/guardian_repository.dart';
import '../domain/guardian_models.dart';

class GuardianPassportScreen extends ConsumerStatefulWidget {
  const GuardianPassportScreen({super.key});

  @override
  ConsumerState<GuardianPassportScreen> createState() => _GuardianPassportScreenState();
}

class _GuardianPassportScreenState extends ConsumerState<GuardianPassportScreen> {
  bool _isGpsScanning = false;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final badgesAsync = ref.watch(guardianBadgesProvider);
    final stampsAsync = ref.watch(passportStampsProvider);

    return Scaffold(
      backgroundColor: AppColors.alpineChalk,
      appBar: AppBar(
        backgroundColor: AppColors.basaltInk,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LIBRETA EXPEDICIONARIA · SERNANP',
              style: TextStyle(
                color: AppColors.cordilleraOchre,
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
            Text(
              AppTranslations.tr(lang, 'tab_passport'),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16.5,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Sincronizar Sellos',
            onPressed: () {
              ref.invalidate(guardianBadgesProvider);
              ref.invalidate(passportStampsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.yaretaPine,
        onRefresh: () async {
          ref.invalidate(guardianBadgesProvider);
          ref.invalidate(passportStampsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGuardianHeader(context, lang),
              const SizedBox(height: 18),
              _buildPassportStampsSection(context, stampsAsync, lang),
              const SizedBox(height: 22),
              _buildBadgesShelfSection(context, badgesAsync, lang),
              const SizedBox(height: 22),
              _buildLeaveNoTraceCard(context, lang),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuardianHeader(BuildContext context, AppLanguage lang) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.basaltInk,
        border: Border(
          bottom: BorderSide(color: AppColors.cordilleraOchre, width: 2.0),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2429),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.cordilleraOchre.withValues(alpha: 0.16),
                        border: Border.all(color: AppColors.cordilleraOchre, width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(Icons.military_tech_rounded, color: AppColors.cordilleraOchre, size: 30),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: AppColors.cordilleraOchre,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'RANGO 02 · CENTINELA ACTIVO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Guardián de Huascacocha',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '350 / 500 XP · Próximo grado: Apu Guardián Glacial',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.72),
                              fontSize: 11.5,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.70,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cordilleraOchre),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassportStampsSection(
    BuildContext context,
    AsyncValue<List<TrailPassportStampModel>> stampsAsync,
    AppLanguage lang,
  ) {
    final stamps = stampsAsync.valueOrNull ?? [];
    final collectedCount = stamps.where((s) => s.isCollected).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CARTOGRAFÍA DE HITOS · SELLOS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: AppColors.cordilleraOchre,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppTranslations.tr(lang, 'stamps_title'),
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.basaltInk,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.basaltInk,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$collectedCount / ${stamps.length} TIMBRADOS',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.cordilleraOchre,
                    letterSpacing: 0.6,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Timbra cada hito acercándote a menos de 250 m con tu GPS o ingresando el código grabado en la estela física.',
            style: TextStyle(fontSize: 12, color: AppColors.graniteMuted, height: 1.35),
          ),
          const SizedBox(height: 12),
          // Consola de Validación GPS Activa 2.0
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.basaltInk,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.basaltInk, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cordilleraOchre,
                  offset: Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.yaretaPine.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.yaretaPine),
                  ),
                  child: const Icon(Icons.satellite_alt_rounded, color: Color(0xFF6EE7B7), size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RADAR DE TIMBRADO SATELITAL',
                        style: TextStyle(
                          color: Color(0xFF6EE7B7),
                          fontWeight: FontWeight.w900,
                          fontSize: 9.5,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Validación Glaciar por GPS (<250m) o Código de Estela',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _isGpsScanning ? null : () => _scanNearbyStamps(stamps),
                  icon: _isGpsScanning
                      ? const SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.my_location_rounded, size: 14),
                  label: Text(_isGpsScanning ? 'ESCANEANDO' : 'ESCANEAR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cordilleraOchre,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10.5, letterSpacing: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          stampsAsync.when(
            data: (stampsList) => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.08,
              ),
              itemCount: stampsList.length,
              itemBuilder: (context, index) {
                final stamp = stampsList[index];
                return _buildStampCard(context, stamp);
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildStampCard(BuildContext context, TrailPassportStampModel stamp) {
    final collected = stamp.isCollected;
    return InkWell(
      onTap: () => _showStampDetailsModal(context, stamp),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: collected ? AppColors.yaretaPine : AppColors.basaltInk,
            width: collected ? 1.6 : 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1414171A),
              offset: Offset(2, 2),
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: collected
                        ? AppColors.forestGreen.withValues(alpha: 0.12)
                        : AppColors.twilightNavy.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        collected ? Icons.verified_rounded : Icons.lock_outline_rounded,
                        color: collected ? AppColors.forestGreen : AppColors.textSecondary,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        collected ? 'TIMBRADO' : 'PENDIENTE',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: collected ? AppColors.forestGreen : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: AppColors.glacierBlueTint,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.glacialBorder),
                  ),
                  child: Text(
                    '${stamp.altitudeMasl}m',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.twilightNavy,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              stamp.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.twilightNavy,
                height: 1.15,
              ),
            ),
            if (stamp.quechuaName.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                stamp.quechuaName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                  color: AppColors.glacierTeal,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  collected ? Icons.check_circle_outline_rounded : Icons.qr_code_2_rounded,
                  size: 12,
                  color: collected ? AppColors.forestGreen : AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    collected ? 'Sello validado' : 'Tocar para validar GPS/Cód.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: collected ? AppColors.forestGreen : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesShelfSection(
    BuildContext context,
    AsyncValue<List<GuardianBadgeModel>> badgesAsync,
    AppLanguage lang,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CONDECORACIONES DE CONSERVACIÓN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: AppColors.glacierTeal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            AppTranslations.tr(lang, 'badges_title'),
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w900,
              color: AppColors.twilightNavy,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          badgesAsync.when(
            data: (badges) => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: badges.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final badge = badges[index];
                return _buildBadgeTile(context, badge);
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeTile(BuildContext context, GuardianBadgeModel badge) {
    final tierColor = _getTierColor(badge.tier);

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badge.isUnlocked ? tierColor.withValues(alpha: 0.6) : AppColors.glacialBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tierColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: tierColor, width: 1.5),
            ),
            child: Icon(
              badge.isUnlocked ? Icons.eco_rounded : Icons.lock_outline_rounded,
              color: tierColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        badge.title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.twilightNavy,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: AppColors.twilightNavy,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '+${badge.xpPoints} XP',
                        style: const TextStyle(
                          color: AppColors.sunGold,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  badge.description,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveNoTraceCard(BuildContext context, AppLanguage lang) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.forestGreen.withValues(alpha: 0.45), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.park_rounded, color: AppColors.forestGreen, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DECÁLOGO DE ALTA MONTAÑA · HUELLA CERO',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    Text(
                      'Compromiso No Deje Rastro (LNT)',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.twilightNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '1. Planifica y prepara tu expedición según ventana meteorológica.\n'
            '2. Camina y acampa únicamente sobre senderos y superficies resistentes.\n'
            '3. Regresa absolutamente todos tus residuos a la Garita Huachón.\n'
            '4. Deja lo que encuentres (prohibido extraer flora o tocar Puya Raimondi).\n'
            '5. Prohibido hacer fogatas abiertas en pajonales de puna.\n'
            '6. Mantén distancia de vicuñas, tarucas y aves altoandinas.\n'
            '7. Respeta las costumbres y chacras de la comunidad campesina de Huachón.',
            style: TextStyle(
              fontSize: 12,
              height: 1.55,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'diamante':
        return AppColors.glacierTeal;
      case 'oro':
        return const Color(0xFFD97706);
      case 'plata':
        return const Color(0xFF475569);
      default:
        return const Color(0xFFB45309);
    }
  }

  Future<void> _scanNearbyStamps(List<TrailPassportStampModel> stamps) async {
    setState(() => _isGpsScanning = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor activa el GPS en tu dispositivo.')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permiso de GPS denegado.')),
            );
          }
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final repo = ref.read(guardianRepositoryProvider);
      final List<TrailPassportStampModel> newlyUnlocked = [];

      for (final stamp in stamps) {
        if (!stamp.isCollected && stamp.latitude != null && stamp.longitude != null) {
          final distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            stamp.latitude!,
            stamp.longitude!,
          );
          if (distance <= 250) {
            await repo.markStampAsCollected(stamp.uuid);
            newlyUnlocked.add(stamp);
          }
        }
      }

      ref.invalidate(passportStampsProvider);

      if (mounted) {
        if (newlyUnlocked.isNotEmpty) {
          _showUnlockedCelebrationDialog(newlyUnlocked);
        } else {
          TrailPassportStampModel? nearest;
          double minDistance = double.infinity;
          for (final stamp in stamps) {
            if (stamp.latitude != null && stamp.longitude != null) {
              final d = Geolocator.distanceBetween(
                position.latitude,
                position.longitude,
                stamp.latitude!,
                stamp.longitude!,
              );
              if (d < minDistance) {
                minDistance = d;
                nearest = stamp;
              }
            }
          }
          final distText = minDistance < 1000
              ? '${minDistance.toStringAsFixed(0)} metros'
              : '${(minDistance / 1000).toStringAsFixed(1)} km';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                nearest != null
                    ? 'Estás a $distText de "${nearest.name}". Acércate a <250m o ingresa su código.'
                    : 'GPS activo. No se encontraron hitos a menos de 250m.',
              ),
              backgroundColor: AppColors.twilightNavy,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al conectar con satélite GPS: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGpsScanning = false);
      }
    }
  }

  Future<void> _validateSingleStampGps(BuildContext modalContext, TrailPassportStampModel stamp) async {
    Navigator.pop(modalContext);
    setState(() => _isGpsScanning = true);
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (stamp.latitude == null || stamp.longitude == null) {
        throw Exception('El hito no tiene coordenadas registradas.');
      }

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        stamp.latitude!,
        stamp.longitude!,
      );

      if (distance <= 250) {
        await ref.read(guardianRepositoryProvider).markStampAsCollected(stamp.uuid);
        ref.invalidate(passportStampsProvider);
        if (mounted) {
          _showUnlockedCelebrationDialog([stamp]);
        }
      } else {
        final distText = distance < 1000
            ? '${distance.toStringAsFixed(0)} metros'
            : '${(distance / 1000).toStringAsFixed(1)} km';
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Fuera de Rango GPS'),
              content: Text(
                'Te encuentras a $distText de "${stamp.name}".\n\nPara timbrar tu pasaporte debes estar a menos de 250 metros del hito geográfico, o ingresar el código secreto inscrito en la estela de control.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cerrar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.twilightNavy),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showRedeemCodeDialog(stamp);
                  },
                  child: const Text('Ingresar Código', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en validación GPS: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGpsScanning = false);
      }
    }
  }

  void _showRedeemCodeDialog(TrailPassportStampModel stamp) {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.qr_code_rounded, color: AppColors.glacierTeal),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Código de ${stamp.name}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingresa el código alfanumérico grabado en el hito de piedra o panel informativo:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Ej. ${stamp.secretCode}',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.vpn_key_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.glacierTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final input = codeController.text.trim().toUpperCase();
              if (input == stamp.secretCode.toUpperCase()) {
                await ref.read(guardianRepositoryProvider).markStampAsCollected(stamp.uuid);
                ref.invalidate(passportStampsProvider);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  _showUnlockedCelebrationDialog([stamp]);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Código inválido. Revisa la placa física del hito.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Validar Código'),
          ),
        ],
      ),
    );
  }

  void _showUnlockedCelebrationDialog(List<TrailPassportStampModel> unlocked) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: AppColors.sunGold, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡SELLO GLACIAR DESBLOQUEADO!',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.forestGreen,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Has validado con éxito tu presencia en:\n${unlocked.map((s) => '• ${s.name} (${s.altitudeMasl}m)').join('\n')}',
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.sunGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.sunGold),
              ),
              child: Text(
                '+${unlocked.length * 100} XP Sumados a tu Rango',
                style: const TextStyle(
                  color: Color(0xFFB7791F),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.twilightNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('¡Excelente!', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStampDetailsModal(BuildContext context, TrailPassportStampModel stamp) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final isCollected = stamp.isCollected;
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isCollected ? const Color(0xFFE8F5E9) : Colors.amber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCollected ? Icons.verified_rounded : Icons.lock_outline_rounded,
                  color: isCollected ? const Color(0xFF2E7D32) : Colors.amber[800],
                  size: 38,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                stamp.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              if (stamp.quechuaName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  stamp.quechuaName,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF00838F),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Altitud Oficial:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text('${stamp.altitudeMasl} m s.n.m.', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    if (stamp.latitude != null && stamp.longitude != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Coordenadas GPS:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(
                            '${stamp.latitude!.toStringAsFixed(4)}, ${stamp.longitude!.toStringAsFixed(4)}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Estado de Validación:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text(
                          isCollected ? 'Timbrado Oficialmente' : 'Pendiente por Validar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isCollected ? const Color(0xFF2E7D32) : Colors.amber[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (isCollected)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.twilightNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showRedeemCodeDialog(stamp);
                        },
                        icon: const Icon(Icons.pin_rounded, size: 16),
                        label: const Text('Código', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.glacierTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => _validateSingleStampGps(ctx, stamp),
                        icon: const Icon(Icons.satellite_alt_rounded, size: 16),
                        label: const Text('Validar GPS', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
