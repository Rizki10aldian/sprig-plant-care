import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sprig/core/models/plant.dart';
import 'package:sprig/render3d/model_store.dart';
import 'package:sprig/render3d/model3d.dart';
import 'package:sprig/render3d/plant_3d_view.dart';
import 'package:sprig/theme/app_colors.dart';

/// Ilustrasi tanaman yang digambar langsung dengan [CustomPainter],
/// jadi aplikasi tidak butuh file gambar dan tetap tajam di semua layar.
/// Harus ditempatkan di dalam parent yang ukurannya terbatas.
class PlantArt extends StatelessWidget {
  const PlantArt({super.key, required this.style, this.potIndex = 0});

  final PlantArtStyle style;
  final int potIndex;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.infinite,
        painter: _PlantPainter(style, potIndex),
      ),
    );
  }
}

/// Ilustrasi di atas latar pastel membulat (dipakai kartu, detail, onboarding).
/// Tanaman bergoyang pelan terus-menerus dan panel diberi kilau lembut agar
/// terasa bervolume (3D).
class PlantArtPanel extends StatefulWidget {
  const PlantArtPanel({
    super.key,
    required this.style,
    required this.tintIndex,
    this.radius = 22,
    this.padding = const EdgeInsets.all(14),
    this.animate = true,
    this.modelKey,
    this.interactive = false,
    this.turn = 0.5,
  });

  /// Kunci model 3D (mis. `p01`). Bila kosong dipakai model wakil [style].
  final String? modelKey;
  final bool interactive;
  final double turn;
  final PlantArtStyle style;
  final int tintIndex;
  final double radius;
  final EdgeInsets padding;
  final bool animate;

  @override
  State<PlantArtPanel> createState() => _PlantArtPanelState();
}

