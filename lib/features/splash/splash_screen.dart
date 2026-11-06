import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprig/routing/app_routes.dart';
import 'package:sprig/theme/app_colors.dart';
import 'package:sprig/theme/app_motion.dart';
import 'package:sprig/theme/app_text.dart';
import 'package:sprig/widgets/mascot.dart';

/// Halaman 1: Splash Screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  late final CurvedAnimation _logoScale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
  );
  late final CurvedAnimation _logoFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
  );
  late final CurvedAnimation _word = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.25, 0.65, curve: Curves.easeOutCubic),
  );
  late final CurvedAnimation _tagline = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic),
  );

  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (AppMotion.reduced(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
    _timer = Timer(const Duration(milliseconds: 2600), _next);
  }

  void _next() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _logoScale.dispose();
    _logoFade.dispose();
    _word.dispose();
    _tagline.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _logoScale,
                        child: FadeTransition(
                          opacity: _logoFade,
                          child: const Mascot(
                            mood: MascotMood.wave,
                            size: 240,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FadeTransition(
                        opacity: _word,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(_word),
                          child: Text(
                            'Sprig',
                            style: AppText.display.copyWith(
                              fontSize: 46,
                              color: Colors.white,
                              letterSpacing: -1.8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FadeTransition(
                        opacity: _tagline,
                        child: Text(
                          'Rawat tanaman, tumbuh bersama.',
                          style: AppText.bodyMuted.copyWith(
                            color: const Color(0xFFADB5BD),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 32,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: SizedBox(
                      width: 96,
                      height: 4,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) => LinearProgressIndicator(
                          value: _controller.value,
                          backgroundColor: const Color(0x33FFFFFF),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.lime,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
