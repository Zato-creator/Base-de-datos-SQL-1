-- ============================================================
-- COMPRAFÁCIL | LABORATORIO MYSQL 8.0.16+
-- Archivo 01/02 - DDL + DML
-- Todos los identificadores: ingles, minusculas y snake_case.
-- Los datos de negocio INSERT INTO se muestran en espanol.
-- ATENCION: Ejecutar completo RECREA la base de datos.
-- ============================================================

-- ============================================================
-- DDL: Definicion de base de datos y tablas
-- Primero tablas independientes y despues las dependientes.
-- ============================================================

DROP DATABASE IF EXISTS comprafacil;
CREATE DATABASE comprafacil CHARACTER SET utf8mb4;

SHOW DATABASES;
USE comprafacil;

CREATE TABLE employees (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    unit_of_measure VARCHAR(30) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE suppliers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nit VARCHAR(25) NOT NULL UNIQUE,
    company_name VARCHAR(180) NOT NULL,
    email VARCHAR(255) NOT NULL,
    status VARCHAR(15) NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT chk_suppliers_1 CHECK (status IN ('ACTIVO','INACTIVO'))
) ENGINE=InnoDB;

CREATE TABLE requests (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    employee_id BIGINT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'BORRADOR',
    justification TEXT NOT NULL,
    CONSTRAINT chk_requests_1 CHECK (status IN ('BORRADOR','EN_REVISION','APROBADA','RECHAZADA')),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
) ENGINE=InnoDB;

CREATE TABLE request_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    request_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    requested_quantity DECIMAL(12,2) NOT NULL,
    CONSTRAINT uq_request_items_1 UNIQUE (request_id, product_id),
    CONSTRAINT chk_request_items_1 CHECK (requested_quantity > 0),
    FOREIGN KEY (request_id) REFERENCES requests(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB;

CREATE TABLE purchase_orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    request_id BIGINT NOT NULL UNIQUE,
    supplier_id BIGINT NOT NULL,
    issued_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(15) NOT NULL DEFAULT 'EMITIDA',
    CONSTRAINT chk_purchase_orders_1 CHECK (status IN ('EMITIDA','PARCIAL','RECIBIDA','ANULADA')),
    FOREIGN KEY (request_id) REFERENCES requests(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
) ENGINE=InnoDB;

CREATE TABLE order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    request_item_id BIGINT NOT NULL UNIQUE,
    ordered_quantity DECIMAL(12,2) NOT NULL,
    unit_price DECIMAL(14,2) NOT NULL,
    CONSTRAINT chk_order_items_1 CHECK (ordered_quantity > 0),
    CONSTRAINT chk_order_items_2 CHECK (unit_price >= 0),
    FOREIGN KEY (order_id) REFERENCES purchase_orders(id),
    FOREIGN KEY (request_item_id) REFERENCES request_items(id)
) ENGINE=InnoDB;

CREATE TABLE receipts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    delivery_note VARCHAR(50) NOT NULL UNIQUE,
    received_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes VARCHAR(255) NULL,
    FOREIGN KEY (order_id) REFERENCES purchase_orders(id)
) ENGINE=InnoDB;

CREATE TABLE receipt_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    receipt_id BIGINT NOT NULL,
    order_item_id BIGINT NOT NULL,
    received_quantity DECIMAL(12,2) NOT NULL,
    CONSTRAINT uq_receipt_items_1 UNIQUE (receipt_id,order_item_id),
    CONSTRAINT chk_receipt_items_1 CHECK (received_quantity > 0),
    FOREIGN KEY (receipt_id) REFERENCES receipts(id),
    FOREIGN KEY (order_item_id) REFERENCES order_items(id)
) ENGINE=InnoDB;

SHOW TABLES;


-- ============================================================
-- DML: INSERT INTO | datos semilla para resolver los 20 retos
-- Nunca ejecutar los ejemplos destructivos antes del DQL.
-- ============================================================

