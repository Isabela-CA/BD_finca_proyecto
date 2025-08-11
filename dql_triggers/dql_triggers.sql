-- 1. trg_actualizar_inventario_venta
-- Se activa después de insertar una fila en `detalle_venta`. Resta automáticamente la cantidad vendida del inventario del producto correspondiente.
    
DELIMITER //
CREATE TRIGGER trg_actualizar_inventario_venta
AFTER INSERT ON detalle_venta
FOR EACH ROW
BEGIN
    UPDATE producto
    SET stock = stock - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END//
DELIMITER ;
    
-- 2. trg_actualizar_inventario_compra
-- Se ejecuta después de insertar en `detalle_compra`. Suma automáticamente la cantidad comprada al inventario del producto.
    
DELIMITER //
CREATE TRIGGER trg_actualizar_inventario_compra
AFTER INSERT ON detalle_compra
FOR EACH ROW
BEGIN
    UPDATE producto
    SET stock = stock + NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END//
DELIMITER ;
    
-- 3. trg_historial_salario_empleado
-- Antes de actualizar el campo `salario` en `empleado`, guarda el salario anterior junto con la fecha y el motivo en una tabla de historial de salarios.
    
DELIMITER //
CREATE TRIGGER trg_historial_salario_empleado
BEFORE UPDATE ON empleado
FOR EACH ROW
BEGIN
    IF NEW.salario <> OLD.salario THEN
        INSERT INTO historial_salario (id_empleado, salario_anterior, fecha_cambio, motivo)
        VALUES (OLD.id_empleado, OLD.salario, NOW(), 'Actualización de salario');
    END IF;
END//
DELIMITER ;
    
-- 4. trg_validar_existencia_producto_en_venta
-- Antes de insertar un `detalle_venta`, valida que el producto tenga suficiente inventario. Si no lo tiene, lanza un error.
    
DELIMITER //
CREATE TRIGGER trg_validar_existencia_producto_en_venta
BEFORE INSERT ON detalle_venta
FOR EACH ROW
BEGIN
    DECLARE stock_actual INT;
    SELECT stock INTO stock_actual
    FROM producto
    WHERE id_producto = NEW.id_producto;

    IF stock_actual < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente para la venta';
    END IF;
END//
DELIMITER ;
    
-- 5. trg_validar_estado_maquinaria_uso
-- Antes de insertar un uso de maquinaria por parte de un empleado, verifica que la maquinaria esté en estado "operativa". Si no, lanza un error.
    
DELIMITER //
CREATE TRIGGER trg_validar_estado_maquinaria_uso
BEFORE INSERT ON uso_maquinaria
FOR EACH ROW
BEGIN
    DECLARE estado_actual VARCHAR(50);
    SELECT estado INTO estado_actual
    FROM maquinaria
    WHERE id_maquinaria = NEW.id_maquinaria;

    IF estado_actual <> 'operativa' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La maquinaria no está operativa';
    END IF;
END//
DELIMITER ;
    
-- 6. trg_actualizar_estado_maquinaria_mantenimiento 
-- Al insertar un nuevo mantenimiento en `mantenimiento_maquinaria`, actualiza automáticamente el estado de la maquinaria a "mantenimiento".

DELIMITER //
CREATE TRIGGER trg_actualizar_estado_maquinaria_mantenimiento
AFTER INSERT ON mantenimiento_maquinaria
FOR EACH ROW
BEGIN
    UPDATE maquinaria
    SET estado = 'mantenimiento'
    WHERE id_maquinaria = NEW.id_maquinaria;
END//
DELIMITER ;

-- 7. trg_finalizar_mantenimiento
-- Al actualizar la fecha de finalización en un mantenimiento, cambia automáticamente el estado de la maquinaria a "operativa".
    
DELIMITER //
CREATE TRIGGER trg_finalizar_mantenimiento
AFTER UPDATE ON mantenimiento_maquinaria
FOR EACH ROW
BEGIN
    IF NEW.fecha_fin IS NOT NULL AND OLD.fecha_fin IS NULL THEN
        UPDATE maquinaria
        SET estado = 'operativa'
        WHERE id_maquinaria = NEW.id_maquinaria;
    END IF;
END//
DELIMITER ;
    
-- 8. trg_insertar_actividad_auto_empleado 
-- Después de insertar una producción, genera automáticamente una actividad laboral del empleado involucrado, registrando que participó en una producción.
    
DELIMITER //
CREATE TRIGGER trg_insertar_actividad_auto_empleado
AFTER INSERT ON produccion
FOR EACH ROW
BEGIN
    INSERT INTO actividad_laboral (id_empleado, area, duracion_horas, fecha)
    VALUES (NEW.id_empleado, 'Producción', 8, NOW()); -- ajusta duración según lógica
END//
DELIMITER ;
    
-- 9. trg_prevenir_eliminacion_empleado_con_produccion
-- Impide eliminar un empleado si tiene registros en la tabla de `produccion`, protegiendo la integridad histórica.
    
DELIMITER //
CREATE TRIGGER trg_prevenir_eliminacion_empleado_con_produccion
BEFORE DELETE ON empleado
FOR EACH ROW
BEGIN
    DECLARE tiene_produccion INT;
    SELECT COUNT(*) INTO tiene_produccion
    FROM produccion
    WHERE id_empleado = OLD.id_empleado;

    IF tiene_produccion > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar un empleado con registros de producción';
    END IF;
END//
DELIMITER ;
    
-- 10. trg_insertar_historial_compra
-- Después de registrar una compra, guarda un resumen de la operación (proveedor, total, fecha) en una tabla de historial.

DELIMITER //
CREATE TRIGGER trg_insertar_historial_compra
AFTER INSERT ON compra
FOR EACH ROW
BEGIN
    INSERT INTO historial_compra (id_compra, id_proveedor, total, fecha)
    VALUES (NEW.id_compra, NEW.id_proveedor, NEW.total, NEW.fecha);
END//
DELIMITER ;