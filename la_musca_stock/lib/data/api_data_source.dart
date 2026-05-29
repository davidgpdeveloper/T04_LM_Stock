// Font de dades remota via API REST.
// Comunica amb el backend Dart per accedir a la BD MySQL.
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/botiga.dart';
import '../models/producte.dart';
import '../models/comanda.dart';

class ApiDataSource {
  static String get _baseUrl => AppConfig.apiUrl;

  // ---- Botigues ----

  static Future<List<Botiga>> loadBotigues() async {
    final response = await http.get(Uri.parse('$_baseUrl/botigues'));
    _checkResponse(response);
    final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
    return jsonList
        .map((j) => Botiga.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  static Future<Botiga> createBotiga(Botiga botiga) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/botigues'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(botiga.toJson()),
    );
    _checkResponse(response);
    return Botiga.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<void> updateBotiga(Botiga botiga) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/botigues/${botiga.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(botiga.toJson()),
    );
    _checkResponse(response);
  }

  static Future<void> deleteBotiga(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/botigues/$id'),
    );
    _checkResponse(response);
  }

  // ---- Productes ----

  static Future<List<Producte>> loadProductes() async {
    final response = await http.get(Uri.parse('$_baseUrl/productes'));
    _checkResponse(response);
    final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
    return jsonList
        .map((j) => Producte.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  static Future<Producte> createProducte(Producte producte) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/productes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(producte.toJson()),
    );
    _checkResponse(response);
    return Producte.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<void> updateProducte(Producte producte) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/productes/${producte.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(producte.toJson()),
    );
    _checkResponse(response);
  }

  static Future<void> deleteProducte(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/productes/$id'),
    );
    _checkResponse(response);
  }

  // ---- Comandes ----

  static Future<List<Comanda>> loadComandes() async {
    final response = await http.get(Uri.parse('$_baseUrl/comandes'));
    _checkResponse(response);
    final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
    return jsonList
        .map((j) => Comanda.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  static Future<Comanda> createComanda(Comanda comanda) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/comandes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(comanda.toJson()),
    );
    _checkResponse(response);
    return Comanda.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<void> updateComanda(Comanda comanda) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/comandes/${comanda.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(comanda.toJson()),
    );
    _checkResponse(response);
  }

  static Future<void> deleteComanda(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/comandes/$id'),
    );
    _checkResponse(response);
  }

  static Future<void> deleteComandesByBotiga(int botigaId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/comandes/by-botiga/$botigaId'),
    );
    _checkResponse(response);
  }

  static Future<void> deleteComandesByProducte(int producteId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/comandes/by-producte/$producteId'),
    );
    _checkResponse(response);
  }

  // ---- Utils ----

  static void _checkResponse(http.Response response) {
    if (response.statusCode >= 400) {
      final body = response.body;
      String message;
      try {
        final json = jsonDecode(body) as Map<String, dynamic>;
        message = json['error'] as String? ?? body;
      } catch (_) {
        message = body;
      }
      throw Exception('Error API (${response.statusCode}): $message');
    }
  }
}
