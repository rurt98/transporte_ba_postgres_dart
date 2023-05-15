import 'dart:convert';

import 'package:paqueteria_barranco/models/address.dart';

class Ruta {
  final int id;
  final String? distancia;
  final String? nombre;
  final String? tiempo;
  final List<Address>? direcciones;

  Ruta({
    required this.id,
    this.distancia,
    this.nombre,
    this.tiempo,
    this.direcciones,
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
      'nombre': nombre,
      'distancia': distancia,
      'tiempo': tiempo,
    };
  }

  factory Ruta.fromMap(Map<String, dynamic> json) {
    return Ruta(
      id: json['id'] as int,
      nombre: json['nombre'] as String?,
      distancia: json['distancia'] as String?,
      tiempo: json['tiempo'] as String?,
      direcciones: (json['direcciones'] as List<dynamic>?)
          ?.map((x) => Address.fromMap(x as Map<String, dynamic>))
          .toList(),
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
