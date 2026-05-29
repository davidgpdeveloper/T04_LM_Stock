import 'dart:convert';
import 'package:flutter/services.dart';

class AppConfig {
  static bool usarDadesDeProva = true;

  static Future<void> load() async {
    try {
      final configString =
          await rootBundle.loadString('assets/config/app_config.json');
      final config = json.decode(configString) as Map<String, dynamic>;
      usarDadesDeProva = config['usar_dades_de_prova'] as bool? ?? true;
    } catch (_) {
      usarDadesDeProva = true;
    }
  }
}
