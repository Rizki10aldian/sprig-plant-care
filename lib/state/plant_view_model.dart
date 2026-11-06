import 'package:flutter/foundation.dart';
import 'package:sprig/core/errors/app_exceptions.dart';
import 'package:sprig/core/models/plant.dart';
import 'package:sprig/data/plant_repository.dart';

enum LoadStatus { loading, ready, error }

enum PlantFilter {
  all('Semua'),
  favorites('Favorit'),
  indoor('Dalam ruangan'),
  succulent('Sukulen'),
  herb('Herbal'),
  outdoor('Luar ruangan');

  const PlantFilter(this.label);
  final String label;

  bool matches(Plant plant) => switch (this) {
        PlantFilter.all => true,
        PlantFilter.favorites => plant.isFavorite,
        PlantFilter.indoor => plant.category == PlantCategory.indoor,
        PlantFilter.succulent => plant.category == PlantCategory.succulent,
        PlantFilter.herb => plant.category == PlantCategory.herb,
        PlantFilter.outdoor => plant.category == PlantCategory.outdoor,
      };
}

/// Catatan penghapusan, dipakai untuk fitur "Urungkan".
class RemovedPlant {
  const RemovedPlant({
    required this.plant,
    required this.index,
    required this.deleted,
  });

  final Plant plant;
  final int index;

  /// `true` jika tanaman buatan pengguna dihapus total dari daftar.
  final bool deleted;
}

/// ViewModel utama: menyimpan seluruh data tanaman, pencarian, filter, dan
/// status pemuatan. Karena hidup di atas `MaterialApp`, datanya tetap ada saat
/// orientasi layar berubah maupun saat berpindah antar halaman.
class PlantViewModel extends ChangeNotifier {
  PlantViewModel(this._repository);

  final PlantRepository _repository;

  List<Plant> _plants = <Plant>[];
  LoadStatus _status = LoadStatus.loading;
  String? _errorMessage;
  String _query = '';
  PlantFilter _filter = PlantFilter.all;
  int _wateringsDone = 0;
  bool _started = false;

  // ---------------------------------------------------------------- getters

  List<Plant> get plants => List<Plant>.unmodifiable(_plants);
  bool get hasPlants => _plants.isNotEmpty;
  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get query => _query;
  PlantFilter get filter => _filter;
  int get wateringsDone => _wateringsDone;
  bool get offline => _repository.offline;

  List<Plant> get visiblePlants {
    final q = _query.trim().toLowerCase();
    return _plants.where((p) {
      if (!_filter.matches(p)) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.latinName.toLowerCase().contains(q);
    }).toList(growable: false);
  }

  /// Tanaman di kebun, diurutkan dari yang paling mendesak disiram.
  List<Plant> get gardenPlants {
    final now = DateTime.now();
    final list = _plants.where((p) => p.inGarden).toList();
    list.sort(
      (a, b) => a.daysUntilWatering(now).compareTo(b.daysUntilWatering(now)),
    );
    return list;
  }

  int get dueCount {
    final now = DateTime.now();
    return _plants.where((p) => p.needsWater(now)).length;
  }

  int get favoriteCount => _plants.where((p) => p.isFavorite).length;

  /// Tanaman pilihan hari ini; berganti setiap hari.
  Plant? get featuredPlant {
    if (_plants.isEmpty) return null;
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    return _plants[dayOfYear % _plants.length];
  }

  Plant? plantById(String id) {
    for (final p in _plants) {
      if (p.id == id) return p;
    }
    return null;
  }

  bool nameExists(String name) {
    final target = name.trim().toLowerCase();
    return _plants.any((p) => p.name.toLowerCase() == target);
  }

  // ---------------------------------------------------------------- loading

