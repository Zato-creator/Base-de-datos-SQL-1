-- ============================================================
-- SPACEBOOK | ESTUDIANTES - ESPACIOS PARA RESOLVER
-- Archivo 02/02 - 20 ejercicios DQL
-- Base de datos: spacebook
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- No modificar los datos semilla durante esta evaluacion.
-- Alias y etiquetas visibles al cliente pueden estar en espanol.
-- ============================================================

USE spacebook;

-- EJEMPLO DE CLASE (no calificable)
SELECT
    r.id AS codigo_sala,
    r.name AS sala,
    r.capacity AS capacidad
FROM rooms AS r;


-- ------------------------------------------------------------
-- 01. Mostrar código, nombre, capacidad y estado de todas las salas.
-- Escribe tu SELECT aqui:
SELECT r.code AS codigo_sala, r.name AS sala, r.capacity AS capacidad, r.status AS estado
FROM rooms AS r ORDER BY r.code;

-- ------------------------------------------------------------
-- 02. Buscar salas ACTIVAS con capacidad entre 6 y 12 personas.
-- Escribe tu SELECT aqui:
SELECT r.code AS codigo_sala, r.name AS sala, r.capacity AS capacidad
FROM rooms AS r
WHERE r.status = 'ACTIVA' AND r.capacity BETWEEN 6 AND 12
ORDER BY r.capacity, r.code;

-- ------------------------------------------------------------
-- 03. Mostrar los recursos DISPONIBLES de tipo PROYECTOR o AUDIO. Usar IN.
-- Escribe tu SELECT aqui:
SELECT r.code AS codigo_recurso, r.name AS recurso, r.type AS tipo
FROM resources AS r
WHERE r.status = 'DISPONIBLE' AND r.type IN ('PROYECTOR','AUDIO')
ORDER BY r.code;

-- ------------------------------------------------------------
-- 04. Mostrar las tres reservas que comienzan primero según la fecha y hora de inicio.
-- Escribe tu SELECT aqui:
SELECT r.id AS codigo_reserva, r.started_at AS fecha_inicio, r.ended_at AS fecha_fin
FROM reservations AS r ORDER BY r.started_at, r.id LIMIT 3;

-- ------------------------------------------------------------
-- 05. Buscar salas cuyo nombre contenga Sur o Ágora. Usar LIKE y OR.
-- Escribe tu SELECT aqui:
SELECT r.code AS codigo_sala, r.name AS sala
FROM rooms AS r
WHERE r.name LIKE '%Sur%' OR r.name LIKE '%Ágora%' ORDER BY r.name;

-- ------------------------------------------------------------
-- 06. Mostrar cada sala con su sede y ciudad.
-- Escribe tu SELECT aqui:
SELECT r.code AS codigo_sala, r.name AS sala, s.name AS sede, s.city AS ciudad
FROM rooms AS r JOIN sites AS s ON s.id = r.site_id
ORDER BY s.name, r.name;

-- ------------------------------------------------------------
-- 07. Mostrar cada reserva con el nombre de la sala y del organizador.
-- Escribe tu SELECT aqui:
SELECT re.id AS codigo_reserva, r.name AS sala, e.name AS organizador
FROM reservations AS re
JOIN rooms AS r ON r.id = re.room_id
JOIN employees AS e ON e.id = re.organizer_id ORDER BY re.id;

-- ------------------------------------------------------------
-- 08. Contar reservas por sala, incluyendo salas sin ninguna reserva. Usar LEFT JOIN.
-- Escribe tu SELECT aqui:
SELECT r.code AS codigo_sala, r.name AS sala, COUNT(re.id) AS total_reservas
FROM rooms AS r LEFT JOIN reservations AS re ON re.room_id = r.id
GROUP BY r.id, r.code, r.name ORDER BY total_reservas DESC, r.code;

-- ------------------------------------------------------------
-- 09. Contar las reservas por estado.
-- Escribe tu SELECT aqui:
SELECT re.status AS estado, COUNT(*) AS total_reservas
FROM reservations AS re GROUP BY re.status
ORDER BY total_reservas DESC, re.status;

-- ------------------------------------------------------------
-- 10. Encontrar salas que tengan al menos dos reservas registradas. Usar HAVING.
-- Escribe tu SELECT aqui:
SELECT r.code AS codigo_sala, r.name AS sala, COUNT(re.id) AS total_reservas
FROM rooms AS r JOIN reservations AS re ON re.room_id = r.id
GROUP BY r.id, r.code, r.name HAVING COUNT(re.id) >= 2
ORDER BY total_reservas DESC, r.code;

