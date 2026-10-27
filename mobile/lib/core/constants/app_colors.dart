import 'package:flutter/material.dart';

/// Huaguruncho 360 · Interfaz 2.0
/// Design System: "Alpine Field Instrument & Editorial Expedition Journal" (Stitch 2.0)
class AppColors {
  AppColors._();

  // 1. Paleta Mineral Primaria (Stitch 2.0)
  static const Color basaltInk = Color(0xFF14171A);         // Carbón basalto mate profundo
  static const Color alpineChalk = Color(0xFFF6F7F4);       // Tiza alpina / Canvas día
  static const Color pureWhite = Color(0xFFFFFFFF);         // Superficie sólida de tarjetas
  static const Color cordilleraOchre = Color(0xFFD95D39);   // Acento de expedición y rescate
  static const Color yaretaPine = Color(0xFF2A5C43);        // Verde conservación y guardaparques
  static const Color glacialBorder = Color(0xFFE2E6E1);      // Borde estructural técnico de 1px
  static const Color graniteMuted = Color(0xFF525860);       // Gris granito para telemetría
  static const Color glacierBlueTint = Color(0xFFEDF3F5);    // Fondo sutil para chips de altitud

  // 2. Compatibilidad y Aliases hacia el nuevo sistema
  static const Color twilightNavy = basaltInk;               // Transición hacia Basalt Ink
  static const Color primaryBlue = basaltInk;
  static const Color glacierTeal = cordilleraOchre;          // Acento principal interactivo
  static const Color glacierBlue = Color(0xFF38A3A5);
  static const Color mountainGreen = yaretaPine;
  static const Color forestGreen = yaretaPine;
  static const Color sunGold = Color(0xFFE9C46A);
  static const Color lightSand = Color(0xFFEFECE6);
  static const Color background = alpineChalk;
  static const Color surface = pureWhite;
  static const Color cardBg = pureWhite;
  static const Color border = glacialBorder;
  static const Color textPrimary = basaltInk;
  static const Color textSecondary = graniteMuted;
  static const Color textMuted = Color(0xFF889096);
  static const Color darkOverlay = Color(0xD914171A);

  // Modern Tactile Elevation & Glassmorphism
  static const Color glassSurface = Color(0xF5FFFFFF);
  static const Color glassDark = Color(0xF014171A);
  static const Color glassBorder = glacialBorder;
  static const Color glassBorderLight = Color(0x33FFFFFF);

  // Degradados de expedición (Sobrios, nada de púrpuras neón)
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF14171A),
      Color(0xFF1F2429),
      Color(0xFF2D353C),
    ],
  );

  static const LinearGradient glacialHeroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x9914171A),
      Color(0xF514171A),
    ],
  );

  static const LinearGradient ecoGuardianGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E3F2F),
      Color(0xFF2A5C43),
      Color(0xFF367556),
    ],
  );

  static const LinearGradient tealButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD95D39),
      Color(0xFFC7512F),
    ],
  );

  // Estados y Alertas
  static const Color warning = Color(0xFFD97706);           // Ámbar montaña
  static const Color error = Color(0xFFDC2626);             // Rojo emergencia
  static const Color success = Color(0xFF2A5C43);           // Verde Yareta
  static const Color info = Color(0xFF0284C7);              // Azul info satelital
  static const Color crimsonAlertLight = Color(0xFFFEE2E2); // Fondo tenue de alerta roja
  static const Color emeraldPassLight = Color(0xFFDCFCE7);  // Fondo tenue de éxito verde
  static const Color stoneSurface = alpineChalk;             // Superficie de piedra / fondo alpino
}


