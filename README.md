# Sprig — aplikasi perawatan tanaman (ATS Praktikum PPB, RPL317)

Flutter + Provider (ChangeNotifier). 8 layar: Splash, Onboarding, Login, Jelajah,
Kebun, Detail, Tambah Tanaman, Profil. Data dummy saja.

## Menjalankan (Windows)
```
cd C:\Users\RIZKY\Project_flutter\sprig
flutter create . --project-name sprig --platforms=android,ios
flutter pub get
flutter run
```
Akun demo: `rizki@sprig.app` / `sprig123`

## Menguji error handling
Profil -> aktifkan "Simulasi koneksi terputus" -> Reset data demo (layar error
penuh + Coba lagi) atau tarik-segarkan di Jelajah (snackbar error).

## Tes
`flutter test`

## Efek visual
- Sentuhan 3D (miring ke arah jari + kilau) di `lib/widgets/pressable_scale.dart`
- Glassmorphism / backdrop blur: `lib/widgets/glass.dart` (nav bar, snackbar, tombol, bilah bawah detail, kartu login)
- Transisi halaman: `lib/routing/app_router.dart`
- Animasi Lottie (JSON buatan sendiri): `assets/lottie/*.json`, dipakai lewat `lib/widgets/lottie_view.dart`

## Tanaman 3D dan maskot
- Model 3D low-poly: `assets/models/p01..p14.json` (satu per tanaman), dirender oleh
  `lib/render3d/` (perender software + widget `Plant3DView`). Geser horizontal di halaman
  Detail untuk memutar tanaman.
- Maskot "Pip": `assets/lottie/pip_*.json` (idle, happy, sad, sleepy, wave, cover),
  dipakai lewat `lib/widgets/mascot.dart`. Sentuh Pip untuk membuatnya melompat.
