import 'package:flutter/material.dart';
import 'package:sprig/features/add_plant/add_plant_screen.dart';
import 'package:sprig/features/detail/detail_screen.dart';
import 'package:sprig/features/login/login_screen.dart';
import 'package:sprig/features/onboarding/onboarding_screen.dart';
import 'package:sprig/features/shell/shell_screen.dart';
import 'package:sprig/features/splash/splash_screen.dart';
import 'package:sprig/routing/app_routes.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.onboarding:
        return _fade(settings, const OnboardingScreen());
      case AppRoutes.login:
        return _fade(settings, const LoginScreen());
      case AppRoutes.shell:
        return _fade(settings, const ShellScreen());
      case AppRoutes.detail:
        final args = settings.arguments;
        if (args is DetailArgs) {
          return _fade(settings, DetailScreen(args: args));
        }
        return _fade(settings, const ShellScreen());
      case AppRoutes.add:
        return _slideUp(settings, const AddPlantScreen());
      case AppRoutes.splash:
      default:
        return _fade(settings, const SplashScreen());
    }
  }

  /// Transisi halaman utama: halaman baru naik pelan dengan sedikit
  /// perspektif 3D dan membesar lembut; halaman lama mengecil di belakangnya.
  static PageRoute<dynamic> _fade(RouteSettings settings, Widget page) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 620),
      reverseTransitionDuration: const Duration(milliseconds: 480),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, animation, secondary, child) {
        if (MediaQuery.disableAnimationsOf(context)) return child;
        final enter = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final fade = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
          reverseCurve: const Interval(0.3, 1.0, curve: Curves.easeIn),
        );
        final back = CurvedAnimation(
          parent: secondary,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return AnimatedBuilder(
          animation: Listenable.merge([enter, fade, back]),
          child: child,
          builder: (context, child) {
            final t = enter.value;
            final matrix = Matrix4.identity()
              ..setEntry(3, 2, 0.0009)
              ..translate(0.0, (1 - t) * 36)
              ..rotateX((1 - t) * 0.07)
              ..scale((0.95 + 0.05 * t) * (1 - 0.05 * back.value));
            return Opacity(
              opacity: (fade.value * (1 - 0.3 * back.value))
                  .clamp(0.0, 1.0)
                  .toDouble(),
              child: Transform(
                alignment: Alignment.center,
                transform: matrix,
                child: child,
              ),
            );
          },
        );
      },
    );
  }

  /// Halaman form naik dari bawah seperti lembar kaca.
  static PageRoute<dynamic> _slideUp(RouteSettings settings, Widget page) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 460),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, animation, secondary, child) {
        if (MediaQuery.disableAnimationsOf(context)) return child;
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart,
          reverseCurve: Curves.easeInCubic,
        );
        final back = CurvedAnimation(
          parent: secondary,
          curve: Curves.easeOutCubic,
        );
        return AnimatedBuilder(
          animation: Listenable.merge([curved, back]),
          child: child,
          builder: (context, child) {
            final t = curved.value;
            final matrix = Matrix4.identity()
              ..setEntry(3, 2, 0.0008)
              ..translate(0.0, (1 - t) * 90)
              ..rotateX((1 - t) * 0.12)
              ..scale(1 - 0.04 * back.value);
            return Opacity(
              opacity: animation.value.clamp(0.0, 1.0).toDouble() < 0.01
                  ? 0
                  : (t * 1.4).clamp(0.0, 1.0).toDouble(),
              child: Transform(
                alignment: Alignment.topCenter,
                transform: matrix,
                child: child,
              ),
            );
          },
        );
      },
    );
  }
}
