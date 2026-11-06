-- ============================================================
-- EXAMEN PRACTICO FINAL - ANALISIS DE INFORMACION CON MYSQL
-- Estudiante: APELLIDO NOMBRE
-- Motor: MySQL 8.x
-- Requisito: haber ejecutado los cinco archivos *_base_datos.sql
-- (datos semilla originales, sin UPDATE / DELETE / TRUNCATE).
-- ============================================================


-- ============================================================
-- CASO 1. HELPDESK PRO
-- ============================================================

-- ------------------------------------------------------------
-- 01. Clientes que requieren atencion prioritaria.
-- Ruta: clients -> contacts -> tickets.
-- WHERE deja solo clientes ACTIVO; HAVING exige >= 2 tickets
-- y al menos un pendiente (ABIERTO o EN_PROCESO).
-- MAX(opened_at) toma el ticket mas reciente de cualquier estado.
-- ------------------------------------------------------------
USE helpdesk_pro;

SELECT
    c.company_name AS cliente,
    COUNT(t.id) AS total_tickets,
    SUM(CASE WHEN t.status IN ('ABIERTO','EN_PROCESO') THEN 1 ELSE 0 END) AS tickets_pendientes,
    SUM(CASE WHEN t.status IN ('ABIERTO','EN_PROCESO')
              AND t.priority = 'CRITICA' THEN 1 ELSE 0 END) AS criticos_pendientes,
    MAX(t.opened_at) AS ultima_apertura
FROM clients AS c
JOIN contacts AS co
    ON co.client_id = c.id
JOIN tickets AS t
    ON t.contact_id = co.id
WHERE c.status = 'ACTIVO'
GROUP BY c.id, c.company_name
HAVING COUNT(t.id) >= 2
   AND SUM(CASE WHEN t.status IN ('ABIERTO','EN_PROCESO') THEN 1 ELSE 0 END) > 0
ORDER BY tickets_pendientes DESC, cliente;


-- ------------------------------------------------------------
-- 02. Responsables vigentes que no han respondido su ticket.
-- La asignacion vigente es la que tiene ended_at IS NULL.
-- NOT EXISTS correlacionado: no hay comentario en ESE ticket
-- escrito por ESE tecnico (los de clientes u otros tecnicos no cuentan).
-- ------------------------------------------------------------
USE helpdesk_pro;

SELECT
    t.id AS codigo_ticket,
    t.subject AS asunto,
    c.company_name AS cliente,
    te.name AS tecnico,
    t.priority AS prioridad,
    a.started_at AS asignado_desde
FROM tickets AS t
JOIN assignments AS a
    ON a.ticket_id = t.id
   AND a.ended_at IS NULL
JOIN technicians AS te
    ON te.id = a.technician_id
JOIN contacts AS co
    ON co.id = t.contact_id
JOIN clients AS c
    ON c.id = co.client_id
WHERE t.status IN ('ABIERTO','EN_PROCESO')
  AND NOT EXISTS (
        SELECT 1
        FROM comments AS cm
        WHERE cm.ticket_id = t.id
          AND cm.technician_id = a.technician_id
  )
ORDER BY t.opened_at, t.id;


-- ============================================================
-- CASO 2. ASSETCONTROL
-- ============================================================

-- ------------------------------------------------------------
-- 03. Inversion en mantenimiento por sede.
-- Los mantenimientos se pre-agregan por activo en una subconsulta
-- (una fila por activo) para que COUNT(a.id) no se infle cuando
-- un equipo tiene varios mantenimientos.
-- LEFT JOIN + COALESCE: sedes/equipos sin mantenimiento muestran 0.
-- Promedio = gasto total / TODOS los equipos de la sede.
-- ------------------------------------------------------------
USE assetcontrol;

SELECT
    s.name AS sede,
    s.city AS ciudad,
    COUNT(a.id) AS total_equipos,
    COUNT(m.asset_id) AS equipos_intervenidos,
    ROUND(COALESCE(SUM(m.costo_equipo), 0), 2) AS costo_total,
    ROUND(COALESCE(SUM(m.costo_equipo), 0) / COUNT(a.id), 2) AS promedio_por_equipo
