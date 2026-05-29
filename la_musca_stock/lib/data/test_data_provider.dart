import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/botiga.dart';
import '../models/producte.dart';
import '../models/comanda.dart';

class TestDataProvider {
  static Future<List<Botiga>> loadBotigues() async {
    final jsonString =
        await rootBundle.loadString('assets/data/botigues.json');
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => Botiga.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Producte>> loadProductes() async {
    final jsonString =
        await rootBundle.loadString('assets/data/productes.json');
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => Producte.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Comanda>> loadComandes() async {
    final jsonString =
        await rootBundle.loadString('assets/data/comandes.json');
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => Comanda.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
