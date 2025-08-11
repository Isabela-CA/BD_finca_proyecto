use finca_agricola;

-- 1. ver el estado actual del inventario por producto
select p.id_producto, p.nombre as producto, p.tipo, i.cantidad_disponible, i.fecha_ultima_actualizacion
from inventario i
join producto p on i.id_producto = p.id_producto
order by p.nombre asc;

-- 2. mostrar los productos con inventario por debajo de 310 unidades
select p.id_producto, p.nombre as producto, p.tipo, i.cantidad_disponible, i.fecha_ultima_actualizacion
from inventario i
join producto p on i.id_producto = p.id_producto
where i.cantidad_disponible < 310
order by i.cantidad_disponible asc;

-- 3. Listar el inventario completo con detalles de productos (nombre, tipo, unidad de medida, cantidad).
select p.nombre as producto, p.tipo, p.unidad_medida, i.cantidad_disponible, i.fecha_ultima_actualizacion
from inventario i
join producto p on i.id_producto = p.id_producto;

-- 4. Obtener solo los productos agrícolas disponibles en el inventario.
select p.nombre as producto, p.tipo,p.unidad_medida, i.cantidad_disponible, i.fecha_ultima_actualizacion
from inventario i
join producto p on i.id_producto = p.id_producto
where p.tipo = 'agrícola';

-- 5. Cuáles son los productos con mas de 400 unidades disponibles
select p.id_producto, p.nombre as producto, p.tipo, i.cantidad_disponible, i.fecha_ultima_actualizacion
from inventario i
join producto p on i.id_producto = p.id_producto
where i.cantidad_disponible > 400
order by i.cantidad_disponible asc;

-- 6. Calcular las ventas mensuales de los dos ultimos meses.
SELECT DATE_FORMAT(fecha_venta, '%Y-%m') AS mes,
    SUM(total) AS total_ventas_mensuales
FROM venta
WHERE fecha_venta <> '2025-07-01' and '2025-08-31'
GROUP BY mes
ORDER BY mes;

-- 7. Mostrar los productos más vendidos en el último trimestre.
select p.id_producto,p.nombre as producto, sum(d.cantidad) as total_vendido, v.fecha_venta
from detalle_venta d
join venta v on d.id_venta = v.id_venta
join producto p on d.id_producto = p.id_producto
where v.fecha_venta <> '2025-05-01' and '2025-08-31'
group by p.id_producto, p.nombre, v.fecha_venta
order by total_vendido desc;

-- 8. Ver el detalle de las ventas realizadas por un cliente determinado.
select d.id_detalle_venta, v.id_cliente, c.nombre as cliente, d.id_producto,  p.nombre as producto, d.cantidad, d.precio_unitario, v.total
from detalle_venta d
join venta v on d.id_venta = v.id_venta
join cliente c on v.id_cliente = c.id_cliente
join producto p on d.id_producto = p.id_producto
where c.nombre = 'Mateo Sánchez';

-- 9. Consultar las ventas agrupadas por cliente.
SELECT c.id_cliente, c.nombre AS cliente, p.nombre as producto, SUM(d.cantidad * d.precio_unitario) AS total_comprado
from detalle_venta d
join venta v on d.id_venta = v.id_venta
join cliente c on v.id_cliente = c.id_cliente
join producto p on d.id_producto = p.id_producto
group by c.id_cliente, c.nombre, p.nombre
order by total_comprado desc;

-- 10. Ver todas las ventas realizadas de un producto específico.
SELECT d.id_producto, p.nombre as producto, p.tipo ,d.cantidad, v.total
from detalle_venta d
join producto p on d.id_producto = p.id_producto
join venta v  on v.id_venta = d.id_venta
where p.nombre = 'Brócoli';

-- 11. mostrar las ventas realizadas por día en la última semana
select date(v.fecha_venta) as fecha, p.nombre as producto, sum(d.cantidad) as total_cantidad_vendida
from detalle_venta d
join venta v on d.id_venta = v.id_venta
join producto p on d.id_producto = p.id_producto
where v.fecha_venta >= '2025-07-01' and v.fecha_venta <= '2025-07-07'
group by fecha, p.nombre
order by fecha asc, producto;

-- 12. listar las compras a proveedores en el año actu
select c.id_compra, pr.nombre as proveedor, c.fecha_compra, c.total
from compra c
join proveedor pr on c.id_proveedor = pr.id_proveedor
where year(c.fecha_compra) = year(curdate())
order by c.fecha_compra asc;

