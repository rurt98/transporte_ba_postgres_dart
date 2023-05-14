import 'dart:convert';

class Vehiculo {
  final int? id;
  final String? marca;
  final String? modelo;
  final String? cap_carga;
  final bool? disponible;
  Vehiculo({
    this.id,
    this.marca,
    this.modelo,
    this.cap_carga,
    this.disponible = true,
  });

  Vehiculo copyWith({
    int? id,
    String? marca,
    String? modelo,
    String? cap_carga,
    bool? disponible,
  }) {
    return Vehiculo(
      id: id ?? this.id,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      cap_carga: cap_carga ?? this.cap_carga,
      disponible: disponible ?? this.disponible,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'marca': marca,
      'modelo': modelo,
      'cap_carga': cap_carga,
    };
  }

  factory Vehiculo.fromMap(Map<String, dynamic> map) {
    return Vehiculo(
      id: map['id'].toInt() as int?,
      marca: map['marca'] as String?,
      modelo: map['modelo'] as String?,
      disponible: map['disponible'] as bool?,
      cap_carga: map['cap_carga'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory Vehiculo.fromJson(String source) =>
      Vehiculo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Vehiculo(id: $id, marca: $marca, modelo: $modelo, cap_carga: $cap_carga)';
  }

  @override
  bool operator ==(covariant Vehiculo other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.marca == marca &&
        other.modelo == modelo &&
        other.cap_carga == cap_carga;
  }

  @override
  int get hashCode {
    return id.hashCode ^ marca.hashCode ^ modelo.hashCode ^ cap_carga.hashCode;
  }
}
