-- =====================================================================
-- CodeQuest: rol de administrador (MySQL / XAMPP)
--
-- Solo para una base creada antes de este cambio (01_schema.sql ya
-- incluye la columna role). Cambia el correo y ejecútalo en phpMyAdmin.
-- =====================================================================

USE codequest_db;

ALTER TABLE users
  ADD COLUMN role ENUM('estudiante', 'admin') NOT NULL DEFAULT 'estudiante'
  COMMENT 'admin ve los resultados de todos' AFTER xp_total;

UPDATE users SET role = 'admin' WHERE email = LOWER('CORREO_DEL_ADMIN@ejemplo.com');
