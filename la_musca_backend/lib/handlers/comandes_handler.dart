// Handler CRUD per a la taula comandes.
import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../database.dart';

class ComandesHandler {
  final Database db;

  ComandesHandler(this.db);

  /// GET /api/comandes — Retorna totes les comandes.
  Future<Response> getAll(Request request) async {
    try {
      final result = await db.pool.execute(
        'SELECT c_ID, c_ALBARA, c_DATA, c_BOTIGA, c_PRODUCTE, '
        'c_QUANTITAT, c_ESTAT, c_OBSERVACIONS '
        'FROM comandes ORDER BY c_DATA DESC, c_ALBARA ASC',
      );
      final comandes = result.rows.map((row) => _rowToJson(row.assoc())).toList();
      return _jsonResponse(comandes);
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// GET /api/comandes/<id> — Retorna una comanda per ID.
  Future<Response> getById(Request request, String id) async {
    try {
      final result = await db.pool.execute(
        'SELECT c_ID, c_ALBARA, c_DATA, c_BOTIGA, c_PRODUCTE, '
        'c_QUANTITAT, c_ESTAT, c_OBSERVACIONS '
        'FROM comandes WHERE c_ID = :id',
        {'id': id},
      );
      if (result.rows.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Comanda no trobada'}),
          headers: _jsonHeaders,
        );
      }
      return _jsonResponse(_rowToJson(result.rows.first.assoc()));
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// POST /api/comandes — Crea una nova comanda.
  Future<Response> create(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final result = await db.pool.execute(
        'INSERT INTO comandes (c_ALBARA, c_DATA, c_BOTIGA, c_PRODUCTE, '
        'c_QUANTITAT, c_ESTAT, c_OBSERVACIONS) '
        'VALUES (:albara, :data, :botiga, :producte, :quantitat, :estat, :observacions)',
        {
          'albara': body['albara'] ?? '',
          'data': body['data'] ?? '',
          'botiga': (body['botiga_id'] ?? 0).toString(),
          'producte': (body['producte_id'] ?? 0).toString(),
          'quantitat': (body['quantitat'] ?? 0).toString(),
          'estat': body['estat'] ?? '',
          'observacions': body['observacions'] ?? '',
        },
      );
      final newId = result.lastInsertID.toInt();
      return _jsonResponse({...body, 'id': newId});
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// PUT /api/comandes/<id> — Actualitza una comanda.
  Future<Response> update(Request request, String id) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      await db.pool.execute(
        'UPDATE comandes SET c_ALBARA = :albara, c_DATA = :data, '
        'c_BOTIGA = :botiga, c_PRODUCTE = :producte, c_QUANTITAT = :quantitat, '
        'c_ESTAT = :estat, c_OBSERVACIONS = :observacions WHERE c_ID = :id',
        {
          'id': id,
          'albara': body['albara'] ?? '',
          'data': body['data'] ?? '',
          'botiga': (body['botiga_id'] ?? 0).toString(),
          'producte': (body['producte_id'] ?? 0).toString(),
          'quantitat': (body['quantitat'] ?? 0).toString(),
          'estat': body['estat'] ?? '',
          'observacions': body['observacions'] ?? '',
        },
      );
      return _jsonResponse({...body, 'id': int.parse(id)});
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// DELETE /api/comandes/<id> — Elimina una comanda.
  Future<Response> delete(Request request, String id) async {
    try {
      await db.pool.execute(
        'DELETE FROM comandes WHERE c_ID = :id',
        {'id': id},
      );
      return _jsonResponse({'deleted': true, 'id': int.parse(id)});
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// DELETE /api/comandes/by-botiga/<botigaId> — Elimina comandes per botiga.
  Future<Response> deleteByBotiga(Request request, String botigaId) async {
    try {
      final result = await db.pool.execute(
        'DELETE FROM comandes WHERE c_BOTIGA = :id',
        {'id': botigaId},
      );
      return _jsonResponse({
        'deleted': true,
        'botiga_id': int.parse(botigaId),
        'affected_rows': result.affectedRows.toInt(),
      });
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// DELETE /api/comandes/by-producte/<producteId> — Elimina comandes per producte.
  Future<Response> deleteByProducte(Request request, String producteId) async {
    try {
      final result = await db.pool.execute(
        'DELETE FROM comandes WHERE c_PRODUCTE = :id',
        {'id': producteId},
      );
      return _jsonResponse({
        'deleted': true,
        'producte_id': int.parse(producteId),
        'affected_rows': result.affectedRows.toInt(),
      });
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// Converteix una fila de la BD al format JSON esperat per Flutter.
  Map<String, dynamic> _rowToJson(Map<String, String?> r) => {
        'id': int.parse(r['c_ID'] ?? '0'),
        'albara': r['c_ALBARA'] ?? '',
        'data': r['c_DATA'] ?? '',
        'botiga_id': int.tryParse(r['c_BOTIGA'] ?? '0') ?? 0,
        'producte_id': int.tryParse(r['c_PRODUCTE'] ?? '0') ?? 0,
        'quantitat': int.tryParse(r['c_QUANTITAT'] ?? '0') ?? 0,
        'estat': r['c_ESTAT'] ?? '',
        'observacions': r['c_OBSERVACIONS'] ?? '',
      };
}

Response _jsonResponse(Object data) =>
    Response.ok(jsonEncode(data), headers: _jsonHeaders);

Response _errorResponse(Object error) => Response.internalServerError(
      body: jsonEncode({'error': error.toString()}),
      headers: _jsonHeaders,
    );

const _jsonHeaders = {'Content-Type': 'application/json'};
