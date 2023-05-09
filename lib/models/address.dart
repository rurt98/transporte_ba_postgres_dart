import 'dart:convert';

class Address {
  final int id;
  final String frac_nombre;
  final String calle;
  final String cp;
  final String colonia;
  final String estado;
  final String municipio;
  int? ruta_id;

  Address({
    required this.id,
    required this.frac_nombre,
    required this.calle,
    required this.cp,
    required this.colonia,
    required this.estado,
    required this.municipio,
    this.ruta_id,
  });

  Address copyWith({
    int? id,
    String? frac_nombre,
    String? calle,
    String? cp,
    String? colonia,
    String? estado,
    String? municipio,
    int? ruta_id,
  }) {
    return Address(
      id: id ?? this.id,
      frac_nombre: frac_nombre ?? this.frac_nombre,
      calle: calle ?? this.calle,
      cp: cp ?? this.cp,
      colonia: colonia ?? this.colonia,
      estado: estado ?? this.estado,
      municipio: municipio ?? this.municipio,
      ruta_id: ruta_id ?? this.ruta_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'frac_nombre': frac_nombre,
      'calle': calle,
      'cp': cp,
      'colonia': colonia,
      'estado': estado,
      'municipio': municipio,
      'ruta_id': ruta_id,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'].toInt() as int,
      frac_nombre: map['frac_nombre'] as String,
      calle: map['calle'] as String,
      cp: map['cp'] as String,
      colonia: map['colonia'] as String,
      estado: map['estado'] as String,
      municipio: map['municipio'] as String,
      ruta_id: map['ruta_id'] == null ? null : map['ruta_id'].toInt() as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Address.fromJson(String source) =>
      Address.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Address(id: $id, frac_nombre: $frac_nombre, calle: $calle, cp: $cp, colonia: $colonia, estado: $estado, municipio: $municipio, ruta_id: $ruta_id)';
  }

  @override
  bool operator ==(covariant Address other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.frac_nombre == frac_nombre &&
        other.calle == calle &&
        other.cp == cp &&
        other.colonia == colonia &&
        other.estado == estado &&
        other.municipio == municipio &&
        other.ruta_id == ruta_id;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        frac_nombre.hashCode ^
        calle.hashCode ^
        cp.hashCode ^
        colonia.hashCode ^
        estado.hashCode ^
        municipio.hashCode ^
        ruta_id.hashCode;
  }
}
