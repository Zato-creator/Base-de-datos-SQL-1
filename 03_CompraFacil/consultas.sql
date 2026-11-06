-- ============================================================
-- COMPRAFÁCIL | ESTUDIANTES - ESPACIOS PARA RESOLVER
-- Archivo 02/02 - 20 ejercicios DQL
-- Base de datos: comprafacil
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- No modificar los datos semilla durante esta evaluacion.
-- Alias y etiquetas visibles al cliente pueden estar en espanol.
-- ============================================================

USE comprafacil;

-- EJEMPLO DE CLASE (no calificable)
SELECT
    p.id AS codigo_producto,
    p.name AS producto,
    p.active AS activo
FROM products AS p;


-- ------------------------------------------------------------
-- 01. Mostrar el código, nombre y correo de los empleados que pueden solicitar compras.
-- Escribe tu SELECT aqui:
SELECT e.code AS codigo_empleado, e.name AS empleado, e.email AS correo
FROM employees AS e ORDER BY e.code;

-- ------------------------------------------------------------
-- 02. Mostrar los productos activos y su unidad de medida. Usar WHERE.
-- Escribe tu SELECT aqui:
SELECT p.sku AS sku, p.name AS producto, p.unit_of_measure AS unidad_medida
FROM products AS p WHERE p.active = TRUE ORDER BY p.sku;

-- ------------------------------------------------------------
-- 03. Listar órdenes con estado PARCIAL o EMITIDA. Usar OR.
-- Escribe tu SELECT aqui:
SELECT po.id AS codigo_orden, po.status AS estado
FROM purchase_orders AS po
WHERE po.status = 'PARCIAL' OR po.status = 'EMITIDA' ORDER BY po.id;

-- ------------------------------------------------------------
-- 04. Mostrar las solicitudes creadas entre el 1 y el 5 de septiembre de 2026. Usar BETWEEN.
-- Escribe tu SELECT aqui:
SELECT r.id AS codigo_solicitud, r.created_at AS fecha_creacion, r.status AS estado
FROM requests AS r
WHERE r.created_at BETWEEN '2026-09-01 00:00:00' AND '2026-09-05 23:59:59'
ORDER BY r.created_at, r.id;

-- ------------------------------------------------------------
-- 05. Buscar productos cuyo nombre contenga Cable o Teclado. Usar LIKE.
-- Escribe tu SELECT aqui:
SELECT p.sku AS sku, p.name AS producto
FROM products AS p
WHERE p.name LIKE '%Cable%' OR p.name LIKE '%Teclado%' ORDER BY p.sku;

-- ------------------------------------------------------------
-- 06. Mostrar cada solicitud con el empleado que la creó, su fecha y estado.
-- Escribe tu SELECT aqui:
SELECT r.id AS codigo_solicitud, e.name AS empleado, r.created_at AS fecha_creacion, r.status AS estado
FROM requests AS r JOIN employees AS e ON e.id = r.employee_id ORDER BY r.id;

-- ------------------------------------------------------------
-- 07. Mostrar cada orden de compra junto con el proveedor y la justificación de la solicitud que originó la orden.
-- Escribe tu SELECT aqui:
SELECT po.id AS codigo_orden, s.company_name AS proveedor, r.justification AS justificacion
FROM purchase_orders AS po
JOIN suppliers AS s ON s.id = po.supplier_id
JOIN requests AS r ON r.id = po.request_id ORDER BY po.id;

-- ------------------------------------------------------------
-- 08. Mostrar productos y cantidades requeridas de cada solicitud. Usar JOIN.
-- Escribe tu SELECT aqui:
SELECT r.id AS codigo_solicitud, p.sku AS sku, p.name AS producto, ri.requested_quantity AS cantidad_requerida
FROM request_items AS ri
JOIN requests AS r ON r.id = ri.request_id
JOIN products AS p ON p.id = ri.product_id ORDER BY r.id, p.sku;

-- ------------------------------------------------------------
-- 09. Contar las solicitudes por estado.
-- Escribe tu SELECT aqui:
SELECT r.status AS estado, COUNT(*) AS total_solicitudes
FROM requests AS r GROUP BY r.status
ORDER BY total_solicitudes DESC, r.status;

-- ------------------------------------------------------------
-- 10. Calcular el valor total de cada orden sumando cantidad ordenada multiplicada por precio unitario.
-- Escribe tu SELECT aqui:
SELECT po.id AS codigo_orden, ROUND(SUM(oi.ordered_quantity * oi.unit_price), 2) AS valor_total
FROM purchase_orders AS po JOIN order_items AS oi ON oi.order_id = po.id
GROUP BY po.id ORDER BY po.id;

-- ------------------------------------------------------------
-- 11. Mostrar cada recepción con su número de remisión y proveedor.
-- Escribe tu SELECT aqui:
SELECT rec.id AS codigo_recepcion, rec.delivery_note AS remision, s.company_name AS proveedor
FROM receipts AS rec
JOIN purchase_orders AS po ON po.id = rec.order_id
JOIN suppliers AS s ON s.id = po.supplier_id ORDER BY rec.id;

