import 'dart:convert';

class Paquete {
  int? id;
  int? peso;
  int? tamanio;
  DateTime? fEntEst;
  DateTime? fEnvio;
  bool? entregado;
  double? costo;

  Paquete({
    this.id,
    this.peso,
    this.tamanio,
    this.fEntEst,
    this.fEnvio,
    this.entregado,
    this.costo,
  });

  Paquete copyWith({
    int? id,
    int? peso,
    int? tamanio,
    DateTime? fEntEst,
    DateTime? fEnvio,
    bool? entregado,
    double? costo,
  }) =>
      Paquete(
        id: id ?? this.id,
        peso: peso ?? this.peso,
        tamanio: tamanio ?? this.tamanio,
        fEntEst: fEntEst ?? this.fEntEst,
        fEnvio: fEnvio ?? this.fEnvio,
        entregado: entregado ?? this.entregado,
        costo: costo ?? this.costo,
      );

  factory Paquete.fromMap(Map<String, dynamic> json) => Paquete(
        id: json["id"],
        peso: json["peso"],
        tamanio: json["tamanio"],
        fEntEst: json["f_ent_est"] == null
            ? null
            : DateTime.parse(json["f_ent_est"]),
        fEnvio:
            json["f_envio"] == null ? null : DateTime.parse(json["f_envio"]),
        entregado: json["entregado"],
        costo: json['costo'],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "peso": peso,
        "tamanio": tamanio,
        "f_ent_est": fEntEst?.toIso8601String(),
        "f_envio": fEnvio?.toIso8601String(),
        "entregado": entregado,
        "costo": costo,
      };

  String toJson() => json.encode(toMap());

  factory Paquete.fromJson(String source) =>
      Paquete.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Paquete(id: $id, peso: $peso, tamanio: $tamanio)';

  @override
  bool operator ==(covariant Paquete other) {
    if (identical(this, other)) return true;

    return other.id == id && other.peso == peso && other.tamanio == tamanio;
  }

  @override
  int get hashCode => id.hashCode ^ peso.hashCode ^ tamanio.hashCode;
}
