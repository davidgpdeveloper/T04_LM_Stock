// Handler CRUD per a la taula productes.
import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../database.dart';

class ProductesHandler {
  final Database db;

  ProductesHandler(this.db);

  /// GET /api/productes — Retorna tots els productes.
  Future<Response> getAll(Request request) async {
    try {
      final result = await db.pool.execute(
        'SELECT p_ID, p_NOM, p_QUANTITAT, p_DESC, p_IMATGE, p_IS_FROM_NEW_APP FROM productes ORDER BY p_NOM',
      );
      final productes = result.rows.map((row) => _rowToJson(row.assoc())).toList();
      return _jsonResponse(productes);
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// GET /api/productes/<id> — Retorna un producte per ID.
  Future<Response> getById(Request request, String id) async {
    try {
      final result = await db.pool.execute(
        'SELECT p_ID, p_NOM, p_QUANTITAT, p_DESC, p_IMATGE, p_IS_FROM_NEW_APP FROM productes WHERE p_ID = :id',
        {'id': id},
      );
      if (result.rows.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Producte no trobat'}),
          headers: _jsonHeaders,
        );
      }
      return _jsonResponse(_rowToJson(result.rows.first.assoc()));
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// POST /api/productes — Crea un nou producte.
  Future<Response> create(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final result = await db.pool.execute(
        'INSERT INTO productes (p_NOM, p_QUANTITAT, p_DESC, p_IMATGE, p_IS_FROM_NEW_APP) '
        'VALUES (:nom, :quantitat, :desc, :imatge, :is_from_new_app)',
        {
          'nom': body['nom'] ?? '',
          'quantitat': (body['quantitat'] ?? 0).toString(),
          'desc': body['descripcio'] ?? '',
          'imatge': body['imatge'],
          'is_from_new_app': body['is_from_new_app'] == null ? null : (body['is_from_new_app'] == true ? '1' : '0'),
        },
      );
      final newId = result.lastInsertID.toInt();
      return _jsonResponse({...body, 'id': newId});
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// PUT /api/productes/<id> — Actualitza un producte.
  Future<Response> update(Request request, String id) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      await db.pool.execute(
        'UPDATE productes SET p_NOM = :nom, p_QUANTITAT = :quantitat, '
        'p_DESC = :desc, p_IMATGE = :imatge, p_IS_FROM_NEW_APP = :is_from_new_app WHERE p_ID = :id',
        {
          'id': id,
          'nom': body['nom'] ?? '',
          'quantitat': (body['quantitat'] ?? 0).toString(),
          'desc': body['descripcio'] ?? '',
          'imatge': body['imatge'],
          'is_from_new_app': body['is_from_new_app'] == null ? null : (body['is_from_new_app'] == true ? '1' : '0'),
        },
      );
      return _jsonResponse({...body, 'id': int.parse(id)});
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// DELETE /api/productes/<id> — Elimina un producte i les seves comandes.
  Future<Response> delete(Request request, String id) async {
    try {
      // Eliminar comandes associades (cascade)
      await db.pool.execute(
        'DELETE FROM comandes WHERE c_PRODUCTE = :id',
        {'id': id},
      );
      // Eliminar el producte
      await db.pool.execute(
        'DELETE FROM productes WHERE p_ID = :id',
        {'id': id},
      );
      return _jsonResponse({'deleted': true, 'id': int.parse(id)});
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// Converteix una fila de la BD al format JSON esperat per Flutter.
  Map<String, dynamic> _rowToJson(Map<String, String?> r) => {
        'id': int.parse(r['p_ID'] ?? '0'),
        'nom': r['p_NOM'] ?? '',
        'quantitat': int.tryParse(r['p_QUANTITAT'] ?? '0') ?? 0,
        'descripcio': r['p_DESC'] ?? '',
        'imatge': r['p_IMATGE'],
        'is_from_new_app': r['p_IS_FROM_NEW_APP'] == null ? null : r['p_IS_FROM_NEW_APP'] == '1',
      };
}

Response _jsonResponse(Object data) =>
    Response.ok(jsonEncode(data), headers: _jsonHeaders);

Response _errorResponse(Object error) => Response.internalServerError(
      body: jsonEncode({'error': error.toString()}),
      headers: _jsonHeaders,
    );

const _jsonHeaders = {'Content-Type': 'application/json'};
