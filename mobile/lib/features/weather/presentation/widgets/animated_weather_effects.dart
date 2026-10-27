import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Tipo de atmósfera visual según condición meteorológica y piso térmico
enum WeatherAtmosphereType {
  glacialSnow,
  sunnyAndean,
  windyPuna,
  electricStorm,
}

WeatherAtmosphereType resolveAtmosphereType({
  required String weatherIcon,
  required double tempCelsius,
}) {
  if (weatherIcon == 'thunderstorm') {
    return WeatherAtmosphereType.electricStorm;
  }
  if (weatherIcon == 'severe_cold' ||
      weatherIcon == 'ac_unit' ||
      tempCelsius <= 3.0) {
    return WeatherAtmosphereType.glacialSnow;
  }
  if (weatherIcon == 'wb_sunny' || tempCelsius >= 11.0) {
    return WeatherAtmosphereType.sunnyAndean;
  }
  return WeatherAtmosphereType.windyPuna;
}

/// Lienzo animado de partículas meteorológicas (Copos de nieve, rayos solares,
/// ráfagas de puna y tormenta glaciar) optimizado a 60fps con CustomPainter.
class AnimatedWeatherBackdrop extends StatefulWidget {
  final WeatherAtmosphereType atmosphere;
  final double windSpeedKmh;
  final Widget child;
  final BorderRadius borderRadius;
  final bool compact;

  const AnimatedWeatherBackdrop({
    super.key,
    required this.atmosphere,
    required this.child,
    this.windSpeedKmh = 18.0,
    this.borderRadius = BorderRadius.zero,
    this.compact = false,
  });

  @override
  State<AnimatedWeatherBackdrop> createState() =>
      _AnimatedWeatherBackdropState();
}

class _AnimatedWeatherBackdropState extends State<AnimatedWeatherBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_WeatherParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    final count = widget.compact ? 18 : 34;
    final rng = math.Random(42);
    _particles = List.generate(count, (i) {
      return _WeatherParticle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: widget.compact
            ? (1.4 + rng.nextDouble() * 2.2)
            : (1.8 + rng.nextDouble() * 3.4),
        speedY: 0.25 + rng.nextDouble() * 0.75,
        speedX: 0.15 + rng.nextDouble() * 0.55,
        phase: rng.nextDouble() * math.pi * 2,
        isDetailedCrystal: i % 3 == 0,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _WeatherAtmospherePainter(
                      progress: _controller.value,
                      atmosphere: widget.atmosphere,
                      particles: _particles,
                      windFactor: (widget.windSpeedKmh / 25.0).clamp(0.5, 2.6),
                      compact: widget.compact,
                    ),
                  );
                },
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _WeatherParticle {
  final double x;
  final double y;
  final double radius;
  final double speedY;
  final double speedX;
  final double phase;
  final bool isDetailedCrystal;

  const _WeatherParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speedY,
    required this.speedX,
    required this.phase,
    required this.isDetailedCrystal,
  });
}

class _WeatherAtmospherePainter extends CustomPainter {
  final double progress;
  final WeatherAtmosphereType atmosphere;
  final List<_WeatherParticle> particles;
  final double windFactor;
  final bool compact;

  _WeatherAtmospherePainter({
    required this.progress,
    required this.atmosphere,
    required this.particles,
    required this.windFactor,
    required this.compact,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    switch (atmosphere) {
      case WeatherAtmosphereType.glacialSnow:
        _paintGlacialSnow(canvas, size);
        break;
      case WeatherAtmosphereType.sunnyAndean:
        _paintSunnyAndean(canvas, size);
        break;
      case WeatherAtmosphereType.windyPuna:
        _paintWindyPuna(canvas, size);
        break;
      case WeatherAtmosphereType.electricStorm:
        _paintElectricStorm(canvas, size);
        break;
    }
  }

  void _paintGlacialSnow(Canvas canvas, Size size) {
    // Resplandor glaciar frío sutil en la esquina superior derecha
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.75, -0.6),
        radius: 1.1,
        colors: [
          const Color(0xFF38BDF8).withValues(alpha: compact ? 0.16 : 0.22),
          const Color(0xFF6EE7B7).withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, glowPaint);

    final snowPaint = Paint()..style = PaintingStyle.fill;
    final crystalStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = compact ? 0.9 : 1.1
      ..strokeCap = StrokeCap.round;

    for (final p in particles) {
      final t = (progress * (compact ? 2.0 : 1.4) * p.speedY + p.y) % 1.0;
      final sway = math.sin(progress * math.pi * 2 + p.phase) * 0.03;
      final driftX =
          (p.x + progress * p.speedX * 0.45 * windFactor + sway) % 1.0;

      final px = driftX * size.width;
      final py = t * size.height;
      final alpha = (0.25 + 0.65 * math.sin(t * math.pi)).clamp(0.15, 0.85);

      if (p.isDetailedCrystal && p.radius > 2.2) {
        crystalStroke.color = Colors.white.withValues(alpha: alpha * 0.85);
        _drawSnowflakeCrystal(
          canvas,
          Offset(px, py),
          p.radius * (compact ? 1.25 : 1.55),
          progress * math.pi * 2 + p.phase,
          crystalStroke,
        );
      } else {
        snowPaint.color = const Color(0xFFE0F2FE).withValues(alpha: alpha);
        canvas.drawCircle(Offset(px, py), p.radius * 0.75, snowPaint);
      }
    }
  }

