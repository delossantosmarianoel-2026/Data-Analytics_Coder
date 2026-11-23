# RetailPro — Proyecto de Data Analytics

Proyecto integrador del curso de Data Analytics (Coderhouse), que recorre el ciclo completo de
análisis de datos para **RetailPro**, una cadena retail ficticia: diseño de base de datos,
consultas SQL de negocio, modelo con joins, modelado en Power BI y documentación con apoyo de IA.

**Autora:** María Noel de los Santos

## Objetivo del proyecto

RetailPro necesita entender qué factores explican las diferencias en su desempeño comercial
(ventas, productos, clientes) para poder priorizar sus acciones. Este repositorio documenta,
paso a paso, el trabajo de análisis que responde esa pregunta: desde el diseño de la base de
datos relacional hasta el dashboard final en Power BI.

## Estructura del repositorio

| Carpeta | Módulo | Contenido |
|---|---|---|
| `modulo-2/` | M2–M3 | Script de creación y carga de la base `Ventas_Tech_DB` (`ventas_tech_db.sql`), según el modelo relacional en 3NF diseñado en M2. |
| `modulo-4/` | M4 | Consultas SQL de negocio sobre la tabla de hechos `ventas` (resumen mensual, ranking de productos, clientes recurrentes, comparación contra el promedio). |
| `modulo-5/` | M5 | Consultas SQL con `JOIN` y `UNION ALL` que cruzan `ventas`, `clientes`, `productos` y `categorias` en una vista base lista para conectar a Power BI. |
| `modulo-10/` | M10 | Validación estadística de la tabla de hechos del dashboard: media vs. mediana del ticket, desvío estándar y detección de outliers con el método IQR. |

> El modelo de datos en Power BI (relaciones, medidas DAX y dashboard) se trabaja en los módulos
> siguientes del curso (M6–M8) y se documenta por separado en los entregables correspondientes.

## Modelo de datos

Base de datos `Ventas_Tech_DB`, en tercera forma normal (3NF):

```
categorias (1) ---- (N) productos (1) ---- (N) ventas (N) ---- (1) clientes
```

- **categorias**: dimensión de categoría de producto.
- **clientes**: dimensión de clientes (nombre, email, ciudad, fecha de registro).
- **productos**: dimensión de productos, con FK a `categorias`.
- **ventas**: tabla de hechos, con FK a `clientes` y a `productos`.

## Herramientas utilizadas

- **SQL Server (T-SQL)**, vía SQL Server Management Studio (SSMS), para el diseño de la base y
  las consultas de negocio.
- **Power BI Desktop**, para el modelado de datos (relaciones, tabla de calendario, medidas DAX)
  y la construcción del dashboard ejecutivo.
- **IA generativa (Claude)**, como co-piloto para optimizar consultas SQL, generar insights
  preliminares sobre resultados y documentar el proyecto — siempre con revisión y validación
  manual antes de aceptar cualquier sugerencia (ver sección siguiente).

## Cómo ejecutar los scripts SQL

Los scripts tienen dependencias entre sí (claves foráneas), así que **deben ejecutarse en este
orden**, todos contra la misma base `Ventas_Tech_DB` en SQL Server (SSMS u otro cliente T-SQL):

1. **`modulo-2/` — script de creación de base** (`ventas_tech_db.sql`): crea las 4 tablas
   (`categorias`, `clientes`, `productos`, `ventas`) y carga los datos semilla. Es idempotente:
   puede correrse varias veces sin fallar, porque elimina las tablas existentes antes de
   recrearlas.
2. **`modulo-4/m4_consultas_negocio.sql`**: las 4 consultas de negocio sobre `ventas` sola
   (resumen mensual, ranking de productos, clientes recurrentes, comparación contra el
   promedio). No requiere los `JOIN` del paso 3.
3. **`modulo-5/m5_consultas_joins.sql`**: agrega un cliente y un producto sin ventas (para poder
   probar los `LEFT JOIN`), y corre las consultas que cruzan las 4 tablas — incluida la vista
   base (`INNER JOIN`) que después se conecta a Power BI.
4. **`modulo-10/m10_validacion_estadistica.sql`**: crea `ventas_semana` (caso guiado) y
   `fact_ventas` (las 50 ventas que usa el dashboard) y corre las validaciones estadísticas.
   Cada consulta trae anotado el resultado esperado.

**Importante:** los scripts usan sintaxis de **T-SQL / SQL Server** (por ejemplo,
`DATEPART(MONTH, fecha)` en vez de `EXTRACT(MONTH FROM fecha)`). Si los corrés en PostgreSQL o
MySQL vas a necesitar adaptar esas funciones a la sintaxis de ese motor.

## Uso de IA en este proyecto

Como parte de la pre-entrega "IA en el flujo del proyecto", se usó IA generativa (Claude) para:

- Revisar y sugerir mejoras sobre la consulta base con `JOIN` (M5).
- Generar una primera lectura de los resultados de las consultas de negocio (M4), contrastada
  siempre contra el análisis propio antes de incorporarla a las conclusiones del proyecto.
- Generar un primer borrador de este mismo README, editado después con criterio propio.

El detalle de los prompts usados, las sugerencias recibidas y la evaluación crítica de cada una
está documentado en la pre-entrega correspondiente del proyecto (no en este repositorio).
