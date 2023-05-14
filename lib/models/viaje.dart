import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:paqueteria_barranco/models/paquete.dart';
import 'package:paqueteria_barranco/models/ruta.dart';

class Viaje {
  final int? id_vehiculo;
  final String? marca;
  final String? modelo;
  final List<Paquete>? paquete;
  final List<Ruta>? ruta;
  Viaje({
    this.id_vehiculo,
    this.marca,
    this.modelo,
    this.paquete,
    this.ruta,
  });

  Viaje copyWith({
    int? id_vehiculo,
    String? marca,
    String? modelo,
    List<Paquete>? paquete,
    List<Ruta>? ruta,
  }) {
    return Viaje(
      id_vehiculo: id_vehiculo ?? this.id_vehiculo,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      paquete: paquete ?? this.paquete,
      ruta: ruta ?? this.ruta,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_vehiculo': id_vehiculo,
      'marca': marca,
      'modelo': modelo,
      'paquete': paquete?.map((x) => x.toMap()).toList(),
      'ruta': ruta?.map((x) => x.toMap()).toList(),
    };
  }

  factory Viaje.fromMap(Map<String, dynamic> map) {
    return Viaje(
      id_vehiculo: map['id_vehiculo'] as int?,
      marca: map['marca'] as String?,
      modelo: map['modelo'] as String?,
      paquete: (map['paquete'] as List<dynamic>?)
          ?.map((x) => Paquete.fromMap(x as Map<String, dynamic>))
          .toList(),
      ruta: (map['ruta'] as List<dynamic>?)
          ?.map((x) => Ruta.fromMap(x as Map<String, dynamic>))
          .toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Viaje.fromJson(String source) =>
      Viaje.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Viaje(id_vehiculo: $id_vehiculo, marca: $marca, modelo: $modelo, paquete: $paquete, ruta: $ruta)';
  }

  @override
  bool operator ==(covariant Viaje other) {
    if (identical(this, other)) return true;

    return other.id_vehiculo == id_vehiculo &&
        other.marca == marca &&
        other.modelo == modelo &&
        listEquals(other.paquete, paquete) &&
        listEquals(other.ruta, ruta);
  }

  @override
  int get hashCode {
    return id_vehiculo.hashCode ^
        marca.hashCode ^
        modelo.hashCode ^
        paquete.hashCode ^
        ruta.hashCode;
  }
}
