/// Kesalahan yang dipahami aplikasi. Semuanya membawa pesan yang siap
/// ditampilkan ke pengguna, sehingga UI tidak perlu menebak-nebak.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Koneksi internet terputus / server tidak terjangkau.
final class NetworkException extends AppException {
  const NetworkException([
    super.message =
        'Tidak ada koneksi internet. Periksa jaringanmu lalu coba lagi.',
  ]);
}

/// Email atau kata sandi tidak cocok.
final class AuthException extends AppException {
  const AuthException(super.message);
}

/// Data yang dimasukkan pengguna tidak memenuhi aturan.
final class ValidationException extends AppException {
  const ValidationException(super.message);
}
