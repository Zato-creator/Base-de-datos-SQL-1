-- ============================================================
-- HELPDESK PRO | LABORATORIO MYSQL 8.0.16+
-- Archivo 01/02 - DDL + DML
-- Todos los identificadores: ingles, minusculas y snake_case.
-- Los datos de negocio INSERT INTO se muestran en espanol.
-- ATENCION: Ejecutar completo RECREA la base de datos.
-- ============================================================

-- ============================================================
-- DDL: Definicion de base de datos y tablas
-- Primero tablas independientes y despues las dependientes.
-- ============================================================

DROP DATABASE IF EXISTS helpdesk_pro;
CREATE DATABASE helpdesk_pro CHARACTER SET utf8mb4;

SHOW DATABASES;
USE helpdesk_pro;

CREATE TABLE clients (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nit VARCHAR(25) NOT NULL UNIQUE,
    company_name VARCHAR(180) NOT NULL,
    status VARCHAR(15) NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT chk_clients_1 CHECK (status IN ('ACTIVO','INACTIVO'))
) ENGINE=InnoDB;

CREATE TABLE categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255) NULL
) ENGINE=InnoDB;

CREATE TABLE technicians (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    corporate_email VARCHAR(255) NOT NULL UNIQUE,
    specialty VARCHAR(100) NOT NULL,
    status VARCHAR(15) NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT chk_technicians_1 CHECK (status IN ('ACTIVO','INACTIVO'))
) ENGINE=InnoDB;

CREATE TABLE contacts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    client_id BIGINT NOT NULL,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL,
    status VARCHAR(15) NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT uq_contacts_1 UNIQUE (client_id, email),
    CONSTRAINT chk_contacts_1 CHECK (status IN ('ACTIVO','INACTIVO')),
    FOREIGN KEY (client_id) REFERENCES clients(id)
) ENGINE=InnoDB;

CREATE TABLE tickets (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    contact_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    subject VARCHAR(180) NOT NULL,
    description TEXT NOT NULL,
    priority VARCHAR(12) NOT NULL DEFAULT 'MEDIA',
    status VARCHAR(20) NOT NULL DEFAULT 'ABIERTO',
    opened_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_tickets_1 CHECK (priority IN ('BAJA','MEDIA','ALTA','CRITICA')),
    CONSTRAINT chk_tickets_2 CHECK (status IN ('ABIERTO','EN_PROCESO','RESUELTO','CERRADO')),
    FOREIGN KEY (contact_id) REFERENCES contacts(id),
    FOREIGN KEY (category_id) REFERENCES categories(id)
) ENGINE=InnoDB;

CREATE TABLE assignments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ticket_id BIGINT NOT NULL,
    technician_id BIGINT NOT NULL,
    started_at DATETIME NOT NULL,
    ended_at DATETIME NULL,
    active_ticket_id BIGINT GENERATED ALWAYS AS (IF(ended_at IS NULL, ticket_id, NULL)) STORED,
    CONSTRAINT uq_assignments_1 UNIQUE (active_ticket_id),
    CONSTRAINT chk_assignments_1 CHECK (ended_at IS NULL OR ended_at > started_at),
    FOREIGN KEY (ticket_id) REFERENCES tickets(id),
    FOREIGN KEY (technician_id) REFERENCES technicians(id)
) ENGINE=InnoDB;

CREATE TABLE status_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ticket_id BIGINT NOT NULL,
    technician_id BIGINT NULL,
    previous_status VARCHAR(20) NULL,
    new_status VARCHAR(20) NOT NULL,
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reason VARCHAR(255) NOT NULL,
    CONSTRAINT chk_status_history_1 CHECK (previous_status IS NULL OR previous_status IN ('ABIERTO','EN_PROCESO','RESUELTO','CERRADO')),
    CONSTRAINT chk_status_history_2 CHECK (new_status IN ('ABIERTO','EN_PROCESO','RESUELTO','CERRADO')),
    CONSTRAINT chk_status_history_3 CHECK (previous_status IS NULL OR previous_status <> new_status),
    FOREIGN KEY (ticket_id) REFERENCES tickets(id),
    FOREIGN KEY (technician_id) REFERENCES technicians(id)
) ENGINE=InnoDB;

