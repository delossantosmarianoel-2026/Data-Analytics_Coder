/* =============================================================
   m4_consultas_negocio.sql
   Proyecto: RetailPro (checkpoint M3: base Ventas_Tech_DB)
   Motor utilizado: SQL Server (T-SQL) - SQL Server Management Studio (SSMS)

   Objetivo: responder con SQL las preguntas de negocio del brief
   de M1, trabajando sobre la tabla de hechos "ventas"
   (id_cliente, id_producto, cantidad, precio_unitario, fecha_venta).
   Los nombres de cliente/producto se incorporan recién en M5 con JOIN.

   Nota de sintaxis: la consigna sugiere EXTRACT(MONTH FROM fecha_venta)
   para agrupar por mes, pero esa función no existe en T-SQL/SQL Server
   (es sintaxis de PostgreSQL/MySQL/estándar ANSI). El equivalente en
   SQL Server es DATEPART(MONTH, fecha_venta), que se usa en todo este
   archivo y devuelve exactamente lo mismo: el número de mes (1-12).
   ============================================================= */

USE Ventas_Tech_DB;
GO


-- =====================================================================
-- CONSULTA 1: Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio, por mes.
-- =====================================================================

SELECT
    DATEPART(MONTH, fecha_venta)                                   AS mes,
    SUM(cantidad * precio_unitario)                                AS total_facturado,
    COUNT(*)                                                       AS cantidad_pedidos,
    ROUND(SUM(cantidad * precio_unitario) / COUNT(*), 2)           AS ticket_promedio
FROM ventas
GROUP BY DATEPART(MONTH, fecha_venta)
ORDER BY mes;
GO


-- =====================================================================
-- CONSULTA 2: Ranking de productos
-- Top 5 de id_producto por total facturado, con unidades vendidas.
-- =====================================================================

SELECT TOP 5
    id_producto,
    SUM(cantidad)                       AS unidades_vendidas,
    SUM(cantidad * precio_unitario)     AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;
GO


-- =====================================================================
-- CONSULTA 3: Clientes recurrentes
-- id_cliente con más de un pedido, con cantidad de pedidos y gasto total.
-- =====================================================================

SELECT
    id_cliente,
    COUNT(*)                            AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)     AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;
GO


-- =====================================================================
-- CONSULTA 4: Meses por encima/por debajo del promedio
-- Total facturado por mes, etiquetado contra el promedio mensual general.
-- =====================================================================

WITH ventas_por_mes AS (
    SELECT
        DATEPART(MONTH, fecha_venta)      AS mes,
        SUM(cantidad * precio_unitario)   AS total_facturado
    FROM ventas
    GROUP BY DATEPART(MONTH, fecha_venta)
)
SELECT
    mes,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM ventas_por_mes)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM ventas_por_mes
ORDER BY mes;
GO


-- =====================================================================
-- HALLAZGOS
-- Lectura de los resultados obtenidos al correr las 4 consultas
-- sobre los 10 registros cargados en el checkpoint de M3.
-- =====================================================================

-- 1. El producto 1 (Laptop Pro 15) concentra el 55,9% de toda la
--    facturación ($3.600 de $6.444 totales) a pesar de haberse vendido
--    apenas 3 unidades. Es el caso opuesto al producto 2 (Mouse
--    Inalámbrico), que vendió 13 unidades -el mayor volumen de todos-
--    pero solo representa el 5,6% de la facturación: mucho volumen,
--    poco valor por unidad.

-- 2. Los 5 clientes cargados en M3 son "recurrentes" según la Consulta 3
--    (los 5 hicieron más de un pedido), pero el gasto está muy
--    concentrado: el cliente 1 y el cliente 5 explican juntos el 73,6%
--    de lo facturado ($4.740 de $6.444), mientras que el cliente 4 gastó
--    apenas $510, siete veces menos que el cliente 1.

-- 3. El producto 2 (Mouse Inalámbrico) es el de mayor volumen de todos
--    -13 unidades vendidas, más del doble que cualquier otro producto-
--    pero solo representa el 5,6% de la facturación total ($364 de
--    $6.444). Es un producto de alto tráfico y bajo ticket: conviene
--    evaluar combinarlo en un bundle con productos de mayor margen
--    (por ejemplo, con el Teclado Mecánico o los Auriculares BT Pro)
--    para subir el ticket promedio sin perder el volumen de ventas que
--    ya genera.
