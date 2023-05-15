import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:paqueteria_barranco/models/vehiculo.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter/services.dart' show rootBundle;

class CarsProvider extends ChangeNotifier {
  final PostgreSQLConnection connection;

  CarsProvider(this.connection);

  // State
  List<Vehiculo> vehiculos = [];

  // Estado loading
  bool _isLoading = false;
  bool get loading => _isLoading;
  set loading(bool valor) {
    _isLoading = valor;
    notifyListeners();
  }

  List<Vehiculo> get vehiculosNoOcupados =>
      vehiculos.where((e) => e.disponible!).toList();

  Future<List<Vehiculo>?> getAll() async {
    try {
      loading = true;
      final res = await connection.query(
        'SELECT * FROM vehiculo',
      );

      vehiculos = res
          .map(
            (data) => Vehiculo(
              id: data[0],
              marca: data[1],
              modelo: data[2],
              disponible: data[3],
              cap_carga: data[4],
            ),
          )
          .toList();

      loading = false;
      return null;
    } catch (e) {
      debugPrint(e.toString());
    }

    return null;
  }

  Future populate() async {
    try {
      if (vehiculos.isNotEmpty) return;

      await connection.transaction((ctx) async {
        String jsonString = await rootBundle.loadString('assets/db/car.json');
        final mockData = json.decode(jsonString);
        final mockDataStream = Stream.fromIterable(mockData);

        await for (var row in mockDataStream) {
          await ctx.query('''
            INSERT INTO vehiculo (marca,modelo,cap_carga, placa)
            VALUES (@marca,@modelo,@cap_carga,@placa)
          ''', substitutionValues: {
            'marca': row['marca'],
            'modelo': row['modelo'],
            'cap_carga': row['cap_carga'],
            'placa': row['placa'],
          });
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }

    getAll();
  }

  Future<bool> agregar({
    required Map<String, dynamic> data,
    required Function() onError,
  }) async {
    try {
      await connection.query('''
         INSERT INTO vehiculo (marca,modelo,cap_carga, placa)
         VALUES (@marca,@modelo,@cap_carga,@placa)
        ''', substitutionValues: {
        'marca': data['marca'],
        'modelo': data['modelo'],
        'cap_carga': data['cap_carga'],
        'placa': data['placa'],
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
        UPDATE vehiculo set marca = @marca, modelo = @modelo, cap_carga = @cap_carga, placa = @placa
        WHERE id = @id
        ''', substitutionValues: {
        'id': id,
        'marca': data['marca'],
        'modelo': data['modelo'],
        'cap_carga': data['cap_carga'],
        'placa': data['placa'],
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
        DELETE FROM vehiculo
        WHERE id = @id
        ''', substitutionValues: {
        'id': id,
      });

      vehiculos.removeWhere((e) => e.id == id);

      notifyListeners();

      return true;
    } catch (e) {
      onError();
      debugPrint(e.toString());
    }

    return false;
  }
}
