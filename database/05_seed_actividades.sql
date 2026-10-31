-- =====================================================================
-- CodeQuest: Aprende a programar
-- 05_seed_actividades.sql - Actividades, preguntas y respuestas
--
-- Ejecutar DESPUÉS de 04_seed_contenido.sql.
--   - Una práctica por lección (2 preguntas). Dificultad = posición de
--     la lección en el módulo (1, 2, 3); XP base 10, 20 o 30.
--   - Una evaluación por módulo y ruta (4 preguntas, dificultad 3, 40 XP).
--     Se desbloquea al leer todas las lecciones del módulo.
-- Tipos de pregunta y uso de answer_options:
--   seleccion / patron -> option_text + is_correct
--   completar_codigo   -> option_text = respuesta aceptada (is_correct = 1)
--   ordenar            -> option_text + correct_order
--   relacionar         -> option_text (concepto) + pair_text (definición)
-- Las opciones se guardan desordenadas (sort_order) para que el orden de
-- los ids no revele la respuesta.
-- =====================================================================

USE codequest_db;

-- Práctica: ¿qué es la abstracción?
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (2, 1, 1, NULL, 'Práctica: ¿qué es la abstracción?', 'practica', 1, 10, 60, 1);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (6, 2, 'seleccion', '¿Qué significa abstraer un problema?', NULL, 'Abstraer es quedarse con lo que sirve para el objetivo y dejar de lado lo demás.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (6, 'Agregar todos los detalles posibles', 0, NULL, NULL, 1),
  (6, 'Quedarse con lo importante para el objetivo y dejar los detalles', 1, NULL, NULL, 2),
  (6, 'Resolverlo sin pensar en el objetivo', 0, NULL, NULL, 3),
  (6, 'Escribir el programa más largo posible', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (7, 2, 'relacionar', 'Relaciona cada concepto con su significado.', NULL, 'El objetivo define qué es esencial; lo que no ayuda al objetivo es un detalle que podemos omitir.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (7, 'Objetivo', 0, NULL, 'Lo que queremos lograr', 1),
  (7, 'Abstracción', 0, NULL, 'Quedarse con lo esencial', 2),
  (7, 'Detalle irrelevante', 0, NULL, 'Información que no ayuda al objetivo', 3);

-- Práctica: lo esencial y los detalles
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (3, 1, 2, 1, 'Práctica: lo esencial y los detalles', 'practica', 2, 20, 60, 2);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (8, 3, 'seleccion', 'Una aplicación de domicilios debe entregar un pedido. ¿Qué dato del cliente es esencial?', NULL, 'Para entregar un pedido se necesita saber a dónde llevarlo: la dirección es lo esencial.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (8, 'Su color favorito', 0, NULL, NULL, 1),
  (8, 'Su equipo de fútbol', 0, NULL, NULL, 2),
  (8, 'La dirección de entrega', 1, NULL, NULL, 3),
  (8, 'La fecha de su cumpleaños', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (9, 3, 'seleccion', 'Para la ficha de la enfermería del colegio, ¿qué dato sobra?', NULL, 'A la enfermería le interesan los datos de salud; los libros prestados son un detalle que no ayuda a su objetivo.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (9, 'Las alergias', 0, NULL, NULL, 1),
  (9, 'Los libros prestados', 1, NULL, NULL, 2),
  (9, 'El grupo sanguíneo', 0, NULL, NULL, 3),
  (9, 'El nombre', 0, NULL, NULL, 4);

-- Práctica: usar sin conocer los detalles
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (4, 1, 3, 1, 'Práctica: usar sin conocer los detalles', 'practica', 3, 30, 60, 3);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (10, 4, 'seleccion', 'Cuando usas la instrucción mostrar, ¿qué necesitas saber?', NULL, 'Basta con saber qué hace la instrucción; los detalles de cómo lo logra quedan ocultos.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (10, 'Cómo se encienden los píxeles', 0, NULL, NULL, 1),
  (10, 'Qué hace: presenta información en pantalla', 1, NULL, NULL, 2),
  (10, 'El voltaje de la pantalla', 0, NULL, NULL, 3),
  (10, 'El código interno del sistema operativo', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (11, 4, 'relacionar', 'Relaciona cada objeto con lo que te muestra y lo que te oculta.', NULL, 'Todos estos objetos son abstracciones: muestran una forma simple de usarlos y ocultan cómo funcionan por dentro.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (11, 'Instrucción mostrar', 0, NULL, 'Presentar texto; oculta cómo se dibuja', 1),
  (11, 'Control remoto', 0, NULL, 'Botones simples; oculta los circuitos', 2),
  (11, 'Volante de un carro', 0, NULL, 'Girar; oculta el mecanismo de dirección', 3);

-- Práctica: modelar datos
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (5, 1, 4, 2, 'Práctica: modelar datos', 'practica', 2, 20, 60, 2);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (12, 5, 'seleccion', 'Una app recomienda canciones según su género y su duración. ¿Qué atributo NO necesita?', NULL, 'Las operaciones de la app usan género y duración (y el título para mostrarla); el ingeniero de sonido no participa en ninguna.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (12, 'Título', 0, NULL, NULL, 1),
  (12, 'Género', 0, NULL, NULL, 2),
  (12, 'Duración', 0, NULL, NULL, 3),
  (12, 'Nombre del ingeniero de sonido', 1, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (13, 5, 'completar_codigo', 'Completa la palabra que cierra la decisión.', 'si cancion.duracion > 300 entonces\n    mostrar "Canción larga"\nfin ___', 'Toda estructura si … entonces se cierra con fin si.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (13, 'si', 1, NULL, NULL, 1);

-- Práctica: funciones
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (6, 1, 5, 2, 'Práctica: funciones', 'practica', 3, 30, 60, 3);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (14, 6, 'seleccion', '¿Cuál es la principal ventaja de usar funciones?', NULL, 'Una función se escribe una vez y se reutiliza; además hace el programa más claro y fácil de corregir.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (14, 'Se escribe una vez y se puede usar muchas veces', 1, NULL, NULL, 1),
  (14, 'Hace que el programa sea más largo', 0, NULL, NULL, 2),
  (14, 'Evita tener que usar variables', 0, NULL, NULL, 3),
  (14, 'Solo sirve para mostrar texto', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (15, 6, 'completar_codigo', 'Completa la palabra que entrega el resultado de la función.', 'funcion doble(n)\n    ___ n * 2\nfin funcion', 'La instrucción devolver entrega el resultado de la función a quien la llamó.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (15, 'devolver', 1, NULL, NULL, 1);

-- Práctica: ¿qué es un patrón?
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (7, 2, 6, NULL, 'Práctica: ¿qué es un patrón?', 'practica', 1, 10, 60, 1);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (16, 7, 'patron', '¿Qué número sigue?', '2, 4, 6, 8, ___', 'Cada número suma 2 al anterior: 8 + 2 = 10.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (16, '9', 0, NULL, NULL, 1),
  (16, '10', 1, NULL, NULL, 2),
  (16, '12', 0, NULL, NULL, 3),
  (16, '16', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (17, 7, 'seleccion', '¿Cuál de estas situaciones muestra un patrón?', NULL, 'El horario se repite cada semana siguiendo una regla; los demás ejemplos son impredecibles.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (17, 'El resultado de lanzar un dado', 0, NULL, NULL, 1),
  (17, 'El número ganador de la lotería', 0, NULL, NULL, 2),
  (17, 'El horario de clases que se repite cada semana', 1, NULL, NULL, 3),
  (17, 'El clima exacto de mañana', 0, NULL, NULL, 4);

-- Práctica: secuencias
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (8, 2, 7, 1, 'Práctica: secuencias', 'practica', 2, 20, 60, 2);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (18, 8, 'patron', '¿Qué número sigue?', '1, 3, 9, 27, ___', 'Cada número se multiplica por 3: 27 × 3 = 81.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (18, '36', 0, NULL, NULL, 1),
  (18, '54', 0, NULL, NULL, 2),
  (18, '81', 1, NULL, NULL, 3),
  (18, '30', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (19, 8, 'patron', '¿Qué figura sigue?', '▲, ●, ●, ▲, ●, ●, ▲, ___', 'El grupo «▲ ● ●» se repite; después de ▲ viene ●.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (19, '▲', 0, NULL, NULL, 1),
  (19, '●', 1, NULL, NULL, 2),
  (19, '■', 0, NULL, NULL, 3),
  (19, '◆', 0, NULL, NULL, 4);

-- Práctica: repetir sin repetirse
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (9, 2, 8, 1, 'Práctica: repetir sin repetirse', 'practica', 3, 30, 60, 3);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (20, 9, 'completar_codigo', 'Completa el número para que el robot dibuje un cuadrado.', 'repetir ___ veces\n    avanzar 10\n    girar 90\nfin repetir', 'Un cuadrado tiene 4 lados: el par «avanzar, girar 90» se repite 4 veces.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (20, '4', 1, NULL, NULL, 1),
  (20, 'cuatro', 1, NULL, NULL, 2);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (21, 9, 'seleccion', '¿Para qué sirve un ciclo?', NULL, 'Un ciclo repite un bloque de instrucciones; existe gracias a que reconocemos patrones de repetición.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (21, 'Para repetir un bloque de instrucciones varias veces', 1, NULL, NULL, 1),
  (21, 'Para tomar una decisión una sola vez', 0, NULL, NULL, 2),
  (21, 'Para borrar variables', 0, NULL, NULL, 3),
  (21, 'Para terminar el programa', 0, NULL, NULL, 4);

-- Práctica: la regla del término n
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (10, 2, 9, 2, 'Práctica: la regla del término n', 'practica', 2, 20, 60, 2);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (22, 10, 'patron', 'Si la regla es término(n) = 2n + 3, ¿cuál es el término 10?', 'termino(n) = 2n + 3\ntermino(10) = ___', '2 · 10 + 3 = 23.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (22, '20', 0, NULL, NULL, 1),
  (22, '23', 1, NULL, NULL, 2),
  (22, '25', 0, NULL, NULL, 3),
  (22, '13', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (23, 10, 'seleccion', '¿Qué regla genera la secuencia 5, 9, 13, 17…?', NULL, 'Aumenta de 4 en 4 y para n = 1 vale 5: 4 · 1 + 1 = 5. La regla es 4n + 1.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (23, '4n', 0, NULL, NULL, 1),
  (23, 'n + 4', 0, NULL, NULL, 2),
  (23, '4n + 1', 1, NULL, NULL, 3),
  (23, '5n', 0, NULL, NULL, 4);

-- Práctica: patrones con ciclos y condiciones
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (11, 2, 10, 2, 'Práctica: patrones con ciclos y condiciones', 'practica', 3, 30, 60, 3);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (24, 11, 'completar_codigo', 'Completa la operación para mostrar los múltiplos de 5.', 'para i desde 1 hasta 20\n    si i ___ 5 = 0 entonces\n        mostrar i\n    fin si\nfin para', 'mod da el residuo de la división; si i mod 5 = 0, i es múltiplo de 5.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (24, 'mod', 1, NULL, NULL, 1);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (25, 11, 'seleccion', '¿Qué se muestra al ejecutar este pseudocódigo?', 'para i desde 1 hasta 6\n    si i mod 2 = 0 entonces\n        mostrar i\n    fin si\nfin para', 'Se muestran los números cuyo residuo al dividir entre 2 es 0: los pares 2, 4 y 6.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (25, '1, 3, 5', 0, NULL, NULL, 1),
  (25, '2, 4, 6', 1, NULL, NULL, 2),
  (25, '1, 2, 3, 4, 5, 6', 0, NULL, NULL, 3),
  (25, '6', 0, NULL, NULL, 4);

-- Práctica: ¿qué es un algoritmo?
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (12, 3, 11, NULL, 'Práctica: ¿qué es un algoritmo?', 'practica', 1, 10, 60, 1);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (26, 12, 'seleccion', '¿Cuál NO es una característica de un buen algoritmo?', NULL, 'Un algoritmo debe ser preciso, ordenado y finito; la ambigüedad hace que no se pueda seguir.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (26, 'Ser preciso', 0, NULL, NULL, 1),
  (26, 'Ser ordenado', 0, NULL, NULL, 2),
  (26, 'Ser ambiguo', 1, NULL, NULL, 3),
  (26, 'Ser finito', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (27, 12, 'ordenar', 'Ordena los pasos del algoritmo para calcular el área de un rectángulo.', NULL, 'Primero se reciben los datos (entrada), luego se calcula (proceso) y al final se muestra (salida).', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (27, 'Calcular área ← base × altura', 0, 3, NULL, 1),
  (27, 'Inicio', 0, 1, NULL, 2),
  (27, 'Mostrar el área', 0, 4, NULL, 3),
  (27, 'Leer la base y la altura', 0, 2, NULL, 4),
  (27, 'Fin', 0, 5, NULL, 5);

-- Práctica: secuencias de pasos
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (13, 3, 12, 1, 'Práctica: secuencias de pasos', 'practica', 2, 20, 60, 2);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (28, 13, 'ordenar', 'Ordena los pasos para lavarse los dientes.', NULL, 'En una secuencia el orden importa: no se puede cepillar antes de poner la crema dental.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (28, 'Cepillar los dientes', 0, 3, NULL, 1),
  (28, 'Tomar el cepillo', 0, 1, NULL, 2),
  (28, 'Enjuagar la boca', 0, 4, NULL, 3),
  (28, 'Poner crema dental', 0, 2, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (29, 13, 'completar_codigo', 'Completa la instrucción que presenta el resultado.', 'inicio\n    leer precio\n    leer cantidad\n    total ← precio * cantidad\n    ___ total\nfin', 'mostrar presenta un valor en pantalla; es la salida del algoritmo.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (29, 'mostrar', 1, NULL, NULL, 1);

-- Práctica: tomar decisiones
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (14, 3, 13, 1, 'Práctica: tomar decisiones', 'practica', 3, 30, 60, 3);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (30, 14, 'seleccion', '¿Qué se muestra al ejecutar este pseudocódigo?', 'x ← 2\nsi x > 5 entonces\n    mostrar "Grande"\nsino\n    mostrar "Pequeño"\nfin si', 'La condición 2 > 5 es falsa, así que se ejecuta el bloque sino.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (30, 'Grande', 0, NULL, NULL, 1),
  (30, 'Pequeño', 1, NULL, NULL, 2),
  (30, 'Grande y Pequeño', 0, NULL, NULL, 3),
  (30, 'Nada', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (31, 14, 'completar_codigo', 'Completa la palabra que falta en la decisión.', 'si nota ≥ 3.0 ___\n    mostrar "Aprobaste"\nfin si', 'La estructura es si condición entonces … fin si.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (31, 'entonces', 1, NULL, NULL, 1);

-- Práctica: acumuladores y contadores
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (15, 3, 14, 2, 'Práctica: acumuladores y contadores', 'practica', 2, 20, 60, 2);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (32, 15, 'seleccion', '¿Qué se muestra al ejecutar este pseudocódigo?', 'suma ← 0\npara i desde 1 hasta 4\n    suma ← suma + i\nfin para\nmostrar suma', 'suma acumula 1 + 2 + 3 + 4 = 10.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (32, '4', 0, NULL, NULL, 1),
  (32, '6', 0, NULL, NULL, 2),
  (32, '10', 1, NULL, NULL, 3),
  (32, '0', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (33, 15, 'relacionar', 'Relaciona cada concepto con su descripción.', NULL, 'Acumuladores y contadores son variables que cambian dentro de un ciclo; las condiciones deciden cuándo cambian.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (33, 'Ciclo', 0, NULL, 'Estructura que repite instrucciones', 1),
  (33, 'Acumulador', 0, NULL, 'Variable que va sumando valores', 2),
  (33, 'Condición', 0, NULL, 'Pregunta que es verdadera o falsa', 3),
  (33, 'Contador', 0, NULL, 'Variable que aumenta de 1 en 1', 4);

-- Práctica: encontrar el mayor
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (16, 3, 15, 2, 'Práctica: encontrar el mayor', 'practica', 3, 30, 60, 3);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (34, 16, 'ordenar', 'Ordena los pasos del algoritmo que encuentra el número mayor.', NULL, 'Se supone que el primero es el mayor, se recorren los demás y se reemplaza cuando aparece uno más grande.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (34, 'Si el elemento es mayor que mayor, reemplazarlo', 0, 3, NULL, 1),
  (34, 'mayor ← primer elemento de la lista', 0, 1, NULL, 2),
  (34, 'Devolver mayor', 0, 4, NULL, 3),
  (34, 'Recorrer los demás elementos', 0, 2, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (35, 16, 'seleccion', 'Haz la prueba de escritorio con la lista [4, 9, 2, 9]. ¿Qué devuelve encontrarMayor?', NULL, 'mayor empieza en 4, cambia a 9 y no vuelve a cambiar: el segundo 9 no es mayor que 9.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (35, '4', 0, NULL, NULL, 1),
  (35, '9', 1, NULL, NULL, 2),
  (35, '2', 0, NULL, NULL, 3),
  (35, '18', 0, NULL, NULL, 4);

-- Evaluación: Abstracción
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (17, 1, NULL, 1, 'Evaluación: Abstracción', 'evaluacion', 3, 40, 60, 10);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (36, 17, 'seleccion', '¿Qué representa el mapa del sistema de transporte de una ciudad?', NULL, 'Solo muestra lo necesario para moverse entre estaciones: es una abstracción.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (36, 'Todas las calles y edificios', 0, NULL, NULL, 1),
  (36, 'Estaciones, líneas y conexiones', 1, NULL, NULL, 2),
  (36, 'Los árboles de cada barrio', 0, NULL, NULL, 3),
  (36, 'El nombre de cada conductor', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (37, 17, 'relacionar', 'Relaciona cada servicio del colegio con el dato que más necesita.', NULL, 'La misma persona se describe con datos distintos según el objetivo de quien usa la información.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (37, 'Transporte escolar', 0, NULL, 'Dirección de la casa', 1),
  (37, 'Biblioteca', 0, NULL, 'Libros prestados', 2),
  (37, 'Enfermería', 0, NULL, 'Alergias', 3);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (38, 17, 'seleccion', '¿Qué hace una buena abstracción?', NULL, 'Elimina lo que no ayuda al objetivo, sin quitar lo necesario para resolver el problema.', 1, 3);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (38, 'Elimina los detalles que no ayudan al objetivo', 1, NULL, NULL, 1),
  (38, 'Guarda toda la información posible', 0, NULL, NULL, 2),
  (38, 'Quita también los datos necesarios', 0, NULL, NULL, 3),
  (38, 'Hace el problema más difícil', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (39, 17, 'seleccion', 'Usas una calculadora para sumar. ¿Qué necesitas saber?', NULL, 'Para usar la calculadora basta saber qué botones usar; el funcionamiento del chip queda oculto.', 1, 4);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (39, 'Cómo funciona el chip por dentro', 0, NULL, NULL, 1),
  (39, 'Qué botones usar para sumar', 1, NULL, NULL, 2),
  (39, 'Cómo se fabricó la pantalla', 0, NULL, NULL, 3),
  (39, 'El voltaje de la batería', 0, NULL, NULL, 4);

-- Evaluación: Abstracción
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (18, 1, NULL, 2, 'Evaluación: Abstracción', 'evaluacion', 3, 40, 60, 10);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (40, 18, 'seleccion', 'Diseñas el modelo de un estudiante para un sistema de calificaciones. ¿Qué atributo sobra?', NULL, 'El sistema calcula y registra notas; el color de ojos no participa en ninguna operación.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (40, 'Código del estudiante', 0, NULL, NULL, 1),
  (40, 'Notas por materia', 0, NULL, NULL, 2),
  (40, 'Color de ojos', 1, NULL, NULL, 3),
  (40, 'Curso', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (41, 18, 'completar_codigo', 'Completa el operador para calcular el área.', 'funcion area(base, altura)\n    devolver base ___ altura\nfin funcion', 'El área de un rectángulo es base multiplicada por altura.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (41, '*', 1, NULL, NULL, 1),
  (41, '×', 1, NULL, NULL, 2),
  (41, 'x', 1, NULL, NULL, 3);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (42, 18, 'relacionar', 'Relaciona cada concepto con su definición.', NULL, 'Funciones y atributos son herramientas de abstracción: ocultan el cómo y describen solo lo relevante.', 1, 3);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (42, 'Atributo', 0, NULL, 'Característica de un objeto modelado', 1),
  (42, 'Función', 0, NULL, 'Bloque con nombre que resuelve una tarea', 2),
  (42, 'Parámetro', 0, NULL, 'Dato que recibe la función', 3);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (43, 18, 'seleccion', '¿Qué nombre de función describe mejor QUÉ hace?', NULL, 'Un buen nombre describe el resultado (el qué), no los pasos internos (el cómo).', 1, 4);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (43, 'sumarYDividirEnUnCiclo', 0, NULL, NULL, 1),
  (43, 'calcularPromedio', 1, NULL, NULL, 2),
  (43, 'funcion1', 0, NULL, NULL, 3),
  (43, 'hacerCosas', 0, NULL, NULL, 4);

-- Evaluación: Patrones
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (19, 2, NULL, 1, 'Evaluación: Patrones', 'evaluacion', 3, 40, 60, 10);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (44, 19, 'patron', '¿Qué número sigue?', '10, 20, 30, 40, ___', 'La regla es sumar 10: 40 + 10 = 50.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (44, '45', 0, NULL, NULL, 1),
  (44, '50', 1, NULL, NULL, 2),
  (44, '60', 0, NULL, NULL, 3),
  (44, '80', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (45, 19, 'patron', '¿Qué número sigue?', '2, 6, 18, 54, ___', 'Cada número se multiplica por 3: 54 × 3 = 162.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (45, '108', 0, NULL, NULL, 1),
  (45, '72', 0, NULL, NULL, 2),
  (45, '162', 1, NULL, NULL, 3),
  (45, '60', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (46, 19, 'completar_codigo', 'Completa el número para aplaudir 3 veces.', 'repetir ___ veces\n    aplaudir\nfin repetir', 'El ciclo repite su contenido el número de veces indicado.', 1, 3);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (46, '3', 1, NULL, NULL, 1),
  (46, 'tres', 1, NULL, NULL, 2);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (47, 19, 'seleccion', 'Un robot repite 3 veces «avanzar 10, girar 120». ¿Qué figura dibuja?', NULL, 'Tres lados iguales con giros de 120° forman un triángulo.', 1, 4);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (47, 'Un cuadrado', 0, NULL, NULL, 1),
  (47, 'Un triángulo', 1, NULL, NULL, 2),
  (47, 'Un círculo', 0, NULL, NULL, 3),
  (47, 'Un hexágono', 0, NULL, NULL, 4);

-- Evaluación: Patrones
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (20, 2, NULL, 2, 'Evaluación: Patrones', 'evaluacion', 3, 40, 60, 10);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (48, 20, 'patron', '¿Qué número sigue?', '3, 8, 13, 18, ___', 'La secuencia suma 5: 18 + 5 = 23.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (48, '21', 0, NULL, NULL, 1),
  (48, '23', 1, NULL, NULL, 2),
  (48, '24', 0, NULL, NULL, 3),
  (48, '28', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (49, 20, 'seleccion', '¿Qué regla genera la secuencia 3, 8, 13, 18…?', NULL, 'Aumenta de 5 en 5 y para n = 1 vale 3: 5 · 1 − 2 = 3. La regla es 5n − 2.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (49, '5n', 0, NULL, NULL, 1),
  (49, 'n + 5', 0, NULL, NULL, 2),
  (49, '5n − 2', 1, NULL, NULL, 3),
  (49, '3n + 5', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (50, 20, 'completar_codigo', 'Completa la operación para que el enemigo aparezca cada 3 turnos.', 'si turno ___ 3 = 0 entonces\n    mostrar "Enemigo"\nfin si', 'turno mod 3 = 0 se cumple en los turnos 3, 6, 9…', 1, 3);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (50, 'mod', 1, NULL, NULL, 1);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (51, 20, 'seleccion', '¿Qué se muestra al ejecutar este pseudocódigo?', 'para i desde 1 hasta 10\n    si i mod 3 = 0 entonces\n        mostrar i\n    fin si\nfin para', 'Entre 1 y 10, los múltiplos de 3 son 3, 6 y 9.', 1, 4);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (51, '3, 6, 9', 1, NULL, NULL, 1),
  (51, '1, 4, 7, 10', 0, NULL, NULL, 2),
  (51, '3, 6, 9, 12', 0, NULL, NULL, 3),
  (51, '0, 3, 6, 9', 0, NULL, NULL, 4);

-- Evaluación: Algoritmos
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (21, 3, NULL, 1, 'Evaluación: Algoritmos', 'evaluacion', 3, 40, 60, 10);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (52, 21, 'ordenar', 'Ordena los pasos para enviar un mensaje desde el celular.', NULL, 'Cada paso depende del anterior: sin desbloquear el celular no se puede abrir el chat.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (52, 'Escribir el mensaje', 0, 3, NULL, 1),
  (52, 'Desbloquear el celular', 0, 1, NULL, 2),
  (52, 'Enviar', 0, 4, NULL, 3),
  (52, 'Abrir el chat', 0, 2, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (53, 21, 'seleccion', '¿Qué se muestra al ejecutar este pseudocódigo?', 'a ← 3\nb ← 4\nc ← a + b\nmostrar c', 'c guarda la suma de a y b: 3 + 4 = 7.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (53, '34', 0, NULL, NULL, 1),
  (53, '7', 1, NULL, NULL, 2),
  (53, 'a + b', 0, NULL, NULL, 3),
  (53, '12', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (54, 21, 'completar_codigo', 'Completa la palabra del camino alternativo.', 'leer edad\nsi edad ≥ 18 entonces\n    mostrar "Adulto"\n___\n    mostrar "Menor"\nfin si', 'sino indica qué hacer cuando la condición es falsa.', 1, 3);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (54, 'sino', 1, NULL, NULL, 1);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (55, 21, 'relacionar', 'Relaciona cada instrucción con lo que hace.', NULL, 'leer es la entrada, ← guarda valores durante el proceso y mostrar es la salida.', 1, 4);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (55, '←', 0, NULL, 'Guarda un valor en una variable', 1),
  (55, 'leer', 0, NULL, 'Recibe un dato', 2),
  (55, 'mostrar', 0, NULL, 'Presenta un resultado', 3);

-- Evaluación: Algoritmos
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (22, 3, NULL, 2, 'Evaluación: Algoritmos', 'evaluacion', 3, 40, 60, 10);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (56, 22, 'seleccion', '¿Qué se muestra al ejecutar este pseudocódigo?', 'contador ← 0\npara i desde 1 hasta 5\n    si i > 2 entonces\n        contador ← contador + 1\n    fin si\nfin para\nmostrar contador', 'La condición i > 2 se cumple para i = 3, 4 y 5: el contador llega a 3.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (56, '2', 0, NULL, NULL, 1),
  (56, '3', 1, NULL, NULL, 2),
  (56, '5', 0, NULL, NULL, 3),
  (56, '0', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (57, 22, 'ordenar', 'Ordena los pasos del algoritmo que calcula el promedio de unas notas.', NULL, 'El acumulador se inicia en 0, se suman las notas en el ciclo y al final se divide y se muestra.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (57, 'promedio ← suma / cantidad de notas', 0, 3, NULL, 1),
  (57, 'suma ← 0', 0, 1, NULL, 2),
  (57, 'Mostrar promedio', 0, 4, NULL, 3),
  (57, 'Para cada nota: suma ← suma + nota', 0, 2, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (58, 22, 'completar_codigo', 'Completa el operador de comparación para encontrar el mayor.', 'mayor ← lista[1]\npara i desde 2 hasta cantidad(lista)\n    si lista[i] ___ mayor entonces\n        mayor ← lista[i]\n    fin si\nfin para', 'Solo se reemplaza mayor cuando el elemento actual es más grande: lista[i] > mayor.', 1, 3);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (58, '>', 1, NULL, NULL, 1);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (59, 22, 'seleccion', 'Prueba de escritorio: con la lista [−3, −8, −1], ¿qué devuelve encontrarMayor?', NULL, 'mayor empieza en −3; −8 no es mayor; −1 sí lo es. Resultado: −1.', 1, 4);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (59, '−8', 0, NULL, NULL, 1),
  (59, '−3', 0, NULL, NULL, 2),
  (59, '−1', 1, NULL, NULL, 3),
  (59, '0', 0, NULL, NULL, 4);