class _PlantArtPanelState extends State<PlantArtPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 3600 + (widget.tintIndex % 4) * 400),
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutSine,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (_model == null && widget.animate && !MediaQuery.disableAnimationsOf(context)) {
      _controller.value = (widget.tintIndex % 5) / 5;
      _controller.repeat(reverse: true);
    }
  }

  Model3D? get _model =>
      ModelStore.instance.get(widget.modelKey ?? ModelStore.keyForStyle(widget.style));

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.tint(widget.tintIndex),
        borderRadius: BorderRadius.circular(widget.radius),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x66FFFFFF), Color(0x00FFFFFF), Color(0x14000000)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Padding(
          padding: widget.padding,
          child: SizedBox.expand(
            child: _model != null
                ? Plant3DView(
                    model: _model!,
                    animate: widget.animate,
                    interactive: widget.interactive,
                    turn: widget.turn,
                    phase: ((widget.modelKey ?? '').hashCode % 628) / 100,
                  )
                : AnimatedBuilder(
              animation: _curve,
              child: PlantArt(style: widget.style, potIndex: widget.tintIndex),
              builder: (context, child) {
                final t = _curve.value * 2 - 1; // -1..1
                return Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0008)
                    ..translate(0.0, -t * 2.5)
                    ..rotateZ(t * 0.025)
                    ..rotateY(t * 0.08),
                  child: child,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantPainter extends CustomPainter {
  const _PlantPainter(this.style, this.potIndex);

  final PlantArtStyle style;
  final int potIndex;

  static const Color _dark = Color(0xFF2E6B45);
  static const Color _mid = Color(0xFF4C9A5F);
  static const Color _light = Color(0xFF8CCB6B);
  static const List<Color> _pots = <Color>[
    Color(0xFF212529),
    Color(0xFFFFFFFF),
    Color(0xFFD9A47A),
    Color(0xFF8E9AAF),
    Color(0xFFE8B4B8),
  ];

  static Paint _fill(Color color) => Paint()
    ..color = color
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    if (side <= 0 || side.isInfinite) return;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(side / 100);

    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(50, 95.5),
        width: 44,
        height: 4.5,
      ),
      Paint()..color = const Color(0x1A000000),
    );

    switch (style) {
      case PlantArtStyle.leafy:
        _leafy(canvas);
      case PlantArtStyle.snake:
        _snake(canvas);
      case PlantArtStyle.cactus:
        _cactus(canvas);
      case PlantArtStyle.rosette:
        _rosette(canvas);
      case PlantArtStyle.fern:
        _fern(canvas);
      case PlantArtStyle.herb:
        _herb(canvas);
    }

    _pot(canvas);
    canvas.restore();
  }

  /// Satu helai daun: dari [base] ke atas, diputar sebesar [angle] radian.
  void _leaf(
    Canvas canvas,
    Offset base,
    double length,
    double width,
    double angle,
    Paint fill, {
    Paint? outline,
  }) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(width, -length * 0.45, 0, -length)
      ..quadraticBezierTo(-width, -length * 0.45, 0, 0)
      ..close();
    canvas.drawPath(path, fill);
    if (outline != null) canvas.drawPath(path, outline);
    canvas.restore();
  }

  void _leafy(Canvas canvas) {
    const base = Offset(50, 71);
    const angles = <double>[-1.2, -0.85, -0.5, -0.15, 0.2, 0.55, 0.9, 1.25];
    const lengths = <double>[28, 36, 42, 46, 44, 40, 34, 27];
    for (var i = 0; i < angles.length; i++) {
      _leaf(
        canvas,
        base,
        lengths[i],
        lengths[i] * 0.75,
        angles[i],
        _fill(i.isEven ? _dark : _mid),
      );
    }
    const frontAngles = <double>[-0.65, 0.05, 0.7];
    const frontLengths = <double>[26, 30, 26];
    for (var i = 0; i < frontAngles.length; i++) {
      _leaf(
        canvas,
        base,
        frontLengths[i],
        frontLengths[i] * 0.6,
        frontAngles[i],
        _fill(_light),
      );
    }
  }

  void _snake(Canvas canvas) {
    const base = Offset(50, 71);
    const angles = <double>[-0.34, -0.17, 0.0, 0.17, 0.34];
    const lengths = <double>[42, 54, 62, 54, 42];
    const order = <int>[0, 4, 1, 3, 2];
    final edge = Paint()
      ..color = _light
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..isAntiAlias = true;
    for (final i in order) {
      _leaf(
        canvas,
        base,
        lengths[i],
        lengths[i] * 0.3,
        angles[i],
        _fill(i.isEven ? _dark : _mid),
        outline: edge,
      );
    }
  }

  void _cactus(Canvas canvas) {
    final body = _fill(_mid);
    final ridge = Paint()
      ..color = const Color(0x22000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(
      RRect.fromLTRBR(26, 42, 35, 60, const Radius.circular(4.5)),
      body,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(28, 53, 44, 62, const Radius.circular(4)),
      body,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(65, 34, 74, 52, const Radius.circular(4.5)),
      body,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(56, 45, 72, 54, const Radius.circular(4)),
      body,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(40, 26, 60, 74, const Radius.circular(10)),
      body,
    );
    for (final x in const <double>[45, 50, 55]) {
      canvas.drawLine(Offset(x, 32), Offset(x, 70), ridge);
    }
    canvas.drawCircle(
      const Offset(50, 25),
      3.2,
      _fill(const Color(0xFFFF8FA3)),
    );
  }

  void _rosette(Canvas canvas) {
    const base = Offset(50, 72);
    void ring(int count, double length, double width, double spread, Color c) {
      for (var i = 0; i < count; i++) {
        final t = count == 1 ? 0.0 : (i / (count - 1)) * 2 - 1;
        _leaf(canvas, base, length, width, t * spread, _fill(c));
      }
    }

    ring(7, 30, 22, 1.35, _dark);
    ring(6, 26, 20, 1.05, _mid);
    ring(5, 21, 16, 0.75, _light);
    ring(3, 15, 11, 0.4, const Color(0xFFB7E08A));
  }

  void _fern(Canvas canvas) {
    const base = Offset(50, 71);
    const count = 11;
    for (var i = 0; i < count; i++) {
      final t = (i / (count - 1)) * 2 - 1;
      final length = 46 - t.abs() * 14;
      _leaf(canvas, base, length, 9, t * 1.35, _fill(i.isEven ? _mid : _light));
    }
  }

  void _herb(Canvas canvas) {
    const base = Offset(50, 71);
    final stem = Paint()
      ..color = _dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    const tips = <Offset>[
      Offset(50, 28),
      Offset(36, 38),
      Offset(64, 36),
      Offset(27, 50),
      Offset(73, 49),
    ];
    for (final tip in tips) {
      canvas.drawLine(base, tip, stem);
      final stemAngle = math.atan2(tip.dx - base.dx, -(tip.dy - base.dy));
      for (var k = 0; k < 4; k++) {
        final pos = Offset.lerp(base, tip, 0.35 + k * 0.2)!;
        final color = k.isEven ? _mid : _light;
        _leaf(canvas, pos, 10, 9, stemAngle - 0.85, _fill(color));
        _leaf(canvas, pos, 10, 9, stemAngle + 0.85, _fill(color));
      }
      _leaf(canvas, tip, 11, 9, stemAngle, _fill(_mid));
    }
  }

  void _pot(Canvas canvas) {
    final color = _pots[potIndex % _pots.length];
    final pot = Path()
      ..moveTo(33, 72)
      ..lineTo(67, 72)
      ..lineTo(62.5, 91.5)
      ..quadraticBezierTo(62, 94, 59, 94)
      ..lineTo(41, 94)
      ..quadraticBezierTo(38, 94, 37.5, 91.5)
      ..close();
    final rim = RRect.fromLTRBR(30, 66, 70, 74, const Radius.circular(3));
    final edge = Paint()
      ..color = const Color(0x22000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    canvas.drawPath(pot, _fill(color));
    canvas.drawRRect(rim, _fill(Color.lerp(color, Colors.white, 0.12)!));
    canvas.drawPath(pot, edge);
    canvas.drawRRect(rim, edge);
  }

  @override
  bool shouldRepaint(covariant _PlantPainter oldDelegate) =>
      oldDelegate.style != style || oldDelegate.potIndex != potIndex;
}
