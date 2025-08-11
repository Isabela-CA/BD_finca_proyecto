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
