import 'dart:convert';
import 'package:flutter/services.dart';

class AppConfig {
  static bool usarDadesDeProva = false;
  static String apiUrl = 'http://localhost:8080/api';

  static Future<void> load() async {
    try {
      final configString =
          await rootBundle.loadString('assets/config/app_config.json');
      final config = json.decode(configString) as Map<String, dynamic>;
      apiUrl = config['api_url'] as String? ?? 'http://localhost:8080/api';
    } catch (_) {
      // Si no es pot carregar el config, es manté el valor per defecte
    }
  }
}
