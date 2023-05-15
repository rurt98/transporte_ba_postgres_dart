import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

class DbConnectionService extends ChangeNotifier {
  late PostgreSQLConnection postgreSQLConnection;

  // Status loading
  bool _isLoading = false;
  bool get loading => _isLoading;
  set loading(bool valor) {
    _isLoading = valor;
    notifyListeners();
  }

  DbConnectionService() {
    connectToDB().then(
      (_) => createSchema(),
    );
  }

  Future<PostgreSQLConnection> connectToDB() async {
    try {
      loading = true;
      postgreSQLConnection = PostgreSQLConnection(
        'localhost',
        5435,
        'barrancoDB',
        username: 'postgres',
        password: 'password',
      );

      await postgreSQLConnection.open();

      print("Se conecto con éxito");
    } catch (e) {
      print(e);
    }
    return postgreSQLConnection;
  }

  Future createSchema() async {
    try {
      // RUTA
      await postgreSQLConnection.query('''
CREATE TABLE Ruta (
    id serial PRIMARY KEY not null,
    distancia VARCHAR(200) not null,
    nombre VARCHAR(200) not null,
    tiempo TIME not null
)
    ''');

      // Dirección
      await postgreSQLConnection.query('''
CREATE TABLE Direccion (
    id serial PRIMARY KEY not null,
    frac_nombre VARCHAR(200) not null,
    calle VARCHAR(200) not null,
    cp VARCHAR(200) not null,
    colonia VARCHAR(200) not null,
    estado VARCHAR(200),
    municipio VARCHAR(200) not null,
    ruta_id INTEGER,
    FOREIGN KEY (ruta_id) REFERENCES Ruta(id)
)
    ''');

      // Vehículo
      await postgreSQLConnection.query('''
CREATE TABLE Vehiculo (
  id serial PRIMARY KEY not null,
  marca VARCHAR(200) not null,
  modelo VARCHAR(200) not null,
  disponible BOOLEAN DEFAULT true,
  placa VARCHAR(200) not null,
  cap_carga VARCHAR(200) not null
)
    ''');

      // Car_viaja
      await postgreSQLConnection.query('''
CREATE TABLE car_viaja (
    id_ruta INTEGER not null,
    id_vehiculo INTEGER not null,
    PRIMARY KEY (id_ruta, id_vehiculo),
    FOREIGN KEY (id_ruta) REFERENCES Ruta(id), 
    FOREIGN KEY (id_vehiculo) REFERENCES Vehiculo(id)
)
    ''');

      // Empleado
      await postgreSQLConnection.query('''
CREATE TABLE Empleado (
    id serial PRIMARY KEY not null,
    nombre VARCHAR(200) not null,
    num_licencia INTEGER not null,
    salario FLOAT not null,
    id_direccion INTEGER not null,
    FOREIGN KEY (id_direccion) REFERENCES Direccion(id)
)
    ''');

      // Empleado_maneja
      await postgreSQLConnection.query('''
CREATE TABLE Empleado_maneja (
    id_vehiculo INTEGER not null,
    id_empleado INTEGER not null,
    fecha_m TIMESTAMP not null,
    hr_salida TIMESTAMP not null, 
    hr_llegada TIMESTAMP not null,
    PRIMARY KEY (id_vehiculo, id_empleado),
    FOREIGN KEY (id_vehiculo) REFERENCES Vehiculo(id),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id)
)
    ''');

      // Cliente
      await postgreSQLConnection.query('''
CREATE TABLE Cliente (
    id serial PRIMARY KEY not null,
    nombre VARCHAR(200) not null,
    num_telefono VARCHAR(200) not null,
    email VARCHAR(200) not null,
    id_direccion INTEGER not null,
    FOREIGN KEY (id_direccion) REFERENCES Direccion(id)
)
    ''');

      // Paquete
      await postgreSQLConnection.query('''
CREATE TABLE Paquete (
    id serial PRIMARY KEY not null,
    peso FLOAT not null,
    tamanio FLOAT not null,
    f_ent_est TIMESTAMP not null,
    f_envio TIMESTAMP not null,
    cobro FLOAT,
    descripcion VARCHAR(200) not null,
    entregado BOOLEAN DEFAULT false,
    id_direccion INTEGER not null,
    id_cliente INTEGER not null,
    id_vehiculo INTEGER not null, 
    FOREIGN KEY (id_direccion) REFERENCES Direccion(id),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id),
    FOREIGN KEY (id_vehiculo) REFERENCES Vehiculo(id)
)
    ''');

      await postgreSQLConnection.query('''
CREATE TABLE Tarifa (
    id SERIAL PRIMARY KEY,
    peso FLOAT not null,
    cobro FLOAT not null,
    tamanio  FLOAT not null,
    id_direccion INTEGER not null,
    FOREIGN KEY (id_direccion) REFERENCES Direccion(id)
);
    ''');

      await postgreSQLConnection.query('''
      CREATE VIEW viajes_sin_finalizar AS
      SELECT v.id AS id_vehiculo, p.id AS id_paquete, r.id AS id_ruta, d.id AS id_direccion
      FROM Vehiculo v
      INNER JOIN car_viaja cv ON v.id = cv.id_vehiculo
      INNER JOIN Ruta r ON cv.id_ruta = r.id
      INNER JOIN Direccion d ON r.id = d.ruta_id
      INNER JOIN Paquete p ON v.id = p.id_vehiculo AND d.id = p.id_direccion
      WHERE v.disponible = false AND p.entregado = false;
    ''');

      await postgreSQLConnection.query('''
CREATE OR REPLACE FUNCTION asignar_cobro() RETURNS TRIGGER AS \$\$
BEGIN
  SELECT cobro INTO NEW.cobro FROM Tarifa 
  WHERE id_direccion = NEW.id_direccion AND 
        peso >= NEW.peso AND 
        tamanio >= NEW.tamanio 
  ORDER BY cobro ASC LIMIT 1;
  RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;
    ''');

      await postgreSQLConnection.query('''
CREATE TRIGGER trigger_asignar_cobro
BEFORE INSERT ON Paquete
FOR EACH ROW
EXECUTE FUNCTION asignar_cobro();
    ''');

      print("Se creo el schema");
    } catch (e) {
      print(e);
    }

    loading = false;
  }
}
