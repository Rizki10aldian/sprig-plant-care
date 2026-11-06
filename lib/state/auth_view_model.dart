import 'package:flutter/foundation.dart';
import 'package:sprig/core/errors/app_exceptions.dart';
import 'package:sprig/core/models/user_profile.dart';
import 'package:sprig/data/auth_repository.dart';

/// State autentikasi. Diletakkan di atas `MaterialApp` lewat Provider,
/// sehingga tidak hilang saat layar diputar atau berpindah halaman.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repository);

  final AuthRepository _repository;

  UserProfile? _user;
  bool _loading = false;
  String? _error;

  UserProfile? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _repository.login(email, password);
      return true;
    } on AppException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Terjadi kesalahan tak terduga. Silakan coba lagi.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  void logout() {
    _user = null;
    _error = null;
    notifyListeners();
  }
}
