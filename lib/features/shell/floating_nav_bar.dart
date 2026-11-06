import 'package:flutter/material.dart';
import 'package:sprig/theme/app_colors.dart';
import 'package:sprig/theme/app_motion.dart';
import 'package:sprig/theme/app_shadows.dart';
import 'package:sprig/widgets/glass.dart';
import 'package:sprig/widgets/pressable_scale.dart';

class NavItemData {
  const NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Bilah navigasi gelap berbentuk pill yang melayang. Pada layar landscape
/// bilah ini berdiri vertikal di sisi kiri.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
    this.vertical = false,
    this.badgeIndex,
  });

  final List<NavItemData> items;
  final int index;
  final ValueChanged<int> onChanged;
  final bool vertical;

  /// Posisi tab yang diberi titik penanda (mis. Kebun saat ada yang perlu disiram).
  final int? badgeIndex;

  @override
  Widget build(BuildContext context) {
    return GlassContainer.dark(
      borderRadius: BorderRadius.circular(99),
      blur: 20,
      shadow: AppShadows.nav,
      padding: const EdgeInsets.all(6),
      child: Flex(
        direction: vertical ? Axis.vertical : Axis.horizontal,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++)
            _NavButton(
              data: items[i],
              selected: i == index,
              badge: i == badgeIndex,
              onTap: () => onChanged(i),
            ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.data,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  final NavItemData data;
  final bool selected;
  final bool badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: data.label,
      excludeSemantics: true,
      child: PressableScale(
        onTap: onTap,
        haptic: false,
        tilt: 0.3,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: AnimatedContainer(
            duration: AppMotion.resolve(context, AppMotion.medium),
            curve: Curves.easeOutCubic,
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  selected ? data.activeIcon : data.icon,
                  size: 24,
                  color: selected ? AppColors.ink : const Color(0xB3FFFFFF),
                ),
                if (badge)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.lime,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? Colors.white : AppColors.ink,
                          width: 1.6,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
