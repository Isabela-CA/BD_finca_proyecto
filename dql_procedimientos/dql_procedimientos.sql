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