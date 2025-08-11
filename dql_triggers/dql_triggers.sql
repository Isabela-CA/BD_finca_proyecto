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

-- 11. trg_alerta_producto_sin_inventario

CREATE TABLE alerta_inventario (
    id_alerta INT PRIMARY KEY AUTO_INCREMENT,
    id_producto INT NOT NULL,
    fecha_alerta DATETIME NOT NULL,
    mensaje VARCHAR(255) NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);

--  registrar alertas después de actualización
drop trigger trg_alerta_producto_sin_inventario;
DELIMITER //
CREATE TRIGGER trg_alerta_producto_sin_inventario
AFTER UPDATE ON inventario
FOR EACH ROW
BEGIN
    IF NEW.cantidad_disponible <= 0 THEN
        INSERT INTO alerta_inventario (id_producto, fecha_alerta, mensaje)
        VALUES (
            NEW.id_producto,
            NOW(),
            CONCAT('El producto con ID ', NEW.id_producto, ' se encuentra sin inventario o en negativo.')
        );
    END IF;
END;
//
DELIMITER ;

-- 12. trg_validar_datos_empleado
DELIMITER //

CREATE TRIGGER trg_validar_datos_empleado
BEFORE INSERT ON empleado
FOR EACH ROW
BEGIN
    -- Validar salario mayor a cero
    IF NEW.salario <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El salario debe ser mayor a cero.';
    END IF;

    -- Validar área asignada no vacía
    IF NEW.area_asignada IS NULL OR TRIM(NEW.area_asignada) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El área asignada no puede estar vacía.';
    END IF;
END;
//

DELIMITER ;


-- 13. trg_historial_modificacion_proveedor
CREATE TABLE IF NOT EXISTS historial_proveedor (
    id_historial INT PRIMARY KEY AUTO_INCREMENT,
    id_proveedor INT NOT NULL,
    campo_modificado VARCHAR(50) NOT NULL,
    valor_anterior VARCHAR(150),
    valor_nuevo VARCHAR(150),
    fecha_modificacion DATETIME NOT NULL,
    FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor)
);

-- registrar cambios en teléfono o dirección
DELIMITER //

CREATE TRIGGER trg_historial_modificacion_proveedor
AFTER UPDATE ON proveedor
FOR EACH ROW
BEGIN
    -- Si cambia la dirección
    IF NEW.direccion <> OLD.direccion THEN
        INSERT INTO historial_proveedor (
            id_proveedor, campo_modificado, valor_anterior, valor_nuevo, fecha_modificacion
        ) VALUES (
            NEW.id_proveedor, 'direccion', OLD.direccion, NEW.direccion, NOW()
        );
    END IF;

    -- Si cambia el teléfono
    IF NEW.telefono <> OLD.telefono THEN
        INSERT INTO historial_proveedor (
            id_proveedor, campo_modificado, valor_anterior, valor_nuevo, fecha_modificacion
        ) VALUES (
            NEW.id_proveedor, 'telefono', OLD.telefono, NEW.telefono, NOW()
        );
    END IF;
END;
//

DELIMITER ;

UPDATE proveedor
SET direccion = 'Calle Nueva #123', telefono = '3009998888'
WHERE id_proveedor = 201;

SELECT * FROM historial_proveedor;


-- 14. trg_historial_modificacion_cliente

CREATE TABLE IF NOT EXISTS historial_cliente (
    id_historial INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    campo_modificado VARCHAR(50) NOT NULL,
    valor_anterior VARCHAR(150),
    valor_nuevo VARCHAR(150),
    fecha_modificacion DATETIME NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);


--  guardar cambios de contacto
DELIMITER //

CREATE TRIGGER trg_historial_modificacion_cliente
AFTER UPDATE ON cliente
FOR EACH ROW
BEGIN
    -- Si cambia la dirección
    IF NEW.direccion <> OLD.direccion THEN
        INSERT INTO historial_cliente (
            id_cliente, campo_modificado, valor_anterior, valor_nuevo, fecha_modificacion
        ) VALUES (
            NEW.id_cliente, 'direccion', OLD.direccion, NEW.direccion, NOW()
        );
    END IF;

    -- Si cambia el teléfono
    IF NEW.telefono <> OLD.telefono THEN
        INSERT INTO historial_cliente (
            id_cliente, campo_modificado, valor_anterior, valor_nuevo, fecha_modificacion
        ) VALUES (
            NEW.id_cliente, 'telefono', OLD.telefono, NEW.telefono, NOW()
        );
    END IF;
