import 'package:flutter/material.dart';
import 'package:sprig/theme/app_colors.dart';
import 'package:sprig/theme/app_motion.dart';
import 'package:sprig/theme/app_text.dart';
import 'package:sprig/widgets/pressable_scale.dart';

enum PillButtonStyle { primary, accent, outline, danger }

/// Tombol utama aplikasi. Mendukung status memuat (loading) dan nonaktif.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = PillButtonStyle.primary,
    this.loading = false,
    this.expand = true,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final PillButtonStyle style;
  final bool loading;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final (Color bg, Color fg, Color border) = switch (style) {
      PillButtonStyle.primary => (AppColors.ink, Colors.white, AppColors.ink),
      PillButtonStyle.accent => (AppColors.lime, AppColors.ink, AppColors.lime),
      PillButtonStyle.outline => (Colors.white, AppColors.ink, AppColors.line),
      PillButtonStyle.danger => (
          AppColors.dangerSoft,
          AppColors.danger,
          AppColors.dangerSoft,
        ),
    };

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: PressableScale(
        onTap: enabled ? onPressed : null,
        child: AnimatedOpacity(
          opacity: onPressed == null && !loading ? 0.45 : 1,
          duration: AppMotion.resolve(context, AppMotion.fast),
          child: Container(
            height: height,
            width: expand ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: border),
            ),
            child: Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: fg,
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: fg),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.button.copyWith(color: fg),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
