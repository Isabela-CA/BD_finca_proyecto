-- 1. actualizar salarios anuales
DELIMITER $$

CREATE EVENT incremento_salarios
ON SCHEDULE
    EVERY 1 YEAR
    STARTS CURRENT_TIMESTAMP
    ENDS CURRENT_TIMESTAMP + INTERVAL 1 YEAR
DO
BEGIN
    -- Incremento del 5% 
    UPDATE empleado 
    SET salario = ROUND(salario * 1.05, 0)
    WHERE id_empleado BETWEEN 1 AND 10; 
    
    SELECT CONCAT('Prueba ejecutada a las ', NOW(), 'Salarios actualizados ') AS mensaje;
END$$

DELIMITER ;

SHOW EVENTS;
SHOW PROCESSLIST;


-- 2.  reporte_mensual_ventas 

CREATE TABLE IF NOT EXISTS reporte_ventas_mensual (
    id_reporte INT PRIMARY KEY AUTO_INCREMENT,
    anio INT NOT NULL,
    mes INT NOT NULL,
    total_ventas DECIMAL(12,2) NOT NULL,
    fecha_generacion DATETIME NOT NULL
);

DELIMITER //

CREATE EVENT IF NOT EXISTS reporte_mensual_ventas
ON SCHEDULE EVERY 1 month
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 DAY - INTERVAL DAY(CURRENT_DATE)-1 DAY) + INTERVAL 5 MINUTE
DO
BEGIN
    -- Insertar el resumen del mes anterior
    INSERT INTO reporte_ventas_mensual (anio, mes, total_ventas, fecha_generacion)
    SELECT
        YEAR(v.fecha_venta) AS anio,
        MONTH(v.fecha_venta) AS mes,
        SUM(dv.cantidad * dv.precio_unitario) AS total_ventas,
        NOW()
    FROM venta v
    JOIN detalle_venta dv ON v.id_venta = dv.id_venta
    WHERE v.fecha_venta >= DATE_FORMAT(CURRENT_DATE - INTERVAL 1 MONTH, '%Y-%m-01')
      AND v.fecha_venta < DATE_FORMAT(CURRENT_DATE, '%Y-%m-01')
    GROUP BY anio, mes;
END;
//

DELIMITER ;

SELECT * FROM reporte_ventas_mensual ORDER BY fecha_generacion DESC;

SELECT *
FROM reporte_ventas_mensual
ORDER BY fecha_generacion DESC;

-- 3. reporte_mensual_produccion
CREATE EVENT IF NOT EXISTS reporte_mensual_produccion
ON SCHEDULE EVERY 1 MONTH
STARTS TIMESTAMP(DATE_FORMAT(CURRENT_DATE, '%Y-%m-01') + INTERVAL 5 MINUTE)
DO
BEGIN
    INSERT INTO reporte_produccion_mensual (
        anio, mes, id_producto, nombre_producto, total_producido, fecha_generacion
    )
    SELECT
        YEAR(p.fecha_produccion) AS anio,
        MONTH(p.fecha_produccion) AS mes,
        p.id_producto,
        prod.nombre,
        SUM(p.cantidad_producida) AS total_producido,
        NOW()
    FROM produccion p
    JOIN producto prod ON p.id_producto = prod.id_producto
    WHERE p.fecha_produccion >= DATE_FORMAT(CURRENT_DATE - INTERVAL 1 MONTH, '%Y-%m-01')
      AND p.fecha_produccion < DATE_FORMAT(CURRENT_DATE, '%Y-%m-01')
    GROUP BY anio, mes, p.id_producto, prod.nombre;
END;
//

DELIMITER ;

SELECT * FROM reporte_produccion_mensual ORDER BY fecha_generacion DESC;

-- 4 verificar_maquinaria_mantenimiento 
CREATE TABLE IF NOT EXISTS alertas_maquinaria (
    id_alerta INT PRIMARY KEY AUTO_INCREMENT,
    id_maquinaria INT NOT NULL,
    fecha_alerta DATETIME NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    FOREIGN KEY (id_maquinaria) REFERENCES maquinaria(id_maquinaria)
);

DELIMITER //

CREATE EVENT IF NOT EXISTS verificar_maquinaria_mantenimiento
ON SCHEDULE EVERY 1 week
DO
BEGIN
    INSERT INTO alertas_maquinaria (id_maquinaria, fecha_alerta, descripcion)
    SELECT m.id_maquinaria, NOW(),
           CONCAT('La maquinaria ', m.nombre, ' lleva más de 6 meses sin mantenimiento.')
    FROM maquinaria m
    WHERE NOT EXISTS (
        SELECT 1
        FROM mantenimiento_maquinaria mm
        WHERE mm.id_maquinaria = m.id_maquinaria
          AND mm.fecha_fin >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
    );
END;
//

DELIMITER ;

select * from alertas_maquinaria order by fecha_alerta desc;


-- 5. actualizar_estado_maquinaria
DELIMITER //

CREATE EVENT IF NOT EXISTS actualizar_estado_maquinaria
ON SCHEDULE EVERY 1 day
DO
BEGIN
    UPDATE maquinaria m
    SET m.estado = 'Operativa'
    WHERE EXISTS (
        SELECT 1
        FROM mantenimiento_maquinaria mm
        WHERE mm.id_maquinaria = m.id_maquinaria
          AND mm.fecha_fin IS NOT NULL
          AND mm.fecha_fin <= CURDATE()
    )
    AND NOT EXISTS (
        SELECT 1
        FROM mantenimiento_maquinaria mm2
        WHERE mm2.id_maquinaria = m.id_maquinaria
          AND mm2.fecha_fin IS NULL
    );
END;
//

DELIMITER ;

SELECT id_maquinaria, estado FROM maquinaria;

-- 6. ajustar_inventario_diario
DELIMITER //

CREATE EVENT IF NOT EXISTS ajustar_inventario_diario
ON SCHEDULE EVERY 1 day
DO
BEGIN
    UPDATE inventario i
    JOIN (
        SELECT id_producto, SUM(cantidad_producida) AS total_producido
        FROM produccion
        WHERE fecha_produccion = CURDATE() - INTERVAL 1 DAY
        GROUP BY id_producto
    ) p ON i.id_producto = p.id_producto
    SET i.cantidad_disponible = i.cantidad_disponible - p.total_producido;
END;
//

DELIMITER ;

select * from inventario;

-- 7. actualizar stock minimo
CREATE TABLE IF NOT EXISTS alertas_stock (
    id_alerta INT PRIMARY KEY AUTO_INCREMENT,
    id_producto INT NOT NULL,
    fecha_alerta DATETIME NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);

drop event actualizar_stock_minimo;
INSERT INTO alertas_stock (id_producto, fecha_alerta, descripcion)
SELECT i.id_producto, NOW(),
       CONCAT('la cantidad (stock) de ', p.nombre, ' es menor que la producción registrada.')
FROM inventario i
JOIN producto p ON i.id_producto = p.id_producto
JOIN produccion pr ON i.id_producto = pr.id_producto
WHERE i.cantidad_disponible < pr.cantidad_producida
  AND NOT EXISTS (
      SELECT 1
      FROM alertas_stock a
      WHERE a.id_producto = i.id_producto
        AND DATE(a.fecha_alerta) = CURDATE()
  );


  SELECT * FROM alertas_stock ORDER BY fecha_alerta DESC;


-- 8. inventario bajo 
CREATE TABLE IF NOT EXISTS alertas_inventario_bajo (
    id_alerta INT PRIMARY KEY AUTO_INCREMENT,
    id_producto INT NOT NULL,
    fecha_alerta DATETIME NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);

INSERT INTO alertas_inventario_bajo (id_producto, fecha_alerta, descripcion)
SELECT i.id_producto, NOW(),
       CONCAT('El producto ', p.nombre, ' tiene inventario bajo (', i.cantidad_disponible, ' unidades).')
FROM inventario i
JOIN producto p ON i.id_producto = p.id_producto
WHERE i.cantidad_disponible < 20
  AND NOT EXISTS (
      SELECT 1
      FROM alertas_inventario_bajo a
      WHERE a.id_producto = i.id_producto
        AND DATE(a.fecha_alerta) = CURDATE()
  );


SELECT * FROM alertas_inventario_bajo ORDER BY fecha_alerta DESC;


