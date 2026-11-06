-- ============================================================
-- HELPDESK PRO | ESTUDIANTES - ESPACIOS PARA RESOLVER
-- Archivo 02/02 - 20 ejercicios DQL
-- Base de datos: helpdesk_pro
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- No modificar los datos semilla durante esta evaluacion.
-- Alias y etiquetas visibles al cliente pueden estar en espanol.
-- ============================================================

USE helpdesk_pro;

-- EJEMPLO DE CLASE (no calificable)
SELECT
    t.id AS codigo_ticket,
    t.subject AS asunto,
    t.status AS estado
FROM tickets AS t;


-- ------------------------------------------------------------
-- 01. Mostrar el código, asunto, prioridad y estado de todos los tickets, ordenados por código.
-- Escribe tu SELECT aqui:
SELECT t.id AS codigo_ticket, t.subject AS asunto, t.priority AS prioridad, t.status AS estado
FROM tickets AS t
ORDER BY t.id;

-- ------------------------------------------------------------
-- 02. Listar los tickets con prioridad ALTA o CRITICA que estén ABIERTO o EN_PROCESO. Usar AND, OR y paréntesis.
-- Escribe tu SELECT aqui:
SELECT t.id AS codigo_ticket, t.subject AS asunto, t.priority AS prioridad, t.status AS estado
FROM tickets AS t
WHERE (t.priority IN ('ALTA','CRITICA'))
  AND t.status IN ('ABIERTO','EN_PROCESO')
ORDER BY t.id;

-- ------------------------------------------------------------
-- 03. Buscar los clientes ACTIVOS cuya razón social contenga SAS. Usar LIKE.
-- Escribe tu SELECT aqui:
SELECT c.company_name AS cliente
FROM clients AS c
WHERE c.status = 'ACTIVO' AND c.company_name LIKE '%SAS%'
ORDER BY c.company_name;

-- ------------------------------------------------------------
-- 04. Obtener los tres tickets más recientes según su fecha de apertura. Usar ORDER BY y LIMIT.
-- Escribe tu SELECT aqui:
SELECT t.id AS codigo_ticket, t.subject AS asunto, t.opened_at AS fecha_apertura
FROM tickets AS t
ORDER BY t.opened_at DESC
LIMIT 3;

-- ------------------------------------------------------------
-- 05. Mostrar tickets cuyo asunto contenga la palabra Red o Servidor. Usar LIKE y OR.
-- Escribe tu SELECT aqui:
SELECT t.id AS codigo_ticket, t.subject AS asunto
FROM tickets AS t
WHERE t.subject LIKE '%Red%' OR t.subject LIKE '%Servidor%'
ORDER BY t.id;

-- ------------------------------------------------------------
-- 06. Mostrar el código y asunto de cada ticket junto con el nombre de su contacto. Usar JOIN.
-- Escribe tu SELECT aqui:
SELECT t.id AS codigo_ticket, t.subject AS asunto, c.name AS contacto
FROM tickets AS t
JOIN contacts AS c ON c.id = t.contact_id
ORDER BY t.id;

-- ------------------------------------------------------------
-- 07. Mostrar cada ticket con el cliente que lo reportó y la categoría de soporte. Usar varios JOIN.
-- Escribe tu SELECT aqui:
SELECT t.id AS codigo_ticket, t.subject AS asunto, cl.company_name AS cliente, ca.name AS categoria
FROM tickets AS t
JOIN contacts AS co ON co.id = t.contact_id
JOIN clients AS cl ON cl.id = co.client_id
JOIN categories AS ca ON ca.id = t.category_id
ORDER BY t.id;

-- ------------------------------------------------------------
-- 08. Listar todos los técnicos y cuántas asignaciones han recibido, incluso si nunca han sido asignados. Usar LEFT JOIN.
-- Escribe tu SELECT aqui:
SELECT te.name AS tecnico, COUNT(a.id) AS asignaciones
FROM technicians AS te
LEFT JOIN assignments AS a ON a.technician_id = te.id
GROUP BY te.id, te.name
ORDER BY te.name;

-- ------------------------------------------------------------
-- 09. Contar cuántos tickets existen por prioridad. Usar GROUP BY.
-- Escribe tu SELECT aqui:
SELECT t.priority AS prioridad, COUNT(*) AS total_tickets
FROM tickets AS t
GROUP BY t.priority
ORDER BY t.priority;

-- ------------------------------------------------------------
-- 10. Mostrar cuántos tickets se registraron en cada estado, ordenados del más frecuente al menos frecuente.
-- Escribe tu SELECT aqui:
SELECT t.status AS estado, COUNT(*) AS total_tickets
FROM tickets AS t
GROUP BY t.status
ORDER BY total_tickets DESC, t.status;

