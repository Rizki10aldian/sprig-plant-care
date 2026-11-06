import 'package:flutter/foundation.dart';

enum PlantCategory {
  indoor('Dalam ruangan'),
  succulent('Sukulen'),
  herb('Herbal'),
  outdoor('Luar ruangan');

  const PlantCategory(this.label);
  final String label;
}

/// Gaya ilustrasi bawaan untuk tiap kategori (dipakai tanaman buatan pengguna).
/// Model 3D wakil tiap kategori (dipakai ikon kategori dan tanaman buatan sendiri).
extension PlantCategoryModel on PlantCategory {
  String get modelKey => switch (this) {
        PlantCategory.indoor => 'p01',
        PlantCategory.succulent => 'p04',
        PlantCategory.herb => 'p06',
        PlantCategory.outdoor => 'p14',
      };
}

extension PlantCategoryArt on PlantCategory {
  PlantArtStyle get art => switch (this) {
        PlantCategory.indoor => PlantArtStyle.leafy,
        PlantCategory.succulent => PlantArtStyle.rosette,
        PlantCategory.herb => PlantArtStyle.herb,
        PlantCategory.outdoor => PlantArtStyle.fern,
      };
}

enum LightLevel {
  low('Cahaya rendah'),
  medium('Cahaya sedang'),
  bright('Cahaya terang');

  const LightLevel(this.label);
  final String label;
}

/// Gaya ilustrasi tanaman yang digambar dengan CustomPainter.
enum PlantArtStyle { leafy, snake, cactus, rosette, fern, herb }

@immutable
class Plant {
  const Plant({
    required this.id,
    required this.name,
    required this.latinName,
    required this.description,
    required this.category,
    required this.light,
    required this.waterEveryDays,
    required this.art,
    required this.tintIndex,
    this.tips = const <String>[],
    this.isFavorite = false,
    this.inGarden = false,
    this.isCustom = false,
    this.lastWatered,
  });

  final String id;
  final String name;
  final String latinName;
  final String description;
  final PlantCategory category;
  final LightLevel light;
  final int waterEveryDays;
  final PlantArtStyle art;
  final int tintIndex;
  final List<String> tips;
  final bool isFavorite;
  final bool inGarden;

  /// `true` untuk tanaman yang dibuat pengguna lewat form "Tambah tanaman".
  final bool isCustom;
  final DateTime? lastWatered;

  /// Kunci model 3D: tanaman bawaan punya model sendiri, tanaman buatan
  /// pengguna memakai model wakil kategorinya.
  String get modelKey => isCustom ? category.modelKey : id;

  Plant copyWith({bool? isFavorite, bool? inGarden, DateTime? lastWatered}) {
    return Plant(
      id: id,
      name: name,
      latinName: latinName,
      description: description,
      category: category,
      light: light,
      waterEveryDays: waterEveryDays,
      art: art,
      tintIndex: tintIndex,
      tips: tips,
      isFavorite: isFavorite ?? this.isFavorite,
      inGarden: inGarden ?? this.inGarden,
      isCustom: isCustom,
      lastWatered: lastWatered ?? this.lastWatered,
    );
  }

  /// Sisa hari sampai jadwal siram berikutnya (negatif = terlambat).
  /// Dihitung per tanggal, bukan per jam.
  int daysUntilWatering([DateTime? now]) {
    final last = lastWatered;
    if (last == null) return waterEveryDays;
    final current = now ?? DateTime.now();
    final today = DateTime.utc(current.year, current.month, current.day);
    final due = DateTime.utc(last.year, last.month, last.day + waterEveryDays);
    return due.difference(today).inDays;
  }

  bool needsWater([DateTime? now]) => inGarden && daysUntilWatering(now) <= 0;

  /// Tanggal siram berikutnya (null bila belum pernah disiram).
  DateTime? get nextWatering {
    final last = lastWatered;
    if (last == null) return null;
    return DateTime(last.year, last.month, last.day + waterEveryDays);
  }

  /// 0.0 tepat setelah disiram, 1.0 saat jadwal siram tiba atau terlewat.
  double waterProgress([DateTime? now]) {
    if (!inGarden || lastWatered == null) return 0;
    final elapsed = waterEveryDays - daysUntilWatering(now);
    return (elapsed / waterEveryDays).clamp(0.0, 1.0).toDouble();
  }
}
