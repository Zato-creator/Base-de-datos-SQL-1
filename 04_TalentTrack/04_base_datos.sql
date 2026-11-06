-- ============================================================
-- TALENTTRACK | LABORATORIO MYSQL 8.0.16+
-- Archivo 01/02 - DDL + DML
-- Todos los identificadores: ingles, minusculas y snake_case.
-- Los datos de negocio INSERT INTO se muestran en espanol.
-- ATENCION: Ejecutar completo RECREA la base de datos.
-- ============================================================

-- ============================================================
-- DDL: Definicion de base de datos y tablas
-- Primero tablas independientes y despues las dependientes.
-- ============================================================

DROP DATABASE IF EXISTS talenttrack;
CREATE DATABASE talenttrack CHARACTER SET utf8mb4;

SHOW DATABASES;
USE talenttrack;

CREATE TABLE companies (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nit VARCHAR(25) NOT NULL UNIQUE,
    company_name VARCHAR(180) NOT NULL,
    status VARCHAR(15) NOT NULL DEFAULT 'ACTIVA',
    CONSTRAINT chk_companies_1 CHECK (status IN ('ACTIVA','INACTIVA'))
) ENGINE=InnoDB;

CREATE TABLE instructors (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE courses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(180) NOT NULL,
    description TEXT NULL,
    duration_hours INT NOT NULL,
    CONSTRAINT chk_courses_1 CHECK (duration_hours > 0)
) ENGINE=InnoDB;

CREATE TABLE collaborators (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT NOT NULL,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL,
    status VARCHAR(15) NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT uq_collaborators_1 UNIQUE (company_id,email),
    CONSTRAINT chk_collaborators_1 CHECK (status IN ('ACTIVO','INACTIVO')),
    FOREIGN KEY (company_id) REFERENCES companies(id)
) ENGINE=InnoDB;

CREATE TABLE editions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    course_id BIGINT NOT NULL,
    instructor_id BIGINT NOT NULL,
    code VARCHAR(40) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    capacity INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PROGRAMADA',
    CONSTRAINT chk_editions_1 CHECK (end_date >= start_date),
    CONSTRAINT chk_editions_2 CHECK (capacity > 0),
    CONSTRAINT chk_editions_3 CHECK (status IN ('PROGRAMADA','ABIERTA','EN_CURSO','FINALIZADA','CANCELADA')),
    FOREIGN KEY (course_id) REFERENCES courses(id),
    FOREIGN KEY (instructor_id) REFERENCES instructors(id)
) ENGINE=InnoDB;

CREATE TABLE enrollments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    collaborator_id BIGINT NOT NULL,
    edition_id BIGINT NOT NULL,
    enrolled_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVA',
    CONSTRAINT uq_enrollments_1 UNIQUE (collaborator_id,edition_id),
    CONSTRAINT chk_enrollments_1 CHECK (status IN ('ACTIVA','FINALIZADA','CANCELADA')),
    FOREIGN KEY (collaborator_id) REFERENCES collaborators(id),
    FOREIGN KEY (edition_id) REFERENCES editions(id)
) ENGINE=InnoDB;

CREATE TABLE sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    edition_id BIGINT NOT NULL,
    started_at DATETIME NOT NULL,
    ended_at DATETIME NOT NULL,
    topic VARCHAR(180) NOT NULL,
    CONSTRAINT chk_sessions_1 CHECK (ended_at > started_at),
    FOREIGN KEY (edition_id) REFERENCES editions(id)
) ENGINE=InnoDB;

CREATE TABLE certificates (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id BIGINT NOT NULL UNIQUE,
    code VARCHAR(60) NOT NULL UNIQUE,
    issued_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verification_url VARCHAR(500) NOT NULL,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(id)
) ENGINE=InnoDB;

CREATE TABLE attendance (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id BIGINT NOT NULL,
    session_id BIGINT NOT NULL,
    status VARCHAR(10) NOT NULL,
    recorded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_attendance_1 UNIQUE (enrollment_id,session_id),
    CONSTRAINT chk_attendance_1 CHECK (status IN ('PRESENTE','AUSENTE')),
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(id),
    FOREIGN KEY (session_id) REFERENCES sessions(id)
) ENGINE=InnoDB;

SHOW TABLES;


-- ============================================================
-- DML: INSERT INTO | datos semilla para resolver los 20 retos
-- Nunca ejecutar los ejemplos destructivos antes del DQL.
-- ============================================================

