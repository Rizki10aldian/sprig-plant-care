import 'package:flutter/material.dart';
import 'package:sprig/theme/app_colors.dart';
import 'package:sprig/theme/app_shadows.dart';

/// Logo Sprig: kotak lime membulat dengan ikon daun.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.lime,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: AppShadows.glow(AppColors.lime, alpha: 0.5),
      ),
      child: Icon(Icons.eco_rounded, size: size * 0.55, color: AppColors.ink),
    );
  }
}
