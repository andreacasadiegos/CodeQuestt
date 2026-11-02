-- =====================================================================
-- CodeQuest: Aprende a programar
-- 07_consultas_metricas.sql - Métricas para el seguimiento del proyecto
--
-- Solo consultas (SELECT): no modifican datos. Ejecútalas en phpMyAdmin
-- (pestaña SQL) cuando quieras ver cómo van los estudiantes.
-- =====================================================================

USE codequest_db;
SET NAMES utf8mb4;

-- 1. Estudiantes registrados y cuántos ya hicieron el diagnóstico.
SELECT COUNT(*)                     AS estudiantes_registrados,
       SUM(path_id IS NOT NULL)     AS con_diagnostico,
       SUM(path_id IS NULL)         AS sin_diagnostico
FROM users;

-- 2. Estudiantes por ruta: asignada en el diagnóstico y ruta actual.
SELECT p.name                                         AS ruta,
       (SELECT COUNT(*) FROM diagnostics d WHERE d.assigned_path_id = p.id) AS asignados_en_diagnostico,
       (SELECT COUNT(*) FROM users u WHERE u.path_id = p.id)              AS en_la_ruta_hoy
FROM learning_paths p
ORDER BY p.sort_order;

-- 3. Estudiantes que avanzaron de ruta básica a intermedia (RF-31).
SELECT u.full_name AS estudiante, u.email, u.xp_total
FROM users u
JOIN diagnostics d ON d.user_id = u.id
WHERE d.assigned_path_id <> u.path_id;

-- 4. Resultado del diagnóstico: autoevaluación y aciertos promedio.
SELECT CASE d.experience_option
         WHEN 1 THEN 'No tengo conocimientos'
         WHEN 2 THEN 'Tengo conocimientos básicos'
         ELSE 'Ya he estudiado programación'
       END                           AS autoevaluacion,
       COUNT(*)                      AS estudiantes,
       ROUND(AVG(d.test_score), 1)   AS aciertos_promedio_de_5
FROM diagnostics d
GROUP BY d.experience_option
ORDER BY d.experience_option;

-- 5. Niveles alcanzados.
SELECT l.number AS nivel, l.name AS nombre, COUNT(u.id) AS estudiantes
FROM levels l
LEFT JOIN users u ON u.level_id = l.id AND u.path_id IS NOT NULL
GROUP BY l.id, l.number, l.name
ORDER BY l.number;

-- 6. Ranking de XP (los 10 primeros).
SELECT u.full_name AS estudiante, p.name AS ruta, l.name AS nivel, u.xp_total
FROM users u
JOIN levels l ON l.id = u.level_id
LEFT JOIN learning_paths p ON p.id = u.path_id
ORDER BY u.xp_total DESC, u.full_name
LIMIT 10;

-- 7. Avance por módulo: estudiantes sin iniciar, en curso y que lo completaron.
SELECT m.name                          AS modulo,
       SUM(mp.status = 'en_curso')     AS en_curso,
       SUM(mp.status = 'completado')   AS completado,
       ROUND(AVG(mp.percent), 1)       AS avance_promedio_pct
FROM modules m
LEFT JOIN module_progress mp ON mp.module_id = m.id
GROUP BY m.id, m.name
ORDER BY m.sort_order;

-- 8. Actividades: intentos, estudiantes, puntaje promedio y tasa de aprobación.
--    Sirve para encontrar las actividades más difíciles.
SELECT a.id, m.name AS modulo, COALESCE(lp.name, 'Ambas') AS ruta, a.kind AS tipo,
       a.title AS actividad, a.difficulty AS dificultad,
       COUNT(t.id)                                  AS intentos,
       COUNT(DISTINCT t.user_id)                    AS estudiantes,
       ROUND(AVG(t.score_pct), 1)                   AS puntaje_promedio,
       ROUND(100 * AVG(t.passed), 1)                AS aprobacion_pct
FROM activities a
JOIN modules m ON m.id = a.module_id
LEFT JOIN learning_paths lp ON lp.id = a.path_id
LEFT JOIN attempts t ON t.activity_id = a.id
WHERE a.kind <> 'diagnostico'
GROUP BY a.id, m.name, lp.name, a.kind, a.title, a.difficulty
ORDER BY AVG(t.score_pct) IS NULL, AVG(t.score_pct);

-- 9. Preguntas con más errores (las 10 primeras con al menos un intento).
SELECT q.id, a.title AS actividad, q.type AS tipo, q.statement AS pregunta,
       COUNT(*)                          AS respuestas,
       ROUND(100 * AVG(aa.is_correct), 1) AS acierto_pct
FROM attempt_answers aa
JOIN questions q  ON q.id = aa.question_id
JOIN activities a ON a.id = q.activity_id
WHERE a.kind <> 'diagnostico'
GROUP BY q.id, a.title, q.type, q.statement
ORDER BY acierto_pct, respuestas DESC
LIMIT 10;

-- 10. Retos completados por módulo.
SELECT m.name AS modulo, COUNT(DISTINCT t.user_id) AS estudiantes_que_lo_superaron
FROM activities a
JOIN modules m ON m.id = a.module_id
LEFT JOIN attempts t ON t.activity_id = a.id AND t.passed = 1
WHERE a.kind = 'reto'
GROUP BY m.id, m.name
ORDER BY m.sort_order;

-- 11. Insignias otorgadas.
SELECT b.name AS insignia, COUNT(ub.user_id) AS estudiantes
FROM badges b
LEFT JOIN user_badges ub ON ub.badge_id = b.id
GROUP BY b.id, b.name
ORDER BY estudiantes DESC, b.id;

-- 12. Comprobación de integridad del XP: el total de cada estudiante debe
--     ser igual a la suma de sus movimientos. Si aparece alguna fila, hay
--     un XP que no se registró correctamente.
SELECT u.id, u.full_name, u.xp_total, COALESCE(SUM(x.amount), 0) AS suma_movimientos
FROM users u
LEFT JOIN xp_transactions x ON x.user_id = u.id
GROUP BY u.id, u.full_name, u.xp_total
HAVING u.xp_total <> suma_movimientos;
