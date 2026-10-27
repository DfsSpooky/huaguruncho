import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Shell & Scaffold
import '../core/widgets/main_shell_scaffold.dart';

// Screens
import '../features/home/presentation/splash_screen.dart';
import '../features/home/presentation/onboarding_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/home/presentation/responsible_use_screen.dart';
import '../features/home/presentation/profile_screen.dart';
import '../features/home/presentation/community_services_screen.dart';
import '../features/routes/domain/route_model.dart';
import '../features/routes/presentation/routes_list_screen.dart';
import '../features/routes/presentation/route_detail_screen.dart';
import '../features/routes/presentation/route_map_screen.dart';
import '../features/tours/presentation/tour_360_screen.dart';
import '../features/tours/presentation/live_trekking_screen.dart';
import '../features/tours/presentation/audio_guides_screen.dart';
import '../features/offline/presentation/offline_packages_screen.dart';
import '../features/safety/presentation/safety_recommendations_screen.dart';
import '../features/safety/presentation/safety_checklist_screen.dart';
import '../features/safety/presentation/emergency_sos_screen.dart';
import '../features/gamification/presentation/guardian_passport_screen.dart';
import '../features/offline/presentation/offline_package_manager_screen.dart';
import '../features/reports/presentation/create_report_screen.dart';
import '../features/reports/presentation/my_reports_screen.dart';
import '../features/reports/presentation/report_detail_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/biodiversity/presentation/biodiversity_screen.dart';
import '../features/weather/presentation/mountain_weather_screen.dart';
import '../features/safety/presentation/trekking_checklist_screen.dart';
import '../features/community/presentation/community_wall_screen.dart';
import '../features/checkpoint/presentation/ranger_checkpoint_dashboard_screen.dart';
import '../features/checkpoint/presentation/ranger_checkin_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // 1. Pantallas Iniciales y Onboarding (Fuera de la barra)
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // 2. Shell Principal con Barra de Navegación Interactiva (4 Ramas)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Rama 0: Inicio
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // Rama 1: Rutas y Senderos
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/routes',
              builder: (context, state) => const RoutesListScreen(),
            ),
          ],
        ),

        // Rama 2: Tour Virtual 360°
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tour-360',
              builder: (context, state) {
                final routeUuid = state.uri.queryParameters['routeUuid'];
                return Tour360Screen(routeUuid: routeUuid);
              },
            ),
          ],
        ),

        // Rama 3: Mis Eco-Reportes
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/my-reports',
              builder: (context, state) => const MyReportsScreen(),
            ),
          ],
        ),
      ],
    ),

    // 3. Pantallas Secundarias / Detalle (En el root navigator para pantalla completa)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/routes/:uuid',
      builder: (context, state) {
        final uuid = state.pathParameters['uuid']!;
        return RouteDetailScreen(routeUuid: uuid);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/routes/:uuid/map',
      builder: (context, state) {
        final uuid = state.pathParameters['uuid']!;
        final route = state.extra as RouteModel?;
        return RouteMapScreen(routeUuid: uuid, initialRoute: route);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/create-report',
      builder: (context, state) {
        final routeUuid = state.uri.queryParameters['routeUuid'];
        return CreateReportScreen(routeUuid: routeUuid);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/reports/:localUuid',
      builder: (context, state) {
        final localUuid = state.pathParameters['localUuid']!;
        return ReportDetailScreen(localUuid: localUuid);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/emergency-sos',
      builder: (context, state) => const EmergencySosScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/eco-passport',
      builder: (context, state) => const GuardianPassportScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/guardian-passport',
      builder: (context, state) => const GuardianPassportScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/routes/:uuid/tour-360',
      builder: (context, state) {
        final uuid = state.pathParameters['uuid'] ?? 'dda96e53-ff74-4dd9-a909-3cc849528aa0';
        final initialSceneUuid = state.uri.queryParameters['scene'];
        return Tour360Screen(routeUuid: uuid, initialSceneUuid: initialSceneUuid);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/tour-360-viewer/:uuid',
      builder: (context, state) {
        final uuid = state.pathParameters['uuid'] ?? 'dda96e53-ff74-4dd9-a909-3cc849528aa0';
        final initialSceneUuid = state.uri.queryParameters['scene'];
        return Tour360Screen(routeUuid: uuid, initialSceneUuid: initialSceneUuid);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/tour-360/:uuid',
      builder: (context, state) {
        final uuid = state.pathParameters['uuid'] ?? 'dda96e53-ff74-4dd9-a909-3cc849528aa0';
        final initialSceneUuid = state.uri.queryParameters['scene'];
        return Tour360Screen(routeUuid: uuid, initialSceneUuid: initialSceneUuid);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/live-trekking/:uuid',
      builder: (context, state) {
        final uuid = state.pathParameters['uuid'] ?? '4a8df556-59f7-442c-a759-5d4020467982';
        final route = state.extra as RouteModel?;
        return LiveTrekkingScreen(routeUuid: uuid, initialRoute: route);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/live-trekking',
      builder: (context, state) {
        final route = state.extra as RouteModel?;
        return LiveTrekkingScreen(routeUuid: '4a8df556-59f7-442c-a759-5d4020467982', initialRoute: route);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/offline-manager',
      builder: (context, state) => const OfflinePackageManagerScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/audio-guides',
      builder: (context, state) => const AudioGuidesScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/community-services',
      builder: (context, state) => const CommunityServicesScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/biodiversity',
      builder: (context, state) => const BiodiversityScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/mountain-weather',
      builder: (context, state) => const MountainWeatherScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/trekking-checklist',
      builder: (context, state) => const TrekkingChecklistScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/community-wall',
      builder: (context, state) => const CommunityWallScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/safety',
      builder: (context, state) => const SafetyRecommendationsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/safety-checklist',
      builder: (context, state) => const SafetyChecklistScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/offline-packages',
      builder: (context, state) {
        final routeUuid = state.uri.queryParameters['routeUuid'];
        return OfflinePackagesScreen(routeUuid: routeUuid);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/responsible-use',
      builder: (context, state) => const ResponsibleUseScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/ranger-checkpoint',
      builder: (context, state) => const RangerCheckpointDashboardScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/checkpoint',
      builder: (context, state) => const RangerCheckpointDashboardScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/ranger-checkpoint/checkin',
      builder: (context, state) => const RangerCheckinScreen(),
    ),
  ],
);
