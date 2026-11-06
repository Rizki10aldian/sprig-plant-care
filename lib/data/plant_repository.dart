import 'package:sprig/core/errors/app_exceptions.dart';
import 'package:sprig/core/models/plant.dart';
import 'package:sprig/data/dummy_plants.dart';

/// Sumber data tanaman. Aplikasi ini hanya memakai data dummy, tetapi
/// pengambilannya disimulasikan sebagai panggilan jaringan (ada jeda waktu
/// dan bisa gagal) supaya penanganan error dapat didemonstrasikan.
class PlantRepository {
  PlantRepository({this.latency = const Duration(milliseconds: 900)});

  final Duration latency;

  /// Saat `true`, setiap pengambilan data gagal dengan [NetworkException].
  bool offline = false;

  Future<List<Plant>> fetchPlants() async {
    await Future<void>.delayed(latency);
    if (offline) throw const NetworkException();
    return buildDummyPlants(DateTime.now());
  }
}
