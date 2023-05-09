import 'dart:convert';

import 'package:paqueteria_barranco/models/address.dart';

class Ruta {
  final int id;
  final String distancia;
  final String nombre;
  final String tiempo;
  final List<Address> direcciones;

  Ruta({
    required this.id,
    required this.distancia,
    required this.nombre,
    required this.tiempo,
    required this.direcciones,
  });

  Ruta copyWith({
    int? id,
    String? distancia,
    String? nombre,
    String? tiempo,
    List<Address>? direcciones,
  }) {
    return Ruta(
      id: id ?? this.id,
      distancia: distancia ?? this.distancia,
      nombre: nombre ?? this.nombre,
      tiempo: tiempo ?? this.tiempo,
      direcciones: direcciones ?? this.direcciones,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'distancia': distancia,
      'nombre': nombre,
      'tiempo': tiempo,
    };
  }

  factory Ruta.fromMap(dynamic json) {
    var direccionesList = json[0]['direcciones'] as List;
    List<Address> direcciones =
        direccionesList.map((i) => Address.fromMap(i)).toList();

    return Ruta(
      id: json[0]['id'],
      nombre: json[0]['nombre'],
      distancia: json[0]['distancia'],
      tiempo: json[0]['tiempo'],
      direcciones: direcciones,
    );
  }

  String toJson() => json.encode(toMap());

  factory Ruta.fromJson(String source) =>
      Ruta.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Ruta(id: $id, distancia: $distancia, nombre: $nombre, tiempo: $tiempo)';
  }

  @override
  bool operator ==(covariant Ruta other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.distancia == distancia &&
        other.nombre == nombre &&
        other.tiempo == tiempo;
  }

  @override
  int get hashCode {
    return id.hashCode ^ distancia.hashCode ^ nombre.hashCode ^ tiempo.hashCode;
  }
}
