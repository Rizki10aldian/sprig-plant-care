import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sprig/theme/app_motion.dart';

/// Pemutar animasi Lottie (JSON) yang aman: jika animasi dimatikan di
/// pengaturan perangkat atau file gagal dibaca, tampil [fallback] (atau kosong)
/// sehingga aplikasi tidak pernah error karena animasi.
class LottieView extends StatelessWidget {
  const LottieView({
    super.key,
    required this.asset,
    this.size = 180,
    this.fallback,
    this.repeat = true,
  });

  final String asset;
  final double size;
  final Widget? fallback;
  final bool repeat;

  static const String sprout = 'assets/lottie/sprout_loop.json';
  static const String waterDrop = 'assets/lottie/water_drop.json';
  static const String leaves = 'assets/lottie/leaf_float.json';

  @override
  Widget build(BuildContext context) {
    final empty = SizedBox(width: size, height: size, child: fallback);
    if (AppMotion.reduced(context)) return empty;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Lottie.asset(
          asset,
          width: size,
          height: size,
          fit: BoxFit.contain,
          repeat: repeat,
          frameRate: FrameRate.max,
          errorBuilder: (context, error, stack) => empty,
        ),
      ),
    );
  }
}
