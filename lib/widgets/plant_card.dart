import 'package:flutter/material.dart';
import 'package:sprig/core/models/plant.dart';
import 'package:sprig/theme/app_colors.dart';
import 'package:sprig/theme/app_shadows.dart';
import 'package:sprig/theme/app_text.dart';
import 'package:sprig/widgets/favorite_button.dart';
import 'package:sprig/widgets/glass.dart';
import 'package:sprig/widgets/plant_art.dart';
import 'package:sprig/widgets/pressable_scale.dart';

/// Kartu tanaman untuk grid di halaman Jelajah.
class PlantCard extends StatelessWidget {
  const PlantCard({
    super.key,
    required this.plant,
    required this.heroTag,
    required this.onTap,
    required this.onFavorite,
  });

  final Plant plant;
  final String heroTag;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      scale: 0.97,
      glare: true,
      semanticLabel: '${plant.name}, ${plant.latinName}',
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: heroTag,
                      child: PlantArtPanel(
                        style: plant.art,
                        modelKey: plant.modelKey,
                        tintIndex: plant.tintIndex,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: FavoriteButton(
                      isFavorite: plant.isFavorite,
                      onTap: onFavorite,
                    ),
                  ),
                  if (plant.inGarden)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: GlassContainer.dark(
                        borderRadius: BorderRadius.circular(99),
                        blur: 10,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        child: Text(
                          'Di kebun',
                          style: AppText.caption.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 10, 6, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.heading.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plant.latinName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.water_drop_outlined,
                        size: 14,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Tiap ${plant.waterEveryDays} hari',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.caption,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
