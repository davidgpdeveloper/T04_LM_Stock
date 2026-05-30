import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../data/api_data_source.dart';
import '../data/test_data_provider.dart';
import '../models/producte.dart';

class ProducteRepository extends ChangeNotifier {
  List<Producte> _productes = [];
  bool _loaded = false;

  List<Producte> get productes => List.unmodifiable(_productes);

  bool get isLoaded => _loaded;

  Future<void> loadData() async {
    if (_loaded) return;
    if (AppConfig.usarDadesDeProva) {
      _productes = await TestDataProvider.loadProductes();
    } else {
      _productes = await ApiDataSource.loadProductes();
    }
    _loaded = true;
    notifyListeners();
  }

  Producte? getById(int id) {
    try {
      return _productes.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  int get nextId =>
      _productes.isEmpty
          ? 1
          : _productes.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;

  Future<bool> existsByName(String nom, {int? excludeId}) {
    final exists = _productes.any(
      (p) =>
          p.nom.toLowerCase() == nom.toLowerCase() &&
          p.id != (excludeId ?? -1),
    );
    return Future.value(exists);
  }

  Future<void> add(Producte producte) async {
    if (!AppConfig.usarDadesDeProva) {
      final created = await ApiDataSource.createProducte(producte);
      _productes.add(created);
    } else {
      _productes.add(producte);
      await TestDataProvider.saveProductes(_productes);
    }
    notifyListeners();
  }

  Future<void> update(Producte producte) async {
    if (!AppConfig.usarDadesDeProva) {
      await ApiDataSource.updateProducte(producte);
    }
    final index = _productes.indexWhere((p) => p.id == producte.id);
    if (index >= 0) {
      _productes[index] = producte;
      if (AppConfig.usarDadesDeProva) {
        await TestDataProvider.saveProductes(_productes);
      }
      notifyListeners();
    }
  }

  Future<void> delete(int id) async {
    if (!AppConfig.usarDadesDeProva) {
      await ApiDataSource.deleteProducte(id);
    }
    _productes.removeWhere((p) => p.id == id);
    if (AppConfig.usarDadesDeProva) {
      await TestDataProvider.saveProductes(_productes);
    }
    notifyListeners();
  }
}
