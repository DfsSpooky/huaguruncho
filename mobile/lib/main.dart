import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bloquear orientación preferente vertical pero permitir horizontal en visor si se requiere
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: HuagurunchoApp(),
    ),
  );
}
