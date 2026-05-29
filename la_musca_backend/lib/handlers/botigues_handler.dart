// Handler CRUD per a la taula botigues.
import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../database.dart';

class BotiguesHandler {
  final Database db;

  BotiguesHandler(this.db);

  /// GET /api/botigues — Retorna totes les botigues.
  Future<Response> getAll(Request request) async {
    try {
      final result = await db.pool.execute(
        'SELECT b_ID, b_NOM, b_NOMF, b_NIF, b_ADRECA, '
        'b_POBLACIO, b_CP, b_MAIL, b_TELF, b_OBSERVACIONS, b_IMATGE '
        'FROM botigues ORDER BY b_NOM',
      );
      final botigues = result.rows.map((row) => _rowToJson(row.assoc())).toList();
      return _jsonResponse(botigues);
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// GET /api/botigues/<id> — Retorna una botiga per ID.
  Future<Response> getById(Request request, String id) async {
    try {
      final result = await db.pool.execute(
        'SELECT b_ID, b_NOM, b_NOMF, b_NIF, b_ADRECA, '
        'b_POBLACIO, b_CP, b_MAIL, b_TELF, b_OBSERVACIONS, b_IMATGE '
        'FROM botigues WHERE b_ID = :id',
        {'id': id},
      );
      if (result.rows.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Botiga no trobada'}),
          headers: _jsonHeaders,
        );
      }
      return _jsonResponse(_rowToJson(result.rows.first.assoc()));
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// POST /api/botigues — Crea una nova botiga.
  Future<Response> create(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final result = await db.pool.execute(
        'INSERT INTO botigues (b_NOM, b_NOMF, b_NIF, b_ADRECA, '
        'b_POBLACIO, b_CP, b_MAIL, b_TELF, b_OBSERVACIONS, b_IMATGE) '
        'VALUES (:nom, :nomf, :nif, :adreca, :poblacio, '
        ':cp, :mail, :telf, :observacions, :imatge)',
        {
          'nom': body['nom'] ?? '',
          'nomf': body['nom_fiscal'] ?? '',
          'nif': body['nif'] ?? '',
          'adreca': body['adreca'] ?? '',
          'poblacio': body['poblacio'] ?? '',
          'cp': body['codi_postal'] ?? '',
          'mail': body['mail'] ?? '',
          'telf': body['telefon'] ?? '',
          'observacions': body['observacions'] ?? '',
          'imatge': body['imatge'],
        },
      );
      final newId = result.lastInsertID.toInt();
      return _jsonResponse({...body, 'id': newId});
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// PUT /api/botigues/<id> — Actualitza una botiga.
  Future<Response> update(Request request, String id) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      await db.pool.execute(
        'UPDATE botigues SET b_NOM = :nom, b_NOMF = :nomf, '
        'b_NIF = :nif, b_ADRECA = :adreca, b_POBLACIO = :poblacio, '
        'b_CP = :cp, b_MAIL = :mail, b_TELF = :telf, '
        'b_OBSERVACIONS = :observacions, b_IMATGE = :imatge WHERE b_ID = :id',
        {
          'id': id,
          'nom': body['nom'] ?? '',
          'nomf': body['nom_fiscal'] ?? '',
          'nif': body['nif'] ?? '',
          'adreca': body['adreca'] ?? '',
          'poblacio': body['poblacio'] ?? '',
          'cp': body['codi_postal'] ?? '',
          'mail': body['mail'] ?? '',
          'telf': body['telefon'] ?? '',
          'observacions': body['observacions'] ?? '',
          'imatge': body['imatge'],
        },
      );
      return _jsonResponse({...body, 'id': int.parse(id)});
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// DELETE /api/botigues/<id> — Elimina una botiga i les seves comandes.
  Future<Response> delete(Request request, String id) async {
    try {
      // Eliminar comandes associades (cascade)
      await db.pool.execute(
        'DELETE FROM comandes WHERE c_BOTIGA = :id',
        {'id': id},
      );
      // Eliminar la botiga
      await db.pool.execute(
        'DELETE FROM botigues WHERE b_ID = :id',
        {'id': id},
      );
      return _jsonResponse({'deleted': true, 'id': int.parse(id)});
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// Converteix una fila de la BD al format JSON esperat per Flutter.
  Map<String, dynamic> _rowToJson(Map<String, String?> r) => {
        'id': int.parse(r['b_ID'] ?? '0'),
        'nom': r['b_NOM'] ?? '',
        'nom_fiscal': r['b_NOMF'] ?? '',
        'nif': r['b_NIF'] ?? '',
        'adreca': r['b_ADRECA'] ?? '',
        'poblacio': r['b_POBLACIO'] ?? '',
        'codi_postal': r['b_CP'] ?? '',
        'mail': r['b_MAIL'] ?? '',
        'telefon': r['b_TELF'] ?? '',
        'observacions': r['b_OBSERVACIONS'] ?? '',
        'imatge': r['b_IMATGE'],
      };
}

Response _jsonResponse(Object data) =>
    Response.ok(jsonEncode(data), headers: _jsonHeaders);

Response _errorResponse(Object error) => Response.internalServerError(
      body: jsonEncode({'error': error.toString()}),
      headers: _jsonHeaders,
    );

const _jsonHeaders = {'Content-Type': 'application/json'};
