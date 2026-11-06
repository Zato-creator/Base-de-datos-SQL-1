# Taller de consultas SQL

Proyecto realizado para practicar consultas en MySQL 8.

## Bases de datos utilizadas

- `helpdesk_pro`: tickets, clientes, técnicos y comentarios.
- `assetcontrol`: activos, empleados, asignaciones y mantenimientos.
- `comprafacil`: solicitudes, productos, órdenes y recepciones.
- `talenttrack`: cursos, matrículas, asistencias y certificados.
- `spacebook`: salas, reservas, participantes y recursos.

## Archivos de cada proyecto

Cada carpeta contiene:

- Un archivo `*_base_datos.sql` con la creación de la base, tablas y datos
  iniciales.
- Un archivo `consultas.sql` con 20 ejercicios de consulta.

## Consultas desarrolladas

Se completaron los 20 ejercicios de cada base de datos:

- `01_HelpDesk_Pro/consultas.sql`
- `02_AssetControl/consultas.sql`
- `03_CompraFacil/consultas.sql`
- `04_TalentTrack/consultas.sql`
- `05_SpaceBook/consultas.sql`

En total se desarrollaron 100 consultas SQL.

## Temas trabajados

Las consultas incluyen:

- filtros con `WHERE`;
- búsquedas con `LIKE`;
- rangos con `BETWEEN`;
- relaciones entre tablas con `JOIN`;
- consultas que conservan registros sin relación usando `LEFT JOIN`;
- agrupaciones con `GROUP BY`;
- filtros de grupos con `HAVING`;
- ordenamiento y límites de resultados;
- subconsultas con `IN` y `NOT EXISTS`;
- conteos, sumas y promedios;
- manejo de valores nulos con `COALESCE`.

## Reglas aplicadas

- Se conservaron los datos semilla de las cinco bases.
- No se ejecutaron los ejemplos de `UPDATE`, `DELETE` ni `TRUNCATE`.
- Se mantuvieron los nombres de tablas y columnas en inglés, minúsculas y
  `snake_case`.
- Se usaron alias en español para los resultados.
- Se revisaron los conteos para evitar duplicados causados por los `JOIN`.
- Las consultas agrupadas se escribieron teniendo en cuenta
  `ONLY_FULL_GROUP_BY`.
- Los valores monetarios, promedios y porcentajes se redondean a dos
  decimales cuando corresponde.

## Archivo del examen

También se trabajó el archivo:

```text
examen_mysql_apellido_nombre.sql
```

Este archivo contiene las diez consultas correspondientes al examen práctico,
organizadas por base de datos.
