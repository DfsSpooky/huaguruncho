import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/storage/secure_storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final SecureStorageService _storage = SecureStorageService();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'index': '01 / 03',
      'tag': 'CARTOGRAFÍA INMERSIVA 360°',
      'coords': '10°31\'48"S · 5,742 M S.N.M.',
      'image': 'assets/images/huaguruncho_hero.jpg',
      'title': 'Exploración Fotogramétrica 360°',
      'description':
          'Inspecciona el macizo glaciar oriental del Nevado Huaguruncho mediante visores esféricos de alta resolución, hitos topográficos y audioguías en Quechua y Español.',
      'specLabel': 'COBERTURA VISUAL',
      'specValue': '12 Miradores Esféricos + Telemetría Solar',
    },
    {
      'index': '02 / 03',
      'tag': 'INSTRUMENTACIÓN AUTÓNOMA OFFLINE',
      'coords': 'QUEBRADA HUACHÓN · 4,250 M',
      'image': 'assets/images/huaguruncho_trekking.jpg',
      'title': 'Navegación GPS 100% Sin Red',
      'description':
          'Descarga cartas topográficas, perfiles de elevación y paquetes de ruta en memoria local para navegar con precisión satelital donde no existe cobertura celular.',
      'specLabel': 'AUTONOMÍA DE CAMPO',
      'specValue': 'Mapas Offline + Alerta de Desvío + SOS',
    },
    {
      'index': '03 / 03',
      'tag': 'PROTOCOLO HUELLA CERO & SERNANP',
      'coords': 'COMUNIDAD DE HUACHÓN · PASCO',
      'image': 'assets/images/huachon_village.jpg',
      'title': 'Bitácora & Auditoría Ambiental',
      'description':
          'Registra tu ingreso en la Garita Digital COEL, audita tus bolsas de residuos al retornar y reporta incidencias ecológicas georreferenciadas en tiempo real.',
      'specLabel': 'SINCRONIZACIÓN DIFERIDA',
      'specValue': 'SQLite Local → Servidor Municipal Huachón',
    },
  ];

  Future<void> _finish() async {
    await _storage.setOnboardingCompleted(true);
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alpineChalk,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Barra Superior de Instrumentación Editorial
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.pureWhite,
                border: Border(
                  bottom: BorderSide(color: AppColors.glacialBorder, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        color: AppColors.cordilleraOchre,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'MANUAL DE EXPEDICIÓN · V2.0',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.basaltInk,
                          letterSpacing: 0.9,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: _finish,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.alpineChalk,
                        border: Border.all(color: AppColors.glacialBorder),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'OMITIR →',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.basaltInk,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Carrusel Editorial de Fichas de Campo
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Marco Fotográfico con Retícula Topográfica
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.basaltInk, width: 1.5),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.basaltInk,
                                offset: Offset(3, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                item['image'] as String,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.basaltInk.withValues(alpha: 0.45),
                                      Colors.transparent,
                                      AppColors.basaltInk.withValues(alpha: 0.85),
                                    ],
                                  ),
                                ),
                              ),
                              // Esquina superior izquierda: Índice Editorial
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.basaltInk,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Text(
                                    'FICHA ${item['index']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                              // Esquina superior derecha: Coordenadas
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.basaltInk.withValues(alpha: 0.78),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item['coords'] as String,
                                    style: const TextStyle(
                                      color: Color(0xFFE2E8F0),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ),
                              // Pie de foto técnico
                              Positioned(
                                bottom: 12,
                                left: 12,
                                right: 12,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.cordilleraOchre,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Text(
                                        item['tag'] as String,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Tarjeta de Especificación Editorial
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.pureWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.glacialBorder, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.basaltInk,
                                  letterSpacing: -0.5,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item['description'] as String,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: AppColors.graniteMuted,
                                  height: 1.48,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Divider(color: AppColors.glacialBorder, height: 1),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['specLabel'] as String,
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.graniteMuted,
                                      letterSpacing: 0.7,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      item['specValue'] as String,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.yaretaPine,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 3. Consola Inferior de Control Táctil
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              decoration: const BoxDecoration(
                color: AppColors.pureWhite,
                border: Border(
                  top: BorderSide(color: AppColors.glacialBorder, width: 1),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          _pages.length,
                          (i) => Container(
                            margin: const EdgeInsets.only(right: 6),
                            width: _currentIndex == i ? 28 : 10,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentIndex == i
                                  ? AppColors.cordilleraOchre
                                  : AppColors.glacialBorder,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'ETAPA 0${_currentIndex + 1} DE 03',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.graniteMuted,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: () {
                      if (_currentIndex < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                        );
                      } else {
                        _finish();
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: _currentIndex == _pages.length - 1
                            ? AppColors.cordilleraOchre
                            : AppColors.basaltInk,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.basaltInk, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.basaltInk,
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentIndex == _pages.length - 1
                                ? 'Comenzar a Explorar'
                                : 'Siguiente',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
