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
        '''
    SELECT 
       json_build_object('id', Ruta.id, 'nombre', Ruta.nombre,  'distancia', Ruta.distancia::text, 'tiempo', to_char(Ruta.tiempo, 'HH24:MI:SS'), 'direcciones', json_agg(json_build_object('id', Direccion.id, 'frac_nombre', Direccion.frac_nombre, 'calle', Direccion.calle, 'cp', Direccion.cp, 'colonia', Direccion.colonia,  'estado', Direccion.estado,  'municipio', Direccion.municipio))) AS ruta
    FROM Ruta
    LEFT JOIN Direccion ON Ruta.id = Direccion.ruta_id
    WHERE Direccion.ruta_id > 0
    GROUP BY Ruta.id, Ruta.distancia, Ruta.tiempo;
      ''',
      );

      rutas = res.map((data) => Ruta.fromMap(data[0])).toList();

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
      final res = await connection.query('''
        INSERT INTO ruta (distancia,nombre,tiempo)
        VALUES (@distancia,@nombre,@tiempo)
        RETURNING id
        ''', substitutionValues: {
        'distancia': data['distancia'],
        'nombre': data['nombre'],
        'tiempo': data['tiempo'],
      });

      if (data['addresses'] != null && (data['addresses'] as List).isNotEmpty) {
        for (var address in data['addresses']) {
          await connection.query('''
          INSERT INTO direccion (frac_nombre,calle,cp,colonia,estado,municipio,ruta_id)
          VALUES (@frac_nombre,@calle,@cp,@colonia,@estado,@municipio,@ruta_id)
        ''', substitutionValues: {
            'frac_nombre': address['frac_nombre'],
            'calle': address['calle'],
            'cp': address['cp'],
            'colonia': address['colonia'],
            'estado': address['estado'],
            'municipio': address['municipio'],
            'ruta_id': res[0][0],
          });
        }
      }

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

      if (data['addresses'] != null && (data['addresses'] as List).isNotEmpty) {
        for (var address in data['addresses']) {
          await connection.query('''
           UPDATE direccion set frac_nombre = @frac_nombre, calle = @calle, cp = @cp, colonia = @colonia, estado = @estado, municipio = @municipio
            WHERE id = @id
        ''', substitutionValues: {
            'id': address['id'],
            'frac_nombre': address['frac_nombre'],
            'calle': address['calle'],
            'cp': address['cp'],
            'colonia': address['colonia'],
            'estado': address['estado'],
            'municipio': address['municipio'],
            'ruta_id': id,
          });
        }
      }

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
