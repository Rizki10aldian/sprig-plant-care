import 'package:flutter/material.dart';
import 'package:sprig/routing/app_router.dart';
import 'package:sprig/routing/app_routes.dart';
import 'package:sprig/theme/app_theme.dart';

class SprigApp extends StatelessWidget {
  const SprigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sprig',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
      // Batasi pembesaran teks sistem agar tata letak tetap rapi.
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: 1.0,
        maxScaleFactor: 1.3,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
