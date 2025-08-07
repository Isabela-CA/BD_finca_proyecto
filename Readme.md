## BD_Proyecto sobre una finca con produccion agricola

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

#### DBeaver

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