  void _drawSnowflakeCrystal(
    Canvas canvas,
    Offset center,
    double radius,
    double rotation,
    Paint paint,
  ) {
    for (int i = 0; i < 3; i++) {
      final angle = rotation + (i * math.pi / 3);
      final dx = math.cos(angle) * radius;
      final dy = math.sin(angle) * radius;
      canvas.drawLine(
        Offset(center.dx - dx, center.dy - dy),
        Offset(center.dx + dx, center.dy + dy),
        paint,
      );
    }
  }

  void _paintSunnyAndean(Canvas canvas, Size size) {
    final sunCenter = Offset(
      size.width * (compact ? 0.82 : 0.86),
      size.height * (compact ? 0.35 : 0.24),
    );
    final pulse = 0.92 + 0.12 * math.sin(progress * math.pi * 4);
    final maxRadius = (compact ? size.height * 1.6 : size.width * 0.48) * pulse;

    // Halo solar cálido de los Andes
    final sunGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFBBF24).withValues(alpha: compact ? 0.28 : 0.32),
          AppColors.cordilleraOchre.withValues(alpha: compact ? 0.14 : 0.16),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: maxRadius));
    canvas.drawCircle(sunCenter, maxRadius, sunGlow);

    // Rayos solares giratorios
    final rayPaint = Paint()
      ..color = const Color(0xFFFDE68A).withValues(alpha: compact ? 0.22 : 0.26)
      ..strokeWidth = compact ? 1.2 : 1.6
      ..strokeCap = StrokeCap.round;

    const rayCount = 12;
    final baseRot = progress * math.pi * 2;
    for (int i = 0; i < rayCount; i++) {
      final angle = baseRot + (i * math.pi * 2 / rayCount);
      final innerR = compact ? 8.0 : 18.0;
      final outerR =
          (compact ? 22.0 : 48.0) + ((i % 2 == 0) ? 6.0 * pulse : 0.0);
      canvas.drawLine(
        Offset(
          sunCenter.dx + math.cos(angle) * innerR,
          sunCenter.dy + math.sin(angle) * innerR,
        ),
        Offset(
          sunCenter.dx + math.cos(angle) * outerR,
          sunCenter.dy + math.sin(angle) * outerR,
        ),
        rayPaint,
      );
    }

    // Motas doradas de luz andina flotando
    final motePaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < (compact ? 10 : 18); i++) {
      final p = particles[i];
      final px = ((p.x + progress * 0.25 * p.speedX) % 1.0) * size.width;
      final py =
          ((p.y - progress * 0.2 * p.speedY + 1.0) % 1.0) * size.height;
      final twinkle =
          0.25 + 0.55 * (0.5 + 0.5 * math.sin(progress * math.pi * 6 + p.phase));
      motePaint.color = const Color(0xFFFDE68A).withValues(alpha: twinkle * 0.55);
      canvas.drawCircle(Offset(px, py), p.radius * 0.65, motePaint);
    }
  }

  void _paintWindyPuna(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          const Color(0xFF6EE7B7).withValues(alpha: 0.08),
          const Color(0xFF38BDF8).withValues(alpha: 0.12),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, glowPaint);

    // Líneas aerodinámicas de viento de puna
    final windPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = compact ? 1.0 : 1.3
      ..strokeCap = StrokeCap.round;

    final streamCount = compact ? 4 : 7;
    for (int i = 0; i < streamCount; i++) {
      final p = particles[i];
      final yBase = (0.18 + (i / streamCount) * 0.68) * size.height;
      final shift = ((progress * 1.5 * windFactor + p.x) % 1.3) - 0.15;
      final startX = shift * size.width;
      final length = size.width * (compact ? 0.22 : 0.28);

      final alpha = (0.15 + 0.35 * math.sin((shift.clamp(0.0, 1.0)) * math.pi))
          .clamp(0.08, 0.42);
      windPaint.color = const Color(0xFFBAE6FD).withValues(alpha: alpha);

      final path = Path()..moveTo(startX, yBase);
      path.quadraticBezierTo(
        startX + length * 0.5,
        yBase - (compact ? 3.5 : 6.0) * math.sin(progress * math.pi * 2 + p.phase),
        startX + length,
        yBase,
      );
      canvas.drawPath(path, windPaint);
    }

    // Cristales finos arrastrados por el viento
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < (compact ? 10 : 18); i++) {
      final p = particles[i];
      final px =
          ((p.x + progress * 1.2 * p.speedX * windFactor) % 1.0) * size.width;
      final py =
          ((p.y + math.sin(progress * math.pi * 2 + p.phase) * 0.05) % 1.0) *
              size.height;
      dotPaint.color = Colors.white.withValues(alpha: 0.35);
      canvas.drawCircle(Offset(px, py), p.radius * 0.55, dotPaint);
    }
  }

  void _paintElectricStorm(Canvas canvas, Size size) {
    _paintGlacialSnow(canvas, size);
    // Destello atmosférico ocasional
    final flashWindow = (progress * 4) % 1.0;
    if (flashWindow > 0.92) {
      final flashAlpha = (1.0 - (flashWindow - 0.92) / 0.08) * 0.18;
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = const Color(0xFFFDE68A).withValues(alpha: flashAlpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeatherAtmospherePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.atmosphere != atmosphere ||
        oldDelegate.windFactor != windFactor;
  }
}

/// Emblema animado de clima (Sol giratorio, Copo de nieve oscilante o Viento)
class AnimatedWeatherEmblem extends StatefulWidget {
  final String weatherIcon;
  final double tempCelsius;
  final double size;
  final bool showContainer;

  const AnimatedWeatherEmblem({
    super.key,
    required this.weatherIcon,
    required this.tempCelsius,
    this.size = 24,
    this.showContainer = true,
  });

  @override
  State<AnimatedWeatherEmblem> createState() => _AnimatedWeatherEmblemState();
}

class _AnimatedWeatherEmblemState extends State<AnimatedWeatherEmblem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final atmosphere = resolveAtmosphereType(
      weatherIcon: widget.weatherIcon,
      tempCelsius: widget.tempCelsius,
    );

    IconData iconData;
    Color iconColor;
    switch (atmosphere) {
      case WeatherAtmosphereType.glacialSnow:
        iconData = Icons.ac_unit_rounded;
        iconColor = const Color(0xFF38BDF8);
        break;
      case WeatherAtmosphereType.sunnyAndean:
        iconData = Icons.wb_sunny_rounded;
        iconColor = const Color(0xFFFBBF24);
        break;
      case WeatherAtmosphereType.electricStorm:
        iconData = Icons.thunderstorm_rounded;
        iconColor = AppColors.cordilleraOchre;
        break;
      case WeatherAtmosphereType.windyPuna:
        iconData = widget.weatherIcon == 'air'
            ? Icons.air_rounded
            : Icons.wb_cloudy_rounded;
        iconColor = const Color(0xFF6EE7B7);
        break;
    }

    final animatedIcon = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        if (atmosphere == WeatherAtmosphereType.sunnyAndean) {
          final scale = 0.94 + 0.10 * math.sin(t * math.pi * 4);
          return Transform.rotate(
            angle: t * math.pi * 2,
            child: Transform.scale(scale: scale, child: child),
          );
        } else if (atmosphere == WeatherAtmosphereType.glacialSnow) {
          final bobY = math.sin(t * math.pi * 4) * 2.0;
          final angle = math.sin(t * math.pi * 2) * 0.35;
          return Transform.translate(
            offset: Offset(0, bobY),
            child: Transform.rotate(angle: angle, child: child),
          );
        } else {
          final shiftX = math.sin(t * math.pi * 4) * 2.2;
          return Transform.translate(
            offset: Offset(shiftX, 0),
            child: child,
          );
        }
      },
      child: Icon(iconData, color: iconColor, size: widget.size),
    );

    if (!widget.showContainer) return animatedIcon;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: iconColor.withValues(alpha: 0.45), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.18),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: animatedIcon,
    );
  }
}

/// Indicador de pulso satelital en vivo para la barra de "TELEMETRÍA EN LÍNEA"
class LiveTelemetryPulseDot extends StatefulWidget {
  final Color color;
  final double size;

  const LiveTelemetryPulseDot({
    super.key,
    required this.color,
    this.size = 8.0,
  });

  @override
  State<LiveTelemetryPulseDot> createState() => _LiveTelemetryPulseDotState();
}

class _LiveTelemetryPulseDotState extends State<LiveTelemetryPulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2.2,
      height: widget.size * 2.2,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.size * (1.0 + t * 1.2),
                height: widget.size * (1.0 + t * 1.2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: (1.0 - t) * 0.45),
                ),
              ),
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