-- 13. mostrar el total gastado en compras por mes durante el último año
select year(c.fecha_compra) as anio, month(c.fecha_compra) as mes, sum(c.total) as total_gastado
from compra c
where c.fecha_compra between '2024-08-01' and '2025-08-01'
group by anio, mes
order by anio asc, mes asc;

-- 14.identificar los 3 proveedores más utilizados
select pr.id_proveedor, pr.nombre as proveedor, count(c.id_compra) as total_compras
from compra c
join proveedor pr on c.id_proveedor = pr.id_proveedor
group by pr.id_proveedor, pr.nombre
order by total_compras desc
limit 3;

-- 15. obtener los productos más comprados (por cantidad)
select p.id_producto, p.nombre as producto, sum(dc.cantidad) as total_comprado
from detalle_compra dc
join producto p on dc.id_producto = p.id_producto
group by p.id_producto, p.nombre
order by total_comprado desc;

-- 16. ver las compras hechas a un proveedor específico
select c.id_compra, pr.nombre as proveedor, c.fecha_compra, c.total
from compra c
join proveedor pr on c.id_proveedor = pr.id_proveedor
where pr.nombre = 'agrosur'
order by c.fecha_compra asc;

-- 17. identificar los empleados que han producido más de 100 unidades
select pr.cantidad_producida, e.nombre as empleado, pr.fecha_produccion
from empleado e
join produccion pr on e.id_empleado = pr.id_empleado
where pr.cantidad_producida > 100;

-- 18. Mostrar la producción diaria en una semana específica.
select date(pr.fecha_produccion) as fecha, p.nombre as producto, sum(pr.cantidad_producida) as total_producido
from produccion pr
join producto p on pr.id_producto = p.id_producto
where pr.fecha_produccion between '2025-06-12' and '2025-06-19'
group by fecha, p.nombre
order by fecha asc, producto;

-- 19. Calcular la cantidad total producida por cada tipo de producto.
select p.tipo, sum(pr.cantidad_producida) as total_producido
from produccion pr
join producto p on pr.id_producto = p.id_producto
group by p.tipo
order by total_producido desc;

-- 20. Ver los lotes producidos agrupados por producto.
select p.nombre as producto, count(l.id_lote) as total_lotes, sum(l.cantidad_producida_unidad) as total_unidades_producidas
from lote l
join produccion pr on l.id_produccion = pr.id_produccion
join producto p on pr.id_producto = p.id_producto
group by p.nombre
order by total_lotes desc;

-- 21. Mostrar el total producido por cada empleado.
select e.nombre as empleado, sum(pr.cantidad_producida) as total_producido
from produccion pr
join empleado e on pr.id_empleado = e.id_empleado
group by e.nombre
order by total_producido desc;

-- 22. Listar todos los empleados con su salario y área asignada.
select e.nombre as empleado, e.salario, e.area_asignada
from empleado e
order by e.area_asignada asc, e.nombre asc;

-- 23. Mostrar empleados que ingresaron en el año 2023 .
select e.nombre as empleado, e.apellido, e.fecha_ingreso, e.area_asignada
from empleado e
where e.fecha_ingreso >= '2023-01-01' and e.fecha_ingreso <= '2023-12-31'
order by e.fecha_ingreso desc;

-- 24. Calcular el costo total de nómina por área.
select e.area_asignada, sum(e.salario) as costo_total_nomina
from empleado e
group by e.area_asignada
order by costo_total_nomina desc;

-- 25. Identificar empleados con más actividades laborales registradas.
select e.nombre as empleado, count(al.id_actividad) as total_actividades
from empleado e
join actividad_laboral al on e.id_empleado = al.id_empleado
group by e.nombre
order by total_actividades desc;

-- 26. Mostrar empleados que operan maquinaria específica.
select e.nombre as empleado, m.nombre as maquinaria, em.fecha_operacion, em.actividad_realizada
from empleado_maquinaria em
join empleado e on em.id_empleado = e.id_empleado
join maquinaria m on em.id_maquinaria = m.id_maquinaria
where m.nombre = 'Sistema de riego Z100'
order by em.fecha_operacion desc;

