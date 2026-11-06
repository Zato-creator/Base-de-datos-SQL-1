-- ============================================================
-- ASSETCONTROL | ESTUDIANTES - ESPACIOS PARA RESOLVER
-- Archivo 02/02 - 20 ejercicios DQL
-- Base de datos: assetcontrol
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- No modificar los datos semilla durante esta evaluacion.
-- Alias y etiquetas visibles al cliente pueden estar en espanol.
-- ============================================================

USE assetcontrol;

-- EJEMPLO DE CLASE (no calificable)
SELECT
    a.id AS codigo_activo,
    a.brand AS marca,
    a.model AS modelo,
    a.status AS estado
FROM assets AS a;


-- ------------------------------------------------------------
-- 01. Mostrar el código, marca, modelo y estado de todos los activos, como se trabajó en clase.
-- Escribe tu SELECT aqui:
SELECT a.id AS codigo_activo, a.brand AS marca, a.model AS modelo, a.status AS estado
FROM assets AS a ORDER BY a.id;

-- ------------------------------------------------------------
-- 02. Mostrar cada equipo junto con el nombre de su tipo. Usar alias a y at y un JOIN.
-- Escribe tu SELECT aqui:
SELECT a.id AS codigo_activo, a.brand AS marca, a.model AS modelo, at.name AS tipo
FROM assets AS a JOIN asset_types AS at ON at.id = a.asset_type_id ORDER BY a.id;

-- ------------------------------------------------------------
-- 03. Filtrar los equipos DISPONIBLES que sean de tipo Portátil o Proyector.
-- Escribe tu SELECT aqui:
SELECT a.id AS codigo_activo, a.brand AS marca, a.model AS modelo
FROM assets AS a JOIN asset_types AS at ON at.id = a.asset_type_id
WHERE a.status = 'DISPONIBLE' AND at.name IN ('Portátil','Proyector')
ORDER BY a.id;

-- ------------------------------------------------------------
-- 04. Listar los empleados ACTIVOS del departamento Tecnología, con el nombre del departamento. Ordenar por empleado descendente.
-- Escribe tu SELECT aqui:
SELECT e.name AS empleado, d.name AS departamento
FROM employees AS e JOIN departments AS d ON d.id = e.department_id
WHERE e.status = 'ACTIVO' AND d.name = 'Tecnología'
ORDER BY e.name DESC;

-- ------------------------------------------------------------
-- 05. Listar los equipos comprados entre el 1 de enero de 2025 y el 31 de diciembre de 2025.
-- Escribe tu SELECT aqui:
SELECT a.id AS codigo_activo, a.purchase_date AS fecha_compra, a.brand AS marca
FROM assets AS a
WHERE a.purchase_date BETWEEN '2025-01-01' AND '2025-12-31'
ORDER BY a.purchase_date, a.id;

-- ------------------------------------------------------------
-- 06. Mostrar cada equipo junto a la sede y ciudad a las que pertenece.
-- Escribe tu SELECT aqui:
SELECT a.id AS codigo_activo, s.name AS sede, s.city AS ciudad
FROM assets AS a JOIN sites AS s ON s.id = a.site_id ORDER BY a.id;

-- ------------------------------------------------------------
-- 07. Mostrar los equipos que tienen una asignación vigente y el nombre del empleado que los tiene.
-- Escribe tu SELECT aqui:
SELECT a.patrimonial_identifier AS codigo_activo, e.name AS empleado
FROM assets AS a
JOIN assignments AS ass ON ass.asset_id = a.id AND ass.return_date IS NULL
JOIN employees AS e ON e.id = ass.employee_id
ORDER BY a.patrimonial_identifier;

-- ------------------------------------------------------------
-- 08. Mostrar cada mantenimiento junto con el activo intervenido, el tipo y su costo.
-- Escribe tu SELECT aqui:
SELECT m.id AS codigo_mantenimiento, a.patrimonial_identifier AS codigo_activo,
       m.type AS tipo, m.cost AS costo
FROM maintenance AS m JOIN assets AS a ON a.id = m.asset_id ORDER BY m.id;

-- ------------------------------------------------------------
-- 09. Contar los equipos por estado, ordenados de mayor a menor cantidad.
-- Escribe tu SELECT aqui:
SELECT a.status AS estado, COUNT(*) AS total_equipos
FROM assets AS a GROUP BY a.status
ORDER BY total_equipos DESC, a.status;

-- ------------------------------------------------------------
-- 10. Contar los equipos registrados por sede, incluyendo sedes sin equipos. Usar LEFT JOIN.
-- Escribe tu SELECT aqui:
SELECT s.name AS sede, COUNT(a.id) AS total_equipos
FROM sites AS s LEFT JOIN assets AS a ON a.site_id = s.id
GROUP BY s.id, s.name ORDER BY s.name;

