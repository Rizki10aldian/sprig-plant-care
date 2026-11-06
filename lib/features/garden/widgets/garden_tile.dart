import 'package:flutter/material.dart';
import 'package:sprig/core/formatters.dart';
import 'package:sprig/core/models/plant.dart';
import 'package:sprig/theme/app_colors.dart';
import 'package:sprig/theme/app_shadows.dart';
import 'package:sprig/theme/app_text.dart';
import 'package:sprig/widgets/due_chip.dart';
import 'package:sprig/widgets/plant_art.dart';
import 'package:sprig/widgets/pressable_scale.dart';
import 'package:sprig/widgets/water_ring.dart';

/// Baris tanaman di tab Kebun: gambar, nama, status siram, dan tombol siram.
class GardenTile extends StatelessWidget {
  const GardenTile({
    super.key,
    required this.plant,
    required this.heroTag,
    required this.onTap,
    required this.onWater,
  });

  final Plant plant;
  final String heroTag;
  final VoidCallback onTap;
  final VoidCallback onWater;

  @override
  Widget build(BuildContext context) {
    final days = plant.daysUntilWatering();
    final due = days <= 0;
    final last = plant.lastWatered;

    return PressableScale(
      onTap: onTap,
      scale: 0.98,
      glare: true,
      semanticLabel: '${plant.name}, ${dueLabel(days)}',
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 84,
              height: 84,
              child: Hero(
                tag: heroTag,
                child: PlantArtPanel(
                  style: plant.art,
                  modelKey: plant.modelKey,
                  tintIndex: plant.tintIndex,
                  radius: 20,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.heading,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    last == null
                        ? 'Belum pernah disiram'
                        : 'Terakhir disiram ${shortDate(last)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DueChip(daysLeft: days),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PressableScale(
              onTap: onWater,
              scale: 0.9,
              semanticLabel: 'Siram ${plant.name}',
              child: WaterRing(
                progress: plant.waterProgress(),
                color: due ? AppColors.danger : AppColors.ink,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: due ? AppColors.lime : AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.water_drop_rounded,
                    size: 18,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
