import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../data/test_data_provider.dart';
import '../models/comanda.dart';

class ComandaRepository extends ChangeNotifier {
  List<Comanda> _comandes = [];
  bool _loaded = false;

  List<Comanda> get comandes => List.unmodifiable(_comandes);

  bool get isLoaded => _loaded;

  Future<void> loadData() async {
    if (_loaded) return;
    if (AppConfig.usarDadesDeProva) {
      _comandes = await TestDataProvider.loadComandes();
    }
    _loaded = true;
    notifyListeners();
  }

  Comanda? getById(int id) {
    try {
      return _comandes.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  int get nextId =>
      _comandes.isEmpty
          ? 1
          : _comandes.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;

  List<Comanda> getByBotigaId(int botigaId) {
    return _comandes.where((c) => c.botigaId == botigaId).toList();
  }

  List<Comanda> getByProducteId(int producteId) {
    return _comandes.where((c) => c.producteId == producteId).toList();
  }

  List<Comanda> getByAlbara(String albara) {
    return _comandes
        .where((c) => c.albara.toLowerCase() == albara.toLowerCase())
        .toList();
  }

  List<String> get albaransDistincts {
    return _comandes.map((c) => c.albara).toSet().toList()..sort();
  }

  Future<void> add(Comanda comanda) async {
    _comandes.add(comanda);
    notifyListeners();
  }

  Future<void> update(Comanda comanda) async {
    final index = _comandes.indexWhere((c) => c.id == comanda.id);
    if (index >= 0) {
      _comandes[index] = comanda;
      notifyListeners();
    }
  }

  Future<void> delete(int id) async {
    _comandes.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Future<void> deleteByBotigaId(int botigaId) async {
    _comandes.removeWhere((c) => c.botigaId == botigaId);
    notifyListeners();
  }

  Future<void> deleteByProducteId(int producteId) async {
    _comandes.removeWhere((c) => c.producteId == producteId);
    notifyListeners();
  }
}
