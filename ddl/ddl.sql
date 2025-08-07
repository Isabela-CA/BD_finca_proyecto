CREATE database Finca_agricola;

USE Finca_agricola;

CREATE TABLE producto (
  id_producto INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  tipo ENUM('agrícola', 'ganadero', 'procesado') NOT NULL,
  unidad_medida VARCHAR(20) NOT NULL,
  precio DECIMAL(10, 0) NOT NULL
);

CREATE TABLE empleado (
  id_empleado INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(50),
  apellido VARCHAR(50),
  cargo VARCHAR(30),
  fecha_ingreso DATE,
  salario DECIMAL(10,0),
  area_asignada VARCHAR(30)
) AUTO_INCREMENT = 51;

CREATE TABLE maquinaria (
  id_maquinaria INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100),
  tipo VARCHAR(50),
  fecha_adquisicion DATE,
  estado ENUM('operativa', 'mantenimiento', 'fuera de servicio')
) AUTO_INCREMENT = 101;

CREATE TABLE mantenimiento_maquinaria (
    id_mantenimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_maquinaria INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    costo DECIMAL(10, 2) NOT NULL,
    descripcion TEXT,
    FOREIGN KEY (id_maquinaria) REFERENCES maquinaria(id_maquinaria)
) AUTO_INCREMENT = 151;

CREATE TABLE proveedor (
  id_proveedor INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  telefono VARCHAR(20),
  direccion VARCHAR(150),
  email VARCHAR(100)
) AUTO_INCREMENT = 201;

CREATE TABLE cliente (
  id_cliente INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  telefono VARCHAR(20),
  direccion VARCHAR(100),
  email VARCHAR(100)
) AUTO_INCREMENT = 251;

CREATE TABLE inventario (
  id_inventario INT PRIMARY KEY AUTO_INCREMENT,
  id_producto INT NOT NULL,
  cantidad_disponible DECIMAL(10, 0) NOT NULL,
  fecha_ultima_actualizacion DATE NOT NULL,
  FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
) AUTO_INCREMENT = 301;

CREATE TABLE venta (
  id_venta INT PRIMARY KEY AUTO_INCREMENT,
  id_cliente INT,
  fecha_venta DATE,
  total DECIMAL(10, 0),
  FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
) AUTO_INCREMENT = 351;