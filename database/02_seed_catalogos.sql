-- =====================================================================
-- CodeQuest: Aprende a programar
-- 02_seed_catalogos.sql - Datos iniciales de catálogo
--
-- Ejecutar DESPUÉS de 01_schema.sql.
-- El contenido educativo (lecciones, actividades y preguntas) se carga
-- en 03_seed_contenido.sql en las Etapas 5 y 6.
-- =====================================================================

USE codequest_db;
SET NAMES utf8mb4;

-- Rutas de aprendizaje.
-- Desde la ruta básica se puede avanzar a la intermedia con un promedio
-- de 80 % o más en las evaluaciones de los 3 módulos (RF-31).
INSERT INTO learning_paths (id, code, name, description, advance_min_pct, sort_order) VALUES
  (1, 'basica',     'Ruta básica',
      'Para estudiantes sin conocimientos previos o con conocimientos mínimos de programación.', 80, 1),
  (2, 'intermedia', 'Ruta intermedia',
      'Para estudiantes que ya poseen conocimientos básicos de programación.', NULL, 2);

-- Niveles de experiencia.
INSERT INTO levels (id, number, name, min_xp) VALUES
  (1, 1, 'Explorador',         0),
  (2, 2, 'Aprendiz',           100),
  (3, 3, 'Programador',        250),
  (4, 4, 'Estratega',          450),
  (5, 5, 'Maestro del código', 700);

-- Módulos de aprendizaje.
INSERT INTO modules (id, slug, name, description, icon, sort_order) VALUES
  (1, 'abstraccion', 'Abstracción',
      'Aprende a quedarte con lo importante de un problema y dejar de lado los detalles.', 'bi-layers', 1),
  (2, 'patrones',    'Patrones',
      'Descubre regularidades y repeticiones para resolver problemas parecidos de la misma forma.', 'bi-grid-3x3-gap', 2),
  (3, 'algoritmos',  'Algoritmos',
      'Diseña secuencias de pasos ordenados y precisos para resolver un problema.', 'bi-diagram-3', 3);

-- Insignias (logros).
INSERT INTO badges (id, code, name, description, icon, rule_type, rule_value, module_id, xp_reward) VALUES
  (1, 'primer-paso',        'Primer paso',
      'Completaste tu primera actividad.',                          'bi-rocket-takeoff', 'actividades_completadas', 1,   NULL, 10),
  (2, 'constancia',         'Constancia',
      'Completaste 10 actividades.',                                'bi-fire',           'actividades_completadas', 10,  NULL, 30),
  (3, 'sin-errores',        'Sin errores',
      'Obtuviste 100 % en una actividad.',                          'bi-bullseye',       'puntaje_perfecto',        1,   NULL, 20),
  (4, 'retador',            'Retador',
      'Superaste tu primer reto de módulo.',                        'bi-trophy',         'reto_completado',         1,   NULL, 25),
  (5, 'maestro-abstraccion','Maestro de la abstracción',
      'Completaste el módulo de Abstracción.',                      'bi-layers-fill',    'modulo_completado',       1,   1,    40),
  (6, 'maestro-patrones',   'Maestro de los patrones',
      'Completaste el módulo de Patrones.',                         'bi-grid-3x3-gap-fill', 'modulo_completado',    1,   2,    40),
  (7, 'maestro-algoritmos', 'Maestro de los algoritmos',
      'Completaste el módulo de Algoritmos.',                       'bi-diagram-3-fill', 'modulo_completado',       1,   3,    40),
  (8, 'leyenda',            'Leyenda en ascenso',
      'Acumulaste 500 puntos de experiencia.',                      'bi-stars',          'xp_total',                500, NULL, 0);
