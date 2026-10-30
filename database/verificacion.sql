-- =====================================================================
-- CodeQuest: Aprende a programar
-- verificacion.sql - Consultas para comprobar que la base quedó bien
--
-- Ejecutar después de 01_schema.sql y 02_seed_catalogos.sql.
-- =====================================================================

USE codequest_db;

-- 1. Deben aparecer 16 tablas.
SELECT COUNT(*) AS total_tablas
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'codequest_db';

-- 2. Relaciones (claves foráneas) definidas: deben ser 26.
SELECT TABLE_NAME AS tabla, COLUMN_NAME AS columna,
       REFERENCED_TABLE_NAME AS referencia, REFERENCED_COLUMN_NAME AS columna_referenciada
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'codequest_db' AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;

-- 3. Datos de catálogo: 2 rutas, 5 niveles, 3 módulos, 8 insignias.
SELECT 'rutas' AS catalogo, COUNT(*) AS filas FROM learning_paths
UNION ALL SELECT 'niveles',    COUNT(*) FROM levels
UNION ALL SELECT 'modulos',    COUNT(*) FROM modules
UNION ALL SELECT 'insignias',  COUNT(*) FROM badges;

-- 4. Insignias de módulo con el nombre del módulo.
SELECT b.name AS insignia, m.name AS modulo, b.xp_reward
FROM badges b
JOIN modules m ON m.id = b.module_id
ORDER BY m.sort_order;

-- 5. Prueba de integridad: este INSERT DEBE FALLAR (correo repetido).
--    Descomenta las tres líneas para comprobarlo y luego borra el usuario.
-- INSERT INTO users (full_name, email, password_hash) VALUES ('Prueba', 'prueba@codequest.test', 'x');
-- INSERT INTO users (full_name, email, password_hash) VALUES ('Prueba 2', 'prueba@codequest.test', 'x');
-- DELETE FROM users WHERE email = 'prueba@codequest.test';