-- 9. auditoria_diaria_inventario

CREATE TABLE IF NOT EXISTS historial_inventario (
    id_registro INT PRIMARY KEY AUTO_INCREMENT,
    id_producto INT NOT NULL,
    fecha DATE NOT NULL,
    cantidad_disponible DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);

DELIMITER //

CREATE EVENT IF NOT EXISTS auditoria_diaria_inventario
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    INSERT INTO historial_inventario (id_producto, fecha, cantidad_disponible)
    SELECT id_producto, CURDATE(), cantidad_disponible
    FROM inventario;
END;
//

DELIMITER ;

SELECT * FROM historial_inventario ORDER BY fecha DESC; 

-- 10. registro_diario_ventas
CREATE TABLE IF NOT EXISTS historial_ventas_diarias (
    id_registro INT PRIMARY KEY AUTO_INCREMENT,
    id_producto INT NOT NULL,
    fecha DATE NOT NULL,
    total_vendido DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);
drop event registro_diario_ventas;
DELIMITER //

CREATE EVENT IF NOT EXISTS registro_diario_ventas
ON SCHEDULE EVERY 1 minute
DO
BEGIN
    INSERT INTO historial_ventas_diarias (id_producto, fecha, total_vendido)
    SELECT dv.id_producto, CURDATE() - INTERVAL 1 DAY, SUM(dv.cantidad)
    FROM detalle_venta dv
    JOIN ventas v ON dv.id_venta = v.id_venta
    WHERE DATE(v.fecha_venta) = CURDATE() - INTERVAL 1 DAY
    GROUP BY dv.id_producto;
END;
//

DELIMITER ;

SELECT * FROM historial_ventas_diarias ORDER BY fecha DESC;


-- 11. Reporte_mensual_clientes_activos
-- Identifica los clientes que han comprado durante el último mes y guarda el total de sus compras.

CREATE EVENT reporte_mensual_clientes_activos
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-09-01 00:00:00'
DO
INSERT INTO reporte_clientes_activos (id_cliente, total_compras, periodo)
SELECT v.id_cliente, SUM(dv.cantidad * dv.precio_unitario), DATE_FORMAT(CURDATE() - INTERVAL 1 MONTH, '%Y-%m')
FROM venta v
JOIN detalle_venta dv ON v.id_venta = dv.id_venta
WHERE MONTH(v.fecha_venta) = MONTH(CURDATE() - INTERVAL 1 MONTH)
AND YEAR(v.fecha_venta) = YEAR(CURDATE() - INTERVAL 1 MONTH)
GROUP BY v.id_cliente;

-- 12. Reporte_compras_mensuales
-- Consolida todas las compras realizadas el mes anterior, agrupadas por proveedor.
CREATE EVENT reporte_compras_mensuales
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-09-01 00:00:00'
DO
INSERT INTO reporte_compras (id_proveedor, total_compras, periodo)
SELECT c.id_proveedor, SUM(dc.cantidad * dc.precio_unitario), DATE_FORMAT(CURDATE() - INTERVAL 1 MONTH, '%Y-%m')
FROM compra c
JOIN detalle_compra dc ON c.id_compra = dc.id_compra
WHERE MONTH(c.fecha_compra) = MONTH(CURDATE() - INTERVAL 1 MONTH)
AND YEAR(c.fecha_compra) = YEAR(CURDATE() - INTERVAL 1 MONTH)
GROUP BY c.id_proveedor;

-- 13. Actualizar_precio_promedio_producto
-- Calcula el precio promedio de compra de cada producto y actualiza un campo auxiliar en la tabla de productos.

CREATE EVENT actualizar_precio_promedio_producto
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-09-01 00:00:00'
DO
UPDATE producto p
SET p.precio_promedio_compra = (
    SELECT AVG(dc.precio_unitario)
    FROM detalle_compra dc
    WHERE dc.id_producto = p.id_producto
);

-- 14. Restaurar_estado_maquinaria_inactiva
-- Revisa maquinarias fuera de servicio durante más de 30 días y las marca como candidatas a revisión.
    
