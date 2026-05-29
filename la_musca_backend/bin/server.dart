// Punt d'entrada del backend. Arrenca el servidor HTTP amb les rutes API.
import 'dart:async';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:la_musca_backend/config.dart';
import 'package:la_musca_backend/database.dart';
import 'package:la_musca_backend/cors_middleware.dart';
import 'package:la_musca_backend/handlers/botigues_handler.dart';
import 'package:la_musca_backend/handlers/productes_handler.dart';
import 'package:la_musca_backend/handlers/comandes_handler.dart';

void main() async {
  // Capturar excepcions no gestionades per evitar que el servidor es tanqui
  runZonedGuarded(() async {
    await _startServer();
  }, (error, stackTrace) {
    print('');
    print('[ERROR NO GESTIONAT] $error');
    print('El servidor continua actiu. La connexió es recuperarà automàticament.');
  });
}

Future<void> _startServer() async {
  print('La Musca Backend');
  print('================');

  // Carregar configuració
  final config = await BackendConfig.load();
  print('Configuració carregada');

  // Connectar a la base de dades
  final db = Database(config);
  await db.initialize();

  // Crear handlers
  final botiguesHandler = BotiguesHandler(db);
  final productesHandler = ProductesHandler(db);
  final comandesHandler = ComandesHandler(db);

  // Definir rutes API
  final router = Router()
    // Botigues
    ..get('/api/botigues', botiguesHandler.getAll)
    ..get('/api/botigues/<id>', botiguesHandler.getById)
    ..post('/api/botigues', botiguesHandler.create)
    ..put('/api/botigues/<id>', botiguesHandler.update)
    ..delete('/api/botigues/<id>', botiguesHandler.delete)
    // Productes
    ..get('/api/productes', productesHandler.getAll)
    ..get('/api/productes/<id>', productesHandler.getById)
    ..post('/api/productes', productesHandler.create)
    ..put('/api/productes/<id>', productesHandler.update)
    ..delete('/api/productes/<id>', productesHandler.delete)
    // Comandes
    ..get('/api/comandes', comandesHandler.getAll)
    ..get('/api/comandes/<id>', comandesHandler.getById)
    ..post('/api/comandes', comandesHandler.create)
    ..put('/api/comandes/<id>', comandesHandler.update)
    ..delete('/api/comandes/<id>', comandesHandler.delete)
    ..delete('/api/comandes/by-botiga/<id>', comandesHandler.deleteByBotiga)
    ..delete('/api/comandes/by-producte/<id>', comandesHandler.deleteByProducte);

  // Configurar pipeline amb CORS i logging
  final handler = const Pipeline()
      .addMiddleware(corsMiddleware())
      .addMiddleware(logRequests())
      .addHandler(router.call);

  // Arrancar servidor
  final server = await shelf_io.serve(
    handler,
    config.serverHost,
    config.serverPort,
  );

  print('');
  print('Servidor actiu a http://${server.address.host}:${server.port}');
  print('Base de dades: ${config.dbName}@${config.dbHost}:${config.dbPort}');
  print('');
  print('Endpoints disponibles:');
  print('  GET/POST       /api/botigues');
  print('  GET/PUT/DELETE  /api/botigues/<id>');
  print('  GET/POST       /api/productes');
  print('  GET/PUT/DELETE  /api/productes/<id>');
  print('  GET/POST       /api/comandes');
  print('  GET/PUT/DELETE  /api/comandes/<id>');
  print('');
  print('Ctrl+C per aturar');

  // Gestió de tancament net
  ProcessSignal.sigint.watch().listen((_) async {
    print('\nAturant servidor...');
    await db.close();
    server.close();
    exit(0);
  });
}