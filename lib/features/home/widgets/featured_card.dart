import 'package:flutter/material.dart';
import 'package:sprig/core/models/plant.dart';
import 'package:sprig/theme/app_colors.dart';
import 'package:sprig/theme/app_shadows.dart';
import 'package:sprig/theme/app_text.dart';
import 'package:sprig/widgets/plant_art.dart';
import 'package:sprig/widgets/pressable_scale.dart';

/// Kartu besar "Tanaman hari ini" di bagian atas Jelajah.
class FeaturedCard extends StatelessWidget {
  const FeaturedCard({
    super.key,
    required this.plant,
    required this.heroTag,
    required this.onTap,
  });

  final Plant plant;
  final String heroTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      scale: 0.98,
      glare: true,
      glareRadius: 32,
      semanticLabel: 'Tanaman pilihan hari ini: ${plant.name}',
      child: Container(
        height: 208,
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(32),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 8, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lime,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        'Pilihan hari ini',
                        style: AppText.caption.copyWith(color: AppColors.ink),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plant.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.title.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          plant.latinName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.caption.copyWith(
                            color: const Color(0xFFADB5BD),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.water_drop_rounded,
                          size: 16,
                          color: AppColors.lime,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Tiap ${plant.waterEveryDays} hari',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.caption.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Hero(
                  tag: heroTag,
                  child: PlantArtPanel(
                    style: plant.art,
                    modelKey: plant.modelKey,
                    tintIndex: plant.tintIndex,
                    radius: 26,
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
