import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huaguruncho_360/app/router.dart';
import 'package:huaguruncho_360/app/app.dart';

void main() {
  testWidgets('Bottom navigation bar renders and navigates to tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HuagurunchoApp(),
      ),
    );

    // Let the splash screen timer expire (2000ms)
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Navigate to home branch
    appRouter.go('/home');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify bottom nav bar items
    expect(find.text('Inicio'), findsWidgets);
    expect(find.text('Rutas'), findsWidgets);
    expect(find.text('Reportar'), findsWidgets);
    expect(find.text('Tour 360°'), findsWidgets);
    expect(find.text('Reportes'), findsWidgets);

    // Tap on Rutas tab
    await tester.tap(find.text('Rutas').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap on Reportes tab
    await tester.tap(find.text('Reportes').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap on Inicio tab
    await tester.tap(find.text('Inicio').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  });
}