-- 27. Mostrar la maquinaria que se encuentra fuera de servicio.
select m.id_maquinaria, m.nombre, m.tipo, m.fecha_adquisicion, m.estado
from maquinaria m
where m.estado = 'fuera de servicio'
order by m.nombre asc;

-- 28. Ver qué maquinaria ha sido usada en más de 2 producciones.
select m.id_maquinaria, m.nombre as maquinaria, count(pr.id_produccion) as total_producciones
from produccion pr
join maquinaria m on pr.id_maquinaria = m.id_maquinaria
group by m.id_maquinaria, m.nombre
having count(pr.id_produccion) > 2
order by total_producciones desc;

-- 29. Consultar el costo total de mantenimiento realizado por maquinaria.
select m.id_maquinaria, m.nombre as maquinaria, sum(mm.costo) as costo_total_mantenimiento
from mantenimiento_maquinaria mm
join maquinaria m on mm.id_maquinaria = m.id_maquinaria
group by m.id_maquinaria, m.nombre
order by costo_total_mantenimiento desc;

-- 30. Listar el total de mantenimiento realizado en el año 2024.
select year(mm.fecha_inicio) as anio, sum(mm.costo) as costo_total_mantenimiento
from mantenimiento_maquinaria mm
where year(mm.fecha_inicio) = 2024
group by anio;

-- 31. Máquinas con alto costo de mantenimiento pero baja utilización.
select m.id_maquinaria, m.nombre as maquinaria, sum(mm.costo) as costo_total_mantenimiento, count(distinct pr.id_produccion) as total_producciones
from maquinaria m
left join mantenimiento_maquinaria mm on m.id_maquinaria = mm.id_maquinaria

-- 32. Calcular los costos totales agrupados por tipo (mano de obra, maquinaria, etc.).
select c.tipo, sum(c.monto) as costo_total
from costos c
group by c.tipo
order by costo_total desc;

-- 33. Mostrar los costos mensuales de este año.
select year(c.fecha) as anio,month(c.fecha) as mes, sum(c.monto) as costo_total
from costos c
where c.fecha between '2025-01-01' and '2025-12-31'
group by year(c.fecha), month(c.fecha)
order by anio asc, mes asc;

-- 34 identificar el mes con mayor costos operativos
select year(c.fecha) as anio, month(c.fecha) as mes, sum(c.monto) as costo_total
from costos c
group by year(c.fecha), month(c.fecha)
order by costo_total desc
limit 1;

-- 35 mostrar la rentabilidad de la finca 
select 
    (select sum(total) from venta) - 
    (select sum(monto) from costos) as rentabilidad_total;



-- 36. Productos que no han tenido ventas en los últimos 3 meses.
select p.id_producto, p.nombre as producto, p.tipo, p.unidad_medida
from producto p
where p.id_producto not in (
    select distinct d.id_producto
    from detalle_venta d
    join venta v on d.id_venta = v.id_venta
    where v.fecha_venta between '2025-05-01' and '2025-08-31'
)
order by p.nombre;

-- 37. empleados sin actividades en el ultimo año
select e.id_empleado, e.nombre, e.apellido, e.area_asignada
from empleado e
where e.id_empleado not in (
    select distinct a.id_empleado
    from actividad_laboral a
    where a.fecha between '2024-01-01' and '2024-12-31'
)
order by e.nombre;


-- 38. Máquinas operativas que no se han usado en producción reciente.
select m.id_maquinaria, m.nombre, m.tipo, m.estado
from maquinaria m
where m.estado = 'operativa'
and m.id_maquinaria not in (
    select distinct pr.id_maquinaria
    from produccion pr
    where pr.fecha_produccion between '2025-06-01' and '2025-08-31'
)
order by m.nombre;

-- 39. Clientes frecuentes (más de 2 compras en este año).
select c.id_cliente, c.nombre, c.telefono, count(v.id_venta) as total_compras
from cliente c
join venta v on c.id_cliente = v.id_cliente
where v.fecha_venta between '2025-01-12' and '2025-12-01'
group by c.id_cliente, c.nombre, c.telefono
having count(v.id_venta) > 2
order by total_compras desc;

-- 40. Proveedores con mayor volumen de compra vs. frecuencia.
select pr.id_proveedor, pr.nombre as proveedor, sum(dc.cantidad) as volumen_total, count(distinct c.id_compra) as frecuencia_compras
from proveedor pr
join compra c on pr.id_proveedor = c.id_proveedor
join detalle_compra dc on c.id_compra = dc.id_compra
group by pr.id_proveedor, pr.nombre
order by volumen_total desc, frecuencia_compras desc;

