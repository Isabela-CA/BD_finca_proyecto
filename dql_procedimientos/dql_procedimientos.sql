-- 1. Actualizar_inventario_manual
-- Permite modificar manualmente el inventario de un producto en caso de ajustes o errores operativos.
DELIMITER //
CREATE PROCEDURE actualizar_inventario_manual(
    IN p_id_producto INT,
    IN p_nueva_cantidad DECIMAL(10,0)
)
BEGIN
    UPDATE inventario
    SET cantidad_disponible = p_nueva_cantidad,
        fecha_ultima_actualizacion = CURDATE()
    WHERE id_producto = p_id_producto;
END //
DELIMITER ;

CALL actualizar_inventario_manual(1, 50); -- Cambia el inventario del producto 1 a 50 unidades
SELECT * FROM inventario WHERE id_producto = 1;

-- 2. Ajustar_precio_producto
-- Cambia el precio de un producto en el catálogo, útil para actualizaciones por inflación o demanda.
DELIMITER //
CREATE PROCEDURE ajustar_precio_producto(
    IN p_id_producto INT,
    IN p_nuevo_precio DECIMAL(10,0)
)
BEGIN
    UPDATE producto
    SET precio = p_nuevo_precio
    WHERE id_producto = p_id_producto;
END //
DELIMITER ;

CALL ajustar_precio_producto(1, 1200); -- Cambia precio del producto 1 a 1200
SELECT * FROM producto WHERE id_producto = 1;

-- 3. Eliminar_empleado
-- Borra un empleado del sistema si no tiene registros vinculados (ventas, producción, etc.), garantizando integridad referencial.
DELIMITER //
CREATE PROCEDURE eliminar_empleado(IN p_id_empleado INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM produccion WHERE id_empleado = p_id_empleado) 
    AND NOT EXISTS (SELECT 1 FROM costos WHERE id_empleado = p_id_empleado) 
    AND NOT EXISTS (SELECT 1 FROM empleado_maquinaria WHERE id_empleado = p_id_empleado)
    AND NOT EXISTS (SELECT 1 FROM actividad_laboral WHERE id_empleado = p_id_empleado) THEN
        DELETE FROM empleado WHERE id_empleado = p_id_empleado;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar: el empleado tiene registros asociados.';
    END IF;
END //
DELIMITER ;

CALL eliminar_empleado(5); -- Intenta eliminar empleado con ID 5

-- 4. Consultar_ventas_cliente
-- Muestra el historial completo de ventas realizadas a un cliente específico, útil para reportes y atención comercial.
DELIMITER //
CREATE PROCEDURE consultar_ventas_cliente(IN p_id_cliente INT)
BEGIN
    SELECT v.id_venta, v.fecha_venta, p.nombre AS producto, dv.cantidad, dv.precio_unitario, (dv.cantidad * dv.precio_unitario) AS total
    FROM venta v
    JOIN detalle_venta dv ON v.id_venta = dv.id_venta
    JOIN producto p ON dv.id_producto = p.id_producto
    WHERE v.id_cliente = p_id_cliente
    ORDER BY v.fecha_venta DESC;
END //
DELIMITER ;

CALL consultar_ventas_cliente(2); -- Lista todas las ventas del cliente 2

-- 5. Consultar_produccion_empleado
-- Devuelve el historial de producción de un empleado determinado, incluyendo fechas y productos.
DELIMITER //
CREATE PROCEDURE consultar_produccion_empleado(IN p_id_empleado INT)
BEGIN
    SELECT pr.id_produccion, pr.fecha_produccion, p.nombre AS producto, pr.cantidad_producida
    FROM produccion pr
    JOIN producto p ON pr.id_producto = p.id_producto
    WHERE pr.id_empleado = p_id_empleado
    ORDER BY pr.fecha_produccion DESC;
END //
DELIMITER ;

CALL consultar_produccion_empleado(3); -- Muestra producción del empleado 3

-- 6. Incrementar_salario_area
-- Aplica un aumento porcentual de salario a todos los empleados de un área específica.
DELIMITER //
CREATE PROCEDURE incrementar_salario_area(
    IN p_area VARCHAR(30),
    IN p_porcentaje DECIMAL(5,2)
)
BEGIN
    UPDATE empleado
    SET salario = salario + (salario * p_porcentaje / 100)
    WHERE area_asignada = p_area;
END //
DELIMITER ;

CALL incrementar_salario_area('Cultivo', 10); -- Aumenta 10% a empleados de Cultivo
SELECT * FROM empleado WHERE area_asignada = 'Cultivo';

