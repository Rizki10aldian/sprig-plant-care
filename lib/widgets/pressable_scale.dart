import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprig/theme/app_motion.dart';

/// Efek sentuh 3D yang lembut: saat ditekan, widget sedikit mengecil dan
/// miring ke arah titik sentuh (perspektif), lalu kembali dengan pantulan
/// halus. Opsional [glare] menambah kilau cahaya yang mengikuti jari.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96,
    this.haptic = true,
    this.semanticLabel,
    this.tilt = 0.14,
    this.glare = false,
    this.glareRadius = 28,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;
  final String? semanticLabel;

  /// Kemiringan maksimum (radian). 0 untuk mematikan efek miring.
  final double tilt;

  /// Tampilkan kilau cahaya di titik sentuh.
  final bool glare;
  final double glareRadius;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;
  Offset _focus = Offset.zero; // -1..1 relatif terhadap pusat widget

  void _press(TapDownDetails details) {
    final box = context.findRenderObject();
    var focus = Offset.zero;
    if (box is RenderBox && box.hasSize && box.size.width > 0 && box.size.height > 0) {
      final size = box.size;
      focus = Offset(
        ((details.localPosition.dx / size.width) * 2 - 1).clamp(-1.0, 1.0).toDouble(),
        ((details.localPosition.dy / size.height) * 2 - 1).clamp(-1.0, 1.0).toDouble(),
      );
    }
    setState(() {
      _down = true;
      _focus = focus;
    });
  }

  void _release() {
    if (_down) setState(() => _down = false);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final reduced = AppMotion.reduced(context);
    final target = (_down && !reduced) ? _focus : Offset.zero;
    final tilt = widget.tilt;

    Widget animated = TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(end: target),
      duration: reduced
          ? Duration.zero
          : (_down
              ? const Duration(milliseconds: 140)
              : const Duration(milliseconds: 560)),
      curve: _down ? Curves.easeOutCubic : Curves.elasticOut,
      child: widget.child,
      builder: (context, value, child) {
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.0011)
          ..rotateX(-value.dy * tilt)
          ..rotateY(value.dx * tilt);
        return Transform(
          alignment: Alignment.center,
          transform: transform,
          child: child,
        );
      },
    );

    animated = AnimatedScale(
      scale: _down ? widget.scale : 1,
      duration: AppMotion.resolve(
        context,
        _down ? AppMotion.fast : const Duration(milliseconds: 420),
      ),
      curve: _down ? Curves.easeOut : Curves.easeOutBack,
      child: animated,
    );

    if (widget.glare) {
      animated = Stack(
        children: [
          animated,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _down ? 1 : 0,
                duration: AppMotion.resolve(context, AppMotion.medium),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.glareRadius),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(_focus.dx, _focus.dy),
                        radius: 0.95,
                        colors: const [Color(0x4DFFFFFF), Color(0x00FFFFFF)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? _press : null,
      onTapUp: enabled ? (_) => _release() : null,
      onTapCancel: enabled ? _release : null,
      onTap: enabled
          ? () {
              if (widget.haptic) HapticFeedback.selectionClick();
              widget.onTap!();
            }
          : null,
      child: animated,
    );
    if (widget.semanticLabel != null) {
      content = Semantics(
        button: true,
        enabled: enabled,
        label: widget.semanticLabel,
        child: content,
      );
    }
    return content;
  }
}
