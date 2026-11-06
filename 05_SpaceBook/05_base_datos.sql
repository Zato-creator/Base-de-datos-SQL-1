-- ============================================================
-- SPACEBOOK | LABORATORIO MYSQL 8.0.16+
-- Archivo 01/02 - DDL + DML
-- Todos los identificadores: ingles, minusculas y snake_case.
-- Los datos de negocio INSERT INTO se muestran en espanol.
-- ATENCION: Ejecutar completo RECREA la base de datos.
-- ============================================================

-- ============================================================
-- DDL: Definicion de base de datos y tablas
-- Primero tablas independientes y despues las dependientes.
-- ============================================================

DROP DATABASE IF EXISTS spacebook;
CREATE DATABASE spacebook CHARACTER SET utf8mb4;

SHOW DATABASES;
USE spacebook;

CREATE TABLE sites (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(120) NOT NULL,
    city VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE resources (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(40) NOT NULL UNIQUE,
    name VARCHAR(120) NOT NULL,
    type VARCHAR(80) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'DISPONIBLE',
    CONSTRAINT chk_resources_1 CHECK (status IN ('DISPONIBLE','MANTENIMIENTO','BAJA'))
) ENGINE=InnoDB;

CREATE TABLE employees (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    site_id BIGINT NOT NULL,
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    FOREIGN KEY (site_id) REFERENCES sites(id)
) ENGINE=InnoDB;

CREATE TABLE rooms (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    site_id BIGINT NOT NULL,
    code VARCHAR(30) NOT NULL,
    name VARCHAR(120) NOT NULL,
    capacity INT NOT NULL,
    status VARCHAR(15) NOT NULL DEFAULT 'ACTIVA',
    CONSTRAINT uq_rooms_1 UNIQUE (site_id,code),
    CONSTRAINT chk_rooms_1 CHECK (capacity > 0),
    CONSTRAINT chk_rooms_2 CHECK (status IN ('ACTIVA','INACTIVA')),
    FOREIGN KEY (site_id) REFERENCES sites(id)
) ENGINE=InnoDB;

CREATE TABLE reservations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    room_id BIGINT NOT NULL,
    organizer_id BIGINT NOT NULL,
    started_at DATETIME NOT NULL,
    ended_at DATETIME NOT NULL,
    reason VARCHAR(255) NOT NULL,
    status VARCHAR(15) NOT NULL DEFAULT 'SOLICITADA',
    CONSTRAINT chk_reservations_1 CHECK (ended_at > started_at),
    CONSTRAINT chk_reservations_2 CHECK (status IN ('SOLICITADA','CONFIRMADA','CANCELADA','FINALIZADA')),
    FOREIGN KEY (room_id) REFERENCES rooms(id),
    FOREIGN KEY (organizer_id) REFERENCES employees(id)
) ENGINE=InnoDB;

CREATE TABLE room_blocks (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    room_id BIGINT NOT NULL,
    started_at DATETIME NOT NULL,
    ended_at DATETIME NOT NULL,
    reason VARCHAR(180) NOT NULL,
    CONSTRAINT chk_room_blocks_1 CHECK (ended_at > started_at),
    FOREIGN KEY (room_id) REFERENCES rooms(id)
) ENGINE=InnoDB;

