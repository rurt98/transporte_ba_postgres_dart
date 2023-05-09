import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:paqueteria_barranco/models/ruta.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter/services.dart' show rootBundle;

class RutasProvider extends ChangeNotifier {
  final PostgreSQLConnection connection;

  RutasProvider(this.connection);

  // State
  List<Ruta> rutas = [];

  // Estado loading
  bool _isLoading = false;
  bool get loading => _isLoading;
  set loading(bool valor) {
    _isLoading = valor;
    notifyListeners();
  }

  Future<List<Ruta>?> getAll() async {
    try {
      loading = true;
      final res = await connection.query(
        'SELECT id, distancia, nombre, to_char(tiempo, \'HH24:MI:SS\') FROM Ruta',
      );

      rutas = res
          .map(
            (data) => Ruta(
              id: data[0],
              distancia: data[1],
              nombre: data[2],
              tiempo: data[3],
            ),
          )
          .toList();

      loading = false;
      return rutas;
    } catch (e) {
      debugPrint(e.toString());
    }

    return null;
  }

  Future populateRutas() async {
    try {
      if (rutas.isNotEmpty) return;

      loading = true;

      await connection.transaction((ctx) async {
        String jsonString = await rootBundle.loadString('assets/db/ruta.json');
        final mockData = json.decode(jsonString);
        final mockDataStream = Stream.fromIterable(mockData);

        await for (var row in mockDataStream) {
          await ctx.query('''
            INSERT INTO ruta (distancia,nombre,tiempo)
            VALUES (@distancia,@nombre,@tiempo)
          ''', substitutionValues: {
            'distancia': row['distancia'],
            'nombre': row['nombre'],
            'tiempo': row['tiempo'],
          });
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }

    loading = false;
  }

  Future<bool> agregar({
    required Map<String, dynamic> data,
    required Function() onError,
  }) async {
    try {
      await connection.query('''
        INSERT INTO ruta (distancia,nombre,tiempo)
        VALUES (@distancia,@nombre,@tiempo)
        ''', substitutionValues: {
        'distancia': data['distancia'],
        'nombre': data['nombre'],
        'tiempo': data['tiempo'],
      });

      getAll();

      return true;
    } catch (e) {
      onError();
      debugPrint(e.toString());
    }

    return false;
  }

  Future<bool> editar({
    required Map<String, dynamic> data,
    required int id,
    required Function() onError,
  }) async {
    try {
      await connection.query('''
        UPDATE ruta set distancia = @distancia, nombre = @nombre, tiempo = @tiempo
        WHERE id = @id
        ''', substitutionValues: {
        'id': id,
        'distancia': data['distancia'],
        'nombre': data['nombre'],
        'tiempo': data['tiempo'],
      });

      getAll();

      return true;
    } catch (e) {
      onError();
      debugPrint(e.toString());
    }

    return false;
  }

  Future<bool> eliminar({
    required int id,
    required Function() onError,
  }) async {
    try {
      await connection.query('''
        DELETE FROM ruta
        WHERE id = @id
        ''', substitutionValues: {
        'id': id,
      });

      rutas.removeWhere((e) => e.id == id);

      notifyListeners();

      return true;
    } catch (e) {
      onError();
      debugPrint(e.toString());
    }

    return false;
  }
}