-- 41. productos cuyo precio es mayor al precio promedio de todos los productos
select nombre, precio
from producto
where precio > (select avg(precio) from producto);

-- 42. empleados que han participado en producciones con maquinaria operativa
select nombre, apellido
from empleado
where id_empleado in (
    select distinct id_empleado
    from produccion
    where id_maquinaria in (
        select id_maquinaria
        from maquinaria
        where estado = 'operativa'
    )
);

-- 43. ventas que tienen un total mayor que el promedio de ventas
select id_venta, total, fecha_venta
from venta
where total > (select avg(total) from venta);

-- 44. productos vendidos (en detalle_venta) que no están en inventario (cantidad = 0 o inexistentes)
select distinct p.nombre
from producto p
where p.id_producto in (
    select id_producto from detalle_venta
) and p.id_producto not in (
    select id_producto from inventario where cantidad_disponible > 0
);

-- 45. clientes que han hecho compras cuyo total supera el promedio de todas las compras
select nombre, email
from cliente
where id_cliente in (
    select id_cliente
    from venta
    where total > (select avg(total) from venta)
);

-- 46. maquinarias que no han tenido mantenimiento en el último año
select nombre, tipo
from maquinaria
where id_maquinaria not in (
    select id_maquinaria
    from mantenimiento_maquinaria
    where fecha_inicio >= date_sub(curdate(), interval 1 year)
);

-- 47. empleados cuyo salario es menor que el promedio de su área asignada
select nombre, apellido, salario, area_asignada
from empleado e1
where salario < (
    select avg(salario)
    from empleado e2
    where e2.area_asignada = e1.area_asignada
);

-- 48. productos con cantidad en inventario menor que la cantidad promedio de inventario
select nombre, cantidad_disponible
from producto p
join inventario i on p.id_producto = i.id_producto
where cantidad_disponible < (
    select avg(cantidad_disponible)
    from inventario
);

-- 49. producciones que tienen más cantidad producida que el promedio de producciones del mismo producto
select id_produccion, cantidad_producida, id_producto
from produccion p1
where cantidad_producida > (
    select avg(cantidad_producida)
    from produccion p2
    where p2.id_producto = p1.id_producto
);

-- 50. detalle de ventas cuyo precio unitario es mayor que el precio promedio del producto
select dv.id_detalle_venta, dv.id_venta, dv.id_producto, dv.precio_unitario
from detalle_venta dv
where dv.precio_unitario > (
    select avg(precio_unitario)
    from detalle_venta
    where id_producto = dv.id_producto
);

-- 51. Mostrar el historial de actualizaciones de inventario en el último mes.
SELECT *
FROM inventario
WHERE fecha_ultima_actualizacion >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);
-- 52. Consultar el inventario actualizado a una fecha específica.
SELECT i.*, p.nombre
FROM inventario i
INNER JOIN producto p
ON i.id_producto=p.id_producto
WHERE i.fecha_ultima_actualizacion = '2025-08-02';
-- 53. Listar el inventario de productos procesados.
SELECT 
p.nombre AS producto,
i.cantidad_disponible,
i.fecha_ultima_actualizacion
FROM inventario i
INNER JOIN producto p ON i.id_producto = p.id_producto
WHERE p.tipo = 'procesado';
-- 54. Mostrar las unidades de inventario de productos ganaderos.
SELECT p.nombre, i.cantidad_disponible, p.tipo
FROM inventario i
INNER JOIN producto p ON i.id_producto = p.id_producto
WHERE p.tipo = 'ganadero';
-- 55. Productos que no han tenido ventas en los últimos 15 dias.
SELECT p.*, v.fecha_venta
FROM producto p
LEFT JOIN detalle_venta dv ON p.id_producto = dv.id_producto
LEFT JOIN venta v ON dv.id_venta = v.id_venta
WHERE v.fecha_venta > CURDATE() - INTERVAL 15 DAY;
-- 56. Consultar las ventas realizadas en el último mes.
SELECT v.id_venta, v.fecha_venta, c.nombre AS cliente, v.total
FROM venta v
JOIN cliente c ON v.id_cliente = c.id_cliente
WHERE v.fecha_venta >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
ORDER BY v.fecha_venta DESC;
-- 57. Calcular el total de ventas del último mes.
SELECT SUM(v.total) AS total_ventas_ultimo_mes
FROM venta v
WHERE v.fecha_venta >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);
-- 58. Listar las 5 ventas más altas del año actual.
SELECT v.id_venta, v.fecha_venta, c.nombre AS cliente, v.total
FROM venta v
JOIN cliente c ON v.id_cliente = c.id_cliente
WHERE YEAR(v.fecha_venta) = YEAR(CURDATE())
ORDER BY v.total DESC
LIMIT 5;
-- 59. Mostrar los clientes que más han comprado (por monto total).
SELECT c.id_cliente, c.nombre, SUM(v.total) AS monto_total_compras
FROM venta v
JOIN cliente c ON v.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre
ORDER BY monto_total_compras DESC;
-- 60. Obtener el detalle de productos vendidos en una venta específica.
SELECT dv.id_venta, p.nombre AS producto, dv.cantidad, dv.precio_unitario, 
       (dv.cantidad * dv.precio_unitario) AS subtotal
