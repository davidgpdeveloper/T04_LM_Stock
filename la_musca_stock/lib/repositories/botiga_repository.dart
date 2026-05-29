import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../data/api_data_source.dart';
import '../data/test_data_provider.dart';
import '../models/botiga.dart';

class BotigaRepository extends ChangeNotifier {
  List<Botiga> _botigues = [];
  bool _loaded = false;

  List<Botiga> get botigues => List.unmodifiable(_botigues);

  bool get isLoaded => _loaded;

  Future<void> loadData() async {
    if (_loaded) return;
    if (AppConfig.usarDadesDeProva) {
      _botigues = await TestDataProvider.loadBotigues();
    } else {
      _botigues = await ApiDataSource.loadBotigues();
    }
    _loaded = true;
    notifyListeners();
  }

  Botiga? getById(int id) {
    try {
      return _botigues.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  int get nextId =>
      _botigues.isEmpty
          ? 1
          : _botigues.map((b) => b.id).reduce((a, b) => a > b ? a : b) + 1;

  Future<bool> existsByName(String nom, {int? excludeId}) {
    final exists = _botigues.any(
      (b) =>
          b.nom.toLowerCase() == nom.toLowerCase() && b.id != (excludeId ?? -1),
    );
    return Future.value(exists);
  }

  Future<void> add(Botiga botiga) async {
    if (!AppConfig.usarDadesDeProva) {
      final created = await ApiDataSource.createBotiga(botiga);
      _botigues.add(created);
    } else {
      _botigues.add(botiga);
    }
    notifyListeners();
  }

  Future<void> update(Botiga botiga) async {
    if (!AppConfig.usarDadesDeProva) {
      await ApiDataSource.updateBotiga(botiga);
    }
    final index = _botigues.indexWhere((b) => b.id == botiga.id);
    if (index >= 0) {
      _botigues[index] = botiga;
      notifyListeners();
    }
  }

  Future<void> delete(int id) async {
    if (!AppConfig.usarDadesDeProva) {
      await ApiDataSource.deleteBotiga(id);
    }
    _botigues.removeWhere((b) => b.id == id);
    notifyListeners();
  }
}