CREATE TABLE comments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ticket_id BIGINT NOT NULL,
    contact_id BIGINT NULL,
    technician_id BIGINT NULL,
    content TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_comments_1 CHECK (
        (contact_id IS NOT NULL AND technician_id IS NULL) OR
        (contact_id IS NULL AND technician_id IS NOT NULL)
    ),
    FOREIGN KEY (ticket_id) REFERENCES tickets(id),
    FOREIGN KEY (contact_id) REFERENCES contacts(id),
    FOREIGN KEY (technician_id) REFERENCES technicians(id)
) ENGINE=InnoDB;

SHOW TABLES;


-- ============================================================
-- DML: INSERT INTO | datos semilla para resolver los 20 retos
-- Nunca ejecutar los ejemplos destructivos antes del DQL.
-- ============================================================

USE helpdesk_pro;
INSERT INTO clients (nit, company_name, status) VALUES
('900111001-1','Andes Digital SAS','ACTIVO'),('900111002-2','Nova Retail SAS','ACTIVO'),('900111003-3','Clínica Norte SAS','ACTIVO'),('900111004-4','Agrocentro SAS','INACTIVO');
INSERT INTO categories (name, description) VALUES
('Acceso','Problemas de inicio de sesión'),('Infraestructura','Servidores y red'),('Facturación','Errores de cobro'),('Aplicación','Funcionalidad de software'),('Seguridad','Reportes de acceso inusual');
INSERT INTO technicians (name,corporate_email,specialty,status) VALUES
('Lucía Pérez','lucia@soporte.test','Redes','ACTIVO'),('Mateo Ruiz','mateo@soporte.test','Aplicaciones','ACTIVO'),('Sara Díaz','sara@soporte.test','Seguridad','ACTIVO'),('Juan Vega','juan@soporte.test','Facturación','ACTIVO'),('Elena Paz','elena@soporte.test','Infraestructura','INACTIVO');
INSERT INTO contacts (client_id,name,email,status) VALUES
(1,'Ana Rojas','ana@andes.test','ACTIVO'),(1,'Carlos Mora','carlos@andes.test','ACTIVO'),(2,'Diana Gil','diana@nova.test','ACTIVO'),(2,'Pedro León','pedro@nova.test','ACTIVO'),(3,'Lina Serrano','lina@clinica.test','ACTIVO'),(3,'Iván Díaz','ivan@clinica.test','ACTIVO'),(4,'Rosa Pinto','rosa@agro.test','INACTIVO');
INSERT INTO tickets (contact_id,category_id,subject,description,priority,status,opened_at) VALUES
(1,1,'No puedo ingresar','La contraseña no se reconoce','ALTA','ABIERTO','2026-09-01 08:00:00'),
(2,2,'Red intermitente','Cortes de red en oficina','CRITICA','EN_PROCESO','2026-09-02 09:00:00'),
(3,3,'Factura duplicada','Cobro repetido de agosto','MEDIA','RESUELTO','2026-09-03 10:30:00'),
(4,4,'Exportación fallida','El módulo de reportes falla','ALTA','CERRADO','2026-09-04 14:20:00'),
(5,5,'Alerta de seguridad','Acceso desde ubicación inusual','CRITICA','EN_PROCESO','2026-09-05 07:15:00'),
(1,4,'Filtro no funciona','Listado devuelve datos incorrectos','BAJA','CERRADO','2026-09-06 12:00:00'),
(6,1,'Cuenta bloqueada','Bloqueo tras varios intentos','MEDIA','ABIERTO','2026-09-07 11:00:00'),
(3,2,'Servidor lento','Tiempos de respuesta elevados','ALTA','RESUELTO','2026-09-08 16:00:00');
INSERT INTO assignments (ticket_id,technician_id,started_at,ended_at) VALUES
(1,2,'2026-09-01 09:00:00',NULL),
(2,1,'2026-09-02 09:30:00','2026-09-02 12:00:00'),
(2,5,'2026-09-02 12:15:00',NULL),
(3,4,'2026-09-03 11:00:00','2026-09-03 16:00:00'),
(4,2,'2026-09-04 15:00:00','2026-09-05 10:00:00'),
(5,3,'2026-09-05 08:00:00',NULL),
(6,2,'2026-09-06 13:00:00','2026-09-06 15:00:00'),
(8,1,'2026-09-08 17:00:00','2026-09-09 09:00:00');
INSERT INTO status_history (ticket_id,technician_id,previous_status,new_status,changed_at,reason) VALUES
(1,NULL,NULL,'ABIERTO','2026-09-01 08:00:00','Registro inicial'),
(2,1,'ABIERTO','EN_PROCESO','2026-09-02 09:30:00','Diagnóstico iniciado'),
(3,4,'EN_PROCESO','RESUELTO','2026-09-03 16:00:00','Ajuste de factura'),
(4,2,'RESUELTO','CERRADO','2026-09-05 10:30:00','Confirmación del cliente'),
(5,3,'ABIERTO','EN_PROCESO','2026-09-05 08:00:00','Auditoría de acceso'),
(6,2,'RESUELTO','CERRADO','2026-09-06 16:00:00','Validación final'),
(7,NULL,NULL,'ABIERTO','2026-09-07 11:00:00','Creación automática'),
(8,1,'EN_PROCESO','RESUELTO','2026-09-09 09:00:00','Reinicio de servicios');
INSERT INTO comments (ticket_id,contact_id,technician_id,content,created_at) VALUES
(1,1,NULL,'Solicito apoyo urgente','2026-09-01 08:05:00'),
(1,NULL,2,'Revisaré el acceso','2026-09-01 09:15:00'),
(2,2,NULL,'La conexión sigue cayéndose','2026-09-02 10:00:00'),
(2,NULL,1,'Se detectó una falla de red','2026-09-02 11:00:00'),
(3,NULL,4,'Se corrigió el documento','2026-09-03 15:30:00'),
(4,4,NULL,'Ya funciona la exportación','2026-09-05 10:15:00'),
(5,NULL,3,'Incidente en investigación','2026-09-05 08:30:00'),
(6,1,NULL,'Gracias por solucionar el filtro','2026-09-06 16:00:00'),
(8,NULL,1,'Servicio restablecido','2026-09-09 09:10:00');


-- ============================================================
-- PRACTICA ADICIONAL: UPDATE / DELETE / TRUNCATE
-- Los siguientes 10 ejemplos estan DESACTIVADOS (comentados).
-- Descomentar uno a la vez, SOLO en una copia de laboratorio.
-- Ejecutar estos ejemplos puede cambiar resultados de DQL.
-- TRUNCATE es DDL en MySQL, no se revierte con ROLLBACK.
-- ============================================================

-- 01. UPDATE clients SET status = 'ACTIVO' WHERE id = 4;
-- 02. UPDATE tickets SET priority = 'CRITICA' WHERE id = 1;
-- 03. UPDATE technicians SET specialty = 'Soporte de red' WHERE id = 1;
-- 04. UPDATE assignments SET ended_at = '2026-09-03 11:00:00' WHERE id = 3;
-- 05. DELETE FROM comments WHERE id = 9;
-- 06. DELETE FROM status_history WHERE id = 7;
-- 07. DELETE FROM assignments WHERE id = 8;
-- 08. DELETE FROM tickets WHERE id = 7;
-- 09. TRUNCATE TABLE comments;
-- 10. TRUNCATE TABLE status_history;
