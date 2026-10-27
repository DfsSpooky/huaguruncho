import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huaguruncho_360/features/tours/presentation/tour_360_viewer_screen.dart';
import 'package:huaguruncho_360/features/tours/presentation/live_trekking_screen.dart';
import 'package:huaguruncho_360/features/safety/presentation/emergency_sos_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Tour360ViewerScreen renders scenes and gyro controls', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Tour360ViewerScreen(routeUuid: 'test-route-uuid'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Plaza Mayor de Huachón'), findsWidgets);
    expect(find.byIcon(Icons.touch_app), findsOneWidget);
    expect(find.byIcon(Icons.navigation), findsOneWidget);
  });

  testWidgets('LiveTrekkingScreen renders HUD mountain metrics and off-trail simulator', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LiveTrekkingScreen(
            routeUuid: 'test-route-uuid',
            routeName: 'Camino al Nevado Huaguruncho',
            totalDistanceKm: 22.0,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('NAVEGACIÓN GPS EN VIVO'), findsWidgets);
    expect(find.text('Altitud Actual'), findsOneWidget);
    expect(find.text('Distancia Faltante'), findsOneWidget);
    expect(find.text('Desvío Sendero'), findsOneWidget);
    expect(find.text('SOS'), findsOneWidget);
  });

  testWidgets('EmergencySosScreen renders without layout errors or infinite width crashes', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: EmergencySosScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    expect(find.text('Centro de Emergencia & SOS'), findsOneWidget);
    expect(find.text('EMITIR ALERTA SOS GLACIAR'), findsOneWidget);
    expect(find.text('Directorio Telefónico de Emergencia'), findsOneWidget);
  });
}
