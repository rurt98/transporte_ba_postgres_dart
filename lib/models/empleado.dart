import 'dart:convert';

import 'package:paqueteria_barranco/models/address.dart';

class Empleado {
  final int id;
  final String nombre;
  final int num_licencia;
  final double salario;
  final Address address;
  Empleado({
    required this.id,
    required this.nombre,
    required this.num_licencia,
    required this.salario,
    required this.address,
  });

  Empleado copyWith({
    int? id,
    String? nombre,
    int? num_licencia,
    double? salario,
    Address? address,
  }) {
    return Empleado(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      num_licencia: num_licencia ?? this.num_licencia,
      salario: salario ?? this.salario,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nombre': nombre,
      'num_licencia': num_licencia,
      'salario': salario,
      "address": address.toMap(),
    };
  }

  factory Empleado.fromMap(Map<String, dynamic> map) {
    return Empleado(
      id: map['id'].toInt() as int,
      nombre: map['nombre'] as String,
      num_licencia: map['num_licencia'].toInt() as int,
      salario: map['salario'],
      address: Address.fromMap(map["address"]),
    );
  }

  String toJson() => json.encode(toMap());

  factory Empleado.fromJson(String source) =>
      Empleado.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Empleado(id: $id, nombre: $nombre, num_licencia: $num_licencia, salario: $salario, id_direccion: ${address.toString()})';
  }

  @override
  bool operator ==(covariant Empleado other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.nombre == nombre &&
        other.num_licencia == num_licencia &&
        other.salario == salario &&
        other.address == address;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nombre.hashCode ^
        num_licencia.hashCode ^
        salario.hashCode ^
        address.hashCode;
  }
}