FROM sites AS s
JOIN assets AS a
    ON a.site_id = s.id
LEFT JOIN (
    SELECT asset_id, SUM(cost) AS costo_equipo
    FROM maintenance
    GROUP BY asset_id
) AS m
    ON m.asset_id = a.id
GROUP BY s.id, s.name, s.city
HAVING COUNT(a.id) >= 2
ORDER BY costo_total DESC, sede;


-- ------------------------------------------------------------
-- 04. Equipos bajo custodia de otra sede.
-- Se usa la tabla sites dos veces con alias distintos:
--   si = sede responsable del inventario (assets.site_id)
--   sd = sede del departamento del colaborador (departments.site_id)
-- Solo asignaciones vigentes (return_date IS NULL).
-- ------------------------------------------------------------
USE assetcontrol;

SELECT
    a.patrimonial_identifier AS codigo_activo,
    a.brand AS marca,
    e.name AS empleado,
    d.name AS departamento,
    si.name AS sede_inventario,
    sd.name AS sede_departamento,
    asg.started_at AS fecha_asignacion
FROM assignments AS asg
JOIN assets AS a
    ON a.id = asg.asset_id
JOIN sites AS si
    ON si.id = a.site_id
JOIN employees AS e
    ON e.id = asg.employee_id
JOIN departments AS d
    ON d.id = e.department_id
JOIN sites AS sd
    ON sd.id = d.site_id
WHERE asg.return_date IS NULL
  AND a.site_id <> d.site_id
ORDER BY a.patrimonial_identifier;


-- ============================================================
-- CASO 3. COMPRAFACIL
-- ============================================================

-- ------------------------------------------------------------
-- 05. Dinero comprometido pendiente por recibir.
-- Las recepciones se suman primero por renglon (subconsulta), asi
-- cada renglon de la orden aparece UNA sola vez y una entrega
-- parcial no duplica el valor ordenado.
-- LEFT JOIN: incluye ordenes sin recepciones (recibido = 0).
-- ------------------------------------------------------------
USE comprafacil;

SELECT
    po.id AS codigo_orden,
    s.company_name AS proveedor,
    po.status AS estado,
    ROUND(COALESCE(SUM(oi.ordered_quantity * oi.unit_price), 0), 2) AS valor_ordenado,
    ROUND(COALESCE(SUM(COALESCE(r.cantidad_recibida, 0) * oi.unit_price), 0), 2) AS valor_recibido,
    ROUND(COALESCE(SUM((oi.ordered_quantity - COALESCE(r.cantidad_recibida, 0)) * oi.unit_price), 0), 2) AS saldo_pendiente
FROM purchase_orders AS po
JOIN suppliers AS s
    ON s.id = po.supplier_id
LEFT JOIN order_items AS oi
    ON oi.order_id = po.id
LEFT JOIN (
    SELECT order_item_id, SUM(received_quantity) AS cantidad_recibida
    FROM receipt_items
    GROUP BY order_item_id
) AS r
    ON r.order_item_id = oi.id
WHERE po.status <> 'ANULADA'
GROUP BY po.id, s.company_name, po.status
ORDER BY saldo_pendiente DESC, codigo_orden;


-- ------------------------------------------------------------
-- 06. Productos pedidos reiteradamente y no ordenados en su totalidad.
-- Todas las solicitudes, sin filtrar estado.
-- order_items.request_item_id es UNIQUE: cada renglon solicitado tiene
-- como maximo un renglon de orden, por eso el LEFT JOIN no duplica.
-- Sin orden -> aporta 0 a lo ordenado (COALESCE).
-- ------------------------------------------------------------
USE comprafacil;

SELECT
    p.sku AS sku,
    p.name AS producto,
    COUNT(DISTINCT ri.request_id) AS solicitudes,
    SUM(ri.requested_quantity) AS cantidad_solicitada,
    COALESCE(SUM(oi.ordered_quantity), 0) AS cantidad_ordenada,
    SUM(ri.requested_quantity) - COALESCE(SUM(oi.ordered_quantity), 0) AS cantidad_no_ordenada