-- ------------------------------------------------------------
-- 11. Mostrar el número de reservas CONFIRMADAS por sala, sin incluir los demás estados.
-- Escribe tu SELECT aqui:
SELECT r.code AS codigo_sala, r.name AS sala, COUNT(re.id) AS reservas_confirmadas
FROM rooms AS r
LEFT JOIN reservations AS re ON re.room_id = r.id AND re.status = 'CONFIRMADA'
GROUP BY r.id, r.code, r.name ORDER BY reservas_confirmadas DESC, r.code;

-- ------------------------------------------------------------
-- 12. Mostrar los empleados invitados a cada reserva, indicando motivo y respuesta.
-- Escribe tu SELECT aqui:
SELECT re.id AS codigo_reserva, e.name AS invitado, re.reason AS motivo, rp.response AS respuesta
FROM reservation_participants AS rp
JOIN reservations AS re ON re.id = rp.reservation_id
JOIN employees AS e ON e.id = rp.employee_id ORDER BY re.id, e.name;

-- ------------------------------------------------------------
-- 13. Listar reservas CONFIRMADAS del 3 de noviembre de 2026. Usar BETWEEN.
-- Escribe tu SELECT aqui:
SELECT re.id AS codigo_reserva, r.name AS sala, re.started_at AS fecha_inicio
FROM reservations AS re JOIN rooms AS r ON r.id = re.room_id
WHERE re.status = 'CONFIRMADA'
  AND re.started_at BETWEEN '2026-11-03 00:00:00' AND '2026-11-03 23:59:59'
ORDER BY re.started_at, re.id;

-- ------------------------------------------------------------
-- 14. Mostrar recursos asociados a reservas, indicando el organizador de la reserva.
-- Escribe tu SELECT aqui:
SELECT re.id AS codigo_reserva, res.name AS recurso, e.name AS organizador
FROM reservation_resources AS rr
JOIN reservations AS re ON re.id = rr.reservation_id
JOIN resources AS res ON res.id = rr.resource_id
JOIN employees AS e ON e.id = re.organizer_id ORDER BY re.id, res.code;

-- ------------------------------------------------------------
-- 15. Contar participantes invitados por reserva, incluyendo reservas sin participantes.
-- Escribe tu SELECT aqui:
SELECT re.id AS codigo_reserva, COUNT(rp.employee_id) AS invitados
FROM reservations AS re LEFT JOIN reservation_participants AS rp ON rp.reservation_id = re.id
GROUP BY re.id ORDER BY re.id;

-- ------------------------------------------------------------
-- 16. Mostrar los bloqueos de salas junto con la sede donde ocurren.
-- Escribe tu SELECT aqui:
SELECT e.name AS empleado, COUNT(*) AS invitaciones_aceptadas
FROM employees AS e JOIN reservation_participants AS rp ON rp.employee_id = e.id
WHERE rp.response = 'ACEPTADA'
GROUP BY e.id, e.name HAVING COUNT(*) >= 2
ORDER BY invitaciones_aceptadas DESC, e.name;

-- ------------------------------------------------------------
-- 17. Encontrar empleados con dos o más invitaciones ACEPTADA. Usar HAVING.
-- Escribe tu SELECT aqui:
SELECT e.name AS empleado
FROM employees AS e
WHERE NOT EXISTS (SELECT 1 FROM reservations AS re WHERE re.organizer_id = e.id)
ORDER BY e.name;

-- ------------------------------------------------------------
-- 18 | SUBCONSULTA. SUBCONSULTA: encontrar empleados que nunca han organizado una reserva. Usar NOT EXISTS.
-- Escribe tu SELECT aqui:
SELECT r.code AS codigo_sala, r.name AS sala, r.capacity AS capacidad
FROM rooms AS r
WHERE r.capacity > (SELECT AVG(capacity) FROM rooms)
ORDER BY r.capacity DESC, r.code;

-- ------------------------------------------------------------
-- 19 | SUBCONSULTA. SUBCONSULTA: mostrar salas cuya capacidad sea mayor al promedio de capacidades de todas las salas.
-- Escribe tu SELECT aqui:
SELECT res.code AS codigo_recurso, res.name AS recurso
FROM resources AS res
WHERE NOT EXISTS (
    SELECT 1
    FROM reservation_resources AS rr
    JOIN reservations AS re ON re.id = rr.reservation_id
    WHERE rr.resource_id = res.id AND re.status = 'CONFIRMADA'
)
ORDER BY res.code;


-- ------------------------------------------------------------
-- 20 | SUBCONSULTA. SUBCONSULTA: listar recursos nunca solicitados en una reserva CONFIRMADA. Usar NOT EXISTS.
-- Escribe tu SELECT aqui:


