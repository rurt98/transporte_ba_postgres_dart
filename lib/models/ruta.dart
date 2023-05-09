import 'dart:convert';

class Ruta {
  final int id;
  final String distancia;
  final String nombre;
  final String tiempo;
  Ruta({
    required this.id,
    required this.distancia,
    required this.nombre,
    required this.tiempo,
  });

  Ruta copyWith({
    int? id,
    String? distancia,
    String? nombre,
    String? tiempo,
  }) {
    return Ruta(
      id: id ?? this.id,
      distancia: distancia ?? this.distancia,
      nombre: nombre ?? this.nombre,
      tiempo: tiempo ?? this.tiempo,
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

  factory Ruta.fromMap(Map<String, dynamic> map) {
    return Ruta(
      id: map['id'],
      distancia: map['distancia'] as String,
      nombre: map['nombre'] as String,
      tiempo: map['tiempo'] as String,
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
