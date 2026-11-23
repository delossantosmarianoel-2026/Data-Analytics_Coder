/* =============================================================
   m10_validacion_estadistica.sql
   Proyecto: RetailPro - Pre-entrega Módulo 10
   Motor utilizado: SQL Server (T-SQL) - SSMS
   Autora: María Noel de los Santos

   Parte 1: caso guiado (tabla ventas_semana).
   Parte 2: validación estadística de la tabla de hechos que alimenta
            el dashboard (Fact_Ventas del Checkpoint 2, 50 ventas,
            ene-2023 a jul-2024, origen Pipeline_ETL_Dataset.xlsx).

   Notas de sintaxis T-SQL (la consigna usa sintaxis PostgreSQL):
   - STDDEV_SAMP() no existe en SQL Server: el equivalente muestral
     es STDEV().
   - PERCENTILE_CONT en SQL Server es una función de ventana, no una
     agregación: exige OVER (). Por eso devuelve el mismo valor en
     cada fila y se usa SELECT DISTINCT / TOP 1 para quedarse con una.
     El cálculo (interpolación lineal) es el mismo que en PostgreSQL.
   ============================================================= */

USE Ventas_Tech_DB;
GO


-- =====================================================================
-- PARTE 1 - CASO GUIADO: ventas_semana
-- =====================================================================

DROP TABLE IF EXISTS ventas_semana;
GO

CREATE TABLE ventas_semana (
    sucursal  VARCHAR(10)    NOT NULL,
    dia       INT            NOT NULL,
    venta     DECIMAL(10,2)  NOT NULL
);
GO

INSERT INTO ventas_semana (sucursal, dia, venta) VALUES
  ('Norte', 1, 500), ('Norte', 2, 510), ('Norte', 3, 490), ('Norte', 4, 505), ('Norte', 5, 495),
  ('Sur',   1, 100), ('Sur',   2, 900), ('Sur',   3,  50), ('Sur',   4, 1200), ('Sur',  5, 250);
GO

-- 1.1 Media y rango
-- Esperado: Norte media 500, rango 20 | Sur media 500, rango 1.150
SELECT
    sucursal,
    AVG(venta)              AS media,
    MAX(venta) - MIN(venta) AS rango
FROM ventas_semana
GROUP BY sucursal;
GO

-- 1.2 Desviación estándar muestral y coeficiente de variación
-- Esperado: Norte 7,91 (CV 1,6%) | Sur 518,41 (CV 103,7%)
SELECT
    sucursal,
    STDEV(venta)                              AS desvio_muestral,
    ROUND(STDEV(venta) / AVG(venta) * 100, 1) AS cv_porcentaje
FROM ventas_semana
GROUP BY sucursal;
GO


-- =====================================================================
-- PARTE 2 - RETAILPRO: tabla de hechos del dashboard
-- La tabla "ventas" de M3 (10 filas) no tiene total_venta ni canal,
-- así que se carga aparte la Fact_Ventas que usa Power BI.
-- =====================================================================

DROP TABLE IF EXISTS fact_ventas;
GO

CREATE TABLE fact_ventas (
    id_venta         INT            NOT NULL,
    fecha_venta      DATE           NOT NULL,
    id_cliente       INT            NOT NULL,
    id_producto      INT            NOT NULL,
    cantidad         INT            NOT NULL,
    precio_unitario  DECIMAL(10,2)  NOT NULL,
    descuento        DECIMAL(4,2)   NOT NULL,
    total_venta      DECIMAL(10,2)  NOT NULL,
    canal            VARCHAR(20)    NOT NULL,
    CONSTRAINT PK_fact_ventas PRIMARY KEY (id_venta)
);
GO

INSERT INTO fact_ventas
  (id_venta, fecha_venta, id_cliente, id_producto, cantidad, precio_unitario, descuento, total_venta, canal)