-- 7. Reporte_costos_por_periodo
-- Genera un resumen de todos los costos operativos registrados entre dos fechas.
DELIMITER //
CREATE PROCEDURE reporte_costos_por_periodo(
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    SELECT tipo, SUM(monto) AS total_costos
    FROM costos
    WHERE fecha BETWEEN p_fecha_inicio AND p_fecha_fin
    GROUP BY tipo
    ORDER BY total_costos DESC;
END //
DELIMITER ;

CALL reporte_costos_por_periodo('2025-01-01', '2025-03-31');

-- 8. Restaurar_estado_maquinaria_todas
-- Restaura a "operativa" todas las maquinarias que actualmente están en "mantenimiento" y ya han finalizado su mantenimiento.
DELIMITER //
CREATE PROCEDURE restaurar_estado_maquinaria_todas()
BEGIN
    UPDATE maquinaria m
    JOIN mantenimiento_maquinaria mm ON m.id_maquinaria = mm.id_maquinaria
    SET m.estado = 'operativa'
    WHERE m.estado = 'mantenimiento' AND mm.fecha_fin <= CURDATE();
END //
DELIMITER ;

CALL restaurar_estado_maquinaria_todas();
SELECT * FROM maquinaria;

-- 9. Inicializar_inventario_producto
-- Crea un registro de inventario inicial para un nuevo producto agregado.
DELIMITER //
CREATE PROCEDURE inicializar_inventario_producto(
    IN p_id_producto INT,
    IN p_cantidad DECIMAL(10,0)
)
BEGIN
    INSERT INTO inventario (id_producto, cantidad_disponible, fecha_ultima_actualizacion)
    VALUES (p_id_producto, p_cantidad, CURDATE());
END //
DELIMITER ;

CALL inicializar_inventario_producto(8, 100); -- Crea inventario inicial de producto 8
SELECT * FROM inventario WHERE id_producto = 8;

-- 10. Actualizar_datos_cliente
-- Modifica los datos de contacto de un cliente (teléfono, dirección o email) en caso de cambios.
DELIMITER //
CREATE PROCEDURE actualizar_datos_cliente(
    IN p_id_cliente INT,
    IN p_telefono VARCHAR(20),
    IN p_direccion VARCHAR(100),
    IN p_email VARCHAR(100)
)
BEGIN
    UPDATE cliente
    SET telefono = p_telefono,
        direccion = p_direccion,
        email = p_email
    WHERE id_cliente = p_id_cliente;
END //
DELIMITER ;

CALL actualizar_datos_cliente(3, '555-987654', 'Nueva dirección', 'nuevo@email.com');
SELECT * FROM cliente WHERE id_cliente = 3;

-- 11. registrar una venta 

DELIMITER $$

CREATE PROCEDURE registrarVenta(
    IN p_id_cliente INT,
    IN p_fecha_venta DATE,
    IN p_id_producto INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_id_venta INT;
    DECLARE v_precio_unitario DECIMAL(10,0);
    DECLARE v_total_venta DECIMAL(10,0);
    DECLARE v_stock_actual INT;

    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL; -- vuelve a lanzar el error para que se muestre
    END;

    START TRANSACTION;
    

    SELECT cantidad_disponible INTO v_stock_actual
    FROM inventario
    WHERE id_producto = p_id_producto;

    IF v_stock_actual IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto no encontrado en inventario';
    END IF;

    IF v_stock_actual < p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente';
    END IF;
    
    -- Insertar la venta que inicie desde 0
    INSERT INTO venta(id_cliente, fecha_venta, total) 
    VALUES (p_id_cliente, p_fecha_venta, 0);
    SET v_id_venta = LAST_INSERT_ID();
    
    -- Obtener precio unitario del producto
    SELECT precio INTO v_precio_unitario 
    FROM producto 
    WHERE id_producto = p_id_producto;
    
    -- Insertar detalle venta
    INSERT INTO detalle_venta(id_venta, id_producto, cantidad, precio_unitario)
    VALUES (v_id_venta, p_id_producto, p_cantidad, v_precio_unitario);
    
    -- Actualizar inventario
    UPDATE inventario
    SET cantidad_disponible = cantidad_disponible - p_cantidad,
        fecha_ultima_actualizacion = p_fecha_venta
    WHERE id_producto = p_id_producto;
    
    -- Calcular total venta
    SET v_total_venta = v_precio_unitario * p_cantidad;
    
    -- Actualizar total
    UPDATE venta 
    SET total = v_total_venta 
    WHERE id_venta = v_id_venta;
    
    COMMIT;
END$$

DELIMITER ;

SHOW PROCEDURE STATUS WHERE Db = 'finca_agricola';
CALL registrarVenta(2 , '2024-06-23', 255, 10);
CALL registrarVenta(255 , '2024-06-23', 44, 800);


-- 12. registrar una compra
DELIMITER $$

CREATE PROCEDURE registrarCompra(
    IN p_id_proveedor INT,
    IN p_fecha_compra DATE,
    IN p_id_producto INT,
    IN p_cantidad INT,
    IN p_precio_unitario DECIMAL(10,0)
)
BEGIN
    DECLARE v_id_compra INT;
    DECLARE v_total_compra DECIMAL(10,0);
    DECLARE v_exist_proveedor INT;
    DECLARE v_exist_producto INT;

    -- manejo de errores: revierte y vuelve a lanzar
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Validar que el proveedor exista
    SELECT COUNT(*) INTO v_exist_proveedor
    FROM proveedor
    WHERE id_proveedor = p_id_proveedor;

    IF v_exist_proveedor = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Proveedor no encontrado';
    END IF;

    -- Validar que el producto exista
    SELECT COUNT(*) INTO v_exist_producto
    FROM inventario
    WHERE id_producto = p_id_producto;

    IF v_exist_producto = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto no se encontro en el inventario';
    END IF;

    -- Insertar compra que inicie desde 0
    INSERT INTO compra(id_proveedor, fecha_compra, total)
    VALUES (p_id_proveedor, p_fecha_compra, 0);
    SET v_id_compra = LAST_INSERT_ID();

    -- Insertar detalle de compra
    INSERT INTO detalle_compra(id_compra, id_producto, cantidad, precio_unitario)
    VALUES (v_id_compra, p_id_producto, p_cantidad, p_precio_unitario);

    -- Actualizar inventario (sumar cantidad)
    UPDATE inventario
    SET cantidad_disponible = cantidad_disponible + p_cantidad,
        fecha_ultima_actualizacion = p_fecha_compra
    WHERE id_producto = p_id_producto;

    -- Calcular total de la compra
    SET v_total_compra = p_cantidad * p_precio_unitario;

    -- Actualizar total en compra
    UPDATE compra
    SET total = v_total_compra
    WHERE id_compra = v_id_compra;

    COMMIT;
END$$

DELIMITER ;

SHOW PROCEDURE STATUS WHERE Db = 'Finca_agricola';
CALL registrarCompra(9999, '2025-08-09', 3, 10, 3500);
call registrarCompra(217 , '2025-08-09', 100, 10, 3500);


-- 13. registrar empleado

DELIMITER $$

CREATE PROCEDURE registroEmpleado(
    IN p_nombre VARCHAR(50),
    IN p_apellido VARCHAR(50),
    IN p_cargo VARCHAR(30),
    IN p_fecha_ingreso DATE,
    IN p_salario DECIMAL(10,0),
    IN p_area_asignada VARCHAR(30)
)
BEGIN
    -- Manejador de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF p_nombre IS NULL OR p_apellido IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nombre y apellido son obligatorios';
    END IF;

    IF p_salario < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El salario no puede ser negativo';
    END IF;

    INSERT INTO empleado(nombre, apellido, cargo, fecha_ingreso, salario, area_asignada)
    VALUES (p_nombre, p_apellido, p_cargo, p_fecha_ingreso, p_salario, p_area_asignada);

    COMMIT;
END$$

DELIMITER ;

SHOW PROCEDURE STATUS WHERE Db = 'finca_agricola';
CALL registroEmpleado('Laura','Gómez','Ingeniera Agrónoma', '2025-08-09', -3500000,'Producción');
CALL registroEmpleado(NULL,'Gómez','Ingeniera Agrónoma','2025-08-09',3500000,'Producción');

-- 14. registrar proveedor

DELIMITER $$

CREATE PROCEDURE registrarProveedor(
    IN p_nombre VARCHAR(50),
    IN p_contacto VARCHAR(50),
    IN p_telefono VARCHAR(20),
    IN p_direccion VARCHAR(100)
)
BEGIN
    -- Manejador de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Validaciones
    IF p_nombre IS NULL OR p_nombre = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del proveedor es obligatorio';
    END IF;

    IF p_telefono IS NOT NULL AND LENGTH(p_telefono) < 7 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El teléfono es demasiado corto';
    END IF;

    -- Insertar proveedor
    INSERT INTO proveedor(nombre, contacto, telefono, direccion)
    VALUES (p_nombre, p_contacto, p_telefono, p_direccion);

    COMMIT;
END$$

DELIMITER ;


drop procedure registrarProveedor;
SHOW PROCEDURE STATUS WHERE Db = 'finca_agricola';
call registrarProveedor('' , 'carlos Pérez', 2367323625,'Calle 12 #45-67');
CALL registrarProveedor('Agroinsumos del Valle', 'juan martinez','31290', 'Calle 24 #45-62');


-- 15. actualizar estado de maquinaria

DELIMITER $$

CREATE PROCEDURE actualizarEstadoMaquinaria(
    IN p_id_maquinaria INT,
    IN p_nuevo_estado VARCHAR(20)
)
BEGIN
    DECLARE v_existencia INT;

    -- Manejador de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Validar que la maquinaria exista
    SELECT COUNT(*) INTO v_existencia
    FROM maquinaria
    WHERE id_maquinaria = p_id_maquinaria;

    IF v_existencia = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Maquinaria no encontrada';
    END IF;

    -- Validar que el estado no esté vacío
    IF p_nuevo_estado IS NULL OR p_nuevo_estado = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado no puede estar vacío';
    END IF;

    -- Actualizar estado
    UPDATE maquinaria
    SET estado = p_nuevo_estado
    WHERE id_maquinaria = p_id_maquinaria;

    COMMIT;
END$$

DELIMITER ;

CALL actualizarEstadoMaquinaria( 200, 'Operativa');
CALL actualizarEstadoMaquinaria( 100, '');


-- 16. registrar mantenimiento

DELIMITER $$

CREATE PROCEDURE registrarMantenimiento(
    IN p_id_maquinaria INT,
    IN p_fecha DATE,
    IN p_tipo VARCHAR(30),
    IN p_descripcion TEXT,
    IN p_costo DECIMAL(10,0),
    IN p_estado VARCHAR(20)
)
BEGIN
    DECLARE v_existencia_maquinaria INT;

    -- Manejador de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Validar que la maquinaria exista
    SELECT COUNT(*) INTO v_existencia_maquinaria
    FROM maquinaria
    WHERE id_maquinaria = p_id_maquinaria;

    IF v_existencia_maquinaria = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Maquinaria no encontrada';
    END IF;

    -- Validar costo
    IF p_costo < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El costo no puede ser negativo';
    END IF;

    -- Insertar mantenimiento
    INSERT INTO mantenimiento(id_maquinaria, fecha, tipo, descripcion, costo, estado)
    VALUES (p_id_maquinaria, p_fecha, p_tipo, p_descripcion, p_costo, p_estado);

    COMMIT;
END$$

DELIMITER ;

CALL registrarMantenimiento(200,'2025-07-09','Preventivo', 'Cambio de aceite', 450000,'Completado');
CALL registrarMantenimiento(140,'2025-07-09','Preventivo', 'Cambio de aceite', -450000,'Completado');

-- 17. finalizar mantenimiento a una maquinaria 
DELIMITER $$

CREATE PROCEDURE finalizarMantenimiento(
    IN p_id_mantenimiento INT,
    IN p_fecha_fin DATE,
    IN p_estado_maquinaria VARCHAR(20)
)
BEGIN
    DECLARE v_id_maquinaria INT;
    DECLARE v_existencia_mant INT;

    -- Manejador de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Verificar que el mantenimiento exista
    SELECT COUNT(*)
    INTO v_existencia_mant
    FROM mantenimiento_maquinaria
    WHERE id_mantenimiento = p_id_mantenimiento;

    IF v_existencia_mant = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mantenimiento no encontrado';
    END IF;

    -- Obtener la maquinaria asociada
    SELECT id_maquinaria
    INTO v_id_maquinaria
    FROM mantenimiento_maquinaria
    WHERE id_mantenimiento = p_id_mantenimiento;

    -- Actualizar el mantenimiento como finalizado
    UPDATE mantenimiento
    SET estado = 'Completado',
        fecha = p_fecha_fin
    WHERE id_mantenimiento = p_id_mantenimiento;

    -- Actualizar el estado de la maquinaria
    UPDATE maquinaria
    SET estado = p_estado_maquinaria
    WHERE id_maquinaria = v_id_maquinaria;

    COMMIT;
END$$

DELIMITER ;

SHOW PROCEDURE STATUS WHERE Db = 'finca_agricola';
CALL finalizarMantenimiento(100,'2025-08-09','Operativa');

-- 18. registrar actividad laboral

DELIMITER $$

CREATE PROCEDURE registrarActividadLaboral(
    IN p_id_empleado INT,
    IN p_fecha DATE,
    IN p_descripcion TEXT,
    IN p_horas_trabajadas DECIMAL(5,2),
    IN p_estado VARCHAR(20)
)
BEGIN
    DECLARE v_existencia_empleado INT;

    -- Manejador de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Validar que el empleado exista
    SELECT COUNT(*)
    INTO v_existencia_empleado
    FROM empleado
    WHERE id_empleado = p_id_empleado;

    IF v_existencia_empleado = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Empleado no encontrado';
    END IF;

    -- Validar fecha
    IF p_fecha IS NULL OR p_fecha > CURRENT_DATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fecha inválida';
    END IF;

    -- Validar descripción
    IF p_descripcion IS NULL OR p_descripcion = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La descripción es obligatoria';
    END IF;

    -- Validar horas trabajadas
    IF p_horas_trabajadas < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Las horas trabajadas no pueden ser negativas';
    END IF;

    -- Insertar actividad
    INSERT INTO actividad_laboral(id_empleado, fecha, descripcion, horas_trabajadas, estado)
    VALUES (p_id_empleado, p_fecha, p_descripcion, p_horas_trabajadas, p_estado);

    COMMIT;
END$$

DELIMITER ;

CALL registrarActividadLaboral( 20, '2025-05-09','Siembra de hortalizas', 8 ,'Completada');
CALL registrarActividadLaboral( 55, '2035-05-09','Siembra de hortalizas', 5 ,'Completada');
CALL registrarActividadLaboral( 60, '2025-05-09','', 8 ,'Completada');
CALL registrarActividadLaboral( 75, '2025-05-09','Siembra de hortalizas', -2 ,'Completada');


-- 19. asignar maquinaria a empleado

DELIMITER $$

CREATE PROCEDURE asignarMaquinariaEmpleado(
    IN p_id_empleado INT,
    IN p_id_maquinaria INT,
    IN p_fecha_asignacion DATE,
    IN p_observaciones TEXT
)
BEGIN
    DECLARE v_existencia_empleado INT;
    DECLARE v_existencia_maquinaria INT;

    -- Manejador de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Validar que el empleado exista
    SELECT COUNT(*) INTO v_existencia_empleado
    FROM empleado
    WHERE id_empleado = p_id_empleado;

    IF v_existencia_empleado = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Empleado no encontrado';
    END IF;

    -- Validar que la maquinaria exista
    SELECT COUNT(*) INTO v_existencia_maquinaria
    FROM maquinaria
    WHERE id_maquinaria = p_id_maquinaria;

    IF v_existencia_maquinaria = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Maquinaria no encontrada';
    END IF;

    -- Validar fecha
    IF p_fecha_asignacion IS NULL OR p_fecha_asignacion > CURRENT_DATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fecha de asignación inválida';
    END IF;

    -- Insertar asignación
    INSERT INTO asignacion_maquinaria(id_empleado, id_maquinaria, fecha_asignacion, observaciones)
    VALUES (p_id_empleado, p_id_maquinaria, p_fecha_asignacion, p_observaciones);

    COMMIT;
END$$

DELIMITER ;
CALL asignarMaquinariaEmpleado( 110,120,'2025-08-09',' Riego de cultivo ');
CALL asignarMaquinariaEmpleado( 100,7,'2025-08-09','Asignada para labores de arado en el lote 5');
CALL asignarMaquinariaEmpleado( 100,120,'2036-01-03','Riego de cultivo');

-- 20. registrar produccion 
DELIMITER $$

CREATE PROCEDURE registrarProduccion(
    IN p_fecha DATE,
    IN p_id_lote INT,
    IN p_cantidad DECIMAL(10,2),
    IN p_unidad_medida VARCHAR(20),
    IN p_estado VARCHAR(20),
    IN p_observaciones TEXT
)
BEGIN
    DECLARE v_existencia_lote INT;

    -- Manejador de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Validar que el lote exista
    SELECT COUNT(*) INTO v_existencia_lote
    FROM lote
    WHERE id_lote = p_id_lote;

    IF v_existencia_lote = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lote no encontrado';
    END IF;

    -- Validar fecha
    IF p_fecha IS NULL OR p_fecha > CURRENT_DATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fecha inválida';
    END IF;

    -- Validar cantidad
    IF p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad debe ser mayor a cero';
    END IF;

    -- Insertar producción
    INSERT INTO produccion(fecha, id_lote, cantidad, unidad_medida, estado, observaciones)
    VALUES (p_fecha, p_id_lote, p_cantidad, p_unidad_medida, p_estado, p_observaciones);

    COMMIT;
END$$

DELIMITER ;

CALL registrarProduccion('2025-02-09',200,1200,'kg','Completada','Cosecha de tomates');
CALL registrarProduccion('2023-02-09',620,0,'kg','Completada','Cosecha de tomates');
CALL registrarProduccion('2028-02-09',630,1200,'kg','Completada','Cosecha de tomates');
