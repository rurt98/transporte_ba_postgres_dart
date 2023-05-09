import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:paqueteria_barranco/models/address.dart';
import 'package:paqueteria_barranco/models/empleado.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter/services.dart' show rootBundle;

class EmpleadoProvider extends ChangeNotifier {
  final PostgreSQLConnection connection;

  EmpleadoProvider(this.connection);

  // State
  List<Empleado> empleados = [];

  // Estado loading
  bool _isLoading = false;
  bool get loading => _isLoading;
  set loading(bool valor) {
    _isLoading = valor;
    notifyListeners();
  }

  Future<List<Empleado>?> getAll() async {
    try {
      loading = true;
      final res = await connection.query(
        '''SELECT Empleado.*, Direccion.frac_nombre, Direccion.calle, Direccion.cp, Direccion.colonia, Direccion.estado, Direccion.municipio
          FROM Empleado
          LEFT JOIN Direccion ON Empleado.id_direccion = Direccion.id;
        ''',
      );

      empleados = res
          .map(
            (data) => Empleado(
              id: data[0],
              nombre: data[1],
              num_licencia: data[2],
              salario: data[3],
              address: Address(
                id: data[4],
                frac_nombre: data[5],
                calle: data[6],
                cp: data[7],
                colonia: data[8],
                estado: data[9],
                municipio: data[10],
              ),
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
      if (empleados.isNotEmpty) return;

      await connection.transaction((ctx) async {
        String jsonString =
            await rootBundle.loadString('assets/db/empleado.json');
        final mockData = json.decode(jsonString);
        final mockDataStream = Stream.fromIterable(mockData);

        await for (var row in mockDataStream) {
          await ctx.query('''
            INSERT INTO empleado (nombre,num_licencia,salario, id_direccion)
            VALUES (@nombre,@num_licencia,@salario, @id_direccion)
          ''', substitutionValues: {
            'nombre': row['nombre'],
            'num_licencia': row['num_licencia'],
            'salario': row['salario'],
            'id_direccion': row['id_direccion'],
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
      final resAddress = await connection.query('''
        INSERT INTO direccion (frac_nombre,calle,cp,colonia,estado,municipio,ruta_id)
        VALUES (@frac_nombre,@calle,@cp,@colonia,@estado,@municipio,@ruta_id)
        RETURNING id
        ''', substitutionValues: {
        'frac_nombre': data['frac_nombre'],
        'calle': data['calle'],
        'cp': data['cp'],
        'colonia': data['colonia'],
        'estado': data['estado'],
        'municipio': data['municipio'],
        'ruta_id': null,
      });

      await connection.query('''
        INSERT INTO empleado (nombre,num_licencia,salario,id_direccion)
        VALUES (@nombre,@num_licencia,@salario,@id_direccion)
        ''', substitutionValues: {
        'nombre': data['nombre'],
        'num_licencia': data['num_licencia'],
        'salario': data['salario'],
        'id_direccion': resAddress[0][0],
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
    required int addressId,
    required Function() onError,
  }) async {
    try {
      await connection.query('''
        UPDATE direccion set frac_nombre = @frac_nombre, calle = @calle, cp = @cp, colonia = @colonia, estado = @estado, municipio = @municipio
        WHERE id = @id
        ''', substitutionValues: {
        'id': addressId,
        'frac_nombre': data['frac_nombre'],
        'calle': data['calle'],
        'cp': data['cp'],
        'colonia': data['colonia'],
        'estado': data['estado'],
        'municipio': data['municipio'],
        'ruta_id': null,
      });

      await connection.query('''
        UPDATE empleado set nombre = @nombre, num_licencia = @num_licencia, salario = @salario
        WHERE id = @id
        ''', substitutionValues: {
        'id': id,
        'nombre': data['nombre'],
        'num_licencia': data['num_licencia'],
        'salario': addressId,
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
        DELETE FROM empleado
        WHERE id = @id
        ''', substitutionValues: {
        'id': id,
      });

      empleados.removeWhere((e) => e.id == id);

      notifyListeners();

      return true;
    } catch (e) {
      onError();
      debugPrint(e.toString());
    }

    return false;
  }
}
