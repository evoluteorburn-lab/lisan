import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/ramadan_theme.dart';

/// Animated starry night sky background with mosque silhouette
class NightSkyBackground extends StatefulWidget {
  final Widget child;

  const NightSkyBackground({Key? key, required this.child}) : super(key: key);

  @override
  State<NightSkyBackground> createState() => _NightSkyBackgroundState();
}

class _NightSkyBackgroundState extends State<NightSkyBackground>
    with TickerProviderStateMixin {
  late AnimationController _twinkleController;
  late AnimationController _moonController;
  final List<Star> stars = [];
  final math.Random random = math.Random();

  @override
  void initState() {
    super.initState();
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _moonController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Generate random stars
    for (int i = 0; i < 80; i++) {
      stars.add(Star(
        x: random.nextDouble(),
        y: random.nextDouble() * 0.7, // Keep stars in upper 70%
        size: random.nextDouble() * 2 + 1,
        twinkleOffset: random.nextDouble() * math.pi * 2,
        twinkleSpeed: random.nextDouble() * 2 + 1,
      ));
    }
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    _moonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RamadanTheme.backgroundGradient,
      ),
      child: Stack(
        children: [
          // Stars
          AnimatedBuilder(
            animation: _twinkleController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: StarsPainter(
                  stars: stars,
                  progress: _twinkleController.value,
                ),
              );
            },
          ),

          // Moon
          Positioned(
            top: MediaQuery.of(context).size.height * 0.08,
            right: MediaQuery.of(context).size.width * 0.1,
            child: AnimatedBuilder(
              animation: _moonController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, math.sin(_moonController.value * math.pi * 2) * 5),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: RamadanTheme.goldLight.withOpacity(0.9),
                      boxShadow: [
                        BoxShadow(
                          color: RamadanTheme.goldLight.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              RamadanTheme.goldLight,
                              Color(0xFFE8D5A3),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Mosque silhouette at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 120),
              painter: MosquePainter(),
            ),
          ),

          // Content
          widget.child,
        ],
      ),
    );
  }
}

class Star {
  final double x;
  final double y;
  final double size;
  final double twinkleOffset;
  final double twinkleSpeed;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleOffset,
    required this.twinkleSpeed,
  });
}

class StarsPainter extends CustomPainter {
  final List<Star> stars;
  final double progress;

  StarsPainter({required this.stars, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = RamadanTheme.goldLight.withOpacity(0.8)
      ..strokeCap = StrokeCap.round;

    for (final star in stars) {
      final twinkle = math.sin(
        (progress * math.pi * 2 * star.twinkleSpeed) + star.twinkleOffset,
      );
      final opacity = (0.3 + (twinkle + 1) / 2 * 0.7).clamp(0.0, 1.0);

      paint.color = RamadanTheme.goldLight.withOpacity(opacity * 0.8);

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MosquePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = RamadanTheme.mosqueSilhouette
      ..style = PaintingStyle.fill;

    final path = Path();

    // Main dome
    path.moveTo(size.width * 0.35, size.height);
    path.lineTo(size.width * 0.35, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.1,
      size.width * 0.65,
      size.height * 0.5,
    );
    path.lineTo(size.width * 0.65, size.height);

    // Left minaret
    path.moveTo(size.width * 0.2, size.height);
    path.lineTo(size.width * 0.2, size.height * 0.3);
    path.lineTo(size.width * 0.15, size.height * 0.25);
    path.lineTo(size.width * 0.25, size.height * 0.25);
    path.lineTo(size.width * 0.25, size.height);

    // Right minaret
    path.moveTo(size.width * 0.8, size.height);
    path.lineTo(size.width * 0.8, size.height * 0.3);
    path.lineTo(size.width * 0.75, size.height * 0.25);
    path.lineTo(size.width * 0.85, size.height * 0.25);
    path.lineTo(size.width * 0.85, size.height);

    // Base platform
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height * 0.85);
    path.lineTo(0, size.height * 0.85);

    canvas.drawPath(path, paint);

    // Subtle glow around dome
    final glowPaint = Paint()
      ..color = RamadanTheme.goldMatte.withOpacity(0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.4),
      size.width * 0.2,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter) => false;
}
