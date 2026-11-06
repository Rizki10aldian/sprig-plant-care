import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sprig/theme/app_colors.dart';
import 'package:sprig/theme/app_motion.dart';

/// Cincin progres yang terisi dengan animasi halus.
class WaterRing extends StatelessWidget {
  const WaterRing({
    super.key,
    required this.progress,
    required this.child,
    this.size = 52,
    this.stroke = 4.5,
    this.color = AppColors.ink,
    this.track = AppColors.line,
  });

  final double progress;
  final Widget child;
  final double size;
  final double stroke;
  final Color color;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0).toDouble()),
        duration: AppMotion.resolve(context, AppMotion.slow),
        curve: Curves.easeOutCubic,
        child: child,
        builder: (context, value, child) => CustomPaint(
          painter: _RingPainter(value, stroke, color, track),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.value, this.stroke, this.color, this.track);

  final double value;
  final double stroke;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track
      ..isAntiAlias = true;
    canvas.drawCircle(rect.center, rect.width / 2, base);
    if (value <= 0.001) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color
      ..isAntiAlias = true;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * value, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.color != color ||
      oldDelegate.track != track ||
      oldDelegate.stroke != stroke;
}
