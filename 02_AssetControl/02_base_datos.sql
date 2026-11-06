-- ============================================================
-- ASSETCONTROL | LABORATORIO MYSQL 8.0.16+
-- Archivo 01/02 - DDL + DML
-- Todos los identificadores: ingles, minusculas y snake_case.
-- Los datos de negocio INSERT INTO se muestran en espanol.
-- ATENCION: Ejecutar completo RECREA la base de datos.
-- ============================================================

-- ============================================================
-- DDL: Definicion de base de datos y tablas
-- Primero tablas independientes y despues las dependientes.
-- ============================================================

DROP DATABASE IF EXISTS assetcontrol;
CREATE DATABASE assetcontrol CHARACTER SET utf8mb4;

SHOW DATABASES;
USE assetcontrol;

CREATE TABLE sites (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(120) NOT NULL,
    city VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE asset_types (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL UNIQUE,
    description VARCHAR(255) NULL
) ENGINE=InnoDB;

CREATE TABLE departments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    site_id BIGINT NOT NULL,
    name VARCHAR(120) NOT NULL,
    CONSTRAINT uq_departments_1 UNIQUE (site_id,name),
    FOREIGN KEY (site_id) REFERENCES sites(id)
) ENGINE=InnoDB;

CREATE TABLE assets (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    site_id BIGINT NOT NULL,
    asset_type_id BIGINT NOT NULL,
    patrimonial_identifier VARCHAR(40) NOT NULL UNIQUE,
    serial_number VARCHAR(100) NOT NULL UNIQUE,
    brand VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    purchase_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'DISPONIBLE',
    CONSTRAINT chk_assets_1 CHECK (status IN ('DISPONIBLE','ASIGNADO','MANTENIMIENTO','BAJA')),
    FOREIGN KEY (site_id) REFERENCES sites(id),
    FOREIGN KEY (asset_type_id) REFERENCES asset_types(id)
) ENGINE=InnoDB;