FROM detalle_venta dv
JOIN producto p ON dv.id_producto = p.id_producto
WHERE dv.id_venta = 368;
-- 61. Listar las compras agrupadas por proveedor.
SELECT p.id_proveedor, p.nombre AS proveedor, COUNT(co.id_compra) AS cantidad_compras, SUM(co.total) AS total_compras
FROM compra co
JOIN proveedor p ON co.id_proveedor = p.id_proveedor
GROUP BY p.id_proveedor, p.nombre
ORDER BY total_compras DESC;
-- 62. Mostrar el historial de compras para un producto determinado.
SELECT dc.id_producto, pr.nombre AS producto, co.id_compra, co.fecha_compra, dc.cantidad, dc.precio_unitario
FROM detalle_compra dc
JOIN producto pr ON dc.id_producto = pr.id_producto
JOIN compra co ON dc.id_compra = co.id_compra
WHERE dc.id_producto = 45
ORDER BY co.fecha_compra DESC;
-- 63. Ver las compras realizadas entre dos fechas.
SELECT co.id_compra, p.nombre AS proveedor, co.fecha_compra, co.total
FROM compra co
JOIN proveedor p ON co.id_proveedor = p.id_proveedor
WHERE co.fecha_compra BETWEEN '2025-01-01' AND '2025-03-31'
ORDER BY co.fecha_compra;
-- 64. Ver el total de compras por categoría de producto.
SELECT pr.tipo AS categoria, SUM(dc.cantidad * dc.precio_unitario) AS total_compras
FROM detalle_compra dc
JOIN producto pr ON dc.id_producto = pr.id_producto
GROUP BY pr.tipo
ORDER BY total_compras DESC;
-- 65. Proveedores con los que no se ha comprado en el último año.
SELECT p.id_proveedor, p.nombre AS proveedor
FROM proveedor p
LEFT JOIN compra co ON p.id_proveedor = co.id_proveedor 
    AND co.fecha_compra >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
WHERE co.id_compra IS NULL;
-- 66. Obtener la producción total por mes.
SELECT DATE_FORMAT(fecha_produccion, '%Y-%m') AS mes,
    SUM(cantidad_producida) AS total_producido
FROM produccion
GROUP BY mes
ORDER BY mes DESC;
-- 67. Calcular la producción mensual de cada tipo de producto (agrícola, ganadero, procesado).
SELECT DATE_FORMAT(pn.fecha_produccion, '%Y-%m') AS mes,
    pr.tipo AS categoria,
    SUM(pn.cantidad_producida) AS total_categoria
