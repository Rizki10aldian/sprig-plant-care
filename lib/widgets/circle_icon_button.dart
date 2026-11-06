import 'package:flutter/material.dart';
import 'package:sprig/theme/app_colors.dart';
import 'package:sprig/theme/app_shadows.dart';
import 'package:sprig/widgets/glass.dart';
import 'package:sprig/widgets/pressable_scale.dart';

/// Tombol ikon bulat putih (kembali, aksi cepat). [semanticLabel] wajib
/// agar tombol tetap bisa dipahami pembaca layar.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.color = AppColors.ink,
    this.size = 44,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: SizedBox(
        width: size,
        height: size,
        child: GlassContainer(
          shape: BoxShape.circle,
          blur: 14,
          tint: const Color(0xB8FFFFFF),
          shadow: AppShadows.soft,
          child: Center(child: Icon(icon, size: 20, color: color)),
        ),
      ),
    );
  }
}
