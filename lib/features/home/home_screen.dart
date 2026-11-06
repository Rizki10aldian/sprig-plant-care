import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sprig/core/formatters.dart';
import 'package:sprig/core/models/plant.dart';
import 'package:sprig/core/models/user_profile.dart';
import 'package:sprig/features/home/widgets/featured_card.dart';
import 'package:sprig/features/home/widgets/filter_chips.dart';
import 'package:sprig/routing/app_routes.dart';
import 'package:sprig/state/auth_view_model.dart';
import 'package:sprig/state/plant_view_model.dart';
import 'package:sprig/theme/app_colors.dart';
import 'package:sprig/theme/app_shadows.dart';
import 'package:sprig/theme/app_text.dart';
import 'package:sprig/widgets/app_snack.dart';
import 'package:sprig/widgets/lottie_view.dart';
import 'package:sprig/widgets/mascot.dart';
import 'package:sprig/widgets/message_panel.dart';
import 'package:sprig/widgets/plant_card.dart';
import 'package:sprig/widgets/pressable_scale.dart';
import 'package:sprig/widgets/section_header.dart';
import 'package:sprig/widgets/skeleton_card.dart';
import 'package:sprig/widgets/stagger_in.dart';

/// Halaman 4: Jelajah (dashboard) - pencarian, filter, favorit, tarik-segarkan.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onSwitchTab});

  final ValueChanged<int> onSwitchTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: context.read<PlantViewModel>().query);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openDetail(Plant plant, String heroTag) {
    Navigator.of(context).pushNamed(
      AppRoutes.detail,
      arguments: DetailArgs(plantId: plant.id, heroTag: heroTag),
    );
  }

  void _openAdd() => Navigator.of(context).pushNamed(AppRoutes.add);

  void _clearSearch() {
    _search.clear();
    context.read<PlantViewModel>().setQuery('');
  }

  void _resetFilters() {
    _search.clear();
    context.read<PlantViewModel>().resetFilters();
  }

  Future<void> _refresh() async {
    final error = await context.read<PlantViewModel>().refresh();
    if (!mounted) return;
    if (error != null) {
      HapticFeedback.lightImpact();
      showAppSnack(context, error, isError: true);
    } else {
      showAppSnack(context, 'Data berhasil diperbarui');
    }
  }

  SliverGridDelegate _gridDelegate(double textScale) {
    return SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 240,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      mainAxisExtent: 268 * textScale,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlantViewModel>();
    if (vm.query.isEmpty && _search.text.isNotEmpty) _search.clear();
    final user = context.select<AuthViewModel, UserProfile?>((a) => a.user);
    final plants = vm.visiblePlants;
    final textScale =
        MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3).toDouble();

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.ink,
        backgroundColor: Colors.white,
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: _Header(
                name: user?.name ?? 'Teman',
                initial: user?.initial ?? '?',
                mood: vm.dueCount > 0 ? MascotMood.sad : MascotMood.idle,
                onAvatar: () => widget.onSwitchTab(2),
                onMascot: () => showAppSnack(
                  context,
                  vm.dueCount > 0
                      ? '${vm.dueCount} tanaman haus. Yuk siram di tab Kebun!'
                      : 'Semua tanamanmu sehat. Kamu hebat!',
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildSearchRow(vm)),
            SliverToBoxAdapter(
              child: StaggerIn(
                index: 2,
                child: FilterChips(
                  selected: vm.filter,
                  onChanged: context.read<PlantViewModel>().setFilter,
                ),
              ),
            ),
            if (vm.offline) const SliverToBoxAdapter(child: _OfflineBanner()),
            ..._content(vm, plants, textScale),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchRow(PlantViewModel vm) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(99),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
      child: StaggerIn(
        index: 1,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _search,
                onChanged: context.read<PlantViewModel>().setQuery,
                textInputAction: TextInputAction.search,
                style: AppText.body.copyWith(color: AppColors.ink),
                decoration: InputDecoration(
                  hintText: 'Cari tanaman...',
                  hintStyle:
                      AppText.body.copyWith(color: const Color(0xFF9AA1A8)),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.muted,
                  ),
                  suffixIcon: vm.query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Hapus pencarian',
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.close_rounded, size: 20),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: border(AppColors.line),
                  enabledBorder: border(AppColors.line),
                  focusedBorder: border(AppColors.ink, 1.6),
                ),
              ),
            ),
            const SizedBox(width: 12),
            PressableScale(
              onTap: _openAdd,
              semanticLabel: 'Tambah tanaman baru',
              child: Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: AppColors.ink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(
    PlantViewModel vm,
    List<Plant> plants,
    double textScale,
  ) {
    const gridPadding = EdgeInsets.symmetric(horizontal: 24);

    if (vm.status == LoadStatus.loading && !vm.hasPlants) {
      return [
        SliverPadding(
          padding: gridPadding,
          sliver: SliverGrid(
            gridDelegate: _gridDelegate(textScale),
            delegate: SliverChildBuilderDelegate(
              (context, i) => const SkeletonCard(),
              childCount: 6,
            ),
          ),
        ),
      ];
    }

    if (vm.status == LoadStatus.error && !vm.hasPlants) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: MessagePanel(
            icon: Icons.wifi_off_rounded,
            leading: const Mascot(size: 150, mood: MascotMood.sad),
            title: 'Gagal memuat tanaman',
            message: vm.errorMessage ?? 'Terjadi kesalahan. Silakan coba lagi.',
            actionLabel: 'Coba lagi',
            onAction: vm.load,
          ),
        ),
      ];
    }

    if (plants.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: MessagePanel(
            icon: Icons.search_off_rounded,
            leading: const LottieView(
              asset: LottieView.leaves,
              size: 170,
              fallback: Icon(Icons.search_off_rounded, size: 40),
            ),
            title: 'Tidak ada hasil',
            message: 'Coba kata kunci lain atau ganti kategori.',
            actionLabel: 'Atur ulang filter',
            onAction: _resetFilters,
          ),
        ),
      ];
    }

    final featured = vm.featuredPlant;
    final showFeatured =
        vm.filter == PlantFilter.all && vm.query.trim().isEmpty && featured != null;

    return [
      if (showFeatured)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: StaggerIn(
              index: 3,
              child: FeaturedCard(
                plant: featured,
                heroTag: 'featured-${featured.id}',
                onTap: () => _openDetail(featured, 'featured-${featured.id}'),
              ),
            ),
          ),
        ),
      SectionHeader(
        title: vm.filter == PlantFilter.all ? 'Semua tanaman' : vm.filter.label,
        trailing: '${plants.length} tanaman',
      ).asSliver(),
      SliverPadding(
        padding: gridPadding,
        sliver: SliverGrid(
          gridDelegate: _gridDelegate(textScale),
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final plant = plants[i];
              final tag = 'home-${plant.id}';
              return KeyedSubtree(
                key: ValueKey<String>(plant.id),
                child: StaggerIn(
                  index: i,
                  child: PlantCard(
                    plant: plant,
                    heroTag: tag,
                    onTap: () => _openDetail(plant, tag),
                    onFavorite: () {
                      context.read<PlantViewModel>().toggleFavorite(plant.id);
                    },
                  ),
                ),
              );
            },
            childCount: plants.length,
          ),
        ),
      ),
    ];
  }
}

extension on Widget {
  Widget asSliver() => SliverToBoxAdapter(child: this);
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.initial,
    required this.mood,
    required this.onAvatar,
    required this.onMascot,
  });

  final String name;
  final String initial;
  final MascotMood mood;
  final VoidCallback onAvatar;
  final VoidCallback onMascot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: StaggerIn(
        index: 0,
        child: Row(
          children: [
            Mascot(size: 72, mood: mood, onTap: onMascot),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting(DateTime.now()), style: AppText.bodyMuted),
                  const SizedBox(height: 2),
                  Text(
                    'Halo, $name',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.display,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            PressableScale(
              onTap: onAvatar,
              semanticLabel: 'Buka profil',
              child: Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.glow(AppColors.lime, alpha: 0.4),
                ),
                child: Text(initial, style: AppText.heading),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warnSoft,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 20,
              color: AppColors.warnInk,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Koneksi terputus. Menampilkan data tersimpan; tarik ke bawah untuk mencoba lagi.',
                style: AppText.caption.copyWith(color: AppColors.warnInk),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