FROM produccion pn
JOIN producto pr ON pn.id_producto = pr.id_producto
GROUP BY mes, pr.tipo
ORDER BY mes DESC, pr.tipo;
-- 68. Listar la producción realizada por un empleado específico.
SELECT pn.id_produccion, pn.fecha_produccion, pr.nombre AS producto, pn.cantidad_producida
FROM produccion pn
JOIN producto pr ON pn.id_producto = pr.id_producto
WHERE pn.id_empleado = 78
ORDER BY pn.fecha_produccion DESC;
-- 69. Mostrar la producción donde se utilizó una máquina específica.
SELECT pn.id_produccion, pn.fecha_produccion, pr.nombre AS producto, pn.cantidad_producida
FROM produccion pn
JOIN producto pr ON pn.id_producto = pr.id_producto
WHERE pn.id_maquinaria = 140
ORDER BY pn.fecha_produccion DESC;
-- 70. Obtener los lotes de producción con menos de 1000 unidades producidas.
SELECT l.id_lote, l.id_produccion, l.tamaño_lote, l.cantidad_producida_unidad
FROM lote l
WHERE l.cantidad_producida_unidad < 1000
ORDER BY l.cantidad_producida_unidad ASC;
-- 71. Calcular el promedio de producción diaria del último mes.
SELECT ROUND(AVG(produccion_diaria), 2) AS promedio_diario
FROM (
    SELECT fecha_produccion, SUM(cantidad_producida) AS produccion_diaria
    FROM produccion
    WHERE fecha_produccion >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    GROUP BY fecha_produccion
) AS sub;
-- 72. Consultar los empleados asignados al área de cultivo.
SELECT id_empleado, nombre, apellido, cargo, area_asignada
FROM empleado
WHERE area_asignada = 'cultivo';
-- 73. Listar empleados que han usado maquinaria en el último mes.
SELECT DISTINCT e.id_empleado, e.nombre, e.apellido, e.cargo
FROM empleado e
JOIN empleado_maquinaria em ON e.id_empleado = em.id_empleado
WHERE em.fecha_operacion >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);
-- 74. Listar empleados con salario superior a cierto valor.
SELECT id_empleado, nombre, apellido, salario
FROM empleado
WHERE salario > 4000000
ORDER BY salario DESC;
-- 75. Empleados que no han registrado actividades en la última semana.
SELECT e.id_empleado, e.nombre, e.apellido
FROM empleado e
LEFT JOIN actividad_laboral al 
    ON e.id_empleado = al.id_empleado
    AND al.fecha >= DATE_SUB(CURDATE(), INTERVAL 1 WEEK)
WHERE al.id_actividad IS NULL;
-- 76. Consultar el promedio de duración de las actividades laborales.
SELECT ROUND(AVG(duracion_horas), 2) AS promedio_duracion_horas
FROM actividad_laboral;
-- 77. Listar todas las máquinas actualmente en mantenimiento.
SELECT id_maquinaria, nombre, tipo, fecha_adquisicion, estado
FROM maquinaria
WHERE estado = 'mantenimiento';
-- 78. Mostrar el historial de mantenimientos de una máquina específica.
SELECT mm.id_mantenimiento, mm.id_maquinaria, m.nombre AS maquinaria, 
    mm.fecha_inicio, mm.fecha_fin, mm.costo, mm.descripcion
FROM mantenimiento_maquinaria mm
JOIN maquinaria m ON mm.id_maquinaria = m.id_maquinaria
WHERE mm.id_maquinaria = 115
ORDER BY mm.fecha_inicio DESC;
-- 79. Calcular el costo total de mantenimiento por máquina.
SELECT m.id_maquinaria, m.nombre, SUM(mm.costo) AS costo_total
FROM mantenimiento_maquinaria mm
JOIN maquinaria m ON mm.id_maquinaria = m.id_maquinaria
GROUP BY m.id_maquinaria, m.nombre
ORDER BY costo_total DESC;
-- 80. Identificar máquinas que no han tenido mantenimiento en más de 6 meses.
SELECT m.id_maquinaria, m.nombre
FROM maquinaria m
LEFT JOIN mantenimiento_maquinaria mm 
    ON m.id_maquinaria = mm.id_maquinaria
    AND mm.fecha_inicio >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
WHERE mm.id_mantenimiento IS NULL;
-- 81. Mostrar las máquinas más utilizadas en producción.
SELECT m.id_maquinaria, m.nombre, COUNT(p.id_produccion) AS veces_utilizada
FROM produccion p
JOIN maquinaria m ON p.id_maquinaria = m.id_maquinaria
GROUP BY m.id_maquinaria, m.nombre
ORDER BY veces_utilizada DESC;
-- 82. Mostrar costos asociados a un empleado específico.
SELECT c.id_costos, c.tipo, c.monto, c.fecha, e.nombre, e.apellido
FROM costos c
JOIN empleado e ON c.id_empleado = e.id_empleado
WHERE c.id_empleado = 69
ORDER BY c.fecha DESC;
-- 83. Calcular el total de costos operativos por área.
SELECT e.area_asignada, SUM(c.monto) AS total_costos
FROM costos c
JOIN empleado e ON c.id_empleado = e.id_empleado
GROUP BY e.area_asignada
ORDER BY total_costos DESC;
-- 84. Calcular el costo total de producción por mes.
SELECT DATE_FORMAT(c.fecha, '%Y-%m') AS mes, SUM(c.monto) AS costo_total
FROM costos c
GROUP BY DATE_FORMAT(c.fecha, '%Y-%m')
ORDER BY mes DESC;
-- 85. Listar los costos asociados a una producción específica.
SELECT c.id_costos, c.tipo, c.monto, c.fecha
FROM costos c
WHERE c.id_produccion = 578
ORDER BY c.fecha DESC;
-- 86. total de costos asociados a cada empleado
SELECT 
    e.nombre,
    e.apellido,
    SUM(c.monto) AS total_costos
