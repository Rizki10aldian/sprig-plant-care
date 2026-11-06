import 'package:flutter/material.dart';
import 'package:sprig/core/models/plant.dart';
import 'package:sprig/render3d/model_store.dart';
import 'package:sprig/render3d/plant_3d_view.dart';

/// Ikon kategori berupa tanaman 3D mini. Hanya berputar saat [active].
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.category,
    required this.active,
    this.size = 34,
  });

  final PlantCategory category;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    final model = ModelStore.instance.get(category.modelKey);
    if (model == null) return SizedBox(width: size, height: size);
    return SizedBox(
      width: size,
      height: size,
      child: Plant3DView(
        model: model,
        animate: active,
        shadow: false,
        turn: 0.7,
      ),
    );
  }
}
