import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sprig/features/garden/garden_screen.dart';
import 'package:sprig/features/home/home_screen.dart';
import 'package:sprig/features/profile/profile_screen.dart';
import 'package:sprig/features/shell/floating_nav_bar.dart';
import 'package:sprig/state/plant_view_model.dart';

/// Kerangka halaman utama dengan tiga tab: Jelajah, Kebun, Profil.
/// Tab disimpan dalam [IndexedStack] sehingga posisi scroll dan isi tiap tab
/// tidak hilang saat berpindah tab.
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen>
    with SingleTickerProviderStateMixin {
  static const List<NavItemData> _items = <NavItemData>[
    NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Jelajah',
    ),
    NavItemData(
      icon: Icons.local_florist_outlined,
      activeIcon: Icons.local_florist_rounded,
      label: 'Kebun',
    ),
    NavItemData(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profil',
    ),
  ];

  int _index = 0;

  late final AnimationController _tab = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 460),
    value: 1,
  );
  late final CurvedAnimation _tabCurve = CurvedAnimation(
    parent: _tab,
    curve: Curves.easeOutCubic,
  );

  @override
  void dispose() {
    _tabCurve.dispose();
    _tab.dispose();
    super.dispose();
  }

  void _animateTab() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _tab.value = 1;
    } else {
      _tab.forward(from: 0);
    }
  }

  void _select(int value) {
    if (value == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = value);
    _animateTab();
  }

  @override
  Widget build(BuildContext context) {
    final landscape = MediaQuery.orientationOf(context) == Orientation.landscape;
    final due = context.select<PlantViewModel, int>((vm) => vm.dueCount);

    final stack = IndexedStack(
      index: _index,
      children: [
        TickerMode(
          enabled: _index == 0,
          child: HomeScreen(onSwitchTab: _select),
        ),
        TickerMode(
          enabled: _index == 1,
          child: GardenScreen(onExplore: () => _select(0)),
        ),
        TickerMode(
          enabled: _index == 2,
          child: ProfileScreen(onSwitchTab: _select),
        ),
      ],
    );
    final pages = AnimatedBuilder(
      animation: _tabCurve,
      child: stack,
      builder: (context, child) {
        final t = _tabCurve.value;
        return Opacity(
          opacity: (0.4 + 0.6 * t).clamp(0.0, 1.0).toDouble(),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0008)
              ..translate(0.0, (1 - t) * 18)
              ..scale(0.97 + 0.03 * t),
            child: child,
          ),
        );
      },
    );

    final nav = FloatingNavBar(
      items: _items,
      index: _index,
      onChanged: _select,
      vertical: landscape,
      badgeIndex: due > 0 ? 1 : null,
    );

    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          setState(() => _index = 0);
          _animateTab();
        }
      },
      child: Scaffold(
        extendBody: true,
        body: landscape
            ? Row(
                children: [
                  SafeArea(
                    right: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                      child: Center(child: nav),
                    ),
                  ),
                  Expanded(child: pages),
                ],
              )
            : pages,
        bottomNavigationBar: landscape
            ? null
            : SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [nav],
                  ),
                ),
              ),
      ),
    );
  }
}
