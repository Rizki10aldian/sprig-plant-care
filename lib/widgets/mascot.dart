import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:sprig/theme/app_colors.dart';
import 'package:sprig/theme/app_motion.dart';

/// Ekspresi maskot.
enum MascotMood { idle, happy, sad, sleepy, wave, cover }

/// "Pip", karakter maskot Sprig: tunas kecil yang ekspresif.
/// Tiap ekspresi adalah animasi Lottie (`assets/lottie/pip_*.json`) yang
/// berputar terus. Sentuh Pip untuk membuatnya melompat senang sebentar.
class Mascot extends StatefulWidget {
  const Mascot({
    super.key,
    this.mood = MascotMood.idle,
    this.size = 110,
    this.pulse = 0,
    this.onTap,
  });

  final MascotMood mood;
  final double size;

  /// Naikkan angka ini untuk memicu reaksi senang (mis. setelah menyiram).
  final int pulse;

  /// Dipanggil saat Pip disentuh (selain animasi senangnya sendiri).
  final VoidCallback? onTap;

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> {
  MascotMood? _override;
  Timer? _timer;

  @override
  void didUpdateWidget(covariant Mascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pulse != widget.pulse) _cheer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _cheer() {
    _timer?.cancel();
    setState(() => _override = MascotMood.happy);
    _timer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _override = null);
    });
  }

  void _tap() {
    HapticFeedback.lightImpact();
    _cheer();
    widget.onTap?.call();
  }

  static String _asset(MascotMood mood) => switch (mood) {
        MascotMood.idle => 'assets/lottie/pip_idle.json',
        MascotMood.happy => 'assets/lottie/pip_happy.json',
        MascotMood.sad => 'assets/lottie/pip_sad.json',
        MascotMood.sleepy => 'assets/lottie/pip_sleepy.json',
        MascotMood.wave => 'assets/lottie/pip_wave.json',
        MascotMood.cover => 'assets/lottie/pip_cover.json',
      };

  @override
  Widget build(BuildContext context) {
    final mood = _override ?? widget.mood;
    final reduced = AppMotion.reduced(context);
    final size = widget.size;

    final face = Lottie.asset(
      _asset(mood),
      key: ValueKey<MascotMood>(mood),
      width: size,
      height: size,
      fit: BoxFit.contain,
      animate: !reduced,
      repeat: true,
      frameRate: FrameRate.max,
      errorBuilder: (context, error, stack) => _Fallback(size: size),
    );

    return Semantics(
      button: true,
      label: 'Pip, maskot Sprig. Sentuh untuk menyapa',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _tap,
        child: SizedBox(
          width: size,
          height: size,
          child: AnimatedSwitcher(
            duration: AppMotion.resolve(context, const Duration(milliseconds: 380)),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: face,
          ),
        ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size * 0.6,
        height: size * 0.6,
        decoration: const BoxDecoration(
          color: AppColors.lime,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.eco_rounded, size: size * 0.3, color: AppColors.ink),
      ),
    );
  }
}
