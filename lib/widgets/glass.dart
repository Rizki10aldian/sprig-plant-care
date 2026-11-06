import 'dart:ui';

import 'package:flutter/material.dart';

/// Panel kaca (glassmorphism): latar di belakangnya diburamkan, lalu ditimpa
/// lapisan tipis semi-transparan dengan garis tepi halus.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.blur = 18,
    this.tint = const Color(0xB3FFFFFF),
    this.borderColor = const Color(0x66FFFFFF),
    this.padding,
    this.shadow = const <BoxShadow>[],
    this.shape = BoxShape.rectangle,
  });

  /// Varian gelap, cocok untuk elemen di atas konten terang.
  const GlassContainer.dark({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.blur = 18,
    this.tint = const Color(0xC7212529),
    this.borderColor = const Color(0x1FFFFFFF),
    this.padding,
    this.shadow = const <BoxShadow>[],
    this.shape = BoxShape.rectangle,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double blur;
  final Color tint;
  final Color borderColor;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow> shadow;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final circle = shape == BoxShape.circle;
    final decoration = BoxDecoration(
      color: tint,
      shape: shape,
      borderRadius: circle ? null : borderRadius,
      border: Border.all(color: borderColor),
    );
    final blurred = BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: DecoratedBox(
        decoration: decoration,
        child: padding == null ? child : Padding(padding: padding!, child: child),
      ),
    );
    final clipped = circle
        ? ClipOval(child: blurred)
        : ClipRRect(borderRadius: borderRadius, child: blurred);
    if (shadow.isEmpty) return clipped;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: circle ? null : borderRadius,
        boxShadow: shadow,
      ),
      child: clipped,
    );
  }
}
