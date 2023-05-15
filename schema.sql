CREATE TABLE Ruta (
    id serial PRIMARY KEY not null,
    distancia VARCHAR(200) not null,
    nombre VARCHAR(200) not null,
    tiempo TIME not null
)

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

CREATE TABLE Vehiculo (
  id serial PRIMARY KEY not null,
  marca VARCHAR(200) not null,
  modelo VARCHAR(200) not null,
  disponible BOOLEAN DEFAULT true,
  placa VARCHAR(200) not null,
  cap_carga VARCHAR(200) not null
)

CREATE TABLE car_viaja (
    id_ruta INTEGER not null,
    id_vehiculo INTEGER not null,
    PRIMARY KEY (id_ruta, id_vehiculo),
    FOREIGN KEY (id_ruta) REFERENCES Ruta(id), 
    FOREIGN KEY (id_vehiculo) REFERENCES Vehiculo(id)
)

CREATE TABLE Empleado (
    id serial PRIMARY KEY not null,
    nombre VARCHAR(200) not null,
    num_licencia INTEGER not null,
    salario FLOAT not null,
    id_direccion INTEGER not null,
    FOREIGN KEY (id_direccion) REFERENCES Direccion(id)
)

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

CREATE TABLE Cliente (
    id serial PRIMARY KEY not null,
    nombre VARCHAR(200) not null,
    num_telefono VARCHAR(200) not null,
    email VARCHAR(200) not null,
    id_direccion INTEGER not null,
    FOREIGN KEY (id_direccion) REFERENCES Direccion(id)
)

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

CREATE TABLE Tarifa (
    id SERIAL PRIMARY KEY,
    peso FLOAT not null,
    cobro FLOAT not null,
    tamanio  FLOAT not null,
    id_direccion INTEGER not null,
    FOREIGN KEY (id_direccion) REFERENCES Direccion(id)
);

-- VIEW viajes_sin_finalizar
      CREATE VIEW viajes_sin_finalizar AS
      SELECT v.id AS id_vehiculo, p.id AS id_paquete, r.id AS id_ruta, d.id AS id_direccion
      FROM Vehiculo v
      INNER JOIN car_viaja cv ON v.id = cv.id_vehiculo
      INNER JOIN Ruta r ON cv.id_ruta = r.id
      INNER JOIN Direccion d ON r.id = d.ruta_id
      INNER JOIN Paquete p ON v.id = p.id_vehiculo AND d.id = p.id_direccion
      WHERE v.disponible = false AND p.entregado = false;

--Función asignar_cobro()
 CREATE OR REPLACE FUNCTION asignar_cobro() RETURNS TRIGGER AS $$
BEGIN
  SELECT cobro INTO NEW.cobro FROM Tarifa 
  WHERE id_direccion = NEW.id_direccion AND 
        peso >= NEW.peso AND 
        tamanio >= NEW.tamanio 
  ORDER BY cobro ASC LIMIT 1;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Trigger trigger_asignar_cobro
CREATE TRIGGER trigger_asignar_cobro
BEFORE INSERT ON Paquete
FOR EACH ROW
EXECUTE FUNCTION asignar_cobro();