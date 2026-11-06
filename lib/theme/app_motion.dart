import 'package:flutter/widgets.dart';

/// Durasi animasi terpusat. Jika pengguna mematikan animasi di pengaturan
/// perangkat, semua durasi menjadi nol sehingga layar langsung tampil final.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration medium = Duration(milliseconds: 360);
  static const Duration slow = Duration(milliseconds: 800);

  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  static Duration resolve(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;
}
