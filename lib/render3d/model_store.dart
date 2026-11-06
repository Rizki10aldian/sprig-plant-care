import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sprig/core/models/plant.dart';
import 'package:sprig/render3d/model3d.dart';

/// Memuat dan menyimpan model 3D dari `assets/models/*.json`.
class ModelStore {
  ModelStore._();

  static final ModelStore instance = ModelStore._();

  static const List<String> keys = <String>[
    'p01', 'p02', 'p03', 'p04', 'p05', 'p06', 'p07',
    'p08', 'p09', 'p10', 'p11', 'p12', 'p13', 'p14',
  ];

  final Map<String, Model3D> _models = <String, Model3D>{};

  Model3D? get(String key) => _models[key];

  bool has(String key) => _models.containsKey(key);

  /// Memuat semua model. Kegagalan satu model tidak menghentikan yang lain.
  Future<void> preload([AssetBundle? bundle]) async {
    final source = bundle ?? rootBundle;
    for (final key in keys) {
      if (_models.containsKey(key)) continue;
      try {
        final text = await source.loadString('assets/models/$key.json');
        final json = jsonDecode(text) as Map<String, dynamic>;
        _models[key] = Model3D.fromJson(json);
      } catch (e) {
        debugPrint('Model 3D $key gagal dimuat: $e');
      }
    }
  }

  /// Model wakil untuk gaya gambar tertentu (onboarding, pratinjau).
  static String keyForStyle(PlantArtStyle style) => switch (style) {
        PlantArtStyle.leafy => 'p01',
        PlantArtStyle.snake => 'p02',
        PlantArtStyle.cactus => 'p03',
        PlantArtStyle.rosette => 'p04',
        PlantArtStyle.fern => 'p05',
        PlantArtStyle.herb => 'p06',
      };
}