-- ------------------------------------------------------------
-- 11. Mostrar los tickets con asignación todavía abierta y el técnico responsable. Usar IS NULL.
-- Escribe tu SELECT aqui:
SELECT t.id AS codigo_ticket, t.subject AS asunto, te.name AS tecnico
FROM tickets AS t
JOIN assignments AS a ON a.ticket_id = t.id
JOIN technicians AS te ON te.id = a.technician_id
WHERE a.ended_at IS NULL
ORDER BY t.id;

-- ------------------------------------------------------------
-- 12. Buscar tickets abiertos desde el 1 hasta el 5 de septiembre de 2026, incluyendo todo el día 5. Usar BETWEEN.
-- Escribe tu SELECT aqui:
SELECT t.id AS codigo_ticket, t.subject AS asunto, t.opened_at AS fecha_apertura
FROM tickets AS t
WHERE t.opened_at BETWEEN '2026-09-01 00:00:00' AND '2026-09-05 23:59:59'
ORDER BY t.opened_at, t.id;

-- ------------------------------------------------------------
-- 13. Mostrar los comentarios escritos por técnicos con el nombre del autor y el asunto del ticket.
-- Escribe tu SELECT aqui:
SELECT te.name AS tecnico, t.subject AS asunto, co.content AS comentario
FROM comments AS co
JOIN technicians AS te ON te.id = co.technician_id
JOIN tickets AS t ON t.id = co.ticket_id
ORDER BY co.created_at;

-- ------------------------------------------------------------
-- 14. Contar los comentarios por ticket, incluyendo tickets sin comentarios.
-- Escribe tu SELECT aqui:
SELECT t.id AS codigo_ticket, t.subject AS asunto, COUNT(co.id) AS comentarios
FROM tickets AS t
LEFT JOIN comments AS co ON co.ticket_id = t.id
GROUP BY t.id, t.subject
ORDER BY t.id;

-- ------------------------------------------------------------
-- 15. Mostrar las empresas que hayan reportado dos o más tickets. Usar GROUP BY y HAVING.
-- Escribe tu SELECT aqui:
SELECT cl.company_name AS cliente, COUNT(t.id) AS total_tickets
FROM clients AS cl
JOIN contacts AS co ON co.client_id = cl.id
JOIN tickets AS t ON t.contact_id = co.id
GROUP BY cl.id, cl.company_name
HAVING COUNT(t.id) >= 2
ORDER BY total_tickets DESC, cl.company_name;

-- ------------------------------------------------------------
-- 16. Encontrar las categorías con al menos dos tickets registrados. Usar HAVING.
-- Escribe tu SELECT aqui:
SELECT ca.name AS categoria, COUNT(t.id) AS total_tickets
FROM categories AS ca
JOIN tickets AS t ON t.category_id = ca.id
GROUP BY ca.id, ca.name
HAVING COUNT(t.id) >= 2
ORDER BY total_tickets DESC, ca.name;

-- ------------------------------------------------------------
-- 17. Mostrar cada cambio de estado con el asunto del ticket y el nombre del técnico, incluyendo cambios automáticos.
-- Escribe tu SELECT aqui:
SELECT sh.id AS codigo_cambio, t.subject AS asunto, te.name AS tecnico,
       sh.previous_status AS estado_anterior, sh.new_status AS estado_nuevo
FROM status_history AS sh
JOIN tickets AS t ON t.id = sh.ticket_id
LEFT JOIN technicians AS te ON te.id = sh.technician_id
ORDER BY sh.changed_at, sh.id;

-- ------------------------------------------------------------
-- 18 | SUBCONSULTA. SUBCONSULTA: encontrar los tickets abiertos después de la fecha de apertura del ticket con id 4.
-- Escribe tu SELECT aqui:
SELECT t.id AS codigo_ticket, t.subject AS asunto, t.opened_at AS fecha_apertura
FROM tickets AS t
WHERE t.opened_at > (SELECT opened_at FROM tickets WHERE id = 4)
ORDER BY t.opened_at, t.id;

-- ------------------------------------------------------------
-- 19 | SUBCONSULTA. SUBCONSULTA: mostrar los técnicos que no han escrito ningún comentario. Usar NOT EXISTS.
-- Escribe tu SELECT aqui:
SELECT te.name AS tecnico
FROM technicians AS te
WHERE NOT EXISTS (
    SELECT 1 FROM comments AS co WHERE co.technician_id = te.id
)
ORDER BY te.name;

-- ------------------------------------------------------------
-- 20 | SUBCONSULTA. SUBCONSULTA: consultar los tickets que tengan una prioridad igual a la de los tickets 1 o 2, excluyendo esos dos tickets. Usar IN.
-- Escribe tu SELECT aqui:
SELECT t.id AS codigo_ticket, t.subject AS asunto, t.priority AS prioridad
FROM tickets AS t
WHERE t.priority IN (SELECT priority FROM tickets WHERE id IN (1, 2))
  AND t.id NOT IN (1, 2)
ORDER BY t.id;
