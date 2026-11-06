import 'dart:ui' show FontVariation;

import 'package:flutter/material.dart';
import 'package:sprig/theme/app_colors.dart';

/// Tipografi kuat dengan Instrument Sans (font variabel).
/// Bobot diatur lewat `fontVariations` agar tampil benar di semua platform.
abstract final class AppText {
  static const String family = 'InstrumentSans';

  static TextStyle _style(
    double size,
    double weight, {
    double? height,
    double spacing = 0,
    Color color = AppColors.ink,
  }) {
    final index = ((weight / 100).round() - 1).clamp(0, 8).toInt();
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight: FontWeight.values[index],
      fontVariations: <FontVariation>[FontVariation('wght', weight)],
      height: height,
      letterSpacing: spacing,
      color: color,
    );
  }

  static final TextStyle display =
      _style(32, 700, height: 1.08, spacing: -1.0);
  static final TextStyle title = _style(22, 700, height: 1.2, spacing: -0.5);
  static final TextStyle heading = _style(17, 600, height: 1.25, spacing: -0.2);
  static final TextStyle body =
      _style(15, 400, height: 1.5, color: const Color(0xFF3B4147));
  static final TextStyle bodyMuted =
      _style(14, 400, height: 1.45, color: AppColors.muted);
  static final TextStyle label = _style(13, 600, color: AppColors.ink);
  static final TextStyle caption =
      _style(12, 500, height: 1.3, color: AppColors.muted);
  static final TextStyle button =
      _style(15.5, 600, spacing: -0.1, color: Colors.white);
}