VALUES
  (1001, '2023-01-10', 1, 101, 2, 1200.00, 0.00, 2400.00, 'Online'),
  (1002, '2023-01-15', 2, 102, 5, 28.00, 0.00, 140.00, 'Presencial'),
  (1003, '2023-01-22', 3, 103, 1, 450.00, 0.05, 427.50, 'Online'),
  (1004, '2023-02-05', 4, 104, 3, 95.00, 0.00, 285.00, 'Presencial'),
  (1005, '2023-02-14', 5, 105, 2, 650.00, 0.00, 1300.00, 'Online'),
  (1006, '2023-02-28', 1, 106, 4, 120.00, 0.10, 432.00, 'Online'),
  (1007, '2023-03-08', 6, 107, 6, 45.00, 0.00, 270.00, 'Presencial'),
  (1008, '2023-03-15', 7, 108, 2, 85.00, 0.00, 170.00, 'Online'),
  (1009, '2023-03-22', 8, 109, 3, 130.00, 0.05, 370.50, 'Presencial'),
  (1010, '2023-04-03', 9, 110, 5, 60.00, 0.00, 300.00, 'Online'),
  (1011, '2023-04-18', 10, 111, 1, 1800.00, 0.00, 1800.00, 'Online'),
  (1012, '2023-04-25', 2, 101, 1, 1200.00, 0.00, 1200.00, 'Presencial'),
  (1013, '2023-05-06', 3, 102, 8, 28.00, 0.00, 224.00, 'Online'),
  (1014, '2023-05-20', 4, 103, 2, 450.00, 0.10, 810.00, 'Presencial'),
  (1015, '2023-05-30', 5, 104, 4, 95.00, 0.00, 380.00, 'Online'),
  (1016, '2023-06-08', 6, 105, 2, 650.00, 0.00, 1300.00, 'Presencial'),
  (1017, '2023-06-15', 7, 106, 3, 120.00, 0.05, 342.00, 'Online'),
  (1018, '2023-06-28', 8, 109, 2, 130.00, 0.00, 260.00, 'Online'),
  (1019, '2023-07-05', 9, 110, 6, 60.00, 0.00, 360.00, 'Presencial'),
  (1020, '2023-07-19', 10, 108, 3, 85.00, 0.00, 255.00, 'Online'),
  (1021, '2023-08-02', 1, 111, 2, 1800.00, 0.10, 3240.00, 'Online'),
  (1022, '2023-08-14', 2, 102, 10, 28.00, 0.00, 280.00, 'Presencial'),
  (1023, '2023-08-25', 3, 105, 1, 650.00, 0.00, 650.00, 'Online'),
  (1024, '2023-09-10', 4, 106, 5, 120.00, 0.05, 570.00, 'Presencial'),
  (1025, '2023-09-22', 5, 103, 3, 450.00, 0.00, 1350.00, 'Online'),
  (1026, '2023-10-04', 6, 101, 1, 1200.00, 0.00, 1200.00, 'Presencial'),
  (1027, '2023-10-18', 7, 107, 8, 45.00, 0.00, 360.00, 'Online'),
  (1028, '2023-11-06', 8, 104, 6, 95.00, 0.10, 513.00, 'Presencial'),
  (1029, '2023-11-20', 9, 109, 4, 130.00, 0.00, 520.00, 'Online'),
  (1030, '2023-12-05', 10, 111, 3, 1800.00, 0.00, 5400.00, 'Online'),
  (1031, '2023-12-15', 1, 110, 7, 60.00, 0.00, 420.00, 'Presencial'),
  (1032, '2023-12-28', 2, 105, 2, 650.00, 0.05, 1235.00, 'Online'),
  (1033, '2024-01-08', 3, 101, 2, 1200.00, 0.00, 2400.00, 'Online'),
  (1034, '2024-01-15', 4, 102, 6, 28.00, 0.00, 168.00, 'Presencial'),
  (1035, '2024-01-25', 5, 103, 1, 450.00, 0.00, 450.00, 'Online'),
  (1036, '2024-02-03', 6, 104, 4, 95.00, 0.10, 342.00, 'Presencial'),
  (1037, '2024-02-14', 7, 106, 3, 120.00, 0.00, 360.00, 'Online'),
  (1038, '2024-02-22', 8, 109, 2, 130.00, 0.05, 247.00, 'Online'),
  (1039, '2024-03-05', 9, 111, 1, 1800.00, 0.00, 1800.00, 'Presencial'),
  (1040, '2024-03-18', 10, 105, 3, 650.00, 0.00, 1950.00, 'Online'),
  (1041, '2024-03-28', 1, 107, 10, 45.00, 0.00, 450.00, 'Presencial'),
  (1042, '2024-04-06', 2, 108, 4, 85.00, 0.00, 340.00, 'Online'),
  (1043, '2024-04-20', 3, 110, 8, 60.00, 0.05, 456.00, 'Presencial'),
  (1044, '2024-05-04', 4, 101, 2, 1200.00, 0.00, 2400.00, 'Online'),
  (1045, '2024-05-18', 5, 103, 3, 450.00, 0.00, 1350.00, 'Presencial'),
  (1046, '2024-06-02', 6, 106, 5, 120.00, 0.10, 540.00, 'Online'),
  (1047, '2024-06-15', 7, 109, 3, 130.00, 0.00, 390.00, 'Presencial'),
  (1048, '2024-06-28', 8, 111, 2, 1800.00, 0.00, 3600.00, 'Online'),
  (1049, '2024-07-10', 9, 102, 12, 28.00, 0.00, 336.00, 'Presencial'),
  (1050, '2024-07-22', 10, 105, 2, 650.00, 0.05, 1235.00, 'Online');
