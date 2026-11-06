import 'package:flutter_test/flutter_test.dart';
import 'package:sprig/core/errors/app_exceptions.dart';
import 'package:sprig/core/models/plant.dart';
import 'package:sprig/data/plant_repository.dart';
import 'package:sprig/state/plant_view_model.dart';

void main() {
  late PlantViewModel vm;

  setUp(() async {
    vm = PlantViewModel(PlantRepository(latency: Duration.zero));
    await vm.load();
  });

  test('memuat data dummy', () {
    expect(vm.status, LoadStatus.ready);
    expect(vm.plants.length, 14);
  });

  test('toggle favorit', () {
    final before = vm.favoriteCount;
    vm.toggleFavorite('p02');
    expect(vm.favoriteCount, before + (vm.plantById('p02')!.isFavorite ? 1 : -1));
  });

  test('tambah, hapus, urungkan tanaman buatan', () {
    final p = vm.addCustomPlant(
      name: 'Kaktus Budi',
      latinName: '',
      notes: '',
      category: PlantCategory.succulent,
      light: LightLevel.bright,
      waterEveryDays: 14,
    );
    expect(vm.plantById(p.id), isNotNull);
    final removed = vm.removeFromGarden(p.id)!;
    expect(vm.plantById(p.id), isNull);
    vm.undoRemove(removed);
    expect(vm.plantById(p.id), isNotNull);
  });

  test('nama duplikat ditolak', () {
    expect(
      () => vm.addCustomPlant(
        name: vm.plants.first.name,
        latinName: '',
        notes: '',
        category: PlantCategory.indoor,
        light: LightLevel.low,
        waterEveryDays: 5,
      ),
      throwsA(isA<ValidationException>()),
    );
  });

  test('offline -> refresh mengembalikan pesan, data lama tetap', () async {
    vm.setOffline(true);
    final error = await vm.refresh();
    expect(error, isNotNull);
    expect(vm.plants.length, 14);
  });
}