  /// Pemuatan awal (atau "Coba lagi" setelah gagal).
  Future<void> load() async {
    if (_status == LoadStatus.ready) return;
    _status = LoadStatus.loading;
    _errorMessage = null;
    if (_started) notifyListeners();
    _started = true;
    try {
      _plants = await _repository.fetchPlants();
      _status = LoadStatus.ready;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _status = LoadStatus.error;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan tak terduga. Silakan coba lagi.';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  /// Tarik-untuk-muat-ulang. Data yang sudah ada tidak dihapus bila gagal.
  /// Mengembalikan pesan error, atau `null` jika berhasil.
  Future<String?> refresh() async {
    try {
      final fresh = await _repository.fetchPlants();
      final known = _plants.map((p) => p.id).toSet();
      _plants = <Plant>[
        ..._plants,
        ...fresh.where((p) => !known.contains(p.id)),
      ];
      _status = LoadStatus.ready;
      _errorMessage = null;
      notifyListeners();
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Terjadi kesalahan tak terduga. Silakan coba lagi.';
    }
  }

  /// Mengosongkan semua data lalu memuat ulang dari awal.
  Future<void> resetDemoData() async {
    _plants = <Plant>[];
    _query = '';
    _filter = PlantFilter.all;
    _wateringsDone = 0;
    _status = LoadStatus.loading;
    await load();
  }

  void setOffline(bool value) {
    _repository.offline = value;
    notifyListeners();
  }

  // ------------------------------------------------------- search and filter

  void setQuery(String value) {
    if (value == _query) return;
    _query = value;
    notifyListeners();
  }

  void setFilter(PlantFilter value) {
    if (value == _filter) return;
    _filter = value;
    notifyListeners();
  }

  void resetFilters() {
    _query = '';
    _filter = PlantFilter.all;
    notifyListeners();
  }

  // ----------------------------------------------------------------- actions

  void toggleFavorite(String id) {
    _replace(id, (p) => p.copyWith(isFavorite: !p.isFavorite));
  }

  void addToGarden(String id) {
    _replace(id, (p) => p.copyWith(inGarden: true, lastWatered: DateTime.now()));
  }

  void waterPlant(String id) {
    final plant = plantById(id);
    if (plant == null) return;
    _wateringsDone++;
    _replace(id, (p) => p.copyWith(lastWatered: DateTime.now()));
  }

  /// Menyiram semua tanaman yang jadwalnya tiba. Mengembalikan jumlahnya.
  int waterAllDue() {
    final now = DateTime.now();
    var count = 0;
    _plants = _plants.map((p) {
      if (!p.needsWater(now)) return p;
      count++;
      return p.copyWith(lastWatered: now);
    }).toList();
    if (count > 0) {
      _wateringsDone += count;
      notifyListeners();
    }
    return count;
  }

  /// Mengeluarkan tanaman dari kebun. Tanaman buatan pengguna dihapus total.
  RemovedPlant? removeFromGarden(String id) {
    final index = _plants.indexWhere((p) => p.id == id);
    if (index < 0) return null;
    final plant = _plants[index];
    final deleted = plant.isCustom;
    if (deleted) {
      _plants = List<Plant>.of(_plants)..removeAt(index);
    } else {
      _plants = List<Plant>.of(_plants)..[index] = plant.copyWith(inGarden: false);
    }
    notifyListeners();
    return RemovedPlant(plant: plant, index: index, deleted: deleted);
  }

  void undoRemove(RemovedPlant removed) {
    final next = List<Plant>.of(_plants);
    if (removed.deleted) {
      final at = removed.index.clamp(0, next.length).toInt();
      next.insert(at, removed.plant);
    } else {
      final i = next.indexWhere((p) => p.id == removed.plant.id);
      if (i >= 0) next[i] = removed.plant;
    }
    _plants = next;
    notifyListeners();
  }

  /// Menambah tanaman buatan pengguna langsung ke kebun.
  /// Melempar [ValidationException] bila nama sudah dipakai.
  Plant addCustomPlant({
    required String name,
    required String latinName,
    required String notes,
    required PlantCategory category,
    required LightLevel light,
    required int waterEveryDays,
  }) {
    final cleanName = name.trim();
    if (nameExists(cleanName)) {
      throw const ValidationException('Nama tanaman sudah ada di daftar.');
    }
    final plant = Plant(
      id: 'custom-${DateTime.now().microsecondsSinceEpoch}',
      name: cleanName,
      latinName: latinName.trim().isEmpty ? 'Koleksi pribadi' : latinName.trim(),
      description:
          notes.trim().isEmpty ? 'Tanaman koleksi pribadi.' : notes.trim(),
      category: category,
      light: light,
      waterEveryDays: waterEveryDays,
      art: category.art,
      tintIndex: _plants.length,
      tips: <String>[
        'Siram setiap $waterEveryDays hari.',
        'Letakkan di tempat dengan ${light.label.toLowerCase()}.',
      ],
      inGarden: true,
      isCustom: true,
      lastWatered: DateTime.now(),
    );
    _plants = <Plant>[plant, ..._plants];
    notifyListeners();
    return plant;
  }

  // ---------------------------------------------------------------- helpers

  void _replace(String id, Plant Function(Plant) change) {
    final index = _plants.indexWhere((p) => p.id == id);
    if (index < 0) return;
    final next = List<Plant>.of(_plants);
    next[index] = change(next[index]);
    _plants = next;
    notifyListeners();
  }
}