USE talenttrack;
INSERT INTO companies (nit,company_name,status) VALUES
('901200001-1','Innovación Delta SAS','ACTIVA'),('901200002-2','Logística Norte SAS','ACTIVA'),('901200003-3','Salud Integral SAS','ACTIVA'),('901200004-4','Comercio Global SAS','INACTIVA');
INSERT INTO instructors (name,email) VALUES
('Elena Pardo','elena@academia.test'),('Julián Mora','julian@academia.test'),('Laura Gil','laura@academia.test'),('Pedro Nieto','pedro@academia.test');
INSERT INTO courses (code,name,description,duration_hours) VALUES
('CUR-IA','Fundamentos de IA','Uso empresarial de inteligencia artificial',20),('CUR-SQL','SQL para analistas','Consultas y modelado relacional',24),('CUR-SEG','Ciberseguridad','Buenas prácticas de seguridad',16),('CUR-DAT','Análisis de datos','Indicadores y tableros',32);
INSERT INTO collaborators (company_id,name,email,status) VALUES
(1,'Ana Torres','ana@delta.test','ACTIVO'),(1,'Luis Pérez','luis@delta.test','ACTIVO'),(2,'Sara Ruiz','sara@norte.test','ACTIVO'),(2,'Mateo Silva','mateo@norte.test','ACTIVO'),(3,'Diana Paz','diana@salud.test','ACTIVO'),(3,'Juan León','juan@salud.test','ACTIVO'),(4,'Laura Cano','laura@comercio.test','INACTIVO');
INSERT INTO editions (course_id,instructor_id,code,start_date,end_date,capacity,status) VALUES
(1,1,'IA-2026-A','2026-09-01','2026-09-30',15,'FINALIZADA'),
(1,2,'IA-2026-B','2026-11-01','2026-11-30',20,'ABIERTA'),
(2,2,'SQL-2026-A','2026-09-01','2026-11-15',12,'EN_CURSO'),
(3,3,'SEG-2026-A','2026-10-01','2026-10-30',10,'EN_CURSO'),
(4,4,'DAT-2026-A','2026-12-01','2026-12-30',18,'PROGRAMADA');
INSERT INTO enrollments (collaborator_id,edition_id,enrolled_at,status) VALUES
(1,1,'2026-08-20 09:00:00','FINALIZADA'),(2,1,'2026-08-20 10:00:00','FINALIZADA'),
(1,2,'2026-10-01 10:00:00','ACTIVA'),(3,2,'2026-10-05 10:00:00','ACTIVA'),
(3,3,'2026-08-29 10:00:00','ACTIVA'),(4,3,'2026-08-30 10:00:00','ACTIVA'),
(5,4,'2026-09-28 10:00:00','ACTIVA'),(6,4,'2026-09-29 10:00:00','ACTIVA');
INSERT INTO sessions (edition_id,started_at,ended_at,topic) VALUES
(1,'2026-09-02 08:00:00','2026-09-02 12:00:00','Introducción'),
(1,'2026-09-04 08:00:00','2026-09-04 12:00:00','Prompting'),
(1,'2026-09-09 08:00:00','2026-09-09 12:00:00','Asistentes'),
(1,'2026-09-11 08:00:00','2026-09-11 12:00:00','Automatización'),
(1,'2026-09-16 08:00:00','2026-09-16 12:00:00','Proyecto'),
(2,'2026-11-04 08:00:00','2026-11-04 12:00:00','Introducción IA'),
(2,'2026-11-06 08:00:00','2026-11-06 12:00:00','Prompts IA'),
(3,'2026-09-10 14:00:00','2026-09-10 18:00:00','SELECT y WHERE'),
(4,'2026-10-10 08:00:00','2026-10-10 12:00:00','Seguridad básica'),
(5,'2026-12-02 08:00:00','2026-12-02 12:00:00','Indicadores');
INSERT INTO attendance (enrollment_id,session_id,status,recorded_at) VALUES
(1,1,'PRESENTE','2026-09-02 12:10:00'),(1,2,'PRESENTE','2026-09-04 12:10:00'),
(1,3,'PRESENTE','2026-09-09 12:10:00'),(1,4,'PRESENTE','2026-09-11 12:10:00'),
(1,5,'AUSENTE','2026-09-16 12:10:00'),
(2,1,'PRESENTE','2026-09-02 12:11:00'),(2,2,'PRESENTE','2026-09-04 12:11:00'),
(2,3,'PRESENTE','2026-09-09 12:11:00'),(2,4,'PRESENTE','2026-09-11 12:11:00'),
(2,5,'PRESENTE','2026-09-16 12:11:00');
INSERT INTO certificates (enrollment_id,code,issued_at,verification_url) VALUES
(1,'CERT-IA-A-001','2026-09-30 09:00:00','https://ejemplo.test/cert/CERT-IA-A-001'),
(2,'CERT-IA-A-002','2026-09-30 09:05:00','https://ejemplo.test/cert/CERT-IA-A-002');


-- ============================================================
-- PRACTICA ADICIONAL: UPDATE / DELETE / TRUNCATE
-- Los siguientes 10 ejemplos estan DESACTIVADOS (comentados).
-- Descomentar uno a la vez, SOLO en una copia de laboratorio.
-- Ejecutar estos ejemplos puede cambiar resultados de DQL.
-- TRUNCATE es DDL en MySQL, no se revierte con ROLLBACK.
-- ============================================================

-- 01. UPDATE collaborators SET status = 'INACTIVO' WHERE id = 6;
-- 02. UPDATE editions SET capacity = 25 WHERE id = 2;
-- 03. UPDATE enrollments SET status = 'CANCELADA' WHERE id = 8;
-- 04. UPDATE courses SET duration_hours = 28 WHERE id = 2;
-- 05. DELETE FROM certificates WHERE id = 2;
-- 06. DELETE FROM attendance WHERE id = 10;
-- 07. DELETE FROM enrollments WHERE id = 8;
-- 08. DELETE FROM sessions WHERE id = 10;
-- 09. TRUNCATE TABLE certificates;
-- 10. TRUNCATE TABLE attendance;
