/* =============================================================
   m5_consultas_joins.sql
   Proyecto: RetailPro (checkpoint M3: base Ventas_Tech_DB)
   Motor utilizado: SQL Server (T-SQL) - SSMS

   Cruce de las tablas de M3 (categorias, clientes, productos, ventas)
   con JOIN para armar la vista que se va a conectar a Power BI en M6.
   El esquema de M3 ya tiene ciudad (clientes) y categorias como
   dimensiones de geografía/segmentación, así que no hizo falta
   agregar ninguna tabla nueva para la Consulta 1.
   ============================================================= */

USE Ventas_Tech_DB;
GO

-- Sumo un cliente y un producto sin ventas para poder probar las
-- consultas de LEFT JOIN de los puntos 2 y 3.
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
  (6, 'Diego Fernández', 'diego@mail.com', 'Salta', '2024-03-20');

INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
  (7, 'Webcam HD', 2, 45.00, 20, 1);
GO


-- =====================================================================
-- CONSULTA 1: Vista base del proyecto (INNER JOIN)
-- Ventas + clientes + productos + categorías en una sola fila.
-- =====================================================================

SELECT
    v.fecha_venta,
    v.id_cliente,
    c.nombre                              AS cliente,
    c.ciudad                              AS ciudad_cliente,
    p.nombre_producto                     AS producto,
    cat.nombre_categoria                  AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario        AS total_venta
FROM ventas v
INNER JOIN clientes c
    ON v.id_cliente = c.id_cliente
INNER JOIN productos p
    ON v.id_producto = p.id_producto
INNER JOIN categorias cat
    ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta;
GO


-- =====================================================================
-- CONSULTA 2: Clientes sin ventas (LEFT JOIN)
-- =====================================================================

SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v
    ON c.id_cliente = v.id_cliente
WHERE v.id_cliente IS NULL;
GO


-- =====================================================================
-- CONSULTA 3: Productos sin ventas (LEFT JOIN)
-- =====================================================================

SELECT
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos p
INNER JOIN categorias cat
    ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v
    ON p.id_producto = v.id_producto
WHERE v.id_producto IS NULL;
GO


-- =====================================================================
-- CONSULTA 4: Consolidado por canal (UNION ALL)
-- No hay columna de canal en ventas, así que la genero como literal
-- dentro de cada SELECT. Separo por quincena (primera y segunda mitad
-- de marzo, que es el único mes cargado) en vez de por sucursal,
-- porque esa dimensión no existe en el esquema.
-- =====================================================================

SELECT canal, SUM(total) AS total_canal
FROM (
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Primera quincena' AS canal
    FROM ventas
    WHERE fecha_venta <= '2024-03-10'

    UNION ALL

    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Segunda quincena' AS canal
    FROM ventas
    WHERE fecha_venta > '2024-03-10'
) AS consolidado
GROUP BY canal;
GO


-- =====================================================================
-- HALLAZGOS
-- =====================================================================

-- 1. El único cliente sin compras es Diego Fernández, que se registró
--    el 20/03 -después de todas las ventas cargadas-, y el único
--    producto sin ventas es la Webcam HD. Tiene sentido: son altas
--    recientes que todavía no tuvieron movimiento.

-- 2. La segunda quincena de marzo facturó $2.824 contra $3.620 de la
--    primera, una caída del 22% dentro del mismo mes. Se explica en
--    buena parte por la Laptop Pro 15: $2.400 de sus $3.600 totales
--    se vendieron en los primeros 10 días.

-- 3. La Consulta 1 deja categoría y ciudad en la misma fila que el
--    total de venta, así que esa vista se puede conectar directo a
--    Power BI en M6 sin necesitar otro cruce.
