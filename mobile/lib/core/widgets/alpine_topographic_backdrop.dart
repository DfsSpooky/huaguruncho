import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Base cartográfica topográfica offline/híbrida (Stitch 2.0)
/// Garantiza que el mapa siempre muestre curvas de nivel, grilla UTM/WGS84 y
/// relieve cordillerano incluso sin conexión a internet o mientras cargan las teselas.
class AlpineTopographicBackdrop extends StatelessWidget {
  final String layerMode; // 'topo', 'satellite', 'osm'

  const AlpineTopographicBackdrop({
    super.key,
    required this.layerMode,
  });

  static String primaryTileUrl(String layer) {
    switch (layer) {
      case 'satellite':
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case 'osm':
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      case 'topo':
      default:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}';
    }
  }

  static String fallbackTileUrl(String layer) {
    switch (layer) {
      case 'satellite':
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}';
      case 'osm':
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}';
      case 'topo':
      default:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _AlpineTopographicPainter(layerMode: layerMode),
      ),
    );
  }
}

class _AlpineTopographicPainter extends CustomPainter {
  final String layerMode;

  _AlpineTopographicPainter({required this.layerMode});

  @override
  void paint(Canvas canvas, Size size) {
    final isSat = layerMode == 'satellite';
    final isTopo = layerMode == 'topo';

    // 1. Fondo hipsométrico según el modo de capa
    final bgGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isSat
          ? const [
              Color(0xFF16221F),
              Color(0xFF1E2D29),
              Color(0xFF121A18),
            ]
          : isTopo
              ? const [
                  Color(0xFFEBE7DC),
                  Color(0xFFE2DDD0),
                  Color(0xFFD8D2C3),
                ]
              : const [
                  Color(0xFFF3F1EB),
                  Color(0xFFEAE7DF),
                  Color(0xFFE3DFD5),
                ],
    );

    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = bgGradient.createShader(Offset.zero & size),
    );

    // 2. Sombreado glaciar y cuencas hidrográficas (Laguna Huascacocha / Nevado)
    final glacierCenter = Offset(size.width * 0.34, size.height * 0.72);
    final valleyCenter = Offset(size.width * 0.65, size.height * 0.26);

    final glacierGlow = RadialGradient(
      colors: isSat
          ? [
              const Color(0xFF38BDF8).withValues(alpha: 0.16),
              Colors.transparent,
            ]
          : [
              const Color(0xFFBAE6FD).withValues(alpha: 0.45),
              Colors.transparent,
            ],
    );
    canvas.drawCircle(
      glacierCenter,
      size.shortestSide * 0.45,
      Paint()
        ..shader = glacierGlow.createShader(
          Rect.fromCircle(center: glacierCenter, radius: size.shortestSide * 0.45),
        ),
    );

    final forestGlow = RadialGradient(
      colors: isSat
          ? [
              AppColors.yaretaPine.withValues(alpha: 0.22),
              Colors.transparent,
            ]
          : [
              const Color(0xFFC7D9C8).withValues(alpha: 0.55),
              Colors.transparent,
            ],
    );
    canvas.drawCircle(
      valleyCenter,
      size.shortestSide * 0.48,
      Paint()
        ..shader = forestGlow.createShader(
          Rect.fromCircle(center: valleyCenter, radius: size.shortestSide * 0.48),
        ),
    );

    // 3. Grilla Cartográfica UTM / WGS84
    final gridPaint = Paint()
      ..color = isSat
          ? Colors.white.withValues(alpha: 0.07)
          : const Color(0xFF8B8578).withValues(alpha: 0.16)
      ..strokeWidth = 0.8;

    const int cols = 6;
    const int rows = 6;
    for (int i = 1; i < cols; i++) {
      final x = (size.width / cols) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (int j = 1; j < rows; j++) {
      final y = (size.height / rows) * j;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 4. Curvas de Nivel Topográficas (Isohipsas)
    final contourMajorPaint = Paint()
      ..color = isSat
          ? const Color(0xFF94A3B8).withValues(alpha: 0.18)
          : const Color(0xFF8C6D46).withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;

    final contourMinorPaint = Paint()
      ..color = isSat
          ? const Color(0xFF94A3B8).withValues(alpha: 0.09)
          : const Color(0xFF8C6D46).withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75;

    _drawContourSet(
      canvas,
      center: glacierCenter,
      maxRadius: size.longestSide * 0.65,
      rings: 9,
      eccentricityX: 1.25,
      eccentricityY: 0.85,
      rotation: -0.35,
      majorPaint: contourMajorPaint,
      minorPaint: contourMinorPaint,
    );

    _drawContourSet(
      canvas,
      center: valleyCenter,
      maxRadius: size.longestSide * 0.55,
      rings: 7,
      eccentricityX: 1.15,
      eccentricityY: 0.9,
      rotation: 0.42,
      majorPaint: contourMajorPaint,
      minorPaint: contourMinorPaint,
    );

    // 5. Río / Quebrada glaciar estilizada
    final riverPath = Path()
      ..moveTo(glacierCenter.dx, glacierCenter.dy)
      ..cubicTo(
        size.width * 0.48,
        size.height * 0.58,
        size.width * 0.44,
        size.height * 0.40,
        valleyCenter.dx,
        valleyCenter.dy,
      );
    canvas.drawPath(
      riverPath,
      Paint()
        ..color = isSat
            ? const Color(0xFF38BDF8).withValues(alpha: 0.22)
            : const Color(0xFF0284C7).withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // 6. Etiquetas cartográficas de cota y coordenadas (sutiles)
    final labelColor = isSat
        ? Colors.white.withValues(alpha: 0.35)
        : const Color(0xFF5C5549).withValues(alpha: 0.55);

    _drawMapLabel(
      canvas,
      '10°31\'S · 75°55\'W',
      Offset(12, size.height - 42),
      labelColor,
    );
    _drawMapLabel(
      canvas,
      'COTA 4,796m',
      Offset(glacierCenter.dx - 28, glacierCenter.dy + 18),
      labelColor,
    );
    _drawMapLabel(
      canvas,
      'VALLE 3,400m',
      Offset(valleyCenter.dx - 28, valleyCenter.dy - 14),
      labelColor,
    );
  }

  void _drawContourSet(
    Canvas canvas, {
    required Offset center,
    required double maxRadius,
    required int rings,
    required double eccentricityX,
    required double eccentricityY,
    required double rotation,
    required Paint majorPaint,
    required Paint minorPaint,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    for (int r = 1; r <= rings; r++) {
      final radius = (maxRadius / rings) * r;
      final path = Path();
      const int steps = 48;
      for (int s = 0; s <= steps; s++) {
        final angle = (s / steps) * math.pi * 2;
        final wobble = 1.0 +
            0.08 * math.sin(angle * 3 + r * 0.7) +
            0.05 * math.cos(angle * 5 - r * 0.4);
        final px = math.cos(angle) * radius * eccentricityX * wobble;
        final py = math.sin(angle) * radius * eccentricityY * wobble;
        if (s == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      canvas.drawPath(path, r % 3 == 0 ? majorPaint : minorPaint);
    }

    canvas.restore();
  }

  void _drawMapLabel(Canvas canvas, String text, Offset pos, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant _AlpineTopographicPainter oldDelegate) {
    return oldDelegate.layerMode != layerMode;
  }
}
