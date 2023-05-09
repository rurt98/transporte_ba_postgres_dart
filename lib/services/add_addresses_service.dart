import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:paqueteria_barranco/models/address.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter/services.dart' show rootBundle;

class AddAddressesService extends ChangeNotifier {
  final PostgreSQLConnection connection;

  AddAddressesService(this.connection);

  // State
  List<Address> direcciones = [];

  // Estado loading
  bool _isLoading = false;
  bool get loading => _isLoading;
  set loading(bool valor) {
    _isLoading = valor;
    notifyListeners();
  }

  Future<List<Address>?> getAll() async {
    try {
      loading = true;
      final res = await connection.query(
        'SELECT * FROM direccion',
      );

      direcciones = [];

      direcciones = res
          .map(
            (data) => Address(
              id: data[0],
              frac_nombre: data[1],
              calle: data[2],
              cp: data[3],
              colonia: data[4],
              estado: data[5],
              municipio: data[6],
              ruta_id: data[7],
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
      if (direcciones.isNotEmpty) return;

      await connection.transaction((ctx) async {
        String jsonString =
            await rootBundle.loadString('assets/db/address.json');
        final mockData = json.decode(jsonString);
        final mockDataStream = Stream.fromIterable(mockData);

        await for (var row in mockDataStream) {
          await ctx.query('''
            INSERT INTO direccion (frac_nombre,calle,cp,colonia,estado,municipio,ruta_id)
            VALUES (@frac_nombre,@calle,@cp,@colonia,@estado,@municipio,@ruta_id)
          ''', substitutionValues: {
            'frac_nombre': row['frac_nombre'],
            'calle': row['calle'],
            'cp': row['cp'],
            'colonia': row['colonia'],
            'estado': row['estado'],
            'municipio': row['municipio'],
            'ruta_id': row['ruta_id'],
          });
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
    getAll();
  }
}
