import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huaguruncho_360/app/app.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HuagurunchoApp(),
      ),
    );

    // Permitir que el temporizador del SplashScreen y animaciones se completen
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.byType(HuagurunchoApp), findsOneWidget);
  });
}
