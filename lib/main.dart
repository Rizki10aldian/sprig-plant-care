import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sprig/app.dart';
import 'package:sprig/data/auth_repository.dart';
import 'package:sprig/data/plant_repository.dart';
import 'package:sprig/render3d/model_store.dart';
import 'package:sprig/state/auth_view_model.dart';
import 'package:sprig/state/plant_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Jaring pengaman: error yang lolos dicatat, bukan membuat aplikasi force close.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Kesalahan tak tertangani: $error');
    return true;
  };

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Model 3D dimuat dulu; bila gagal, aplikasi tetap jalan dengan gambar 2D.
  await ModelStore.instance.preload();

  runApp(const SprigRoot());
}

/// Akar aplikasi. ViewModel dibuat di sini, di atas `MaterialApp`, sehingga
/// state bertahan saat layar diputar dan saat berpindah halaman.
class SprigRoot extends StatelessWidget {
  const SprigRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(AuthRepository()),
        ),
        ChangeNotifierProvider<PlantViewModel>(
          create: (_) => PlantViewModel(PlantRepository())..load(),
        ),
      ],
      child: const SprigApp(),
    );
  }
}
