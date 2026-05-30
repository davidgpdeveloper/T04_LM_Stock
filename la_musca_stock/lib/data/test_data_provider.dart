import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/botiga.dart';
import '../models/producte.dart';
import '../models/comanda.dart';

/// Proveïdor de dades de prova amb persistència local.
/// Les dades es carreguen primer de SharedPreferences; si no n'hi ha,
/// es fa fallback als JSON d'assets (dades inicials seed).
class TestDataProvider {
  static const _keyBotigues = 'demo_botigues';
  static const _keyProductes = 'demo_productes';
  static const _keyComandes = 'demo_comandes';

  static Future<List<Botiga>> loadBotigues() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_keyBotigues);
    final String jsonString;
    if (saved != null) {
      jsonString = saved;
    } else {
      jsonString = await rootBundle.loadString('assets/data/botigues.json');
    }
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => Botiga.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Producte>> loadProductes() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_keyProductes);
    final String jsonString;
    if (saved != null) {
      jsonString = saved;
    } else {
      jsonString = await rootBundle.loadString('assets/data/productes.json');
    }
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => Producte.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Comanda>> loadComandes() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_keyComandes);
    final String jsonString;
    if (saved != null) {
      jsonString = saved;
    } else {
      jsonString = await rootBundle.loadString('assets/data/comandes.json');
    }
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => Comanda.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Mètodes per guardar les dades actualitzades

  static Future<void> saveBotigues(List<Botiga> botigues) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(botigues.map((b) => b.toJson()).toList());
    await prefs.setString(_keyBotigues, jsonString);
  }

  static Future<void> saveProductes(List<Producte> productes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(productes.map((p) => p.toJson()).toList());
    await prefs.setString(_keyProductes, jsonString);
  }

  static Future<void> saveComandes(List<Comanda> comandes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(comandes.map((c) => c.toJson()).toList());
    await prefs.setString(_keyComandes, jsonString);
  }
}