END;
//

DELIMITER ;

UPDATE cliente
SET direccion = 'Carrera 45 #12-34', telefono = '3205557788'
WHERE id_cliente = 251;

SELECT * FROM historial_cliente;

-- 15.trg_registrar_costo_produccion

DELIMITER //

CREATE TRIGGER trg_registrar_costo_produccion
AFTER INSERT ON produccion
FOR EACH ROW
BEGIN
    DECLARE monto_estimado DECIMAL(10,0);

    -- estimar costo en función de la cantidad producida 
    SET monto_estimado = NEW.cantidad_producida * 10000;

    INSERT INTO costos (id_empleado,id_maq,id_produccion,tipo,monto,fecha
    ) VALUES (NEW.id_empleado,NEW.id_maquinaria,NEW.id_produccion,'estimado',monto_estimado, NOW() );
END;
//

DELIMITER ;

-- Insertar producción de prueba
INSERT INTO produccion (id_producto, fecha_produccion, cantidad_producida, id_empleado, id_maquinaria)
VALUES (1, '2025-05-10', 50, 51, 101);

-- Verificar que se creó el costo automáticamente
SELECT * FROM costos
ORDER BY id_costos desc
LIMIT 1;


-- 16. trg_actualizar_costo_mantenimiento

--  Agregar columna de resumen de costos en maquinaria 
ALTER TABLE maquinaria
ADD COLUMN costo_total_mantenimientos DECIMAL(12,2) DEFAULT 0;

DELIMITER //
CREATE TRIGGER trg_actualizar_costo_mantenimiento_insert
AFTER INSERT ON mantenimiento_maquinaria
FOR EACH ROW
BEGIN
    UPDATE maquinaria
    SET costo_total_mantenimientos = (
        SELECT IFNULL(SUM(costo), 0)
        FROM mantenimiento_maquinaria
        WHERE id_maquinaria = NEW.id_maquinaria
    )
    WHERE id_maquinaria = NEW.id_maquinaria;
END;
//
DELIMITER ;


DELIMITER //
CREATE TRIGGER trg_actualizar_costo_mantenimiento_update
AFTER UPDATE ON mantenimiento_maquinaria
FOR EACH ROW
BEGIN
    UPDATE maquinaria
    SET costo_total_mantenimientos = (
        SELECT IFNULL(SUM(costo), 0)
        FROM mantenimiento_maquinaria
        WHERE id_maquinaria = NEW.id_maquinaria
    )
    WHERE id_maquinaria = NEW.id_maquinaria;
END;
//
DELIMITER ;

SHOW TRIGGERS FROM Finca_agricola;

SELECT id_maquinaria, costo
FROM mantenimiento_maquinaria
WHERE id_maquinaria = 142;

-- Insertar mantenimiento 
INSERT INTO mantenimiento_maquinaria (id_maquinaria, fecha_inicio, fecha_fin, costo, descripcion)
VALUES (142, '2025-01-10', '2025-01-12', 500000, 'Cambio de aceite');

select * from mantenimiento_maquinaria
where id_maquinaria = 142;


-- 17. trg_validar_fecha_produccion

DELIMITER //

CREATE TRIGGER trg_validar_fecha_produccion
BEFORE INSERT ON produccion
FOR EACH ROW
BEGIN
    -- Validar que la fecha de producción no sea mayor a la fecha actual
    IF NEW.fecha_produccion > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha de producción no puede ser posterior a la fecha actual.';
    END IF;
END;
//

DELIMITER ;

INSERT INTO produccion (id_producto, fecha_produccion, cantidad_producida, id_empleado, id_maquinaria)
VALUES (6, '2026-12-01', 100, 63, 107);

