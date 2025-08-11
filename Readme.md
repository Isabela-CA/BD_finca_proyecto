## BD_Proyecto sobre una finca con produccion agricola

![Base de Datos](https://agbaragriculture.com/wp-content/uploads/2021/07/1626431446.jpeg)

 produccion agricola

Es un sistema de base de datos relacional desarrollado en MySQL, cuyo objetivo es centralizar y automatizar las operaciones de una finca dedicada a la producción y comercialización de productos agrícolas, ganaderos y procesados.

Este sistema permite registrar y controlar de manera eficiente todos los aspectos clave de la finca, tales como:

- **Producción agrícola y ganadera**: Registro detallado de los productos generados, fechas, maquinaria utilizada, empleados involucrados y lotes producidos.
- **Gestión de inventario**: Monitoreo de las **unidades disponibles**, sus cambios por ventas o producción, y actualizaciones automáticas.
- **Ventas y compras**: Registro completo de transacciones comerciales con clientes y proveedores, con desglose por producto, cantidad y precios unitarios.
- **Recursos humanos**: Gestión de empleados, sus actividades laborales diarias y las máquinas que operan.
- **Maquinaria y mantenimiento**: Seguimiento del estado, uso y mantenimiento de equipos agrícolas.
- **Control de costos**: Registro de costos asociados a producción, mano de obra y maquinaria.
- **Automatización**: Uso de procedimientos almacenados, funciones, triggers y eventos para optimizar tareas operativas recurrentes.

El diseño sigue los principios de normalización hasta Tercera Forma Normal (3FN), garantizando integridad, consistencia y eficiencia en el manejo de los datos. Este sistema está preparado para generar reportes de apoyo a la toma de decisiones y para escalar según el crecimiento de la finca.

#### Requisitos del sistema

#### 1. **Motor de Base de Datos**

- **MySQL Community Server**

  - **Versión recomendada:** `8.0.x` o superior.

  - **Motivo:** Soporta eventos, triggers, funciones, procedimientos almacenados y gestión avanzada de usuarios y roles.

    

#### 2. **Cliente SQL para gestionar la base de datos**

se utilizo la siguiente aplicacion 

#### DBeaver y MySQL Workbrench

- interfaz más versátil y multiplataforma.
- Esta herramienta ofrece una amplia gama de funciones para scripting SQL, visualización, gestión y transferencia de datos

#### Organizacion

el repositorio esta organizado de la siguiente manera: 

**Carga la estructura de la base de datos**:

- ddl.sql (Creación de base de datos con tabls y relaciones)

**Carga los datos iniciales**:

- dml.sql (inserciones de datos)

**Ejecución de componentes SQL**:

- dql_select.sql (Consultas)
- dql_procedimientos.sql (procedimientos almacenados)
- dql_funciones.sql (funciones)
- dql. triggers.sql (triggers)
- dql. eventos.sql (eventos)

#### Instalación y Configuración

**1. Clonar el repositorio (opcional si ya tienes los archivos en local):** 

*git clone https://github.com/usuario/BD_finca_proyecto.git*
*cd BD_finca_proyecto*

**2. Abrir MySQL Workbench o DBeaver e iniciar sesión en el servidor MySQL.**

**3. Ejecutar el script de creación de base de datos (ddl.sql) para generar la estructura y relaciones:**

*SOURCE ruta/ddl.sql;*

**4. Cargar los datos iniciales (dml.sql):**

*SOURCE ruta/dml.sql;*

**5. Ejecutar los demás scripts según necesidad:**

*SOURCE ruta/dql_select.sql;         -- Consultas*
*SOURCE ruta/dql_procedimientos.sql; -- Procedimientos almacenados*
*SOURCE ruta/dql_funciones.sql;      -- Funciones*
*SOURCE ruta/dql_triggers.sql;       -- Triggers*
*SOURCE ruta/dql_eventos.sql;        -- Eventos*

**6. Verificar carga de tablas:**

*SHOW TABLES;*

#### Estructura de la Base de Datos

**Tablas principales**
- Producto – Información de cada producto agrícola, ganadero o procesado, con su tipo, unidad de medida y precio.

- Empleado – Datos personales, cargo, fecha de ingreso, salario y área asignada.

- Maquinaria – Inventario de maquinaria utilizada, con tipo, fecha de adquisición y estado.

- Mantenimiento_maquinaria – Historial de mantenimientos realizados a la maquinaria.

- Proveedor – Información de proveedores, contactos y dirección.

- Cliente – Datos de clientes y su información de contacto.

- Inventario – Cantidad disponible de cada producto y fecha de última actualización.

- Venta – Registro de ventas realizadas a clientes.

- Detalle_Venta – Productos, cantidades y precios unitarios de cada venta.

- Compra – Registro de compras realizadas a proveedores.

- Detalle_Compra – Productos, cantidades y precios unitarios de cada compra.

- Producción – Registro de producción de productos, con fecha, cantidad, empleado y maquinaria utilizada.

- Lote – Detalle de lotes generados en la producción.

- Costos – Registro de costos asociados a empleados, maquinaria y producción.

**Entidades de relación y apoyo**
- Empleado_Maquinaria – Relación de qué empleados operan qué maquinaria, en qué fecha y con qué actividad.

- Actividad_Laboral – Registro de actividades laborales diarias o por evento realizadas por los empleados.

**Relaciones clave**
- Un empleado puede operar varias maquinarias y realizar múltiples actividades laborales.

- Un producto puede ser vendido a clientes, comprado a proveedores o producido en la finca.

- La producción puede generar uno o varios lotes.

- Ventas y compras se detallan en sus respectivas tablas de detalle.

- Costos pueden asociarse a empleados, maquinaria o producción.

#### Ejemplos de Consulta

A continuación, se presentan ejemplos de consultas SQL que pueden ejecutarse en la base de datos. Incluyen casos básicos y avanzados, con su descripción y resultado esperado.

**Producción total por mes**

*SELECT DATE_FORMAT(fecha_produccion, '%Y-%m') AS mes,*
      *SUM(cantidad_producida) AS total_producido*
*FROM produccion*
*GROUP BY mes*
*ORDER BY mes DESC;*

**Descripción:** Muestra la cantidad total producida en cada mes, útil para evaluar la productividad general.

**Promedio de duración de actividades por área**

*SELECT promedio_area.area,*
       *ROUND(promedio_area.promedio_horas, 2) AS promedio_horas*
*FROM (*
    *SELECT area,*
           *AVG(duracion_horas) AS promedio_horas*
    *FROM actividad_laboral*
    *GROUP BY area*
*) AS promedio_area*
*ORDER BY promedio_area.promedio_horas DESC;*

**Descripción:** Calcula el tiempo promedio dedicado a cada área de trabajo, útil para identificar sobrecargas y cuellos de botella.

#### Procedimientos, Funciones, Triggers y Eventos

En este proyecto se han creado diferentes elementos avanzados de MySQL para automatizar procesos, mantener la integridad de los datos y realizar tareas programadas.

**1. Procedimientos Almacenados**

Permiten ejecutar secuencias de instrucciones SQL encapsuladas bajo un nombre, evitando repetir código y mejorando la eficiencia.
Son útiles para operaciones complejas como registrar una venta, generar un reporte o procesar datos masivamente.

*DELIMITER //*
*CREATE PROCEDURE actualizar_inventario_manual(*
    *IN p_id_producto INT,*
    *IN p_nueva_cantidad DECIMAL(10,0)*
*)*
*BEGIN*
    *UPDATE inventario*
    *SET cantidad_disponible = p_nueva_cantidad,*
        *fecha_ultima_actualizacion = CURDATE()*
    *WHERE id_producto = p_id_producto;*
*END //*
*DELIMITER ;*

*-- Ejemplo de uso:*
*CALL actualizar_inventario_manual(1, 50);*
*SELECT * FROM inventario WHERE id_producto = 1;*

**Descripción:**
Permite modificar manualmente el inventario de un producto, útil para correcciones por errores de registro o ajustes operativos.

**2. Funciones (Stored Functions)**
Son similares a los procedimientos, pero devuelven un valor y se pueden usar directamente en consultas SQL.
Sirven para cálculos recurrentes como aplicar impuestos, calcular descuentos o márgenes de ganancia.

*DELIMITER //*
*CREATE FUNCTION total_horas_laboradas_empleado(pid INT)*
*RETURNS DECIMAL(10,2)*
*DETERMINISTIC*
*BEGIN*
    *DECLARE total DECIMAL(10,2);*
    *SELECT SUM(duracion_horas) INTO total*
    *FROM actividad_laboral*
    *WHERE id_empleado = pid;*
    *RETURN IFNULL(total,0);*
*END //*
*DELIMITER ;*

*-- Ejemplo de uso:*
*SELECT total_horas_laboradas_empleado(3);*

**Descripción:**
Devuelve el total de horas trabajadas por un empleado según los registros de la tabla actividad_laboral.
Si el empleado no tiene registros, devuelve 0.

**3. Triggers (Disparadores)**
Se ejecutan automáticamente en respuesta a ciertos eventos INSERT, UPDATE o DELETE sobre una tabla.
Sirven para mantener la coherencia de los datos o generar acciones automáticas, como auditorías o actualizaciones de stock.

*DELIMITER //*
*CREATE TRIGGER trg_finalizar_mantenimiento*
*AFTER UPDATE ON mantenimiento_maquinaria*
*FOR EACH ROW*
*BEGIN*
    *IF NEW.fecha_fin IS NOT NULL AND OLD.fecha_fin IS NULL THEN*
        *UPDATE maquinaria*
        *SET estado = 'operativa'*
        *WHERE id_maquinaria = NEW.id_maquinaria;*
    *END IF;*
*END//*
*DELIMITER ;*

**Descripción:**
Cuando se actualiza un registro en mantenimiento_maquinaria y se agrega la fecha de finalización (fecha_fin), el estado de la maquinaria pasa automáticamente a "operativa".
Esto evita olvidos al actualizar manualmente el estado.

**4. Eventos Programados (Events)**
Permiten ejecutar tareas automáticamente en un intervalo de tiempo específico, sin intervención manual.
Son útiles para generar reportes periódicos, eliminar registros antiguos o realizar copias de seguridad automáticas.

*CREATE EVENT actualizar_precio_promedio_producto*
*ON SCHEDULE EVERY 1 MONTH*
*STARTS '2025-09-01 00:00:00'*
*DO*
*UPDATE producto p*
*SET p.precio_promedio_compra = (*
    *SELECT AVG(dc.precio_unitario)*
    *FROM detalle_compra dc*
    *WHERE dc.id_producto = p.id_producto*
*);*

*-- Nota: Asegúrate de activar el programador de eventos:*
*SET GLOBAL event_scheduler = ON;*

**Descripción:**
Calcula mensualmente el precio promedio de compra de cada producto usando los registros de detalle_compra y actualiza el campo precio_promedio_compra en la tabla producto.

#### Contribuciones

**Isabella**

- Creación de 8 tablas en *ddl.sql* (modelo de base de datos y relaciones).

- Inserción de 25 registros en *dml.sql.*

- Desarrollo de 50 consultas SQL en *dql_select.sql.*

- Creación de 10 procedimientos almacenados en *dql_procedimientos.sql.*

- Creación de 10 funciones en *dql_funciones.sql.*

- Creación de 10 triggers en *dql_triggers.sql.*

- Creación de 10 eventos programados en *dql_eventos.sql.*

- Diseño del diagrama de la base de datos (Diagrama.jpg).

- Colaboración en la redacción del README.md.

**Brayan**

- Creación de 8 tablas en *ddl.sql* (modelo de base de datos y relaciones).

- Inserción de 25 registros en *dml.sql.*

- Desarrollo de 50 consultas SQL en *dql_select.sql.*

- Creación de 10 procedimientos almacenados en *dql_procedimientos.sql.*

- Creación de 10 funciones en *dql_funciones.sql.*

- Creación de 10 triggers en d*ql_triggers.sql.*

- Creación de 10 eventos programados en *dql_eventos.sql.*

- Colaboración en la redacción del README.md.

#### Licencia y Contacto

Este proyecto está bajo la licencia CampusLands.
- Contacto Isabella: icarrilloazain@gmail.com
- GitHub: https://github.com/Isabela-CA

- Contacto Brayan: brayan21120409@gmail.com
- GitHub: https://github.com/Brayanmantilla