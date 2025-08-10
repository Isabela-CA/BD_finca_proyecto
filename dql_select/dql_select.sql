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