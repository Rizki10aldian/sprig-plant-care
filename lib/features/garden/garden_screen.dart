import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sprig/core/models/plant.dart';
import 'package:sprig/features/garden/widgets/garden_tile.dart';
import 'package:sprig/routing/app_routes.dart';
import 'package:sprig/state/plant_view_model.dart';
import 'package:sprig/theme/app_colors.dart';
import 'package:sprig/theme/app_shadows.dart';
import 'package:sprig/theme/app_text.dart';
import 'package:sprig/widgets/app_snack.dart';
import 'package:sprig/widgets/lottie_view.dart';
import 'package:sprig/widgets/mascot.dart';
import 'package:sprig/widgets/message_panel.dart';
import 'package:sprig/widgets/pill_button.dart';
import 'package:sprig/widgets/stagger_in.dart';
import 'package:sprig/widgets/water_ring.dart';

/// Halaman 5: Kebun saya - jadwal siram, siram semua, geser untuk menghapus.
class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key, required this.onExplore});

  final VoidCallback onExplore;

  void _waterAll(BuildContext context) {
    final count = context.read<PlantViewModel>().waterAllDue();
    HapticFeedback.mediumImpact();
    showAppSnack(
      context,
      count == 0
          ? 'Belum ada tanaman yang perlu disiram'
          : '$count tanaman berhasil disiram',
    );
  }

  void _water(BuildContext context, Plant plant) {
    context.read<PlantViewModel>().waterPlant(plant.id);
    HapticFeedback.lightImpact();
    showAppSnack(context, '${plant.name} sudah disiram');
  }

  void _remove(BuildContext context, Plant plant) {
    final vm = context.read<PlantViewModel>();
    final removed = vm.removeFromGarden(plant.id);
    if (removed == null) return;
    HapticFeedback.mediumImpact();
    showAppSnack(
      context,
      '${plant.name} dikeluarkan dari kebun',
      actionLabel: 'Urungkan',
      onAction: () => vm.undoRemove(removed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlantViewModel>();
    final garden = vm.gardenPlants;
    final due = vm.dueCount;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: StaggerIn(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kebun saya', style: AppText.display),
                          const SizedBox(height: 2),
                          Text(
                            garden.isEmpty
                                ? 'Mulai koleksi tanamanmu'
                                : '${garden.length} tanaman dirawat',
                            style: AppText.bodyMuted,
                          ),
                        ],
                      ),
                    ),
                    Mascot(
                      size: 88,
                      mood: garden.isEmpty
                          ? MascotMood.sleepy
                          : (due > 0 ? MascotMood.sad : MascotMood.happy),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (garden.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: MessagePanel(
                icon: Icons.local_florist_outlined,
                leading: const LottieView(
                  asset: LottieView.waterDrop,
                  size: 190,
                  fallback: Icon(Icons.local_florist_outlined, size: 40),
                ),
                title: 'Kebunmu masih kosong',
                message:
                    'Tambahkan tanaman dari halaman Jelajah, atau buat tanamanmu sendiri.',
                actionLabel: 'Jelajahi tanaman',
                onAction: onExplore,
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: StaggerIn(
                  index: 1,
                  child: _SummaryCard(
                    due: due,
                    total: garden.length,
                    onWaterAll: due > 0 ? () => _waterAll(context) : null,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
              sliver: SliverList.separated(
                itemCount: garden.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  final plant = garden[i];
                  final tag = 'garden-${plant.id}';
                  return Dismissible(
                    key: ValueKey<String>('dismiss-${plant.id}'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _remove(context, plant),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 28),
                      decoration: BoxDecoration(
                        color: AppColors.dangerSoft,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.danger,
                      ),
                    ),
                    child: StaggerIn(
                      index: i + 2,
                      child: GardenTile(
                        plant: plant,
                        heroTag: tag,
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.detail,
                          arguments: DetailArgs(plantId: plant.id, heroTag: tag),
                        ),
                        onWater: () => _water(context, plant),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.due,
    required this.total,
    required this.onWaterAll,
  });

  final int due;
  final int total;
  final VoidCallback? onWaterAll;

  @override
  Widget build(BuildContext context) {
    final done = total - due;
    final fraction = total == 0 ? 0.0 : done / total;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          WaterRing(
            progress: fraction,
            size: 76,
            stroke: 7,
            color: AppColors.lime,
            track: const Color(0xFF3B4147),
            child: Text(
              '$done/$total',
              style: AppText.heading.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  due == 0 ? 'Semua sudah segar' : '$due perlu disiram',
                  style: AppText.title.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  due == 0
                      ? 'Kerja bagus hari ini.'
                      : 'Siram sekarang agar tetap sehat.',
                  style: AppText.caption.copyWith(
                    color: const Color(0xFFADB5BD),
                  ),
                ),
                const SizedBox(height: 12),
                PillButton(
                  label: 'Siram semua',
                  icon: Icons.water_drop_rounded,
                  style: PillButtonStyle.accent,
                  height: 44,
                  expand: false,
                  onPressed: onWaterAll,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
