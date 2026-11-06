import 'package:flutter/material.dart';
import 'package:sprig/theme/app_colors.dart';
import 'package:sprig/theme/app_motion.dart';
import 'package:sprig/theme/app_shadows.dart';
import 'package:sprig/widgets/glass.dart';
import 'package:sprig/widgets/pressable_scale.dart';

/// Tombol hati dengan animasi membal saat status favorit berubah.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.size = 38,
  });

  final bool isFavorite;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: isFavorite,
      label: isFavorite ? 'Hapus dari favorit' : 'Tambahkan ke favorit',
      excludeSemantics: true,
      child: PressableScale(
        onTap: onTap,
        scale: 0.88,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: SizedBox(
              width: size,
              height: size,
              child: GlassContainer(
              shape: BoxShape.circle,
              blur: 12,
              tint: const Color(0xB8FFFFFF),
              shadow: AppShadows.soft,
              child: AnimatedSwitcher(
                duration: AppMotion.resolve(context, AppMotion.medium),
                switchInCurve: Curves.easeOutBack,
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey<bool>(isFavorite),
                  size: 20,
                  color: isFavorite ? AppColors.danger : AppColors.ink,
                ),
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
