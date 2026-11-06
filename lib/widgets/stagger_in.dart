import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sprig/theme/app_motion.dart';

/// Memunculkan konten bertahap (memudar + naik) menurut urutan [index].
class StaggerIn extends StatefulWidget {
  const StaggerIn({
    super.key,
    required this.child,
    this.index = 0,
    this.step = const Duration(milliseconds: 70),
    this.offset = 24,
  });

  final Widget child;
  final int index;
  final Duration step;
  final double offset;

  @override
  State<StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final CurvedAnimation _curved = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (AppMotion.reduced(context)) {
      _controller.value = 1;
      return;
    }
    final steps = widget.index > 8 ? 8 : widget.index;
    _timer = Timer(widget.step * steps, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curved,
      child: widget.child,
      builder: (context, child) {
        final t = _curved.value;
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..translate(0.0, (1 - t) * widget.offset)
          ..rotateX((1 - t) * 0.32);
        return Opacity(
          opacity: t.clamp(0.0, 1.0).toDouble(),
          child: Transform(
            alignment: Alignment.topCenter,
            transform: matrix,
            child: child,
          ),
        );
      },
    );
  }
}