CREATE TABLE reservation_participants (
    reservation_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    response VARCHAR(15) NOT NULL DEFAULT 'PENDIENTE',
    PRIMARY KEY (reservation_id,employee_id),
    CONSTRAINT chk_reservation_participants_1 CHECK (response IN ('PENDIENTE','ACEPTADA','RECHAZADA')),
    FOREIGN KEY (reservation_id) REFERENCES reservations(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
) ENGINE=InnoDB;

CREATE TABLE reservation_resources (
    reservation_id BIGINT NOT NULL,
    resource_id BIGINT NOT NULL,
    PRIMARY KEY (reservation_id,resource_id),
    FOREIGN KEY (reservation_id) REFERENCES reservations(id),
    FOREIGN KEY (resource_id) REFERENCES resources(id)
) ENGINE=InnoDB;

SHOW TABLES;


-- ============================================================
-- DML: INSERT INTO | datos semilla para resolver los 20 retos
-- Nunca ejecutar los ejemplos destructivos antes del DQL.
-- ============================================================

USE spacebook;
INSERT INTO sites (code,name,city) VALUES
('BGA','Sede Centro','Bucaramanga'),('FLB','Sede Sur','Floridablanca'),('BOG','Sede Capital','Bogotá'),('MED','Sede Antioquia','Medellín');
INSERT INTO resources (code,name,type,status) VALUES
('REC-001','Proyector Epson','PROYECTOR','DISPONIBLE'),('REC-002','Cámara Logitech','CAMARA','DISPONIBLE'),('REC-003','Micrófono Jabra','AUDIO','DISPONIBLE'),('REC-004','Pantalla portátil','PANTALLA','DISPONIBLE'),('REC-005','Proyector BenQ','PROYECTOR','MANTENIMIENTO'),('REC-006','Kit de audio','AUDIO','DISPONIBLE');
INSERT INTO employees (site_id,code,name,email) VALUES
(1,'E-001','Ana Torres','ana@space.test'),(1,'E-002','Luis Rojas','luis@space.test'),(2,'E-003','Sara Gil','sara@space.test'),(2,'E-004','Mateo Vega','mateo@space.test'),(3,'E-005','Diana Pérez','diana@space.test'),(3,'E-006','Carlos Ruiz','carlos@space.test'),(4,'E-007','Laura Mora','laura@space.test');
INSERT INTO rooms (site_id,code,name,capacity,status) VALUES
(1,'S1','Sala Horizonte',6,'ACTIVA'),(1,'S2','Sala Ágora',12,'ACTIVA'),(2,'S1','Sala Sur',8,'ACTIVA'),(2,'S2','Sala Verde',4,'ACTIVA'),(3,'S1','Sala Capital',10,'ACTIVA'),(4,'S1','Sala Antioquia',8,'INACTIVA');
INSERT INTO reservations (room_id,organizer_id,started_at,ended_at,reason,status) VALUES
(1,1,'2026-11-03 08:00:00','2026-11-03 09:00:00','Planeación semanal','CONFIRMADA'),
(1,2,'2026-11-03 09:00:00','2026-11-03 10:00:00','Revisión de entregas','CONFIRMADA'),
(2,1,'2026-11-03 08:00:00','2026-11-03 10:00:00','Comité directivo','CONFIRMADA'),
(3,3,'2026-11-04 14:00:00','2026-11-04 15:00:00','Capacitación interna','CONFIRMADA'),
(4,4,'2026-11-05 10:00:00','2026-11-05 11:00:00','Revisión comercial','CANCELADA'),
(5,5,'2026-11-06 08:00:00','2026-11-06 09:00:00','Presupuesto','SOLICITADA'),
(1,1,'2026-11-07 11:00:00','2026-11-07 12:00:00','Cierre de sprint','SOLICITADA'),
(3,6,'2026-10-08 15:00:00','2026-10-08 16:00:00','Retroalimentación','FINALIZADA');
INSERT INTO room_blocks (room_id,started_at,ended_at,reason) VALUES
(1,'2026-11-03 10:00:00','2026-11-03 12:00:00','Limpieza'),
(2,'2026-11-04 08:00:00','2026-11-04 12:00:00','Mantenimiento audiovisual'),
(3,'2026-11-05 12:00:00','2026-11-05 14:00:00','Acondicionamiento'),
(5,'2026-11-09 08:00:00','2026-11-09 11:00:00','Limpieza');
INSERT INTO reservation_participants (reservation_id,employee_id,response) VALUES
(1,2,'ACEPTADA'),(1,3,'ACEPTADA'),(1,4,'PENDIENTE'),
(2,1,'ACEPTADA'),(2,5,'RECHAZADA'),(3,2,'ACEPTADA'),
(3,5,'PENDIENTE'),(4,4,'ACEPTADA'),(5,3,'ACEPTADA'),(6,6,'PENDIENTE');
INSERT INTO reservation_resources (reservation_id,resource_id) VALUES
(1,1),(1,3),(2,1),(3,2),(3,4),(4,6),(5,3),(6,2);


-- ============================================================
-- PRACTICA ADICIONAL: UPDATE / DELETE / TRUNCATE
-- Los siguientes 10 ejemplos estan DESACTIVADOS (comentados).
-- Descomentar uno a la vez, SOLO en una copia de laboratorio.
-- Ejecutar estos ejemplos puede cambiar resultados de DQL.
-- TRUNCATE es DDL en MySQL, no se revierte con ROLLBACK.
-- ============================================================

-- 01. UPDATE employees SET name = 'Ana María Torres' WHERE id = 1;
-- 02. UPDATE resources SET status = 'DISPONIBLE' WHERE id = 5;
-- 03. UPDATE reservations SET status = 'CANCELADA' WHERE id = 7;
-- 04. UPDATE reservation_participants SET response = 'ACEPTADA' WHERE reservation_id = 1 AND employee_id = 4;
-- 05. DELETE FROM reservation_resources WHERE reservation_id = 6 AND resource_id = 2;
-- 06. DELETE FROM reservation_participants WHERE reservation_id = 6 AND employee_id = 6;
-- 07. DELETE FROM room_blocks WHERE id = 4;
-- 08. DELETE FROM reservations WHERE id = 7;
-- 09. TRUNCATE TABLE reservation_participants;
-- 10. TRUNCATE TABLE reservation_resources;
