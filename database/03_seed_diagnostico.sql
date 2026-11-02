-- =====================================================================
-- CodeQuest: Aprende a programar
-- 03_seed_diagnostico.sql - Prueba diagnóstica de 5 preguntas
--
-- Ejecutar DESPUÉS de 02_seed_catalogos.sql.
-- Una pregunta por concepto (abstracción, patrones, algoritmos) y dos
-- de lectura de pseudocódigo. Todas son de selección única.
-- =====================================================================

USE codequest_db;
SET NAMES utf8mb4;

INSERT INTO activities (id, module_id, lesson_id, path_id, title, description, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (1, NULL, NULL, NULL, 'Prueba diagnóstica',
   'Cinco preguntas cortas para conocer tu punto de partida.', 'diagnostico', 1, 0, 60, 0);

-- 1. Abstracción
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (1, 1, 'seleccion',
   'Vas a dibujar un mapa para que un amigo llegue a tu casa desde el colegio. ¿Qué es lo más importante incluir?',
   NULL,
   'Eso es abstracción: quedarse con la información que sirve para el objetivo (llegar) y dejar de lado detalles como colores o árboles.',
   1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, sort_order) VALUES
  (1, 'Las calles principales y algunos puntos de referencia', 1, 1),
  (1, 'El color de cada casa del barrio', 0, 2),
  (1, 'La cantidad de árboles de cada cuadra', 0, 3),
  (1, 'Los nombres de todos los vecinos', 0, 4);

-- 2. Patrones
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (2, 1, 'patron',
   '¿Qué número sigue en la secuencia?',
   '3, 6, 9, 12, ___',
   'Cada número suma 3 al anterior: 12 + 3 = 15. Reconocer esa regularidad es identificar un patrón.',
   1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, sort_order) VALUES
  (2, '14', 0, 1),
  (2, '15', 1, 2),
  (2, '16', 0, 3),
  (2, '18', 0, 4);

-- 3. Algoritmos
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (3, 1, 'seleccion',
   '¿Cuál es el orden correcto de pasos para enviar un mensaje de chat?',
   NULL,
   'Un algoritmo es una secuencia de pasos en un orden preciso: primero se abre el chat, luego se escribe y al final se envía.',
   1, 3);
INSERT INTO answer_options (question_id, option_text, is_correct, sort_order) VALUES
  (3, 'Escribir el mensaje → abrir el chat → enviar', 0, 1),
  (3, 'Abrir el chat → escribir el mensaje → enviar', 1, 2),
  (3, 'Enviar → abrir el chat → escribir el mensaje', 0, 3),
  (3, 'Abrir el chat → enviar → escribir el mensaje', 0, 4);

-- 4. Lectura de pseudocódigo: variables
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (4, 1, 'seleccion',
   '¿Qué valor se muestra al ejecutar este pseudocódigo?',
   'x ← 5\nx ← x + 3\nmostrar x',
   'x empieza en 5; luego se le suma 3 y queda en 8. Las instrucciones se ejecutan en orden, de arriba hacia abajo.',
   1, 4);
INSERT INTO answer_options (question_id, option_text, is_correct, sort_order) VALUES
  (4, '5', 0, 1),
  (4, '3', 0, 2),
  (4, '8', 1, 3),
  (4, 'x + 3', 0, 4);

-- 5. Lectura de pseudocódigo: repetición
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (5, 1, 'seleccion',
   '¿Cuántas veces se muestra la palabra "Hola"?',
   'para i desde 1 hasta 3\n    mostrar "Hola"\nfin para',
   'El ciclo repite su contenido para i = 1, 2 y 3: tres veces. Los ciclos aprovechan un patrón de repetición.',
   1, 5);
INSERT INTO answer_options (question_id, option_text, is_correct, sort_order) VALUES
  (5, '1', 0, 1),
  (5, '2', 0, 2),
  (5, '3', 1, 3),
  (5, '4', 0, 4);
