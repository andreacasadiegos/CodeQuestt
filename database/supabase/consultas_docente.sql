-- =====================================================================
-- CodeQuest: resultados de los estudiantes (Supabase / PostgreSQL)
--
-- Pega una consulta en Supabase -> SQL Editor y pulsa Run.
-- Solo leen datos: no modifican nada.
-- =====================================================================

-- 1. Resumen por estudiante: ruta, nivel, XP, actividades y promedio.
SELECT u.full_name                                   AS estudiante,
       u.email                                       AS correo,
       COALESCE(p.name, 'Sin diagnóstico')           AS ruta,
       l.name                                        AS nivel,
       u.xp_total                                    AS xp,
       COUNT(DISTINCT t.activity_id) FILTER (WHERE t.passed = 1) AS actividades_aprobadas,
       ROUND(AVG(t.score_pct))                       AS puntaje_promedio,
       (SELECT COUNT(*) FROM user_badges b WHERE b.user_id = u.id) AS insignias,
       to_char(MAX(t.submitted_at), 'YYYY-MM-DD HH24:MI') AS ultima_actividad
FROM users u
JOIN levels l ON l.id = u.level_id
LEFT JOIN learning_paths p ON p.id = u.path_id
LEFT JOIN attempts t ON t.user_id = u.id
  AND t.activity_id IN (SELECT id FROM activities WHERE kind <> 'diagnostico')
GROUP BY u.id, p.name, l.name
ORDER BY u.full_name;

-- 2. Avance de cada estudiante en cada módulo.
SELECT u.full_name AS estudiante, m.name AS modulo, mp.percent AS porcentaje, mp.status AS estado
FROM module_progress mp
JOIN users u ON u.id = mp.user_id
JOIN modules m ON m.id = mp.module_id
ORDER BY u.full_name, m.sort_order;

-- 3. Últimos 50 intentos: quién, qué actividad y qué nota.
SELECT u.full_name AS estudiante, m.name AS modulo, a.title AS actividad, a.kind AS tipo,
       t.correct_count || '/' || t.total_count AS aciertos, t.score_pct AS puntaje,
       CASE WHEN t.passed = 1 THEN 'Aprobó' ELSE 'No aprobó' END AS resultado,
       to_char(t.submitted_at, 'YYYY-MM-DD HH24:MI') AS fecha
FROM attempts t
JOIN users u ON u.id = t.user_id
JOIN activities a ON a.id = t.activity_id
LEFT JOIN modules m ON m.id = a.module_id
ORDER BY t.id DESC
LIMIT 50;

-- 4. Actividades más difíciles (menor puntaje promedio).
SELECT m.name AS modulo, a.title AS actividad, COUNT(*) AS intentos,
       ROUND(AVG(t.score_pct)) AS puntaje_promedio
FROM attempts t
JOIN activities a ON a.id = t.activity_id
LEFT JOIN modules m ON m.id = a.module_id
WHERE a.kind <> 'diagnostico'
GROUP BY m.name, a.title
ORDER BY puntaje_promedio
LIMIT 10;