-- ------------------------------------------------------------
-- 11. Calcular el costo total de mantenimientos por activo. Mostrar solo activos con mantenimiento.
-- Escribe tu SELECT aqui:
SELECT a.patrimonial_identifier AS codigo_activo, SUM(m.cost) AS costo_total
FROM assets AS a JOIN maintenance AS m ON m.asset_id = a.id
GROUP BY a.id, a.patrimonial_identifier
ORDER BY costo_total DESC, a.patrimonial_identifier;

-- ------------------------------------------------------------
-- 12. Contar cuántos equipos vigentes tiene cada empleado, incluyendo los que no tienen ninguno.
-- Escribe tu SELECT aqui:
SELECT e.name AS empleado, COUNT(ass.id) AS equipos_vigentes
FROM employees AS e
LEFT JOIN assignments AS ass ON ass.employee_id = e.id AND ass.return_date IS NULL
GROUP BY e.id, e.name ORDER BY e.name;

-- ------------------------------------------------------------
-- 13. Encontrar los tipos de equipo que tengan dos o más activos. Usar HAVING.
-- Escribe tu SELECT aqui:
SELECT at.name AS tipo, COUNT(a.id) AS total_activos
FROM asset_types AS at JOIN assets AS a ON a.asset_type_id = at.id
GROUP BY at.id, at.name
HAVING COUNT(a.id) >= 2
ORDER BY total_activos DESC, at.name;

-- ------------------------------------------------------------
-- 14. Calcular el costo promedio de mantenimiento por tipo: PREVENTIVO o CORRECTIVO.
-- Escribe tu SELECT aqui:
SELECT m.type AS tipo, ROUND(AVG(m.cost), 2) AS costo_promedio
FROM maintenance AS m GROUP BY m.type ORDER BY m.type;

-- ------------------------------------------------------------
-- 15. Mostrar los tres mantenimientos más costosos, con su descripción y costo.
-- Escribe tu SELECT aqui:
SELECT m.id AS codigo_mantenimiento, a.patrimonial_identifier AS codigo_activo,
       m.description AS descripcion, m.cost AS costo
FROM maintenance AS m JOIN assets AS a ON a.id = m.asset_id
ORDER BY m.cost DESC, m.id LIMIT 3;

-- ------------------------------------------------------------
-- 16. Consultar el nombre y departamento de quienes tienen equipos asignados actualmente.
-- Escribe tu SELECT aqui:
SELECT e.name AS empleado, d.name AS departamento, a.patrimonial_identifier AS codigo_activo
FROM employees AS e
JOIN departments AS d ON d.id = e.department_id
JOIN assignments AS ass ON ass.employee_id = e.id AND ass.return_date IS NULL
JOIN assets AS a ON a.id = ass.asset_id
ORDER BY e.name, a.patrimonial_identifier;

-- ------------------------------------------------------------
-- 17. Mostrar los activos que actualmente no tienen ninguna asignación abierta, usando LEFT JOIN e IS NULL.
-- Escribe tu SELECT aqui:
SELECT a.patrimonial_identifier AS codigo_activo, a.brand AS marca, a.model AS modelo
FROM assets AS a
LEFT JOIN assignments AS ass ON ass.asset_id = a.id AND ass.return_date IS NULL
WHERE ass.id IS NULL ORDER BY a.patrimonial_identifier;

-- ------------------------------------------------------------
-- 18 | SUBCONSULTA. SUBCONSULTA: mostrar mantenimientos con costo superior al costo promedio de todos los mantenimientos.
-- Escribe tu SELECT aqui:
SELECT m.id AS codigo_mantenimiento, m.type AS tipo, m.cost AS costo
FROM maintenance AS m
WHERE m.cost > (SELECT AVG(cost) FROM maintenance)
ORDER BY m.cost DESC, m.id;

-- ------------------------------------------------------------
-- 19 | SUBCONSULTA. SUBCONSULTA: buscar empleados que figuren en asignaciones vigentes mediante IN.
-- Escribe tu SELECT aqui:
SELECT e.name AS empleado
FROM employees AS e
WHERE e.id IN (SELECT employee_id FROM assignments WHERE return_date IS NULL)
ORDER BY e.name;

-- ------------------------------------------------------------
-- 20 | SUBCONSULTA. SUBCONSULTA: encontrar activos que nunca han tenido un mantenimiento mediante NOT EXISTS.
-- Escribe tu SELECT aqui:
SELECT a.patrimonial_identifier AS codigo_activo, a.brand AS marca, a.model AS modelo
FROM assets AS a
WHERE NOT EXISTS (SELECT 1 FROM maintenance AS m WHERE m.asset_id = a.id)
ORDER BY a.patrimonial_identifier;
