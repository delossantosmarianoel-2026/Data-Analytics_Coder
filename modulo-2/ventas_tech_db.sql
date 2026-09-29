/* =============================================================
   ventas_tech_db.sql
   Base de datos: Ventas_Tech_DB
   Autor: DBA de TechStore
   Motor utilizado: SQL Server (T-SQL) - SQL Server Management Studio (SSMS)

   Modelo relacional (3NF):
     categorias (1) ---- (N) productos (1) ---- (N) ventas (N) ---- (1) clientes

   Este script es repetible: puede ejecutarse las veces que se
   quiera sin fallar, porque la Sección 1 elimina las tablas en
   orden inverso a las dependencias antes de volver a crearlas.
   ============================================================= */

/* -------------------------------------------------------------
   Paso previo (no forma parte de las 4 secciones evaluadas):
   crear la base de datos si todavía no existe y seleccionarla.
   Se deja acá, de forma idempotente, para que el script sea
   ejecutable de punta a punta en una instancia nueva de SSMS.
   ------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Ventas_Tech_DB')
BEGIN
    CREATE DATABASE Ventas_Tech_DB;
END
GO

USE Ventas_Tech_DB;
GO


-- =====================================================================
-- SECCIÓN 1: DROP TABLES
-- Se eliminan en orden inverso a las dependencias (primero la tabla de
-- hechos, al final las dimensiones) para no violar las foreign keys.
-- =====================================================================

DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;
GO


-- =====================================================================
-- SECCIÓN 2: CREATE TABLES
-- Orden: primero las tablas que no dependen de nadie (dimensiones),
-- al final la tabla de hechos (ventas), que referencia a las demás.
-- =====================================================================

-- Tabla de dimensión: categorias -----------------------------------
CREATE TABLE categorias (
    id_categoria     INT             NOT NULL,
    nombre_categoria VARCHAR(50)     NOT NULL,
    descripcion      VARCHAR(200)    NULL,
    CONSTRAINT PK_categorias PRIMARY KEY (id_categoria)
);
GO

-- Tabla de dimensión: clientes --------------------------------------
CREATE TABLE clientes (
    id_cliente      INT             NOT NULL,
    nombre          VARCHAR(100)    NOT NULL,
    email           VARCHAR(100)    NULL,
    ciudad          VARCHAR(50)     NULL,
    fecha_registro  DATE            NOT NULL,
    CONSTRAINT PK_clientes PRIMARY KEY (id_cliente),
    CONSTRAINT UQ_clientes_email UNIQUE (email)
);
GO

-- Tabla de dimensión: productos --------------------------------------
-- Depende de categorias (FK id_categoria).
CREATE TABLE productos (
    id_producto      INT             NOT NULL,
    nombre_producto  VARCHAR(100)    NOT NULL,
    id_categoria     INT             NULL,
    precio           DECIMAL(10,2)   NOT NULL,
    stock            INT             DEFAULT 0,
    activo           BIT             DEFAULT 1,
    CONSTRAINT PK_productos PRIMARY KEY (id_producto),
    CONSTRAINT FK_productos_categorias FOREIGN KEY (id_categoria)
        REFERENCES categorias (id_categoria)
);
GO

-- Tabla de hechos: ventas --------------------------------------------
-- Depende de clientes (FK id_cliente) y de productos (FK id_producto).
-- Por eso se crea al final: si intentara crearse antes que sus
-- referencias, el CREATE fallaría ("el huevo y la gallina").
CREATE TABLE ventas (
    id_venta         INT             NOT NULL,
    id_cliente       INT             NULL,
    id_producto      INT             NULL,
    cantidad         INT             NOT NULL,
    precio_unitario  DECIMAL(10,2)   NOT NULL,
    fecha_venta      DATE            NOT NULL,
    CONSTRAINT PK_ventas PRIMARY KEY (id_venta),
    CONSTRAINT FK_ventas_clientes FOREIGN KEY (id_cliente)
        REFERENCES clientes (id_cliente),
    CONSTRAINT FK_ventas_productos FOREIGN KEY (id_producto)
        REFERENCES productos (id_producto)
);
GO


-- =====================================================================
-- SECCIÓN 3: INSERT DATA
-- Orden lógico: primero las tablas sin dependencias (categorias,
-- clientes), después las que dependen de ellas (productos, ventas).
-- Las columnas van explicitadas para que el INSERT no se rompa si en
-- el futuro se agrega una columna nueva a alguna tabla.
-- =====================================================================

-- categorias — 4 registros -------------------------------------------
INSERT INTO categorias (id_categoria, nombre_categoria, descripcion) VALUES
  (1, 'Computación',    'Laptops, PCs y monitores'),
  (2, 'Accesorios',     'Periféricos y complementos'),
  (3, 'Audio',          'Auriculares y parlantes'),
  (4, 'Almacenamiento', 'Discos y memorias');
GO

-- clientes — 5 registros ----------------------------------------------
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
  (1, 'María López',  'maria@mail.com',  'Buenos Aires', '2024-01-05'),
  (2, 'Carlos Ruiz',  'carlos@mail.com', 'Córdoba',      '2024-01-10'),
  (3, 'Ana Gómez',    'ana@mail.com',    'Rosario',      '2024-02-01'),
  (4, 'Pedro Sanz',   'pedro@mail.com',  'Mendoza',      '2024-02-15'),
  (5, 'Laura Torres', 'laura@mail.com',  'Tucumán',      '2024-03-01');
GO

-- productos — 6 registros -----------------------------------------------
INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
  (1, 'Laptop Pro 15',      1, 1200.00, 15, 1),
  (2, 'Mouse Inalámbrico',  2,   28.00, 80, 1),
  (3, 'Monitor 4K 27',      1,  450.00, 12, 1),
  (4, 'Auriculares BT Pro', 3,  120.00, 35, 1),
  (5, 'SSD Externo 1TB',    4,  130.00, 18, 1),
  (6, 'Teclado Mecánico',   2,   95.00, 40, 1);
GO

-- ventas — 10 registros ---------------------------------------------------
INSERT INTO ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
  ( 1, 1, 1, 2, 1200.00, '2024-03-05'),
  ( 2, 2, 2, 5,   28.00, '2024-03-06'),
  ( 3, 3, 3, 1,  450.00, '2024-03-07'),
  ( 4, 1, 4, 2,  120.00, '2024-03-08'),
  ( 5, 4, 5, 3,  130.00, '2024-03-10'),
  ( 6, 2, 6, 4,   95.00, '2024-03-11'),
  ( 7, 5, 1, 1, 1200.00, '2024-03-12'),
  ( 8, 3, 2, 8,   28.00, '2024-03-13'),
  ( 9, 4, 4, 1,  120.00, '2024-03-14'),
  (10, 5, 3, 2,  450.00, '2024-03-15');
GO


-- =====================================================================
-- SECCIÓN 4: VALIDACIÓN
-- Confirma que las cuatro tablas cargaron la cantidad de filas
-- esperada: 4, 5, 6 y 10 respectivamente.
-- =====================================================================

SELECT * FROM categorias;   -- esperado: 4 filas
SELECT * FROM clientes;     -- esperado: 5 filas
SELECT * FROM productos;    -- esperado: 6 filas
SELECT * FROM ventas;       -- esperado: 10 filas
GO
