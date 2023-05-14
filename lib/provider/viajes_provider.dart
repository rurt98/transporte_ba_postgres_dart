import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:paqueteria_barranco/models/vehiculo.dart';
import 'package:paqueteria_barranco/models/viaje.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter/services.dart' show rootBundle;

class ViajesProvider extends ChangeNotifier {
  final PostgreSQLConnection connection;

  ViajesProvider(this.connection);

  // State
  List<Viaje> viajes = [];

  // Estado loading
  bool _isLoading = false;
  bool get loading => _isLoading;
  set loading(bool valor) {
    _isLoading = valor;
    notifyListeners();
  }

  Future<List<Vehiculo>?> getAll() async {
    try {
      loading = true;
      final res = await connection.query(
        ''' 
        SELECT 
        json_build_object(
            'id_vehiculo', v.id,
            'marca', v.marca,
            'modelo', v.modelo,
            'paquete', json_agg(
              json_build_object(
              'id', p.id,
              'peso', p.peso,
              'tamanio', p.tamanio,
              'f_ent_est', p.f_ent_est,
              'f_envio', p.f_envio,
              'entregado', p.entregado
              )
            ),
            'ruta', json_agg(
              json_build_object(
                'id', r.id,
                'nombre', r.nombre,
                'distancia', r.distancia
              )
            )
        ) AS viaje
      FROM 
          Vehiculo v
          INNER JOIN car_viaja cv ON v.id = cv.id_vehiculo
          INNER JOIN Ruta r ON cv.id_ruta = r.id
          INNER JOIN Direccion d ON r.id = d.ruta_id
          INNER JOIN Paquete p ON v.id = p.id_vehiculo AND d.id = p.id_direccion
          INNER JOIN viajes_sin_finalizar vsf ON vsf.id_vehiculo = v.id AND vsf.id_paquete = p.id AND vsf.id_ruta = r.id AND vsf.id_direccion = d.id
      WHERE 
          v.disponible = false AND p.entregado = false
      GROUP BY 
          v.id;''',
      );

      viajes = res.map((e) => Viaje.fromMap(e[0])).toList();

      loading = false;
      return null;
    } catch (e) {
      debugPrint(e.toString());
    }

    return null;
  }

  Future populate() async {
    try {
      if (viajes.isNotEmpty) return;

      await connection.query(
        '''
        UPDATE vehiculo set disponible = @disponible
        WHERE id = @id
        ''',
        substitutionValues: {'id': 1, 'disponible': false},
      );

      await connection.transaction((ctx) async {
        String jsonString =
            await rootBundle.loadString('assets/db/viajes.json');
        final mockData = json.decode(jsonString);
        final mockDataStream = Stream.fromIterable(mockData);

        await for (var row in mockDataStream) {
          for (var element in row['car_viaja']) {
            await ctx.query('''
                INSERT INTO car_viaja (id_ruta,id_vehiculo)
                VALUES (@id_ruta,@id_vehiculo)
              ''', substitutionValues: {
              'id_ruta': element['id_ruta'],
              'id_vehiculo': element['id_vehiculo'],
            });
          }

          await ctx.query('''
              INSERT INTO empleado_maneja (id_vehiculo,id_empleado,fecha_m,hr_salida,hr_llegada)
              VALUES (@id_vehiculo,@id_empleado,@hr_salida,@fecha_m,@hr_llegada)
            ''', substitutionValues: {
            'id_vehiculo': row['empleado_maneja']['id_vehiculo'],
            'id_empleado': row['empleado_maneja']['id_empleado'],
            'fecha_m': row['empleado_maneja']['fecha_m'],
            'hr_llegada': row['empleado_maneja']['hr_llegada'],
            'hr_salida': row['empleado_maneja']['hr_salida'],
          });

          for (var element in row['paquetes']) {
            await ctx.query('''
               INSERT INTO paquete (peso,tamanio,f_ent_est,f_envio,cobro,entregado,id_direccion,id_cliente,id_vehiculo)
               VALUES (@peso,@tamanio,@f_ent_est,@f_envio,@cobro,@entregado,@id_direccion,@id_cliente,@id_vehiculo)
              ''', substitutionValues: {
              'peso': element['peso'],
              'tamanio': element['tamanio'],
              'f_ent_est': element['f_ent_est'],
              'f_envio': element['f_envio'],
              'cobro': element['cobro'],
              'entregado': element['entregado'],
              'id_direccion': element['id_direccion'],
              'id_cliente': element['id_cliente'],
              'id_vehiculo': element['id_vehiculo'],
            });
          }
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
        INSERT INTO vehiculo (marca,modelo,cap_carga)
        VALUES (@marca,@modelo,@cap_carga)
        ''', substitutionValues: {
        'marca': data['marca'],
        'modelo': data['modelo'],
        'cap_carga': data['cap_carga'],
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
        UPDATE vehiculo set marca = @marca, modelo = @modelo, cap_carga = @cap_carga
        WHERE id = @id
        ''', substitutionValues: {
        'id': id,
        'marca': data['marca'],
        'modelo': data['modelo'],
        'cap_carga': data['cap_carga'],
      });

      getAll();

      return true;
    } catch (e) {
      onError();
      debugPrint(e.toString());
    }

    return false;
  }

  // Future<bool> eliminar({
  //   required int id,
  //   required Function() onError,
  // }) async {
  //   try {
  //     await connection.query('''
  //       DELETE FROM vehiculo
  //       WHERE id = @id
  //       ''', substitutionValues: {
  //       'id': id,
  //     });

  //     vehiculos.removeWhere((e) => e.id == id);

  //     notifyListeners();

  //     return true;
  //   } catch (e) {
  //     onError();
  //     debugPrint(e.toString());
  //   }

  //   return false;
  // }
}