GO

-- Control: 50 filas, total 47.578,00 (igual al Total Ventas del dashboard)
SELECT COUNT(*) AS filas, SUM(total_venta) AS total FROM fact_ventas;
GO


-- ---------------------------------------------------------------------
-- 2a) Media vs. mediana del total de venta
-- Esperado: media 951,56 | mediana 450,00 | desvío 1.041,76
-- ---------------------------------------------------------------------
SELECT DISTINCT
    ROUND(AVG(total_venta)   OVER (), 2)                                AS media,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_venta) OVER ()    AS mediana,
    ROUND(STDEV(total_venta) OVER (), 2)                                AS desvio_muestral,
    MIN(total_venta) OVER ()                                            AS minimo,
    MAX(total_venta) OVER ()                                            AS maximo
FROM fact_ventas;
GO

-- Cuántas ventas quedan por debajo del promedio
-- Esperado: 33 de 50 (66%)
SELECT COUNT(*) AS ventas_bajo_la_media
FROM fact_ventas
WHERE total_venta < (SELECT AVG(total_venta) FROM fact_ventas);
GO


-- ---------------------------------------------------------------------
-- 2b) Outliers con el método IQR
-- Esperado: Q1 340,50 | Q3 1.283,75 | IQR 943,25
--           límite inferior -1.074,38 | límite superior 2.698,63
-- ---------------------------------------------------------------------
WITH q AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_venta) OVER () AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_venta) OVER () AS q3
    FROM fact_ventas
)
SELECT
    q1,
    q3,
    q3 - q1               AS iqr,
    q1 - 1.5 * (q3 - q1)  AS limite_inferior,
    q3 + 1.5 * (q3 - q1)  AS limite_superior
FROM q;
GO

-- Registros fuera de los límites, con producto y cliente para interpretarlos
-- Esperado: 3 filas (1021: 3.240 | 1030: 5.400 | 1048: 3.600), todas Laptop Gaming Pro
WITH q AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_venta) OVER () AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_venta) OVER () AS q3
    FROM fact_ventas
)
SELECT
    v.id_venta,
    v.fecha_venta,
    v.id_cliente,
    v.id_producto,
    v.cantidad,
    v.precio_unitario,
    v.descuento,
    v.total_venta,
    v.canal,
    -- control de carga: el total tiene que ser cantidad x precio x (1 - descuento)
    CASE WHEN v.total_venta = v.cantidad * v.precio_unitario * (1 - v.descuento)
         THEN 'Coherente' ELSE 'Revisar' END AS control_total
FROM fact_ventas v
CROSS JOIN q
WHERE v.total_venta < q.q1 - 1.5 * (q.q3 - q.q1)
   OR v.total_venta > q.q3 + 1.5 * (q.q3 - q.q1)
ORDER BY v.total_venta DESC;
GO

-- Sensibilidad: media y mediana sin los outliers
-- Esperado: 47 ventas | media 751,87 | mediana 432,00
WITH q AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_venta) OVER () AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_venta) OVER () AS q3
    FROM fact_ventas
),
sin_outliers AS (
    SELECT v.total_venta
    FROM fact_ventas v
    CROSS JOIN q
    WHERE v.total_venta BETWEEN q.q1 - 1.5 * (q.q3 - q.q1)
                            AND q.q3 + 1.5 * (q.q3 - q.q1)
)
SELECT DISTINCT
    COUNT(*)         OVER ()                                          AS ventas,
    ROUND(AVG(total_venta) OVER (), 2)                                AS media,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_venta) OVER ()  AS mediana
FROM sin_outliers;
GO


-- ---------------------------------------------------------------------
-- 2c) Peso de los outliers en los meses pico del gráfico de tendencia
-- Esperado: ago-2023 3.240 de 4.170 | dic-2023 5.400 de 7.055 | jun-2024 3.600 de 4.530
-- ---------------------------------------------------------------------
SELECT
    YEAR(fecha_venta)                                             AS anio,
    MONTH(fecha_venta)                                            AS mes,
    SUM(total_venta)                                              AS total_mes,
    SUM(CASE WHEN id_producto = 111 THEN total_venta ELSE 0 END)  AS laptop_gaming_pro,
    ROUND(SUM(CASE WHEN id_producto = 111 THEN total_venta ELSE 0 END)
          / SUM(total_venta) * 100, 1)                            AS pct_laptop_gaming
FROM fact_ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY anio, mes;
GO
