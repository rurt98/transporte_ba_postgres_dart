import 'dart:convert';

import 'package:paqueteria_barranco/models/address.dart';

class Cliente {
  final int id;
  final String nombre;
  final String num_telefono;
  final String email;
  final Address address;
  Cliente({
    required this.id,
    required this.nombre,
    required this.num_telefono,
    required this.email,
    required this.address,
  });

  Cliente copyWith({
    int? id,
    String? nombre,
    String? num_telefono,
    String? email,
    Address? address,
  }) {
    return Cliente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      num_telefono: num_telefono ?? this.num_telefono,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nombre': nombre,
      'num_telefono': num_telefono,
      'email': email,
      'address': address.toMap(),
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'].toInt() as int,
      nombre: map['nombre'] as String,
      num_telefono: map['num_telefono'] as String,
      email: map['email'] as String,
      address: Address.fromMap(map['address'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory Cliente.fromJson(String source) =>
      Cliente.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Cliente(id: $id, nombre: $nombre, num_telefono: $num_telefono, email: $email, address: $address)';
  }

  @override
  bool operator ==(covariant Cliente other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.nombre == nombre &&
        other.num_telefono == num_telefono &&
        other.email == email &&
        other.address == address;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nombre.hashCode ^
        num_telefono.hashCode ^
        email.hashCode ^
        address.hashCode;
  }
}