FROM products AS p
JOIN request_items AS ri
    ON ri.product_id = p.id
LEFT JOIN order_items AS oi
    ON oi.request_item_id = ri.id
GROUP BY p.id, p.sku, p.name
HAVING COUNT(DISTINCT ri.request_id) >= 2
   AND SUM(ri.requested_quantity) > COALESCE(SUM(oi.ordered_quantity), 0)
ORDER BY cantidad_no_ordenada DESC, sku;


-- ============================================================
-- CASO 4. TALENTTRACK
-- ============================================================

-- ------------------------------------------------------------
-- 07. Matriculas aptas para certificarse.
-- ses: sesiones programadas por edicion.
-- asi: asistencias por matricula, contando solo sesiones de la
--      MISMA edicion de la matricula.
-- Apta = edicion FINALIZADA + asistencia registrada en todas las
--        sesiones + PRESENTE en >= 80 % de ellas.
-- El certificado registrado se informa aparte; no define la aptitud.
-- ------------------------------------------------------------
USE talenttrack;

SELECT
    e.id AS codigo_matricula,
    cl.name AS colaborador,
    ed.code AS edicion,
    COALESCE(ses.programadas, 0) AS sesiones_programadas,
    COALESCE(asi.registradas, 0) AS asistencias_registradas,
    COALESCE(asi.presentes, 0) AS presencias,
    ROUND(COALESCE(100.0 * COALESCE(asi.presentes, 0) / NULLIF(ses.programadas, 0), 0), 2) AS porcentaje_asistencia,
    CASE
        WHEN ed.status = 'FINALIZADA'
         AND COALESCE(ses.programadas, 0) > 0
         AND COALESCE(asi.registradas, 0) = ses.programadas
         AND 100.0 * COALESCE(asi.presentes, 0) / ses.programadas >= 80
        THEN 'SI' ELSE 'NO'
    END AS apto_para_certificado,
    CASE WHEN ce.id IS NOT NULL THEN 'SI' ELSE 'NO' END AS certificado_emitido
FROM enrollments AS e
JOIN collaborators AS cl
    ON cl.id = e.collaborator_id
JOIN editions AS ed
    ON ed.id = e.edition_id
LEFT JOIN (
    SELECT edition_id, COUNT(*) AS programadas
    FROM sessions
    GROUP BY edition_id
) AS ses
    ON ses.edition_id = ed.id
LEFT JOIN (
    SELECT
        a.enrollment_id,
        COUNT(DISTINCT a.session_id) AS registradas,
        COUNT(DISTINCT CASE WHEN a.status = 'PRESENTE' THEN a.session_id END) AS presentes
    FROM attendance AS a
    JOIN enrollments AS e2
        ON e2.id = a.enrollment_id
    JOIN sessions AS s
        ON s.id = a.session_id
       AND s.edition_id = e2.edition_id
    GROUP BY a.enrollment_id
) AS asi
    ON asi.enrollment_id = e.id
LEFT JOIN certificates AS ce
    ON ce.enrollment_id = e.id
ORDER BY ed.code, cl.name;


-- ------------------------------------------------------------
-- 08. Empresas con mejores resultados de certificacion.
-- COUNT(DISTINCT cl.id): una persona con varias matriculas = 1 colaborador.
-- COUNT(DISTINCT ed.course_id): dos ediciones del mismo curso = 1 curso.
-- certificates.enrollment_id es UNIQUE: el LEFT JOIN no duplica matriculas.
-- ------------------------------------------------------------
USE talenttrack;

SELECT
    co.company_name AS empresa,
    COUNT(DISTINCT cl.id) AS colaboradores_matriculados,
    COUNT(DISTINCT e.id) AS total_matriculas,
    COUNT(DISTINCT ed.course_id) AS cursos_distintos,
    COUNT(DISTINCT ce.id) AS certificados_emitidos,
    ROUND(100.0 * COUNT(DISTINCT ce.id) / COUNT(DISTINCT e.id), 2) AS tasa_certificacion
