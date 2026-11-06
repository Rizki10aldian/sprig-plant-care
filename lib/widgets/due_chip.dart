import 'package:flutter/material.dart';
import 'package:sprig/core/formatters.dart';
import 'package:sprig/theme/app_colors.dart';
import 'package:sprig/theme/app_text.dart';

/// Label status jadwal siram: kuning bila sudah waktunya, hijau bila masih lama.
class DueChip extends StatelessWidget {
  const DueChip({super.key, required this.daysLeft});

  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    final due = daysLeft <= 0;
    final background = due ? AppColors.warnSoft : AppColors.okSoft;
    final foreground = due ? AppColors.warnInk : AppColors.okInk;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            due ? Icons.water_drop_rounded : Icons.schedule_rounded,
            size: 13,
            color: foreground,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              dueLabel(daysLeft),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
