-- ============================================================
-- TALENTTRACK | ESTUDIANTES - ESPACIOS PARA RESOLVER
-- Archivo 02/02 - 20 ejercicios DQL
-- Base de datos: talenttrack
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- No modificar los datos semilla durante esta evaluacion.
-- Alias y etiquetas visibles al cliente pueden estar en espanol.
-- ============================================================

USE talenttrack;

-- EJEMPLO DE CLASE (no calificable)
SELECT
    c.id AS codigo_curso,
    c.name AS curso,
    c.duration_hours AS horas
FROM courses AS c;


-- ------------------------------------------------------------
-- 01. Mostrar código, nombre y duración en horas de todos los cursos.
-- Escribe tu SELECT aqui:
SELECT c.code AS codigo_curso, c.name AS curso, c.duration_hours AS horas
FROM courses AS c ORDER BY c.code;

-- ------------------------------------------------------------
-- 02. Listar ediciones en estado ABIERTA o EN_CURSO cuya fecha de inicio sea desde septiembre de 2026.
-- Escribe tu SELECT aqui:
SELECT e.code AS codigo_edicion, e.start_date AS fecha_inicio, e.status AS estado
FROM editions AS e
WHERE e.status IN ('ABIERTA','EN_CURSO') AND e.start_date >= '2026-09-01'
ORDER BY e.start_date, e.code;

-- ------------------------------------------------------------
-- 03. Mostrar colaboradores ACTIVO de empresas cuyo nombre contenga SAS. Usar JOIN y LIKE.
-- Escribe tu SELECT aqui:
SELECT co.name AS colaborador, c.company_name AS empresa
FROM collaborators AS co JOIN companies AS c ON c.id = co.company_id
WHERE co.status = 'ACTIVO' AND c.company_name LIKE '%SAS%' ORDER BY co.name;

-- ------------------------------------------------------------
-- 04. Mostrar las tres ediciones con fecha de inicio más reciente. Usar LIMIT.
-- Escribe tu SELECT aqui:
SELECT e.code AS codigo_edicion, e.start_date AS fecha_inicio
FROM editions AS e ORDER BY e.start_date DESC, e.code LIMIT 3;

-- ------------------------------------------------------------
-- 05. Buscar cursos cuyo nombre incluya IA o datos. Usar LIKE y OR.
-- Escribe tu SELECT aqui:
SELECT c.code AS codigo_curso, c.name AS curso
FROM courses AS c
WHERE c.name LIKE '%IA%' OR c.name LIKE '%datos%' ORDER BY c.code;

-- ------------------------------------------------------------
-- 06. Mostrar cada edición junto con el nombre del curso y el instructor que la imparte.
-- Escribe tu SELECT aqui:
SELECT e.code AS codigo_edicion, c.name AS curso, i.name AS instructor
FROM editions AS e
JOIN courses AS c ON c.id = e.course_id
JOIN instructors AS i ON i.id = e.instructor_id ORDER BY e.code;

-- ------------------------------------------------------------
-- 07. Relacionar cada matrícula con colaborador, empresa y edición.
-- Escribe tu SELECT aqui:
SELECT en.id AS codigo_matricula, co.name AS colaborador,
       c.company_name AS empresa, e.code AS edicion
FROM enrollments AS en
JOIN collaborators AS co ON co.id = en.collaborator_id
JOIN companies AS c ON c.id = co.company_id
JOIN editions AS e ON e.id = en.edition_id ORDER BY en.id;

-- ------------------------------------------------------------
-- 08. Contar los matriculados por edición, incluyendo ediciones sin inscritos. Usar LEFT JOIN.
-- Escribe tu SELECT aqui:
SELECT e.code AS codigo_edicion, COUNT(en.id) AS matriculados
FROM editions AS e LEFT JOIN enrollments AS en ON en.edition_id = e.id
GROUP BY e.id, e.code ORDER BY e.code;

-- ------------------------------------------------------------
-- 09. Contar matrículas agrupadas por su estado.
-- Escribe tu SELECT aqui:
SELECT en.status AS estado, COUNT(*) AS total_matriculas
FROM enrollments AS en GROUP BY en.status
ORDER BY total_matriculas DESC, en.status;

-- ------------------------------------------------------------
-- 10. Encontrar los cursos que se han ofrecido en dos o más ediciones. Usar HAVING.
-- Escribe tu SELECT aqui:
SELECT c.code AS codigo_curso, c.name AS curso, COUNT(e.id) AS total_ediciones
FROM courses AS c JOIN editions AS e ON e.course_id = c.id
GROUP BY c.id, c.code, c.name HAVING COUNT(e.id) >= 2
ORDER BY total_ediciones DESC, c.code;

-- ------------------------------------------------------------
-- 11. Contar las sesiones programadas en cada edición.
-- Escribe tu SELECT aqui:
SELECT e.code AS codigo_edicion, COUNT(s.id) AS sesiones_programadas
FROM editions AS e LEFT JOIN sessions AS s ON s.edition_id = e.id
GROUP BY e.id, e.code ORDER BY e.code;