CREATE TABLE employees (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    department_id BIGINT NOT NULL,
    employee_code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    status VARCHAR(15) NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT chk_employees_1 CHECK (status IN ('ACTIVO','INACTIVO')),
    FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

CREATE TABLE assignments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    asset_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    started_at DATETIME NOT NULL,
    return_date DATETIME NULL,
    delivery_status VARCHAR(20) NOT NULL DEFAULT 'BUENO',
    active_asset_id BIGINT GENERATED ALWAYS AS (IF(return_date IS NULL,asset_id,NULL)) STORED,
    CONSTRAINT uq_assignments_1 UNIQUE (active_asset_id),
    CONSTRAINT chk_assignments_1 CHECK (return_date IS NULL OR return_date > started_at),
    CONSTRAINT chk_assignments_2 CHECK (delivery_status IN ('BUENO','REGULAR','DANADO')),
    FOREIGN KEY (asset_id) REFERENCES assets(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
) ENGINE=InnoDB;

CREATE TABLE maintenance (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    asset_id BIGINT NOT NULL,
    type VARCHAR(15) NOT NULL,
    started_at DATETIME NOT NULL,
    ended_at DATETIME NULL,
    description TEXT NOT NULL,
    cost DECIMAL(12,2) NOT NULL DEFAULT 0,
    result VARCHAR(255) NULL,
    CONSTRAINT chk_maintenance_1 CHECK (type IN ('PREVENTIVO','CORRECTIVO')),
    CONSTRAINT chk_maintenance_2 CHECK (ended_at IS NULL OR ended_at > started_at),
    CONSTRAINT chk_maintenance_3 CHECK (cost >= 0),
    FOREIGN KEY (asset_id) REFERENCES assets(id)
) ENGINE=InnoDB;

SHOW TABLES;


-- ============================================================
-- DML: INSERT INTO | datos semilla para resolver los 20 retos
-- Nunca ejecutar los ejemplos destructivos antes del DQL.
-- ============================================================

USE assetcontrol;
INSERT INTO sites (code,name,city) VALUES
('BGA','Sede Centro','Bucaramanga'),('FLB','Sede Floridablanca','Floridablanca'),('BOG','Sede Bogotá','Bogotá'),('MED','Sede Medellín','Medellín');
INSERT INTO asset_types (name,description) VALUES
('Portátil','Equipo de cómputo móvil'),('Monitor','Pantalla externa'),('Impresora','Equipo de impresión'),('Teléfono','Teléfono corporativo'),('Proyector','Equipo audiovisual');
INSERT INTO departments (site_id,name) VALUES
(1,'Tecnología'),(1,'Contabilidad'),(2,'Comercial'),(2,'Operaciones'),(3,'Recursos Humanos'),(4,'Tecnología');
INSERT INTO assets (site_id,asset_type_id,patrimonial_identifier,serial_number,brand,model,purchase_date,status) VALUES
(1,1,'ACT-001','SER-L001','Lenovo','ThinkPad E14','2025-02-10','ASIGNADO'),
(1,2,'ACT-002','SER-M002','Dell','P2422','2025-03-01','ASIGNADO'),
(2,1,'ACT-003','SER-L003','HP','ProBook 440','2024-08-20','DISPONIBLE'),
(2,3,'ACT-004','SER-I004','Epson','L4260','2025-07-11','MANTENIMIENTO'),
(3,1,'ACT-005','SER-L005','Acer','TravelMate','2024-11-20','ASIGNADO'),
(1,4,'ACT-006','SER-T006','Samsung','A35','2026-01-15','DISPONIBLE'),
(4,2,'ACT-007','SER-M007','LG','24MP400','2025-09-14','ASIGNADO'),
(2,5,'ACT-008','SER-P008','Epson','PowerLite','2025-05-05','DISPONIBLE'),
(3,2,'ACT-009','SER-M009','Dell','P2419H','2023-04-05','BAJA');
INSERT INTO employees (department_id,employee_code,name,email,status) VALUES
(1,'EMP-001','Ana Torres','ana@empresa.test','ACTIVO'),(1,'EMP-002','Luis Gómez','luis@empresa.test','ACTIVO'),
(2,'EMP-003','María Peña','maria@empresa.test','ACTIVO'),(3,'EMP-004','Carlos Díaz','carlos@empresa.test','ACTIVO'),
(4,'EMP-005','Sofía Rojas','sofia@empresa.test','ACTIVO'),(5,'EMP-006','Jorge León','jorge@empresa.test','ACTIVO'),
(6,'EMP-007','Diana Luna','diana@empresa.test','INACTIVO');
INSERT INTO assignments (asset_id,employee_id,started_at,return_date,delivery_status) VALUES
(1,1,'2026-08-01 09:00:00',NULL,'BUENO'),
(2,2,'2026-06-01 09:00:00','2026-08-01 18:00:00','BUENO'),
(2,1,'2026-08-02 09:00:00',NULL,'REGULAR'),
(3,4,'2026-04-01 09:00:00','2026-05-20 17:00:00','BUENO'),
(5,6,'2026-09-01 10:00:00',NULL,'BUENO'),
(7,7,'2026-01-01 09:00:00','2026-02-01 18:00:00','REGULAR'),
(7,2,'2026-09-10 09:00:00',NULL,'BUENO'),
(8,5,'2026-07-01 09:00:00','2026-07-15 17:00:00','BUENO');
INSERT INTO maintenance (asset_id,type,started_at,ended_at,description,cost,result) VALUES
(1,'PREVENTIVO','2026-01-10 08:00:00','2026-01-10 11:00:00','Limpieza preventiva',85000,'Completado'),
(2,'CORRECTIVO','2026-05-10 09:00:00','2026-05-11 15:00:00','Cambio de cable',125000,'Resuelto'),
(3,'PREVENTIVO','2026-06-01 09:00:00','2026-06-01 12:00:00','Actualización de sistema',60000,'Completado'),
(4,'CORRECTIVO','2026-10-05 10:00:00',NULL,'Falla de impresión',210000,NULL),
(5,'PREVENTIVO','2026-02-05 08:00:00','2026-02-05 10:00:00','Diagnóstico general',70000,'Completado'),
(5,'CORRECTIVO','2026-09-20 09:00:00','2026-09-21 12:00:00','Reemplazo de memoria',220000,'Resuelto'),
(8,'PREVENTIVO','2026-08-15 08:00:00','2026-08-15 11:00:00','Limpieza de lente',95000,'Completado'),
(9,'CORRECTIVO','2026-04-01 09:00:00','2026-04-03 14:00:00','Falla de panel',550000,'Sin reparación');


-- ============================================================
-- PRACTICA ADICIONAL: UPDATE / DELETE / TRUNCATE
-- Los siguientes 10 ejemplos estan DESACTIVADOS (comentados).
-- Descomentar uno a la vez, SOLO en una copia de laboratorio.
-- Ejecutar estos ejemplos puede cambiar resultados de DQL.
-- TRUNCATE es DDL en MySQL, no se revierte con ROLLBACK.
-- ============================================================

-- 01. UPDATE assets SET status = 'MANTENIMIENTO' WHERE id = 3;
-- 02. UPDATE employees SET status = 'INACTIVO' WHERE id = 6;
-- 03. UPDATE maintenance SET cost = 230000 WHERE id = 6;
-- 04. UPDATE assignments SET return_date = '2026-10-02 17:00:00' WHERE id = 5;
-- 05. DELETE FROM maintenance WHERE id = 8;
-- 06. DELETE FROM assignments WHERE id = 8;
-- 07. DELETE FROM maintenance WHERE id = 7;
-- 08. DELETE FROM employees WHERE id = 5;
-- 09. TRUNCATE TABLE maintenance;
-- 10. TRUNCATE TABLE assignments;