USE comprafacil;
INSERT INTO employees (code,name,email) VALUES
('C-001','Ana Torres','ana@compras.test'),('C-002','Luis Herrera','luis@compras.test'),('C-003','Sara Díaz','sara@compras.test'),('C-004','Carlos Vega','carlos@compras.test'),('C-005','Mónica Gil','monica@compras.test');
INSERT INTO products (sku,name,unit_of_measure,active) VALUES
('TEC-001','Teclado USB','UND',TRUE),('MOU-002','Mouse óptico','UND',TRUE),('PAP-003','Resma de papel','PAQ',TRUE),('MON-004','Monitor 24 pulgadas','UND',TRUE),('CAB-005','Cable HDMI','UND',TRUE),('SIL-006','Silla ergonómica','UND',TRUE),('TIN-007','Tóner negro','UND',FALSE),('LAM-008','Lámpara de escritorio','UND',TRUE);
INSERT INTO suppliers (nit,company_name,email,status) VALUES
('901100001-1','TecnoMayorista SAS','ventas@tecnom.test','ACTIVO'),('901100002-2','OfiSuministros SAS','pedidos@ofis.test','ACTIVO'),('901100003-3','Dotaciones Norte SAS','contacto@dotaciones.test','ACTIVO'),('901100004-4','Proveedora Andina SAS','hola@andina.test','INACTIVO');
INSERT INTO requests (employee_id,created_at,status,justification) VALUES
(1,'2026-09-01 08:00:00','APROBADA','Periféricos nuevos'),
(2,'2026-09-02 09:00:00','APROBADA','Papelería mensual'),
(3,'2026-09-03 11:00:00','APROBADA','Monitores de equipo'),
(4,'2026-09-04 14:00:00','EN_REVISION','Adecuación de oficina'),
(5,'2026-09-05 10:00:00','RECHAZADA','Gasto no presupuestado'),
(1,'2026-09-06 15:00:00','APROBADA','Accesorios sala'),
(2,'2026-09-07 08:00:00','APROBADA','Insumos del mes siguiente');
INSERT INTO request_items (request_id,product_id,requested_quantity) VALUES
(1,1,10),(1,2,5),(2,3,20),(3,4,4),(3,5,4),(4,6,8),(5,7,2),(6,5,10),(6,1,5),(7,3,12);
INSERT INTO purchase_orders (request_id,supplier_id,issued_at,status) VALUES
(1,1,'2026-09-08 09:00:00','PARCIAL'),
(2,2,'2026-09-08 10:00:00','RECIBIDA'),
(3,1,'2026-09-09 08:00:00','EMITIDA'),
(6,3,'2026-09-10 14:00:00','PARCIAL');
INSERT INTO order_items (order_id,request_item_id,ordered_quantity,unit_price) VALUES
(1,1,10,75000),(1,2,5,36000),(2,3,20,22000),(3,4,4,680000),(3,5,4,25000),(4,8,10,24000),(4,9,5,78000);
INSERT INTO receipts (order_id,delivery_note,received_at,notes) VALUES
(1,'REM-001','2026-09-11 09:00:00','Primera entrega de teclados'),
(1,'REM-002','2026-09-13 09:00:00','Segunda entrega de teclados'),
(2,'REM-003','2026-09-12 11:00:00','Papelería completa'),
(4,'REM-004','2026-09-16 14:00:00','Entrega inicial de cables');
INSERT INTO receipt_items (receipt_id,order_item_id,received_quantity) VALUES
(1,1,6),(2,1,4),(3,3,20),(4,6,4);


-- ============================================================
-- PRACTICA ADICIONAL: UPDATE / DELETE / TRUNCATE
-- Los siguientes 10 ejemplos estan DESACTIVADOS (comentados).
-- Descomentar uno a la vez, SOLO en una copia de laboratorio.
-- Ejecutar estos ejemplos puede cambiar resultados de DQL.
-- TRUNCATE es DDL en MySQL, no se revierte con ROLLBACK.
-- ============================================================

-- 01. UPDATE suppliers SET status = 'ACTIVO' WHERE id = 4;
-- 02. UPDATE products SET active = TRUE WHERE id = 7;
-- 03. UPDATE requests SET status = 'APROBADA' WHERE id = 4;
-- 04. UPDATE order_items SET unit_price = 76500 WHERE id = 1;
-- 05. UPDATE requests SET status = 'EN_REVISION' WHERE id = 7;
-- 06. DELETE FROM receipt_items WHERE id = 4;
-- 07. DELETE FROM receipts WHERE id = 4;
-- 08. DELETE FROM request_items WHERE id = 10;
-- 09. DELETE FROM requests WHERE id = 7;
-- 10. TRUNCATE TABLE receipt_items;