FROM companies AS co
JOIN collaborators AS cl
    ON cl.company_id = co.id
JOIN enrollments AS e
    ON e.collaborator_id = cl.id
JOIN editions AS ed
    ON ed.id = e.edition_id
LEFT JOIN certificates AS ce
    ON ce.enrollment_id = e.id
WHERE co.status = 'ACTIVA'
GROUP BY co.id, co.company_name
HAVING COUNT(DISTINCT e.id) >= 2
ORDER BY tasa_certificacion DESC, empresa;


-- ============================================================
-- CASO 5. SPACEBOOK
-- ============================================================

-- ------------------------------------------------------------
-- 09. Salas disponibles el 2026-11-03 de 08:30 a 09:30.
-- Hay cruce de intervalos cuando: inicio_ocupacion < fin_reunion
--                                Y fin_ocupacion > inicio_reunion.
-- Con < y > estrictos, terminar justo a las 08:30 o empezar justo
-- a las 09:30 NO es conflicto.
-- Solo bloquean las reservas CONFIRMADA y cualquier room_block.
-- ------------------------------------------------------------
USE spacebook;

SELECT
    r.code AS codigo_sala,
    r.name AS sala,
    s.name AS sede,
    s.city AS ciudad,
    r.capacity AS capacidad
FROM rooms AS r
JOIN sites AS s
    ON s.id = r.site_id
WHERE r.status = 'ACTIVA'
  AND NOT EXISTS (
        SELECT 1
        FROM reservations AS rv
        WHERE rv.room_id = r.id
          AND rv.status = 'CONFIRMADA'
          AND rv.started_at < '2026-11-03 09:30:00'
          AND rv.ended_at   > '2026-11-03 08:30:00'
  )
  AND NOT EXISTS (
        SELECT 1
        FROM room_blocks AS b
        WHERE b.room_id = r.id
          AND b.started_at < '2026-11-03 09:30:00'
          AND b.ended_at   > '2026-11-03 08:30:00'
  )
ORDER BY sede, sala;


-- ------------------------------------------------------------
-- 10. Uso del aforo de las reuniones confirmadas.
-- Participantes y recursos se agregan en subconsultas separadas
-- para evitar el producto cruzado invitados x recursos.
-- asistentes_confirmados = 1 (organizador) + invitados ACEPTADA.
-- ------------------------------------------------------------
USE spacebook;

SELECT
    rv.id AS codigo_reserva,
    r.name AS sala,
    e.name AS organizador,
    r.capacity AS capacidad,
    COALESCE(p.invitados, 0) AS invitados,
    COALESCE(p.aceptados, 0) AS aceptados,
    COALESCE(p.rechazados, 0) AS rechazados,
    COALESCE(rr.recursos, 0) AS recursos,
    1 + COALESCE(p.aceptados, 0) AS asistentes_confirmados,
    ROUND(100.0 * (1 + COALESCE(p.aceptados, 0)) / r.capacity, 2) AS porcentaje_aforo
FROM reservations AS rv
JOIN rooms AS r
    ON r.id = rv.room_id
JOIN employees AS e
    ON e.id = rv.organizer_id
LEFT JOIN (
    SELECT
        reservation_id,
        COUNT(DISTINCT employee_id) AS invitados,
        COUNT(DISTINCT CASE WHEN response = 'ACEPTADA'  THEN employee_id END) AS aceptados,
        COUNT(DISTINCT CASE WHEN response = 'RECHAZADA' THEN employee_id END) AS rechazados
    FROM reservation_participants
    GROUP BY reservation_id
) AS p
    ON p.reservation_id = rv.id
LEFT JOIN (
    SELECT reservation_id, COUNT(DISTINCT resource_id) AS recursos
    FROM reservation_resources
    GROUP BY reservation_id
) AS rr
    ON rr.reservation_id = rv.id
WHERE rv.status = 'CONFIRMADA'
ORDER BY porcentaje_aforo DESC, codigo_reserva;