-- ------------------------------------------------------------
-- 12. Mostrar los productos recibidos, su cantidad recibida y la remisión correspondiente.
-- Escribe tu SELECT aqui:
SELECT p.sku AS sku, ri.received_quantity AS cantidad_recibida, rec.delivery_note AS remision
FROM receipt_items AS ri
JOIN order_items AS oi ON oi.id = ri.order_item_id
JOIN request_items AS reqi ON reqi.id = oi.request_item_id
JOIN products AS p ON p.id = reqi.product_id
JOIN receipts AS rec ON rec.id = ri.receipt_id ORDER BY rec.id, p.sku;

-- ------------------------------------------------------------
-- 13. Calcular la cantidad pendiente por renglón de orden: cantidad ordenada menos lo recibido. Mostrar también los renglones sin recepción.
-- Escribe tu SELECT aqui:
SELECT oi.id AS codigo_renglon, p.sku AS sku, oi.ordered_quantity AS cantidad_ordenada,
       COALESCE(SUM(ri.received_quantity), 0) AS cantidad_recibida,
       oi.ordered_quantity - COALESCE(SUM(ri.received_quantity), 0) AS cantidad_pendiente
FROM order_items AS oi
JOIN request_items AS reqi ON reqi.id = oi.request_item_id
JOIN products AS p ON p.id = reqi.product_id
LEFT JOIN receipt_items AS ri ON ri.order_item_id = oi.id
GROUP BY oi.id, p.sku, oi.ordered_quantity ORDER BY oi.id;

-- ------------------------------------------------------------
-- 14. Contar las órdenes por proveedor, incluyendo proveedores que todavía no tienen órdenes.
-- Escribe tu SELECT aqui:
SELECT s.company_name AS proveedor, COUNT(po.id) AS total_ordenes
FROM suppliers AS s LEFT JOIN purchase_orders AS po ON po.supplier_id = s.id
GROUP BY s.id, s.company_name ORDER BY total_ordenes DESC, s.company_name;

-- ------------------------------------------------------------
-- 15. Mostrar empleados que hayan realizado dos o más solicitudes. Usar HAVING.
-- Escribe tu SELECT aqui:
SELECT e.name AS empleado, COUNT(r.id) AS total_solicitudes
FROM employees AS e JOIN requests AS r ON r.employee_id = e.id
GROUP BY e.id, e.name HAVING COUNT(r.id) >= 2
ORDER BY total_solicitudes DESC, e.name;

-- ------------------------------------------------------------
-- 16. Mostrar productos presentes en dos o más renglones de órdenes de compra.
-- Escribe tu SELECT aqui:
SELECT p.sku AS sku, p.name AS producto, COUNT(oi.id) AS total_renglones
FROM products AS p
JOIN request_items AS ri ON ri.product_id = p.id
JOIN order_items AS oi ON oi.request_item_id = ri.id
GROUP BY p.id, p.sku, p.name HAVING COUNT(oi.id) >= 2
ORDER BY total_renglones DESC, p.sku;

-- ------------------------------------------------------------
-- 17. Mostrar los tres renglones de órdenes con mayor valor total (cantidad por precio). Usar LIMIT.
-- Escribe tu SELECT aqui:
SELECT oi.id AS codigo_renglon, oi.order_id AS codigo_orden,
       ROUND(oi.ordered_quantity * oi.unit_price, 2) AS valor_total
FROM order_items AS oi ORDER BY valor_total DESC, oi.id LIMIT 3;

-- ------------------------------------------------------------
-- 18 | SUBCONSULTA. SUBCONSULTA: encontrar renglones cuyo precio unitario sea superior al precio unitario promedio.
-- Escribe tu SELECT aqui:
SELECT oi.id AS codigo_renglon, oi.unit_price AS precio_unitario
FROM order_items AS oi
WHERE oi.unit_price > (SELECT AVG(unit_price) FROM order_items)
ORDER BY oi.unit_price DESC, oi.id;

-- ------------------------------------------------------------
-- 19 | SUBCONSULTA. SUBCONSULTA: listar productos que nunca han aparecido en una orden de compra. Usar NOT EXISTS.
-- Escribe tu SELECT aqui:
SELECT p.sku AS sku, p.name AS producto
FROM products AS p
WHERE NOT EXISTS (
    SELECT 1 FROM request_items AS ri
    JOIN order_items AS oi ON oi.request_item_id = ri.id
    WHERE ri.product_id = p.id
)
ORDER BY p.sku;

-- ------------------------------------------------------------
-- 20 | SUBCONSULTA. SUBCONSULTA: listar proveedores que tengan al menos una orden PARCIAL. Usar IN.
-- Escribe tu SELECT aqui:
SELECT s.nit AS nit, s.company_name AS proveedor
FROM suppliers AS s
WHERE s.id IN (SELECT supplier_id FROM purchase_orders WHERE status = 'PARCIAL')
ORDER BY s.company_name;
