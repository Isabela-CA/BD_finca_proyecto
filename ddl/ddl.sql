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

CREATE TABLE detalle_venta (
  id_detalle_venta INT AUTO_INCREMENT PRIMARY KEY,
  id_venta INT NOT NULL,
  id_producto INT NOT NULL,
  cantidad INT NOT NULL,
  precio_unitario DECIMAL(10, 0) NOT NULL,
  FOREIGN KEY (id_venta) REFERENCES venta(id_venta),
  FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
) AUTO_INCREMENT = 401;

CREATE TABLE compra (
  id_compra INT AUTO_INCREMENT PRIMARY KEY,
  id_proveedor INT NOT NULL,
  fecha_compra DATE NOT NULL,
  total DECIMAL(10, 0) NOT NULL,
  FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor)
) AUTO_INCREMENT = 451;

CREATE TABLE detalle_compra (
  id_detalle_compra INT AUTO_INCREMENT PRIMARY KEY,
  id_compra INT NOT NULL,
  id_producto INT NOT NULL,
  cantidad INT NOT NULL,
  precio_unitario DECIMAL(10, 0) NOT NULL,
  FOREIGN KEY (id_compra) REFERENCES compra(id_compra),
  FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
) AUTO_INCREMENT = 501;

CREATE TABLE produccion (
  id_produccion INT AUTO_INCREMENT PRIMARY KEY,
  id_producto INT NOT NULL,
  fecha_produccion DATE NOT NULL,
  cantidad_producida INT NOT NULL,
  id_empleado INT NOT NULL,
  id_maquinaria INT,
  FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
  FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado),
  FOREIGN KEY (id_maquinaria) REFERENCES maquinaria(id_maquinaria)
) AUTO_INCREMENT = 551;

CREATE TABLE lote (
  id_lote INT AUTO_INCREMENT PRIMARY KEY,
  id_produccion INT NOT NULL,
  tamaño_lote INT NOT NULL,
  cantidad_producida_unidad INT NOT NULL,
  FOREIGN KEY (id_produccion) REFERENCES produccion(id_produccion)
) AUTO_INCREMENT = 601;

CREATE TABLE costos (
  id_costos INT AUTO_INCREMENT PRIMARY KEY,
  id_empleado INT NOT NULL,
  id_maq INT,
  id_produccion INT NOT NULL,
  tipo VARCHAR(50) NOT NULL,
  monto DECIMAL(10,0) NOT NULL,
  fecha DATE NOT NULL,
  FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado),
  FOREIGN KEY (id_maq) REFERENCES maquinaria(id_maquinaria),
  FOREIGN KEY (id_produccion) REFERENCES produccion(id_produccion)
) AUTO_INCREMENT = 651;

CREATE TABLE empleado_maquinaria (
  id_empleado INT NOT NULL,
  id_maquinaria INT NOT NULL,
  fecha_operacion DATE NOT NULL,
  actividad_realizada VARCHAR(100) NOT NULL,
  FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado),
  FOREIGN KEY (id_maquinaria) REFERENCES maquinaria(id_maquinaria)
);

CREATE TABLE actividad_Laboral (
    id_actividad INT PRIMARY KEY,
    id_empleado INT,
    fecha DATE,
    descripcion VARCHAR(255),
    duracion_horas INT,
    area VARCHAR(50),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado)
)  AUTO_INCREMENT = 701;