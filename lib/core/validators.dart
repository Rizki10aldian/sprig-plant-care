/// Aturan validasi input. Setiap fungsi mengembalikan pesan error,
/// atau `null` jika input valid (sesuai kontrak `FormFieldValidator`).
abstract final class Validators {
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static String? email(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Email tidak boleh kosong';
    if (!_email.hasMatch(text)) return 'Format email tidak valid';
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Kata sandi tidak boleh kosong';
    if (text.length < 6) return 'Kata sandi minimal 6 karakter';
    return null;
  }

  static String? plantName(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Nama tanaman wajib diisi';
    if (text.length < 2) return 'Nama minimal 2 karakter';
    if (text.length > 30) return 'Nama maksimal 30 karakter';
    return null;
  }

  static String? optionalMax(String? value, int max) {
    final text = (value ?? '').trim();
    if (text.length > max) return 'Maksimal $max karakter';
    return null;
  }

  static String? waterDays(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Isi jumlah hari';
    final days = int.tryParse(text);
    if (days == null) return 'Masukkan angka yang valid';
    if (days < 1 || days > 60) return 'Isi antara 1 sampai 60 hari';
    return null;
  }
}
