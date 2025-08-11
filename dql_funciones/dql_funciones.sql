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

-- 11. productos sin ventas 

DELIMITER $$

CREATE FUNCTION productos_sin_ventas()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_sin_ventas INT;

    SELECT COUNT(*) INTO total_sin_ventas
    FROM producto p
    WHERE p.id_producto NOT IN (
        SELECT DISTINCT dv.id_producto
        FROM detalle_venta dv
    );

    RETURN total_sin_ventas;
END$$

DELIMITER ;

SELECT productos_sin_ventas() AS total_sin_ventas;

-- 12. monto_total_ventas_periodo
DELIMITER $$

CREATE FUNCTION monto_total_ventas(
    p_fecha_venta DATE
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE suma_total DECIMAL(10,2);

    SELECT IFNULL(SUM(total), 0)
    INTO suma_total
    FROM venta
    WHERE fecha_venta = p_fecha_venta;

    RETURN suma_total;
END$$

DELIMITER ;

SELECT monto_total_ventas('2025-07-28') AS total_ventas;

-- 13. productos_por_tipo(tipo_producto)
DELIMITER $$

CREATE FUNCTION productos_por_tipo(
    p_tipo VARCHAR(50)
)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_productos INT;

    SELECT COUNT(*) 
    INTO total_productos
    FROM producto
    WHERE tipo = p_tipo;

    RETURN total_productos;
END$$

DELIMITER ;

SELECT productos_por_tipo('agrícola') AS total_agricolas;
SELECT productos_por_tipo('ganadero') AS total_ganaderos;
SELECT productos_por_tipo('procesado') AS total_procesados;

-- 14. empleados_por_area(area_asignada)

DELIMITER $$

CREATE FUNCTION empleados_por_area(
    p_area_asignada VARCHAR(50)
)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_empleados INT;

    SELECT COUNT(*) 
    INTO total_empleados
    FROM empleado
    WHERE area_asignada = p_area_asignada;

    RETURN total_empleados;
END$$

DELIMITER ;

SELECT empleados_por_area('cultivo') AS total_cultivo;
SELECT empleados_por_area('logística') AS total_logistica;

-- 15. maquinaria_en_uso_actual

DELIMITER $$

CREATE FUNCTION maquinaria_en_uso_actual()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_maquinarias INT;

    SELECT COUNT(*)
    INTO total_maquinarias
    FROM maquinaria
    WHERE estado = 'operativa';

    RETURN total_maquinarias;
END$$

DELIMITER ;

SELECT maquinaria_en_uso_actual() AS total_operativas;

-- 16. ganancia_neta_mensual

DELIMITER $$

CREATE FUNCTION ganancia_neta_mensual(
    p_anio INT,
    p_mes INT
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_ventas DECIMAL(10,2);
    DECLARE total_compras DECIMAL(10,2);
    DECLARE ganancia_neta DECIMAL(10,2);

    -- Total de ventas del mes
    SELECT IFNULL(SUM(total), 0)
    INTO total_ventas
    FROM venta
    WHERE YEAR(fecha_venta) = p_anio
      AND MONTH(fecha_venta) = p_mes;

    -- Total de compras del mes
    SELECT IFNULL(SUM(total), 0)
    INTO total_compras
    FROM compra
    WHERE YEAR(fecha_compra) = p_anio
      AND MONTH(fecha_compra) = p_mes;

    -- Calcular ganancia neta
    SET ganancia_neta = total_ventas - total_compras;

    RETURN ganancia_neta;
END$$

DELIMITER ;


SELECT ganancia_neta_mensual(2025, 7) AS ganancia;

-- 17. actividad_mas_frecuente_empleado

DELIMITER $$

CREATE FUNCTION actividad_mas_frecuente_empleado(
    p_id_empleado INT
)
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE actividad_frecuente VARCHAR(255);

    SELECT descripcion
    INTO actividad_frecuente
    FROM actividad_laboral
    WHERE id_empleado = p_id_empleado
    GROUP BY descripcion
    ORDER BY COUNT(*) DESC
    LIMIT 1;

    RETURN actividad_frecuente;
END$$

DELIMITER ;

SELECT actividad_mas_frecuente_empleado(56) AS actividad_mas_frecuente;



-- 18. cantidad_veces_maquinaria_usada
DELIMITER //

CREATE FUNCTION cantidad_veces_maquinaria_usada(maquinaria_id INT) 
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total_usos INT DEFAULT 0;
    
    -- Contar usos en empleado_maquinaria
    SELECT COUNT(*) INTO total_usos
    FROM empleado_maquinaria
    WHERE id_maquinaria = maquinaria_id;
    
    -- Sumar usos en produccion (si no es NULL)
    SELECT total_usos + COUNT(*) INTO total_usos
    FROM produccion
    WHERE id_maquinaria = maquinaria_id AND id_maquinaria IS NOT NULL;
    
    RETURN total_usos;
END //

DELIMITER ;


SELECT cantidad_veces_maquinaria_usada(150) AS veces_usada;


-- 19. promedio_precio_compra_producto

DELIMITER //

CREATE FUNCTION promedio_precio_compra_producto(producto_id INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE precio_promedio DECIMAL(10,2) DEFAULT 0.00;
    
    -- Calcular el promedio de precio_unitario para el producto en todas las compras
    SELECT IFNULL(AVG(dc.precio_unitario), 0) INTO precio_promedio
    FROM detalle_compra dc
    WHERE dc.id_producto = producto_id;
    
    RETURN precio_promedio;
END //

DELIMITER ;

SELECT promedio_precio_compra_producto(6) AS precio_promedio_compra;

-- 20. porcentaje_utilizacion_maquinaria
DELIMITER //

CREATE FUNCTION porcentaje_utilizacion_maquinaria(maquinaria_id INT) 
RETURNS DECIMAL(5,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE dias_operativos INT;
    DECLARE dias_totales INT;
    DECLARE porcentaje DECIMAL(5,2) DEFAULT 0.00;
    
    -- Calcular días operativos (producciones + operaciones de empleados)
    SELECT COUNT(DISTINCT fecha_operacion) INTO dias_operativos
    FROM (
        SELECT fecha_operacion 
        FROM empleado_maquinaria 
        WHERE id_maquinaria = maquinaria_id
        
        UNION
        
        SELECT fecha_produccion AS fecha_operacion
        FROM produccion
        WHERE id_maquinaria = maquinaria_id
    ) AS operaciones;
    
    -- Calcular días totales desde la adquisición hasta hoy
    SELECT DATEDIFF(CURRENT_DATE(), fecha_adquisicion) + 1 INTO dias_totales
    FROM maquinaria
    WHERE id_maquinaria = maquinaria_id;
    
    -- Calcular porcentaje 
    IF dias_totales > 0 THEN
        SET porcentaje = (dias_operativos * 100.0) / dias_totales;
    END IF;
    
    RETURN porcentaje;
END //

DELIMITER ;
SELECT porcentaje_utilizacion_maquinaria(140) AS porcentaje_utilizacion;
