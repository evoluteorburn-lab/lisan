import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/ramadan_theme.dart';

/// Traditional Arabic lantern (Fanous) button with microphone icon
/// This is the main recording button in Ramadan Kareem style
class LampButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback? onTap;
  final double size;

  const LampButton({
    Key? key,
    this.isRecording = false,
    this.onTap,
    this.size = 140,
  }) : super(key: key);

  @override
  State<LampButton> createState() => _LampButtonState();
}

class _LampButtonState extends State<LampButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isRecording) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LampButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isRecording ? _pulseAnimation.value : 1.0,
            child: SizedBox(
              width: widget.size,
              height: widget.size * 1.3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow
                  if (widget.isRecording)
                    Container(
                      width: widget.size * 1.3,
                      height: widget.size * 1.5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x20FFD700),
                      ),
                    ),

                  // Main lamp body
                  CustomPaint(
                    size: Size(widget.size, widget.size * 1.3),
                    painter: LampPainter(
                      isRecording: widget.isRecording,
                    ),
                  ),

                  // Microphone icon
                  Positioned(
                    top: widget.size * 0.45,
                    child: Icon(
                      Icons.mic,
                      color: RamadanTheme.textOnGold,
                      size: widget.size * 0.35,
                    ),
                  ),

                  // Recording indicator
                  if (widget.isRecording)
                    Positioned(
                      top: widget.size * 0.25,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter for Arabic lantern shape
class LampPainter extends CustomPainter {
  final bool isRecording;

  LampPainter({this.isRecording = false});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Colors
    final baseColor = isRecording ? const Color(0xFFFFD700) : RamadanTheme.goldMatte;
    final lightColor = isRecording ? const Color(0xFFFFE87C) : RamadanTheme.goldLight;
    final darkColor = isRecording ? const Color(0xFFE5AC00) : RamadanTheme.goldDark;

    // Main body gradient
    final bodyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lightColor,
        baseColor,
        darkColor,
      ],
    );

    final bodyPaint = Paint()
      ..shader = bodyGradient.createShader(
        Rect.fromLTWH(0, 0, width, height),
      )
      ..style = PaintingStyle.fill;

    // Lamp body path (traditional fanous shape)
    final bodyPath = Path();

    // Top loop (handle)
    final loopCenter = Offset(width * 0.5, height * 0.06);
    final loopRadius = width * 0.08;

    bodyPath.addArc(
      Rect.fromCircle(center: loopCenter, radius: loopRadius),
      math.pi,
      math.pi,
    );

    // Top of lamp
    bodyPath.moveTo(width * 0.3, height * 0.12);
    bodyPath.quadraticBezierTo(
      width * 0.5,
      height * 0.08,
      width * 0.7,
      height * 0.12,
    );

    // Right side
    bodyPath.lineTo(width * 0.75, height * 0.25);
    bodyPath.quadraticBezierTo(
      width * 0.8,
      height * 0.5,
      width * 0.75,
      height * 0.75,
    );

    // Bottom flare
    bodyPath.quadraticBezierTo(
      width * 0.7,
      height * 0.9,
      width * 0.6,
      height * 0.95,
    );
    bodyPath.lineTo(width * 0.4, height * 0.95);
    bodyPath.quadraticBezierTo(
      width * 0.3,
      height * 0.9,
      width * 0.25,
      height * 0.75,
    );

    // Left side
    bodyPath.quadraticBezierTo(
      width * 0.2,
      height * 0.5,
      width * 0.25,
      height * 0.25,
    );
    bodyPath.lineTo(width * 0.3, height * 0.12);

    canvas.drawPath(bodyPath, bodyPaint);

    // Decorative ribs (vertical lines)
    final ribPaint = Paint()
      ..color = darkColor.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 1; i <= 3; i++) {
      final x = width * (0.3 + i * 0.133);
      canvas.drawLine(
        Offset(x, height * 0.15),
        Offset(x, height * 0.85),
        ribPaint,
      );
    }

    // Top rim
    final topRimPaint = Paint()
      ..color = darkColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromLTWH(width * 0.25, height * 0.1, width * 0.5, height * 0.08),
      0,
      math.pi,
      false,
      topRimPaint,
    );

    // Bottom rim
    canvas.drawArc(
      Rect.fromLTWH(width * 0.3, height * 0.85, width * 0.4, height * 0.1),
      0,
      math.pi,
      false,
      topRimPaint,
    );

    // Inner glow effect
    if (isRecording) {
      final glowPaint = Paint()
        ..color = const Color(0x40FFD700)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawCircle(
        Offset(width * 0.5, height * 0.5),
        width * 0.3,
        glowPaint,
      );
    }

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawOval(
      Rect.fromLTWH(
        width * 0.2,
        height * 0.95,
        width * 0.6,
        height * 0.08,
      ),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}