import 'package:flutter/material.dart';

/// Palet Sprig: hitam-putih minimalis dengan satu aksen lime.
abstract final class AppColors {
  static const Color ink = Color(0xFF212529);
  static const Color inkSoft = Color(0xFF343A40);
  static const Color background = Color(0xFFF5F6F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF6C757D);
  static const Color line = Color(0xFFE6E8EA);

  static const Color lime = Color(0xFFC8F169);
  static const Color limeSoft = Color(0xFFEAF8C8);

  static const Color danger = Color(0xFFE5484D);
  static const Color dangerSoft = Color(0xFFFDECEC);
  static const Color warnSoft = Color(0xFFFFF1CC);
  static const Color warnInk = Color(0xFF8A5A00);
  static const Color okSoft = Color(0xFFE6F4EA);
  static const Color okInk = Color(0xFF2E6B45);

  /// Warna latar pastel untuk ilustrasi tanaman.
  static const List<Color> tints = <Color>[
    Color(0xFFDDEBDD),
    Color(0xFFE9EFD2),
    Color(0xFFF1E6D8),
    Color(0xFFDCE8EC),
    Color(0xFFEBE3F0),
  ];

  static Color tint(int index) => tints[index % tints.length];
}
