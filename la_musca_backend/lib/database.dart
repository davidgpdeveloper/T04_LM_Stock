// Gestió de la connexió a MySQL amb pool de connexions.
import 'package:mysql_client/mysql_client.dart';
import 'config.dart';

class Database {
  final BackendConfig config;
  late MySQLConnectionPool _pool;

  Database(this.config);

  MySQLConnectionPool get pool => _pool;

  Future<void> initialize() async {
    _pool = MySQLConnectionPool(
      host: config.dbHost,
      port: config.dbPort,
      userName: config.dbUser,
      password: config.dbPassword,
      maxConnections: 10,
      databaseName: config.dbName,
      secure: false,
    );

    // Verificar connexió
    await _pool.execute('SELECT 1');
    print('  Base de dades connectada correctament');

    // Executar migracions per afegir columnes que no existeixen a l'esquema original
    await _ensureSchema();
  }

  /// Afegeix columnes que el model Flutter necessita però que no existeixen
  /// a l'esquema original del projecte Java.
  Future<void> _ensureSchema() async {
    final migrations = [
      "ALTER TABLE botigues ADD COLUMN b_NOM_COMPLET VARCHAR(255) DEFAULT ''",
      "ALTER TABLE botigues ADD COLUMN b_POBLACIO VARCHAR(99) DEFAULT ''",
      "ALTER TABLE botigues ADD COLUMN b_CODI_POSTAL VARCHAR(10) DEFAULT ''",
      "ALTER TABLE botigues ADD COLUMN b_OBSERVACIONS VARCHAR(500) DEFAULT ''",
      "ALTER TABLE productes ADD COLUMN p_QUANTITAT INT DEFAULT 0",
      "ALTER TABLE comandes ADD COLUMN c_OBSERVACIONS VARCHAR(500) DEFAULT ''",
    ];

    for (final sql in migrations) {
      try {
        await _pool.execute(sql);
        print('  Migració aplicada: $sql');
      } catch (_) {
        // La columna ja existeix o error no crític, es continua
      }
    }
  }

  Future<void> close() async {
    await _pool.close();
  }
}