CREATE EVENT restaurar_estado_maquinaria_inactiva
ON SCHEDULE EVERY 1 DAY
DO
UPDATE maquinaria
SET estado = 'candidata_revision'
WHERE estado = 'fuera_servicio'
AND DATEDIFF(CURDATE(), fecha_ultimo_uso) > 30;
    
-- 15. Resumen_actividad_laboral_semanal`**
-- Calcula las horas trabajadas por cada empleado en la semana anterior y las guarda en una tabla de control.

CREATE EVENT resumen_actividad_laboral_semanal
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-08-11 00:00:00'
DO
INSERT INTO control_horas (id_empleado, total_horas, semana)
SELECT id_empleado, SUM(duracion_horas), YEARWEEK(CURDATE() - INTERVAL 1 WEEK)
FROM actividad_laboral
WHERE YEARWEEK(fecha_actividad) = YEARWEEK(CURDATE() - INTERVAL 1 WEEK)
GROUP BY id_empleado;

-- 16.Verificar_ventas_sin_detalle
-- Busca cada noche ventas registradas sin detalle de productos y las marca como incompletas para corrección.

CREATE EVENT verificar_ventas_sin_detalle
ON SCHEDULE EVERY 1 DAY
DO
UPDATE venta v
LEFT JOIN detalle_venta dv ON v.id_venta = dv.id_venta
SET v.estado = 'incompleta'
WHERE dv.id_detalle IS NULL;

-- 17. Cerrar_periodo_costos
-- Marca el fin de cada mes como cierre de costos, impidiendo modificaciones posteriores a esos registros.

CREATE EVENT cerrar_periodo_costos
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-09-01 00:00:00'
DO
UPDATE costos
SET bloqueado = 1
WHERE MONTH(fecha_costo) = MONTH(CURDATE() - INTERVAL 1 MONTH)
AND YEAR(fecha_costo) = YEAR(CURDATE() - INTERVAL 1 MONTH);

-- 18. Generar_resumen_fin_semana
-- Cada domingo, resume la producción, ventas y costos de la semana en una tabla de control de gestión.

CREATE EVENT generar_resumen_fin_semana
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-08-10 23:59:00'
DO
INSERT INTO resumen_semanal (total_produccion, total_ventas, total_costos, semana)
SELECT 
    (SELECT SUM(cantidad_producida) FROM produccion 
    WHERE YEARWEEK(fecha_produccion) = YEARWEEK(CURDATE() - INTERVAL 1 WEEK)),
    (SELECT SUM(dv.cantidad * dv.precio_unitario) FROM venta v 
    JOIN detalle_venta dv ON v.id_venta = dv.id_venta
    WHERE YEARWEEK(v.fecha_venta) = YEARWEEK(CURDATE() - INTERVAL 1 WEEK)),
    (SELECT SUM(monto) FROM costos 
    WHERE YEARWEEK(fecha_costo) = YEARWEEK(CURDATE() - INTERVAL 1 WEEK)),
    YEARWEEK(CURDATE() - INTERVAL 1 WEEK);

-- 19. Actualizar_inventario_lotes
-- Toma la producción registrada por lote y actualiza automáticamente el inventario cada noche.
    
CREATE EVENT actualizar_inventario_lotes
ON SCHEDULE EVERY 1 DAY
DO
UPDATE inventario i
JOIN (
    SELECT id_producto, SUM(cantidad_producida) AS total_dia
    FROM produccion
    WHERE fecha_produccion = CURDATE()
    GROUP BY id_producto
) p ON i.id_producto = p.id_producto
SET i.cantidad = i.cantidad + p.total_dia;
    
-- 20. Reporte_empleados_sin_actividad
-- Detecta empleados sin actividad laboral registrada en los últimos 7 días y los incluye en un informe de inactividad.

CREATE EVENT reporte_empleados_sin_actividad
ON SCHEDULE EVERY 1 WEEK
DO
INSERT INTO empleados_inactivos (id_empleado, fecha_reporte)
SELECT e.id_empleado, CURDATE()
FROM empleado e
LEFT JOIN actividad_laboral a 
ON e.id_empleado = a.id_empleado 
AND a.fecha_actividad >= CURDATE() - INTERVAL 7 DAY
WHERE a.id_actividad IS NULL;
