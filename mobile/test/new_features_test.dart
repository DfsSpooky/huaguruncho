import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huaguruncho_360/features/biodiversity/domain/species_model.dart';
import 'package:huaguruncho_360/features/biodiversity/presentation/biodiversity_controller.dart';
import 'package:huaguruncho_360/features/biodiversity/presentation/biodiversity_screen.dart';
import 'package:huaguruncho_360/features/weather/domain/weather_model.dart';
import 'package:huaguruncho_360/features/weather/presentation/weather_controller.dart';
import 'package:huaguruncho_360/features/weather/presentation/mountain_weather_screen.dart';
import 'package:huaguruncho_360/features/safety/presentation/trekking_checklist_screen.dart';
import 'package:huaguruncho_360/features/community/domain/community_post_model.dart';
import 'package:huaguruncho_360/features/community/presentation/community_posts_controller.dart';
import 'package:huaguruncho_360/features/community/presentation/community_wall_screen.dart';
import 'package:huaguruncho_360/features/tours/domain/audio_guide_model.dart';
import 'package:huaguruncho_360/features/tours/presentation/audio_guides_controller.dart';
import 'package:huaguruncho_360/features/tours/presentation/audio_guides_screen.dart';
import 'package:huaguruncho_360/features/home/domain/community_service_model.dart';
import 'package:huaguruncho_360/features/home/presentation/community_services_controller.dart';
import 'package:huaguruncho_360/features/home/presentation/community_services_screen.dart';
import 'package:huaguruncho_360/features/gamification/presentation/guardian_passport_screen.dart';
import 'package:huaguruncho_360/features/offline/presentation/offline_package_manager_screen.dart';

void main() {
  testWidgets('BiodiversityScreen renders successfully with data', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          biodiversityListProvider.overrideWith((ref) => Future.value([
                const SpeciesModel(
                  uuid: 't1',
                  name: 'Puya Raimondi',
                  quechuaName: 'Tinkaq',
                  scientificName: 'Puya raimondii',
                  category: 'flora',
                  categoryDisplay: 'Flora Nativa',
                  altitudeRange: '3,800 - 4,400 m',
                  conservationStatus: 'EN',
                  conservationStatusDisplay: 'En Peligro (EN)',
                  summary: 'La reina de las plantas altoandinas.',
                ),
              ])),
        ],
        child: const MaterialApp(
          home: BiodiversityScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Biodiversidad Altoandina'), findsOneWidget);
    expect(find.text('Puya Raimondi'), findsWidgets);
  });

  testWidgets('MountainWeatherScreen renders successfully with data', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weatherStationsProvider.overrideWith((ref) => Future.value([
                const WeatherStationModel(
                  uuid: 'st1',
                  name: 'Laguna Huascacocha',
                  altitudeMasl: 4250,
                  tempDayCelsius: 6.0,
                  tempNightCelsius: -3.0,
                ),
              ])),
          weatherAlertsProvider.overrideWith((ref) => Future.value([])),
        ],
        child: const MaterialApp(
          home: MountainWeatherScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Clima y Monitoreo Glaciar'), findsOneWidget);
    expect(find.text('Laguna Huascacocha'), findsWidgets);
  });

  testWidgets('TrekkingChecklistScreen renders successfully', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TrekkingChecklistScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Mochila Virtual de Trekking'), findsOneWidget);
    expect(find.text('Peso Estimado Mochila'), findsOneWidget);
  });

  testWidgets('CommunityWallScreen renders successfully with data', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          communityPostsListProvider.overrideWith((ref) => Future.value([
                const CommunityPostModel(
                  uuid: 'p1',
                  authorName: 'Valeria Mendoza',
                  category: 'fotografia',
                  locationName: 'Laguna Huascacocha',
                  content: 'Amanecer despejado en el nevado.',
                ),
              ])),
        ],
        child: const MaterialApp(
          home: CommunityWallScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Muro de Centinelas Ecológicos'), findsOneWidget);
    expect(find.text('Compartir Relato'), findsOneWidget);
  });

  testWidgets('AudioGuidesScreen renders successfully with data', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioGuidesListProvider.overrideWith((ref) => Future.value([
                const AudioGuideModel(
                  uuid: 'ag1',
                  titleEs: 'La Leyenda del Apu Huaguruncho',
                  titleQu: 'Apu Wajuruncho Willakuy',
                  category: 'mitologia',
                  locationName: 'Mirador Principal 5,742m',
                  transcriptEs: 'Historia del Apu protector.',
                ),
              ])),
        ],
        child: const MaterialApp(
          home: AudioGuidesScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Audioguías & Relatos Orales'), findsOneWidget);
  });

  testWidgets('CommunityServicesScreen renders successfully with data', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          communityServicesListProvider.overrideWith((ref) => Future.value([
                const CommunityServiceModel(
                  uuid: 'cs1',
                  name: 'Guías de Huachón',
                  category: 'guia',
                  servicesDescription: 'Guiado de montaña.',
                ),
              ])),
        ],
        child: const MaterialApp(
          home: CommunityServicesScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Servicios Comunitarios Huachón'), findsOneWidget);
  });

  testWidgets('GuardianPassportScreen renders passport stamps and badges', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: GuardianPassportScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Guardián de Huascacocha'), findsOneWidget);
    expect(find.text('Compromiso No Deje Rastro (LNT)'), findsOneWidget);
  });

  testWidgets('OfflinePackageManagerScreen renders package breakdown and toggle', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OfflinePackageManagerScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Ruta Huachón – Nevado Huaguruncho'), findsOneWidget);
    expect(find.text('Forzar Modo Desconectado'), findsOneWidget);
  });
}

