import 'package:flutter/material.dart';

abstract final class AppShadows {
  /// Drop shadow lembut dua lapis untuk kartu dan tombol putih.
  static const List<BoxShadow> soft = <BoxShadow>[
    BoxShadow(color: Color(0x0F000000), blurRadius: 24, offset: Offset(0, 10)),
    BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  /// Bayangan lebih tegas untuk bilah navigasi gelap yang melayang.
  static const List<BoxShadow> nav = <BoxShadow>[
    BoxShadow(color: Color(0x33000000), blurRadius: 28, offset: Offset(0, 12)),
  ];

  /// Cahaya berwarna di bawah elemen aksen.
  static List<BoxShadow> glow(Color color, {double alpha = 0.45}) {
    return <BoxShadow>[
      BoxShadow(
        color: color.withAlpha((alpha * 255).round()),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ];
  }
}