-- ------------------------------------------------------------
-- 12. Mostrar los certificados emitidos junto al nombre del colaborador y el curso.
-- Escribe tu SELECT aqui:
SELECT ce.code AS codigo_certificado, co.name AS colaborador, c.name AS curso
FROM certificates AS ce
JOIN enrollments AS en ON en.id = ce.enrollment_id
JOIN collaborators AS co ON co.id = en.collaborator_id
JOIN editions AS e ON e.id = en.edition_id
JOIN courses AS c ON c.id = e.course_id ORDER BY ce.code;

-- ------------------------------------------------------------
-- 13. Mostrar las sesiones realizadas durante septiembre de 2026, junto a su edición.
-- Escribe tu SELECT aqui:
SELECT s.id AS codigo_sesion, e.code AS codigo_edicion, s.topic AS tema
FROM sessions AS s JOIN editions AS e ON e.id = s.edition_id
WHERE s.started_at BETWEEN '2026-09-01 00:00:00' AND '2026-09-30 23:59:59'
ORDER BY s.started_at, s.id;

-- ------------------------------------------------------------
-- 14. Mostrar todas las asistencias registradas con el colaborador, tema de la sesión y estado.
-- Escribe tu SELECT aqui:
SELECT a.id AS codigo_asistencia, co.name AS colaborador,
       s.topic AS tema, a.status AS estado
FROM attendance AS a
JOIN enrollments AS en ON en.id = a.enrollment_id
JOIN collaborators AS co ON co.id = en.collaborator_id
JOIN sessions AS s ON s.id = a.session_id ORDER BY a.id;

-- ------------------------------------------------------------
-- 15. Contar cuántas asistencias PRESENTE registra cada matrícula con registros de asistencia.
-- Escribe tu SELECT aqui:
SELECT en.id AS codigo_matricula, COUNT(*) AS presencias
FROM enrollments AS en JOIN attendance AS a ON a.enrollment_id = en.id
WHERE a.status = 'PRESENTE' GROUP BY en.id ORDER BY en.id;

-- ------------------------------------------------------------
-- 16. Mostrar ediciones con al menos dos matriculados e indicar su capacidad. Usar HAVING.
-- Escribe tu SELECT aqui:
SELECT e.code AS codigo_edicion, COUNT(en.id) AS matriculados, e.capacity AS capacidad
FROM editions AS e JOIN enrollments AS en ON en.edition_id = e.id
GROUP BY e.id, e.code, e.capacity HAVING COUNT(en.id) >= 2
ORDER BY e.code;

-- ------------------------------------------------------------
-- 17. Mostrar matrículas cuya asistencia registrada tenga al menos 80% PRESENTE. Usar GROUP BY y HAVING.
-- Escribe tu SELECT aqui:
SELECT en.id AS codigo_matricula, co.name AS colaborador,
       ROUND(100 * SUM(a.status = 'PRESENTE') / COUNT(a.id), 2) AS porcentaje_asistencia
FROM enrollments AS en
JOIN collaborators AS co ON co.id = en.collaborator_id
JOIN attendance AS a ON a.enrollment_id = en.id
GROUP BY en.id, co.name
HAVING SUM(a.status = 'PRESENTE') / COUNT(a.id) >= 0.80
ORDER BY en.id;

-- ------------------------------------------------------------
-- 18 | SUBCONSULTA. SUBCONSULTA: encontrar colaboradores que todavía no se han matriculado en ninguna edición. Usar NOT EXISTS.
-- Escribe tu SELECT aqui:
SELECT co.name AS colaborador
FROM collaborators AS co
WHERE NOT EXISTS (SELECT 1 FROM enrollments AS en WHERE en.collaborator_id = co.id)
ORDER BY co.name;

-- ------------------------------------------------------------
-- 19 | SUBCONSULTA. SUBCONSULTA: mostrar ediciones cuya capacidad sea mayor al promedio de capacidades de las ediciones.
-- Escribe tu SELECT aqui:
SELECT e.code AS codigo_edicion, e.capacity AS capacidad
FROM editions AS e
WHERE e.capacity > (SELECT AVG(capacity) FROM editions)
ORDER BY e.capacity DESC, e.code;

-- ------------------------------------------------------------
-- 20 | SUBCONSULTA. SUBCONSULTA: mostrar colaboradores que estén matriculados en alguna edición del curso con código CUR-IA. Usar IN.
-- Escribe tu SELECT aqui:
SELECT co.name AS colaborador
FROM collaborators AS co
WHERE co.id IN (
    SELECT en.collaborator_id
    FROM enrollments AS en
    JOIN editions AS e ON e.id = en.edition_id
    JOIN courses AS c ON c.id = e.course_id
    WHERE c.code = 'CUR-IA'
)
ORDER BY co.name;
