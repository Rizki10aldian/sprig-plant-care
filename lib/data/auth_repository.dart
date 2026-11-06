import 'package:sprig/core/errors/app_exceptions.dart';
import 'package:sprig/core/models/user_profile.dart';

/// Autentikasi dummy: hanya satu akun demo yang diterima.
class AuthRepository {
  AuthRepository({this.latency = const Duration(milliseconds: 900)});

  static const String demoEmail = 'rizki@sprig.app';
  static const String demoPassword = 'sprig123';

  final Duration latency;

  Future<UserProfile> login(String email, String password) async {
    await Future<void>.delayed(latency);
    final matches = email.trim().toLowerCase() == demoEmail &&
        password == demoPassword;
    if (!matches) {
      throw const AuthException('Email atau kata sandi salah.');
    }
    return const UserProfile(name: 'Rizki', email: demoEmail);
  }
}