FROM costos c
JOIN empleado e ON c.id_empleado = e.id_empleado
GROUP BY e.id_empleado, e.nombre, e.apellido
ORDER BY total_costos DESC;
-- 87. Comparar ventas vs. producción del último trimestre.
SELECT 
    p.nombre AS producto,
    COALESCE(SUM(dv.cantidad), 0) AS total_vendido,
    COALESCE(SUM(pd.cantidad_producida), 0) AS total_producido
FROM producto p
LEFT JOIN detalle_venta dv 
    ON p.id_producto = dv.id_producto
LEFT JOIN venta v 
    ON dv.id_venta = v.id_venta 
    AND v.fecha_venta >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
LEFT JOIN produccion pd 
    ON p.id_producto = pd.id_producto
    AND pd.fecha_produccion >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY p.id_producto, p.nombre
ORDER BY p.nombre;
-- 88. Mostrar productos con alta venta pero bajo inventario.
SELECT 
    p.nombre,
    SUM(dv.cantidad) AS total_vendido,
    i.cantidad_disponible
FROM producto p
JOIN detalle_venta dv ON p.id_producto = dv.id_producto
JOIN inventario i ON p.id_producto = i.id_producto
GROUP BY p.id_producto, p.nombre, i.cantidad_disponible
ORDER BY total_vendido DESC, i.cantidad_disponible ASC;
-- 89. Identificar empleados con mayor producción pero menores costos asociados.
SELECT 
    e.nombre,
    e.apellido,
    SUM(pr.cantidad_producida) AS total_producido,
    COALESCE(SUM(c.monto), 0) AS total_costos
FROM empleado e
LEFT JOIN produccion pr ON e.id_empleado = pr.id_empleado
LEFT JOIN costos c ON e.id_empleado = c.id_empleado
GROUP BY e.id_empleado, e.nombre, e.apellido
ORDER BY total_producido DESC, total_costos ASC;
-- 90. Máquinas con alto costo de mantenimiento pero baja utilización.
SELECT 
    m.id_maquinaria,
    m.nombre,
    COALESCE(SUM(mm.costo), 0) AS total_mantenimiento,
    COUNT(DISTINCT p.id_produccion) AS veces_usada_en_produccion
FROM maquinaria m
LEFT JOIN mantenimiento_maquinaria mm 
    ON m.id_maquinaria = mm.id_maquinaria
LEFT JOIN produccion p 
    ON m.id_maquinaria = p.id_maquinaria
GROUP BY m.id_maquinaria, m.nombre
ORDER BY total_mantenimiento DESC, veces_usada_en_produccion ASC;

-- 91. Total de productos vendidos por tipo de producto**
-- Muestra cuántas unidades se han vendido por cada categoría de producto (agrícola, ganadero o procesado), ayudando a identificar qué tipo de producción es más rentable.
SELECT p.tipo, 
    SUM(dv.cantidad) AS total_vendido
