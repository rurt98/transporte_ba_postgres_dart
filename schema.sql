CREATE TABLE Ruta (
    id serial PRIMARY KEY not null,
    distancia VARCHAR(50) not null,
    nombre VARCHAR(100) not null,
    tiempo TIME not null
)

CREATE TABLE Direccion (
    id serial PRIMARY KEY not null,
    frac_nombre VARCHAR(50) not null,
    calle VARCHAR(50) not null,
    cp VARCHAR(10) not null,
    colonia VARCHAR(50) not null,
    estado VARCHAR(50),
    municipio VARCHAR(50) not null,
    ruta_id INTEGER,
    FOREIGN KEY (ruta_id) REFERENCES Ruta(id)
)

CREATE TABLE Vehiculo (
  id serial PRIMARY KEY not null,
  marca VARCHAR(50) not null,
  modelo VARCHAR(50) not null,
  disponible BOOLEAN DEFAULT true,
  cap_carga VARCHAR(50) not null
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
    nombre VARCHAR(50) not null,
    num_licencia INTEGER not null,
    salario FLOAT not null,
    id_direccion INTEGER not null,
    FOREIGN KEY (id_direccion) REFERENCES Direccion(id)
)

CREATE TABLE Empleado_maneja (
    id_vehiculo INTEGER not null,
    id_empleado INTEGER not null,
    hr_salida TIME not null,
    fecha_m DATE not null,
    hr_llegada TIME not null,
    PRIMARY KEY (id_vehiculo, id_empleado),
    FOREIGN KEY (id_vehiculo) REFERENCES Vehiculo(id),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id)
)

CREATE TABLE Cliente (
    id serial PRIMARY KEY not null,
    nombre VARCHAR(50) not null,
    num_telefono VARCHAR(15) not null,
    email VARCHAR(50) not null,
    id_direccion INTEGER not null,
    FOREIGN KEY (id_direccion) REFERENCES Direccion(id)
)

CREATE TABLE Paquete (
    id serial PRIMARY KEY not null,
    peso INTEGER not null,
    tamanio FLOAT not null,
    f_ent_est TIMESTAMP not null,
    f_envio TIMESTAMP not null,
    cobro FLOAT not null,
    entregado BOOLEAN DEFAULT false,
    id_direccion INTEGER not null,
    id_cliente INTEGER not null,
    id_vehiculo INTEGER not null, 
    FOREIGN KEY (id_direccion) REFERENCES Direccion(id),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id),
    FOREIGN KEY (id_vehiculo) REFERENCES Vehiculo(id)
)

CREATE TABLE Empleado_recibe (
    id_paquete INTEGER not null,
    id_empleado INTEGER not null,
    fecha DATE not null,
    hora TIME not null, 
    PRIMARY KEY (id_paquete, id_empleado),
    FOREIGN KEY (id_paquete) REFERENCES Paquete(id),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id)
)