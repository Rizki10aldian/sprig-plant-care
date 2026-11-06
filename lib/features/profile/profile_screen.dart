import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sprig/core/models/user_profile.dart';
import 'package:sprig/routing/app_routes.dart';
import 'package:sprig/state/auth_view_model.dart';
import 'package:sprig/state/plant_view_model.dart';
import 'package:sprig/theme/app_colors.dart';
import 'package:sprig/theme/app_shadows.dart';
import 'package:sprig/theme/app_text.dart';
import 'package:sprig/widgets/app_snack.dart';
import 'package:sprig/widgets/mascot.dart';
import 'package:sprig/widgets/pill_button.dart';
import 'package:sprig/widgets/stagger_in.dart';

/// Halaman 8: Profil - statistik, simulasi offline, reset data, keluar.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onSwitchTab});

  final ValueChanged<int> onSwitchTab;

  Future<void> _reset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Reset data demo?', style: AppText.heading),
        content: Text(
          'Semua perubahan (kebun, favorit, tanaman buatanmu) akan dikembalikan ke data awal.',
          style: AppText.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Batal', style: AppText.label),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Reset',
              style: AppText.label.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final vm = context.read<PlantViewModel>();
    onSwitchTab(0);
    await vm.resetDemoData();
  }

  void _logout(BuildContext context) {
    context.read<AuthViewModel>().logout();
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlantViewModel>();
    final user = context.select<AuthViewModel, UserProfile?>((a) => a.user);

    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
            children: [
              StaggerIn(
                child: Row(
                  children: [
                    Expanded(child: Text('Profil', style: AppText.display)),
                    Mascot(
                      size: 92,
                      mood: vm.offline ? MascotMood.sad : MascotMood.wave,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              StaggerIn(
                index: 1,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: AppShadows.soft,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.lime,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          user?.initial ?? '?',
                          style: AppText.title,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Tamu',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.title.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? '-',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.caption.copyWith(
                                color: const Color(0xFFADB5BD),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              StaggerIn(
                index: 2,
                child: Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        value: '${vm.gardenPlants.length}',
                        label: 'Di kebun',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Stat(
                        value: '${vm.favoriteCount}',
                        label: 'Favorit',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Stat(
                        value: '${vm.wateringsDone}',
                        label: 'Penyiraman',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              StaggerIn(
                index: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: AppShadows.soft,
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: vm.offline,
                        activeColor: AppColors.ink,
                        activeTrackColor: AppColors.lime,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        title: Text(
                          'Simulasi koneksi terputus',
                          style: AppText.label,
                        ),
                        subtitle: Text(
                          'Untuk menguji penanganan error saat offline.',
                          style: AppText.caption,
                        ),
                        onChanged: (value) {
                          HapticFeedback.selectionClick();
                          vm.setOffline(value);
                          showAppSnack(
                            context,
                            value
                                ? 'Mode offline aktif. Tarik ke bawah di Jelajah untuk mencoba.'
                                : 'Koneksi dipulihkan',
                            isError: value,
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        title: Text('Reset data demo', style: AppText.label),
                        subtitle: Text(
                          'Kembalikan semua data ke kondisi awal.',
                          style: AppText.caption,
                        ),
                        trailing: const Icon(Icons.restart_alt_rounded),
                        onTap: () => _reset(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              StaggerIn(
                index: 4,
                child: PillButton(
                  label: 'Keluar',
                  icon: Icons.logout_rounded,
                  style: PillButtonStyle.danger,
                  onPressed: () => _logout(context),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text('Sprig · versi 1.0.0', style: AppText.caption),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Text(value, style: AppText.title),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption,
          ),
        ],
      ),
    );
  }
}
