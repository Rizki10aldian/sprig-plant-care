abstract final class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String shell = '/shell';
  static const String detail = '/detail';
  static const String add = '/add';
}

/// Argumen halaman detail. Hanya membawa id, bukan objek tanaman, supaya
/// halaman detail selalu menampilkan data terbaru dari ViewModel.
class DetailArgs {
  const DetailArgs({required this.plantId, required this.heroTag});

  final String plantId;
  final String heroTag;
}
