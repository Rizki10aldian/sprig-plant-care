import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sprig/core/formatters.dart';
import 'package:sprig/core/models/plant.dart';
import 'package:sprig/routing/app_routes.dart';
import 'package:sprig/state/plant_view_model.dart';
import 'package:sprig/theme/app_colors.dart';
import 'package:sprig/theme/app_shadows.dart';
import 'package:sprig/theme/app_text.dart';
import 'package:sprig/widgets/app_snack.dart';
import 'package:sprig/widgets/circle_icon_button.dart';
import 'package:sprig/widgets/due_chip.dart';
import 'package:sprig/widgets/favorite_button.dart';
import 'package:sprig/widgets/glass.dart';
import 'package:sprig/widgets/mascot.dart';
import 'package:sprig/widgets/message_panel.dart';
import 'package:sprig/widgets/pill_button.dart';
import 'package:sprig/widgets/plant_art.dart';
import 'package:sprig/widgets/stagger_in.dart';

/// Halaman 6: Detail tanaman.
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  /// Salinan terakhir; mencegah layar kosong sesaat ketika tanaman buatan
  /// pengguna dihapus lalu halaman ditutup.
  Plant? _last;
  int _pulse = 0;

  void _remove(Plant plant) {
    final vm = context.read<PlantViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final removed = vm.removeFromGarden(plant.id);
    if (removed == null) return;
    HapticFeedback.mediumImpact();
    showAppSnackOn(
      messenger,
      '${plant.name} dikeluarkan dari kebun',
      actionLabel: 'Urungkan',
      onAction: () => vm.undoRemove(removed),
    );
    if (removed.deleted) Navigator.of(context).maybePop();
  }

  void _water(Plant plant) {
    context.read<PlantViewModel>().waterPlant(plant.id);
    HapticFeedback.lightImpact();
    setState(() => _pulse++);
    showAppSnack(context, '${plant.name} sudah disiram');
  }

  void _add(Plant plant) {
    context.read<PlantViewModel>().addToGarden(plant.id);
    HapticFeedback.mediumImpact();
    setState(() => _pulse++);
    showAppSnack(context, '${plant.name} ditambahkan ke kebun');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlantViewModel>();
    final found = vm.plantById(widget.args.plantId);
    if (found != null) _last = found;
    final plant = found ?? _last;

    if (plant == null) {
      return Scaffold(
        appBar: AppBar(),
        body: MessagePanel(
          icon: Icons.search_off_rounded,
          title: 'Tanaman tidak ditemukan',
          message: 'Data tanaman ini sudah tidak tersedia.',
          actionLabel: 'Kembali',
          onAction: () => Navigator.of(context).maybePop(),
        ),
      );
    }

    final landscape = MediaQuery.orientationOf(context) == Orientation.landscape;
    final artHeight = landscape ? 220.0 : 340.0;

    return Scaffold(
      extendBody: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: artHeight,
                backgroundColor: AppColors.background,
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading: false,
                toolbarHeight: 64,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      CircleIconButton(
                        icon: Icons.arrow_back_rounded,
                        semanticLabel: 'Kembali',
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      FavoriteButton(
                        isFavorite: plant.isFavorite,
                        onTap: () => context
                            .read<PlantViewModel>()
                            .toggleFavorite(plant.id),
                      ),
                    ],
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 72, 20, 12),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: Hero(
                            tag: widget.args.heroTag,
                            child: PlantArtPanel(
                              style: plant.art,
                              modelKey: plant.modelKey,
                              interactive: true,
                              turn: 0.3,
                              tintIndex: plant.tintIndex,
                              radius: 36,
                              padding: const EdgeInsets.all(20),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 4,
                          child: Mascot(
                            size: 84,
                            pulse: _pulse,
                            mood: plant.inGarden
                                ? (plant.needsWater()
                                    ? MascotMood.sad
                                    : MascotMood.happy)
                                : MascotMood.idle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _Body(plant: plant)),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        blur: 22,
        tint: const Color(0xB3F5F6F7),
        child: SafeArea(
          child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 632),
              child: plant.inGarden
                  ? Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: PillButton(
                            label: 'Hapus',
                            icon: Icons.delete_outline_rounded,
                            style: PillButtonStyle.outline,
                            onPressed: () => _remove(plant),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: PillButton(
                            label: 'Siram sekarang',
                            icon: Icons.water_drop_rounded,
                            style: PillButtonStyle.accent,
                            onPressed: () => _water(plant),
                          ),
                        ),
                      ],
                    )
                  : PillButton(
                      label: 'Tambah ke kebun',
                      icon: Icons.add_rounded,
                      onPressed: () => _add(plant),
                    ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: StaggerIn(
        offset: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plant.name, style: AppText.display),
            const SizedBox(height: 2),
            Text(plant.latinName, style: AppText.bodyMuted),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.water_drop_rounded,
                    label: 'Penyiraman',
                    value: 'Tiap ${plant.waterEveryDays} hari',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.wb_sunny_rounded,
                    label: 'Cahaya',
                    value: plant.light.label.replaceFirst('Cahaya ', ''),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.category_rounded,
                    label: 'Kategori',
                    value: plant.category.label,
                  ),
                ),
              ],
            ),
            if (plant.inGarden) ...[
              const SizedBox(height: 16),
              _WateringCard(plant: plant),
            ],
            const SizedBox(height: 24),
            Text('Tentang', style: AppText.heading),
            const SizedBox(height: 8),
            Text(plant.description, style: AppText.body),
            if (plant.tips.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Tips perawatan', style: AppText.heading),
              const SizedBox(height: 12),
              for (final tip in plant.tips)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: AppColors.lime,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(tip, style: AppText.body)),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.ink),
          const SizedBox(height: 10),
          Text(label, style: AppText.caption),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.label,
          ),
        ],
      ),
    );
  }
}

class _WateringCard extends StatelessWidget {
  const _WateringCard({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context) {
    final days = plant.daysUntilWatering();
    final last = plant.lastWatered;
    final next = plant.nextWatering;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.limeSoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jadwal siram', style: AppText.label),
                const SizedBox(height: 4),
                Text(
                  last == null
                      ? 'Belum pernah disiram'
                      : 'Terakhir ${shortDate(last)}'
                          '${next == null ? '' : ' · berikut ${shortDate(next)}'}',
                  style: AppText.caption.copyWith(color: AppColors.inkSoft),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          DueChip(daysLeft: days),
        ],
      ),
    );
  }
}