INSERT INTO produccion (id_producto, fecha_produccion, cantidad_producida, id_empleado, id_maquinaria)
VALUES (1, '2025-01-02', 100, 51, 101);


-- 18. trg_prevenir_eliminacion_producto_con_ventas

DELIMITER //

CREATE TRIGGER trg_prevenir_eliminacion_producto_con_ventas
BEFORE DELETE ON producto
FOR EACH ROW
BEGIN
    -- Verificar si el producto tiene ventas registradas
    IF EXISTS (
        SELECT 1
        FROM detalle_venta
        WHERE id_producto = OLD.id_producto
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No es permitido eliminar el producto porque tiene ventas registradas.';
    END IF;
END;
//

DELIMITER ;

DELETE FROM producto
WHERE id_producto = 5;

-- 19. trg_historial_modificacion_inventario_manual

CREATE TABLE IF NOT EXISTS auditoria_inventario (
    id_auditoria INT PRIMARY KEY AUTO_INCREMENT,
    id_inventario INT NOT NULL,
    producto VARCHAR(100) NOT NULL,
    cantidad_anterior INT NOT NULL,
    cantidad_nueva INT NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    fecha_modificacion DATETIME NOT NULL,
    FOREIGN KEY (id_inventario) REFERENCES inventario(id_inventario)
);

DELIMITER //

CREATE TRIGGER trg_historial_modificacion_inventario_manual
AFTER UPDATE ON inventario
FOR EACH ROW
BEGIN
    -- Solo registrar si la cantidad disponible cambia
    IF NEW.cantidad_disponible <> OLD.cantidad_disponible THEN
        INSERT INTO auditoria_inventario (
            id_inventario, producto, cantidad_anterior, cantidad_nueva, usuario, fecha_modificacion
        )
        VALUES (
            NEW.id_inventario,
            (SELECT nombre FROM producto WHERE id_producto = NEW.id_producto),
            OLD.cantidad_disponible,
            NEW.cantidad_disponible,
            CURRENT_USER(),
            NOW()
        );
    END IF;
END;
//

DELIMITER ;


SHOW TRIGGERS FROM Finca_agricola
WHERE `Trigger` = 'trg_historial_modificacion_inventario_manual';

SELECT * FROM auditoria_inventario;

UPDATE inventario
SET cantidad_disponible = cantidad_disponible - 10
WHERE id_inventario = 310;


-- 20. trg_insertar_alerta_empleado_inactivo

CREATE TABLE IF NOT EXISTS alertas_empleado (
    id_alerta INT PRIMARY KEY AUTO_INCREMENT,
    id_empleado INT NOT NULL,
    tipo_alerta VARCHAR(50) NOT NULL,
    fecha_alerta DATETIME NOT NULL,
    descripcion VARCHAR(255),
    FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado)
);


DELIMITER //

CREATE TRIGGER trg_insertar_alerta_empleado_inactivo
AFTER INSERT ON actividad_laboral
FOR EACH ROW
BEGIN
    -- Verificar si no hubo actividades en los últimos días 
    IF NOT EXISTS (
        SELECT 1
        FROM actividad_laboral
        WHERE id_empleado = NEW.id_empleado
          AND fecha < NEW.fecha
          AND fecha >= DATE_SUB(NEW.fecha , INTERVAL 15 DAY)
    ) THEN
        INSERT INTO alertas_empleado (
            id_empleado, tipo_alerta, fecha_alerta, descripcion
        )
        VALUES (
            NEW.id_empleado,
            'Reactivación',
            NOW(),
            CONCAT('El empleado volvió a registrar actividad laboral despues de un par de dias ', NEW.id_actividad)
        );
    END IF;
END;
//

DELIMITER ;


ALTER TABLE actividad_laboral
MODIFY id_actividad INT AUTO_INCREMENT;

INSERT INTO actividad_laboral ( id_empleado, fecha, descripcion)
VALUES (710 ,60, '2025-08-07', 'Revisión de maquinaria');

select * from actividad_laboral;
SELECT * FROM alertas_empleado ORDER BY id_alerta DESC;
