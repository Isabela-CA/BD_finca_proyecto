-- 1. Calcular_rendimiento_promedio_producto(id_producto)
-- Devuelve el rendimiento promedio (cantidad producida) por producción registrada para un producto específico.
DELIMITER //
CREATE FUNCTION calcular_rendimiento_promedio_producto(pid INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(10,2);
    SELECT AVG(cantidad_producida) INTO promedio
    FROM produccion
    WHERE id_producto = pid;
    RETURN IFNULL(promedio,0);
END //
DELIMITER ;
DROP FUNCTION calcular_rendimiento_promedio_producto;

SELECT calcular_rendimiento_promedio_producto(1);

-- 2. Total_costos_por_empleado(id_empleado)
-- Calcula el total acumulado de costos en los que ha incurrido un empleado específico, útil para evaluar su impacto financiero.

DELIMITER //
CREATE FUNCTION total_costos_por_empleado(pid INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(monto) INTO total
    FROM costos
    WHERE id_empleado = pid;
    RETURN IFNULL(total,0);
END //
DELIMITER ;

SELECT total_costos_por_empleado(3);

-- 3. Costo_operativo_total_periodo(fecha_inicio, fecha_fin)
-- Retorna el total de costos operativos (mano de obra, maquinaria, producción) dentro de un rango de fechas determinado.

DELIMITER //
CREATE FUNCTION costo_operativo_total_periodo(f_ini DATE, f_fin DATE)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(monto) INTO total
    FROM costos
    WHERE fecha BETWEEN f_ini AND f_fin;
    RETURN IFNULL(total,0);
END //
DELIMITER ;

SELECT costo_operativo_total_periodo('2025-01-01','2025-03-31');

-- 4. Promedio_mantenimiento_maquinaria(id_maquinaria)
-- Devuelve el costo promedio de mantenimiento para una maquinaria específica.
    
DELIMITER //
CREATE FUNCTION promedio_mantenimiento_maquinaria(pid INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(10,2);
    SELECT AVG(monto) INTO promedio
    FROM costos
    WHERE id_maq = pid;
    RETURN IFNULL(promedio,0);
END //
DELIMITER ;

SELECT promedio_mantenimiento_maquinaria(2);

-- 5. Total_produccion_por_mes(anio, mes)
-- Calcula la cantidad total de productos producidos en un mes y año específicos.

DELIMITER //
CREATE FUNCTION total_produccion_por_mes(anio INT, mes INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(cantidad_producida) INTO total
    FROM produccion
    WHERE YEAR(fecha_produccion) = anio
    AND MONTH(fecha_produccion) = mes;
    RETURN IFNULL(total,0);
END //
DELIMITER ;
DROP FUNCTION total_produccion_por_mes;

SELECT total_produccion_por_mes(2025, 7);

-- 6. Ventas_totales_producto(id_producto)
-- Suma todas las ventas (en valor) generadas por un producto determinado.

DELIMITER //
CREATE FUNCTION ventas_totales_producto(pid INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(dv.cantidad * dv.precio_unitario) INTO total
    FROM detalle_venta dv
    WHERE id_producto = pid;
    RETURN IFNULL(total,0);
END //
DELIMITER ;

SELECT ventas_totales_producto(4);

-- 7. Compras_totales_producto(id_producto)
-- Devuelve el total gastado en compras de un producto específico a lo largo del tiempo.
    
DELIMITER //
CREATE FUNCTION compras_totales_producto(pid INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(dc.cantidad * dc.precio_unitario) INTO total
    FROM detalle_compra dc
    WHERE id_producto = pid;
    RETURN IFNULL(total,0);
END //
DELIMITER ;

SELECT compras_totales_producto(4);

-- 8. Inventario_actual_producto(id_producto)
-- Retorna la cantidad de inventario disponible del producto en su última actualización.

 DELIMITER //
CREATE FUNCTION inventario_actual_producto(pid INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE stock INT;
    SELECT cantidad_disponible INTO stock
    FROM inventario
    WHERE id_producto = pid
    ORDER BY fecha_ultima_actualizacion DESC
    LIMIT 1;
    RETURN IFNULL(stock,0);
END //
DELIMITER ;
DROP FUNCTION inventario_actual_producto;

SELECT inventario_actual_producto(5);

-- 9. Total_horas_laboradas_empleado(id_empleado)
-- Suma todas las horas de trabajo registradas por un empleado en la tabla de actividades laborales.
    
DELIMITER //
CREATE FUNCTION total_horas_laboradas_empleado(pid INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(duracion_horas) INTO total
    FROM actividad_laboral
    WHERE id_empleado = pid;
    RETURN IFNULL(total,0);
END //
DELIMITER ;

SELECT total_horas_laboradas_empleado(3);

-- 10. Costo_por_unidad_producida(id_producto) 
-- Calcula el costo promedio de producción por unidad de producto, dividiendo el costo total entre las unidades producidas.

DELIMITER //
CREATE FUNCTION costo_por_unidad_producida(pid INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_costo DECIMAL(10,2);
    DECLARE total_unidades DECIMAL(10,2);

    -- Sumar costos asociados a las producciones del producto
    SELECT SUM(c.monto) INTO total_costo
    FROM costos c
    JOIN produccion pr ON c.id_produccion = pr.id_produccion
    WHERE pr.id_producto = pid;

    -- Sumar todas las unidades producidas
    SELECT SUM(pr.cantidad_producida) INTO total_unidades
    FROM produccion pr
    WHERE pr.id_producto = pid;

    RETURN IFNULL(total_costo / NULLIF(total_unidades,0), 0);
END //
DELIMITER ;
DROP FUNCTION costo_por_unidad_producida;

SELECT costo_por_unidad_producida(2);