import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprig/render3d/model3d.dart';
import 'package:sprig/render3d/model_store.dart';

void main() {
  for (final key in ModelStore.keys) {
    test('model $key valid dan bisa dirender', () {
      final text = File('assets/models/$key.json').readAsStringSync();
      final model = Model3D.fromJson(jsonDecode(text) as Map<String, dynamic>);
      expect(model.triangleCount, greaterThan(100));

      final renderer = Renderer3D(model);
      final out = renderer.render(
        time: 1.2,
        yaw: 0.5,
        pitch: 0.2,
        width: 300,
        height: 300,
      );
      expect(out.positions.length, model.triangleCount * 6);
      expect(out.colors.length, model.triangleCount * 3);
      for (final v in out.positions) {
        expect(v.isFinite, isTrue);
      }
    });
  }
}
