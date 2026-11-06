import 'package:flutter/material.dart';
import 'package:sprig/theme/app_motion.dart';
import 'package:sprig/theme/app_shadows.dart';

/// Kerangka kartu yang berdenyut selama data dimuat.
/// Animasi berhenti otomatis saat widget dilepas (dispose) dan saat
/// pengguna mematikan animasi di perangkat.
class SkeletonCard extends StatefulWidget {
  const SkeletonCard({super.key});

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (AppMotion.reduced(context)) {
      _controller.value = 0.5;
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final tone = Color.lerp(
          const Color(0xFFEDEFF1),
          const Color(0xFFE0E3E6),
          _controller.value,
        )!;
        Widget bar(double widthFactor) => FractionallySizedBox(
              widthFactor: widthFactor,
              alignment: Alignment.centerLeft,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: tone,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            );

        return Container(
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
                child: Container(
                  decoration: BoxDecoration(
                    color: tone,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              bar(0.7),
              const SizedBox(height: 8),
              bar(0.45),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
