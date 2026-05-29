// Configuració del backend. Llegeix backend_config.json.
import 'dart:convert';
import 'dart:io';

class BackendConfig {
  final String dbHost;
  final int dbPort;
  final String dbUser;
  final String dbPassword;
  final String dbName;
  final String serverHost;
  final int serverPort;

  BackendConfig({
    required this.dbHost,
    required this.dbPort,
    required this.dbUser,
    required this.dbPassword,
    required this.dbName,
    required this.serverHost,
    required this.serverPort,
  });

  static Future<BackendConfig> load() async {
    final file = File('backend_config.json');
    if (!await file.exists()) {
      throw Exception(
        'backend_config.json no trobat.\n'
        'Copia backend_config.example.json → backend_config.json i omple les credencials.',
      );
    }
    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;
    return BackendConfig(
      dbHost: json['db_host'] as String,
      dbPort: json['db_port'] as int,
      dbUser: json['db_user'] as String,
      dbPassword: json['db_password'] as String,
      dbName: json['db_name'] as String,
      serverHost: json['server_host'] as String? ?? 'localhost',
      serverPort: json['server_port'] as int? ?? 8080,
    );
  }
}
