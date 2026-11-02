-- =====================================================================
-- CodeQuest: Aprende a programar
-- 06_seed_retos.sql - Retos de módulo (RF-24)
--
-- Ejecutar DESPUÉS de 05_seed_actividades.sql.
-- Un reto por módulo y ruta: 5 preguntas que combinan varios tipos,
-- dificultad 3, 60 XP y se aprueba con 70 %. Se desbloquea al aprobar
-- la evaluación del módulo. Superar el primero otorga la insignia Retador.
-- =====================================================================

USE codequest_db;
SET NAMES utf8mb4;

-- Reto: Abstracción
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (23, 1, NULL, 1, 'Reto: Abstracción', 'reto', 3, 60, 70, 20);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (60, 23, 'seleccion', 'Vas a crear una app para reservar las canchas del colegio. ¿Qué datos son esenciales para una reserva?', NULL, 'Para reservar solo importa qué cancha, cuándo y quién la usa; lo demás no ayuda al objetivo.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (60, 'Cancha, fecha, hora y nombre de quien reserva', 1, NULL, NULL, 1),
  (60, 'Color del uniforme y marca del balón', 0, NULL, NULL, 2),
  (60, 'Clima del día y canción favorita', 0, NULL, NULL, 3),
  (60, 'Talla de zapatos de los jugadores', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (61, 23, 'relacionar', 'Relaciona cada objeto con lo que te deja hacer y lo que te oculta.', NULL, 'Cada objeto ofrece una forma simple de usarlo y esconde su funcionamiento interno: eso es abstracción.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (61, 'Mapa del metro', 0, NULL, 'Muestra estaciones; oculta las distancias reales', 1),
  (61, 'Cajero automático', 0, NULL, 'Retirar dinero; oculta la conexión con el banco', 2),
  (61, 'Microondas', 0, NULL, 'Elegir el tiempo; oculta cómo se calienta la comida', 3);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (62, 23, 'seleccion', 'Para la lista de asistencia de una clase, ¿qué información de cada estudiante es suficiente?', NULL, 'Para tomar asistencia basta con identificar al estudiante: nombre y grupo.', 1, 3);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (62, 'Nombre y grupo', 1, NULL, NULL, 1),
  (62, 'Nombre, estatura y peso', 0, NULL, NULL, 2),
  (62, 'Dirección y número de hermanos', 0, NULL, NULL, 3),
  (62, 'Película favorita', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (63, 23, 'completar_codigo', 'Completa la instrucción que presenta el saludo en pantalla.', 'leer nombre\n___ "Hola, " + nombre', 'mostrar presenta información en pantalla sin que necesitemos saber cómo se dibuja.', 1, 4);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (63, 'mostrar', 1, NULL, NULL, 1);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (64, 23, 'ordenar', 'Ordena los pasos para abstraer un problema.', NULL, 'Primero se fija el objetivo; con él se decide qué información es esencial y solo entonces se resuelve.', 1, 5);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (64, 'Separar lo esencial de los detalles', 0, 3, NULL, 1),
  (64, 'Identificar el objetivo', 0, 1, NULL, 2),
  (64, 'Resolver usando solo lo esencial', 0, 4, NULL, 3),
  (64, 'Listar la información disponible', 0, 2, NULL, 4);

-- Reto: Abstracción
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (24, 1, NULL, 2, 'Reto: Abstracción', 'reto', 3, 60, 70, 20);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (65, 24, 'seleccion', 'Modelas un libro para el sistema de préstamos de la biblioteca. ¿Qué atributo NO necesitas?', NULL, 'Los préstamos usan el código, el título y si está disponible; el color de la portada no interviene en ninguna operación.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (65, 'Código', 0, NULL, NULL, 1),
  (65, 'Título', 0, NULL, NULL, 2),
  (65, 'Disponible (sí o no)', 0, NULL, NULL, 3),
  (65, 'Color de la portada', 1, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (66, 24, 'completar_codigo', 'Completa el operador para que la función calcule el área de un rectángulo.', 'funcion area(base, altura)\n    devolver base ___ altura\nfin funcion', 'El área de un rectángulo es base × altura.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (66, '*', 1, NULL, NULL, 1),
  (66, '×', 1, NULL, NULL, 2),
  (66, 'x', 1, NULL, NULL, 3);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (67, 24, 'relacionar', 'Relaciona cada concepto con su definición.', NULL, 'Las funciones reciben parámetros y devuelven un valor; los atributos describen lo que modelamos.', 1, 3);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (67, 'Atributo', 0, NULL, 'Característica de algo que modelamos', 1),
  (67, 'Parámetro', 0, NULL, 'Dato que recibe una función', 2),
  (67, 'Valor de retorno', 0, NULL, 'Resultado que entrega una función', 3);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (68, 24, 'seleccion', '¿Qué se muestra al ejecutar este pseudocódigo?', 'funcion doble(n)\n    devolver n * 2\nfin funcion\n\nmostrar doble(doble(3))', 'Primero doble(3) = 6 y luego doble(6) = 12.', 1, 4);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (68, '6', 0, NULL, NULL, 1),
  (68, '9', 0, NULL, NULL, 2),
  (68, '12', 1, NULL, NULL, 3),
  (68, '18', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (69, 24, 'ordenar', 'Ordena los pasos para crear y usar una función.', NULL, 'Una función se nombra, se definen sus parámetros, se escribe su cuerpo y finalmente se llama con valores concretos.', 1, 5);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (69, 'Escribir sus instrucciones y devolver el resultado', 0, 3, NULL, 1),
  (69, 'Darle un nombre a la función', 0, 1, NULL, 2),
  (69, 'Llamarla con valores concretos', 0, 4, NULL, 3),
  (69, 'Definir sus parámetros', 0, 2, NULL, 4);

-- Reto: Patrones
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (25, 2, NULL, 1, 'Reto: Patrones', 'reto', 3, 60, 70, 20);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (70, 25, 'patron', '¿Qué número sigue?', '5, 10, 15, 20, ___', 'Cada número suma 5 al anterior: 20 + 5 = 25.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (70, '21', 0, NULL, NULL, 1),
  (70, '25', 1, NULL, NULL, 2),
  (70, '30', 0, NULL, NULL, 3),
  (70, '40', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (71, 25, 'patron', '¿Qué figura sigue?', '■, ■, ▲, ■, ■, ▲, ■, ___', 'El grupo «■ ■ ▲» se repite; después del primer ■ viene otro ■.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (71, '■', 1, NULL, NULL, 1),
  (71, '▲', 0, NULL, NULL, 2),
  (71, '●', 0, NULL, NULL, 3),
  (71, '◆', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (72, 25, 'completar_codigo', 'Completa el número para que el robot dibuje un triángulo.', 'repetir ___ veces\n    avanzar 10\n    girar 120\nfin repetir', 'Un triángulo tiene 3 lados: el par «avanzar, girar 120» se repite 3 veces.', 1, 3);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (72, '3', 1, NULL, NULL, 1),
  (72, 'tres', 1, NULL, NULL, 2);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (73, 25, 'seleccion', '¿Cuántas veces se muestra la palabra "Hola"?', 'repetir 4 veces\n    mostrar "Hola"\n    mostrar "Hola"\nfin repetir', 'Cada vuelta muestra «Hola» 2 veces y hay 4 vueltas: 2 × 4 = 8.', 1, 4);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (73, '2', 0, NULL, NULL, 1),
  (73, '4', 0, NULL, NULL, 2),
  (73, '6', 0, NULL, NULL, 3),
  (73, '8', 1, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (74, 25, 'relacionar', 'Relaciona cada concepto con su significado.', NULL, 'Reconocer un patrón permite escribir un ciclo que repita el bloque en lugar de copiarlo.', 1, 5);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (74, 'Secuencia', 0, NULL, 'Elementos en un orden determinado', 1),
  (74, 'Patrón', 0, NULL, 'Regularidad que se repite', 2),
  (74, 'Ciclo', 0, NULL, 'Instrucción que repite un bloque', 3);

-- Reto: Patrones
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (26, 2, NULL, 2, 'Reto: Patrones', 'reto', 3, 60, 70, 20);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (75, 26, 'patron', 'Si la regla es término(n) = 3n − 1, ¿cuál es el término 7?', 'termino(n) = 3n − 1\ntermino(7) = ___', '3 · 7 − 1 = 20.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (75, '21', 0, NULL, NULL, 1),
  (75, '20', 1, NULL, NULL, 2),
  (75, '19', 0, NULL, NULL, 3),
  (75, '22', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (76, 26, 'seleccion', '¿Qué regla genera la secuencia 4, 7, 10, 13…?', NULL, 'Aumenta de 3 en 3 y para n = 1 vale 4: 3 · 1 + 1 = 4. La regla es 3n + 1.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (76, '3n', 0, NULL, NULL, 1),
  (76, 'n + 3', 0, NULL, NULL, 2),
  (76, '3n + 1', 1, NULL, NULL, 3),
  (76, '4n', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (77, 26, 'completar_codigo', 'Completa la operación para mostrar los múltiplos de 5.', 'para i desde 1 hasta 20\n    si i ___ 5 = 0 entonces\n        mostrar i\n    fin si\nfin para', 'i mod 5 = 0 se cumple cuando i es múltiplo de 5: 5, 10, 15 y 20.', 1, 3);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (77, 'mod', 1, NULL, NULL, 1);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (78, 26, 'ordenar', 'Ordena los pasos para encontrar la regla de una secuencia que crece siempre lo mismo.', NULL, 'La diferencia constante da el número que multiplica a n; luego se ajusta con el primer término y se comprueba.', 1, 4);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (78, 'Sumar o restar para que el primer término coincida', 0, 3, NULL, 1),
  (78, 'Calcular la diferencia entre términos seguidos', 0, 1, NULL, 2),
  (78, 'Comprobar la regla con otro término', 0, 4, NULL, 3),
  (78, 'Multiplicar esa diferencia por n', 0, 2, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (79, 26, 'seleccion', '¿Qué se muestra al ejecutar este pseudocódigo?', 'para i desde 1 hasta 4\n    mostrar i * i\nfin para', 'Se muestran los cuadrados de 1 a 4: 1, 4, 9 y 16.', 1, 5);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (79, '1, 2, 3, 4', 0, NULL, NULL, 1),
  (79, '2, 4, 6, 8', 0, NULL, NULL, 2),
  (79, '1, 4, 9, 16', 1, NULL, NULL, 3),
  (79, '1, 4, 8, 16', 0, NULL, NULL, 4);

-- Reto: Algoritmos
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (27, 3, NULL, 1, 'Reto: Algoritmos', 'reto', 3, 60, 70, 20);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (80, 27, 'ordenar', 'Ordena los pasos para calentar una arepa.', NULL, 'Primero se calienta la plancha, luego se pone la arepa, se voltea y al final se sirve.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (80, 'Voltearla cuando esté dorada', 0, 3, NULL, 1),
  (80, 'Calentar la plancha', 0, 1, NULL, 2),
  (80, 'Servirla', 0, 4, NULL, 3),
  (80, 'Poner la arepa', 0, 2, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (81, 27, 'seleccion', 'Si se lee nota = 2.5, ¿qué se muestra?', 'leer nota\nsi nota ≥ 3 entonces\n    mostrar "Aprobó"\nsino\n    mostrar "Reprobó"\nfin si', '2.5 no es mayor o igual a 3, así que la condición es falsa y se ejecuta el camino sino.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (81, 'Aprobó', 0, NULL, NULL, 1),
  (81, 'Reprobó', 1, NULL, NULL, 2),
  (81, 'Aprobó y Reprobó', 0, NULL, NULL, 3),
  (81, 'Nada', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (82, 27, 'completar_codigo', 'Completa el operador para que el algoritmo sume los dos números.', 'leer a\nleer b\nsuma ← a ___ b\nmostrar suma', 'La suma se calcula con el operador +.', 1, 3);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (82, '+', 1, NULL, NULL, 1);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (83, 27, 'relacionar', 'Relaciona cada parte de un algoritmo con su función.', NULL, 'Todo algoritmo recibe datos (entrada), los transforma (proceso) y entrega un resultado (salida).', 1, 4);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (83, 'Salida', 0, NULL, 'Resultado que entrega el algoritmo', 1),
  (83, 'Entrada', 0, NULL, 'Datos que recibe el algoritmo', 2),
  (83, 'Proceso', 0, NULL, 'Pasos que transforman los datos', 3);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (84, 27, 'seleccion', '¿Qué característica debe tener todo algoritmo?', NULL, 'Un algoritmo debe ser preciso y terminar después de un número finito de pasos.', 1, 5);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (84, 'Estar escrito en inglés', 0, NULL, NULL, 1),
  (84, 'Tener más de 100 pasos', 0, NULL, NULL, 2),
  (84, 'Terminar después de un número finito de pasos', 1, NULL, NULL, 3),
  (84, 'Usar siempre ciclos', 0, NULL, NULL, 4);

-- Reto: Algoritmos
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (28, 3, NULL, 2, 'Reto: Algoritmos', 'reto', 3, 60, 70, 20);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (85, 28, 'seleccion', '¿Qué se muestra al ejecutar este pseudocódigo?', 'x ← 1\nmientras x < 20\n    x ← x * 2\nfin mientras\nmostrar x', 'x toma los valores 1, 2, 4, 8, 16 y 32; al llegar a 32 la condición x < 20 es falsa y el ciclo termina.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (85, '16', 0, NULL, NULL, 1),
  (85, '20', 0, NULL, NULL, 2),
  (85, '32', 1, NULL, NULL, 3),
  (85, '64', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (86, 28, 'ordenar', 'Ordena los pasos del algoritmo que encuentra el menor de dos números.', NULL, 'Se leen los datos, se comparan, se guarda el menor según el resultado y se muestra.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (86, 'Si es verdad, menor ← a; si no, menor ← b', 0, 3, NULL, 1),
  (86, 'Leer a y b', 0, 1, NULL, 2),
  (86, 'Mostrar menor', 0, 4, NULL, 3),
  (86, 'Comparar si a < b', 0, 2, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (87, 28, 'completar_codigo', 'Completa el operador para contar los números pares del 1 al 10.', 'pares ← 0\npara i desde 1 hasta 10\n    si i mod 2 = 0 entonces\n        pares ← pares ___ 1\n    fin si\nfin para', 'Un contador aumenta de 1 en 1: pares ← pares + 1.', 1, 3);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (87, '+', 1, NULL, NULL, 1);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (88, 28, 'seleccion', 'Prueba de escritorio: ¿qué se muestra?', 'suma ← 0\npara i desde 1 hasta 4\n    suma ← suma + i\nfin para\nmostrar suma', 'suma pasa por 1, 3, 6 y 10.', 1, 4);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (88, '4', 0, NULL, NULL, 1),
  (88, '10', 1, NULL, NULL, 2),
  (88, '6', 0, NULL, NULL, 3),
  (88, '15', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (89, 28, 'relacionar', 'Relaciona cada concepto con su definición.', NULL, 'Las variables guardan datos, las condiciones deciden y los acumuladores van sumando dentro de un ciclo.', 1, 5);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (89, 'Acumulador', 0, NULL, 'Variable que va sumando valores', 1),
  (89, 'Variable', 0, NULL, 'Espacio que guarda un valor', 2),
  (89, 'Condición', 0, NULL, 'Pregunta que es verdadera o falsa', 3);
