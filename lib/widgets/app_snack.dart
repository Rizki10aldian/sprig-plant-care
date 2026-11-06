import 'package:flutter/material.dart';
import 'package:sprig/theme/app_colors.dart';
import 'package:sprig/theme/app_text.dart';
import 'package:sprig/widgets/glass.dart';

/// Menampilkan pesan singkat. [showAppSnackOn] dipakai bila halaman akan
/// ditutup sebelum pesan muncul (messenger diambil lebih dulu).
void showAppSnack(
  BuildContext context,
  String message, {
  bool isError = false,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  showAppSnackOn(
    ScaffoldMessenger.of(context),
    message,
    isError: isError,
    actionLabel: actionLabel,
    onAction: onAction,
  );
}

void showAppSnackOn(
  ScaffoldMessengerState messenger,
  String message, {
  bool isError = false,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: GlassContainer(
          borderRadius: BorderRadius.circular(20),
          blur: 16,
          tint: isError ? const Color(0xE6E5484D) : const Color(0xD9212529),
          borderColor: const Color(0x26FFFFFF),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              size: 20,
              color: isError ? Colors.white : AppColors.lime,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppText.body.copyWith(color: Colors.white, fontSize: 14),
              ),
            ),
            if (actionLabel != null)
              TextButton(
                onPressed: () {
                  messenger.hideCurrentSnackBar();
                  (onAction ?? () {})();
                },
                child: Text(
                  actionLabel,
                  style: AppText.label.copyWith(color: AppColors.lime),
                ),
              ),
          ],
        ),
        ),
      ),
    );
}