FROM producto p
JOIN detalle_venta dv ON p.id_producto = dv.id_producto
GROUP BY p.tipo;
-- 92. Empleado con mayor producción acumulada**
-- Identifica al empleado que ha producido la mayor cantidad total de productos en el sistema, útil para reconocer el desempeño individual.
SELECT e.id_empleado, e.nombre, e.apellido, total_producido
FROM (
    SELECT id_empleado, SUM(cantidad_producida) AS total_producido
    FROM produccion
    GROUP BY id_empleado
) AS prod
JOIN empleado e ON prod.id_empleado = e.id_empleado
ORDER BY total_producido DESC
LIMIT 1;
-- 93. Cliente que más ha comprado**
-- Presenta el cliente con el mayor valor acumulado en compras, lo cual es clave para estrategias de fidelización o descuentos.
SELECT c.id_cliente, c.nombre, total_compras
FROM (
    SELECT v.id_cliente, SUM(v.total) AS total_compras
    FROM venta v
    GROUP BY v.id_cliente
) AS compras
JOIN cliente c ON compras.id_cliente = c.id_cliente
ORDER BY total_compras DESC
LIMIT 1;
-- 94. Productos con inventario por debajo del promedio general**
-- Detecta qué productos tienen menos existencias que el promedio general del inventario, útil para reabastecimiento o promoción.
SELECT p.id_producto, p.nombre, i.cantidad_disponible
FROM inventario i
JOIN producto p ON i.id_producto = p.id_producto
WHERE i.cantidad_disponible < (
    SELECT AVG(cantidad_disponible) FROM inventario
);
-- 95. Producción total agrupada por mes
-- Muestra la cantidad total producida mensualmente para observar patrones estacionales o evaluar la eficiencia de producción.
SELECT DATE_FORMAT(fecha_produccion, '%Y-%m') AS mes, 
    SUM(cantidad_producida) AS total_producido
FROM produccion
GROUP BY DATE_FORMAT(fecha_produccion, '%Y-%m')
ORDER BY mes;
-- 96. Promedio de costo por tipo de maquinaria utilizada**
-- Calcula el costo operativo promedio según el tipo de maquinaria, ayudando a identificar equipos más costosos de mantener.
SELECT tipo, 
    ROUND(AVG(promedio_por_maquina), 2) AS promedio_costo_tipo
FROM (
    SELECT m.tipo, m.id_maquinaria, AVG(c.monto) AS promedio_por_maquina
    FROM costos c
    JOIN maquinaria m ON c.id_maq = m.id_maquinaria
    GROUP BY m.tipo, m.id_maquinaria
) AS costos_promedio
GROUP BY tipo;
-- 97. Producto más vendido en cantidad**
-- Determina cuál ha sido el producto más vendido en términos de unidades, lo cual orienta decisiones de producción y marketing.
SELECT p.id_producto, p.nombre, total_vendido
FROM (
    SELECT id_producto, SUM(cantidad) AS total_vendido
    FROM detalle_venta
    GROUP BY id_producto
) AS ventas
JOIN producto p ON ventas.id_producto = p.id_producto
ORDER BY total_vendido DESC
LIMIT 1;
-- 98. Ventas mensuales por tipo de producto**
-- Resume el total de ventas por categoría de producto cada mes, útil para análisis de mercado y tendencias de consumo.
SELECT ventas_por_mes.mes,
    ventas_por_mes.tipo,
    SUM(ventas_por_mes.total_producto) AS total_ventas
FROM (
    SELECT DATE_FORMAT(v.fecha_venta, '%Y-%m') AS mes,
        p.tipo,
           (dv.cantidad * dv.precio_unitario) AS total_producto
    FROM venta v
    JOIN detalle_venta dv ON v.id_venta = dv.id_venta
    JOIN producto p ON dv.id_producto = p.id_producto
) AS ventas_por_mes
GROUP BY ventas_por_mes.mes, ventas_por_mes.tipo
ORDER BY ventas_por_mes.mes, total_ventas DESC;
-- 99. Promedio de duración de actividades por área**
-- Evalúa cuánto tiempo en promedio se dedica a cada área de trabajo, como logística, cultivo u ordeño, lo cual puede revelar sobrecargas o cuellos de botella.
SELECT promedio_area.area,
    ROUND(promedio_area.promedio_horas, 2) AS promedio_horas
FROM (
    SELECT area,
        AVG(duracion_horas) AS promedio_horas
    FROM actividad_laboral
    GROUP BY area
) AS promedio_area
ORDER BY promedio_area.promedio_horas DESC;
-- 100. Productos más comprados a proveedores**
-- Lista los productos más adquiridos en compras, útil para gestionar relaciones con proveedores y ajustar compras futuras.
SELECT p.id_producto, p.nombre, total_comprado
FROM (
    SELECT id_producto, SUM(cantidad) AS total_comprado
    FROM detalle_compra
    GROUP BY id_producto
) AS compras
JOIN producto p ON compras.id_producto = p.id_producto
ORDER BY total_comprado DESC;