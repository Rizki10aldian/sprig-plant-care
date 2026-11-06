import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sprig/render3d/model3d.dart';

/// Posisi/animasi saat ini. Dipisah agar hanya kanvas yang digambar ulang
/// (bukan seluruh widget) setiap frame.
class _Pose extends ChangeNotifier {
  double time = 0;
  double dragYaw = 0;
  double dragPitch = 0;

  void tick(double t, double dragYawValue, double dragPitchValue) {
    time = t;
    dragYaw = dragYawValue;
    dragPitch = dragPitchValue;
    notifyListeners();
  }
}

/// Menampilkan model 3D tanaman: berputar pelan bolak-balik, daun bergoyang,
/// dan (bila [interactive]) bisa diputar dengan geser jari.
class Plant3DView extends StatefulWidget {
  const Plant3DView({
    super.key,
    required this.model,
    this.animate = true,
    this.interactive = false,
    this.phase = 0,
    this.turn = 0.5,
    this.shadow = true,
  });

  final Model3D model;
  final bool animate;
  final bool interactive;

  /// Pergeseran fase agar banyak kartu tidak bergerak serempak.
  final double phase;

  /// Besar ayunan putar (radian).
  final double turn;
  final bool shadow;

  @override
  State<Plant3DView> createState() => _Plant3DViewState();
}

class _Plant3DViewState extends State<Plant3DView>
    with SingleTickerProviderStateMixin {
  final _Pose _pose = _Pose();
  late Renderer3D _renderer = Renderer3D(widget.model);
  Ticker? _ticker;
  Duration _last = Duration.zero;
  double _time = 0;
  double _dragYaw = 0;
  double _dragPitch = 0;
  bool _dragging = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant Plant3DView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model != widget.model) {
      _renderer = Renderer3D(widget.model);
    }
    _syncTicker();
  }

  void _syncTicker() {
    final run = widget.animate && !MediaQuery.disableAnimationsOf(context);
    // Satu Ticker dibuat sekali lalu hanya dijalankan/dihentikan. Membuat
    // ticker baru pada SingleTickerProviderStateMixin menimbulkan error.
    final ticker = _ticker ??= createTicker(_onTick);
    if (run) {
      if (!ticker.isActive) {
        _last = Duration.zero;
        ticker.start();
      }
    } else {
      if (ticker.isActive) ticker.stop();
      _last = Duration.zero;
      _pose.tick(_time == 0 ? 0.8 : _time, _dragYaw, _dragPitch);
    }
  }

  void _onTick(Duration elapsed) {
    final dt = _last == Duration.zero
        ? 0.0
        : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    _time += dt;
    if (!_dragging) {
      final k = math.exp(-dt * 1.6);
      _dragYaw *= k;
      _dragPitch *= k;
    }
    _pose.tick(_time, _dragYaw, _dragPitch);
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _pose.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget canvas = RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _Plant3DPainter(
          renderer: _renderer,
          pose: _pose,
          phase: widget.phase,
          turn: widget.turn,
          shadow: widget.shadow,
        ),
      ),
    );
    if (widget.interactive) {
      canvas = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) => _dragging = true,
        onHorizontalDragUpdate: (d) {
          _dragYaw += d.delta.dx * 0.014;
          _dragPitch = (_dragPitch - d.delta.dy * 0.004).clamp(-0.25, 0.25).toDouble();
          if (!(_ticker?.isActive ?? false)) _pose.tick(_time, _dragYaw, _dragPitch);
        },
        onHorizontalDragEnd: (_) => _dragging = false,
        onHorizontalDragCancel: () => _dragging = false,
        child: canvas,
      );
    }
    return ExcludeSemantics(child: canvas);
  }
}

class _Plant3DPainter extends CustomPainter {
  _Plant3DPainter({
    required this.renderer,
    required this.pose,
    required this.phase,
    required this.turn,
    required this.shadow,
  }) : super(repaint: pose);

  final Renderer3D renderer;
  final _Pose pose;
  final double phase;
  final double turn;
  final bool shadow;

  static final ui.Paint _meshPaint = ui.Paint()
    ..blendMode = BlendMode.modulate
    ..shader = ui.Gradient.linear(
      Offset.zero,
      const Offset(1, 0),
      const [Colors.white, Colors.white],
    );

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final t = pose.time;
    final yaw = 0.55 + turn * math.sin(t * 0.55 + phase) + pose.dragYaw;
    final pitch = 0.2 + 0.03 * math.sin(t * 0.8 + phase) + pose.dragPitch;
    final buffers = renderer.render(
      time: t + phase,
      yaw: yaw,
      pitch: pitch,
      width: size.width,
      height: size.height,
    );

    if (shadow) {
      final w = buffers.unit * 1.9;
      canvas.save();
      canvas.translate(buffers.baseX, buffers.baseY);
      canvas.scale(1, 0.32);
      canvas.drawCircle(
        Offset.zero,
        w / 2,
        Paint()
          ..shader = ui.Gradient.radial(
            Offset.zero,
            w / 2,
            const [Color(0x47000000), Color(0x00000000)],
            const [0.25, 1.0],
          ),
      );
      canvas.restore();
    }

    final vertices = ui.Vertices.raw(
      ui.VertexMode.triangles,
      buffers.positions,
      colors: buffers.colors,
    );
    canvas.drawVertices(vertices, BlendMode.modulate, _meshPaint);
    vertices.dispose();
  }

  @override
  bool shouldRepaint(covariant _Plant3DPainter old) =>
      old.renderer != renderer ||
      old.phase != phase ||
      old.turn != turn ||
      old.shadow != shadow;
}
