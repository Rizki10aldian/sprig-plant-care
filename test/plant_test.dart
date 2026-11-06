import 'package:flutter_test/flutter_test.dart';
import 'package:sprig/core/models/plant.dart';

Plant _plant({DateTime? last, int every = 7, bool inGarden = true}) => Plant(
      id: 't',
      name: 'Tes',
      latinName: 'Testus',
      description: 'd',
      category: PlantCategory.indoor,
      light: LightLevel.medium,
      waterEveryDays: every,
      art: PlantArtStyle.leafy,
      tintIndex: 0,
      inGarden: inGarden,
      lastWatered: last,
    );

void main() {
  final now = DateTime(2026, 11, 5, 10);

  test('baru disiram -> jatuh tempo penuh', () {
    expect(_plant(last: now).daysUntilWatering(now), 7);
  });

  test('tepat jatuh tempo -> 0 dan perlu air', () {
    final p = _plant(last: DateTime(2026, 10, 29));
    expect(p.daysUntilWatering(now), 0);
    expect(p.needsWater(now), isTrue);
  });

  test('terlambat -> negatif', () {
    expect(_plant(last: DateTime(2026, 10, 25)).daysUntilWatering(now), -3);
  });

  test('di luar kebun tidak perlu air', () {
    final p = _plant(last: DateTime(2026, 10, 1), inGarden: false);
    expect(p.needsWater(now), isFalse);
  });

  test('progress dibatasi 0..1', () {
    expect(_plant(last: DateTime(2026, 9, 1)).waterProgress(now), 1.0);
    expect(_plant(last: now).waterProgress(now), 0.0);
  });
}
