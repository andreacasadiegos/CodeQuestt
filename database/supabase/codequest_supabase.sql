-- =====================================================================
-- CodeQuest: Aprende a programar
-- Base de datos completa para Supabase (PostgreSQL)
--
-- Cómo usarlo: en Supabase abre SQL Editor -> New query, pega TODO este
-- archivo y pulsa Run. Crea las 16 tablas y carga rutas, niveles,
-- módulos, insignias, diagnóstico, lecciones, actividades y retos.
--
-- Es la misma base que database/01..06 (MySQL), traducida a PostgreSQL.
-- ATENCIÓN: si las tablas ya existen, las borra y las vuelve a crear.
-- Archivo generado; si cambias los seeds de MySQL, vuelve a generarlo.
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- 0. LIMPIEZA (permite volver a ejecutar este archivo desde cero)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS php_sessions, module_progress, lesson_progress, user_badges, xp_transactions,
  diagnostics, attempt_answers, attempts, users, badges, answer_options, questions,
  activities, lessons, modules, levels, learning_paths CASCADE;

-- ---------------------------------------------------------------------
-- 1. CATÁLOGO
-- ---------------------------------------------------------------------

-- Rutas de aprendizaje: básica e intermedia.
CREATE TABLE learning_paths (
  id               SMALLSERIAL PRIMARY KEY,
  code             VARCHAR(20)  NOT NULL UNIQUE,
  name             VARCHAR(60)  NOT NULL,
  description      VARCHAR(255) NOT NULL,
  advance_min_pct  SMALLINT NULL CHECK (advance_min_pct IS NULL OR advance_min_pct BETWEEN 0 AND 100),
  sort_order       SMALLINT NOT NULL DEFAULT 0
);

-- Niveles de experiencia según el XP acumulado.
CREATE TABLE levels (
  id      SMALLSERIAL PRIMARY KEY,
  number  SMALLINT NOT NULL UNIQUE,
  name    VARCHAR(60) NOT NULL,
  min_xp  INTEGER NOT NULL UNIQUE CHECK (min_xp >= 0)
);

-- ---------------------------------------------------------------------
-- 2. CONTENIDO
-- ---------------------------------------------------------------------

CREATE TABLE modules (
  id           SMALLSERIAL PRIMARY KEY,
  slug         VARCHAR(40)  NOT NULL UNIQUE,
  name         VARCHAR(60)  NOT NULL,
  description  VARCHAR(255) NOT NULL,
  icon         VARCHAR(40)  NOT NULL,
  sort_order   SMALLINT NOT NULL DEFAULT 0
);

CREATE TABLE lessons (
  id          SERIAL PRIMARY KEY,
  module_id   SMALLINT NOT NULL REFERENCES modules (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  path_id     SMALLINT NULL REFERENCES learning_paths (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  title       VARCHAR(120) NOT NULL,
  content     TEXT NOT NULL,
  example     TEXT NULL,
  sort_order  SMALLINT NOT NULL DEFAULT 0
);
CREATE INDEX idx_lessons_module ON lessons (module_id, sort_order);
CREATE INDEX idx_lessons_path ON lessons (path_id);

CREATE TABLE activities (
  id          SERIAL PRIMARY KEY,
  module_id   SMALLINT NULL REFERENCES modules (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  lesson_id   INTEGER NULL REFERENCES lessons (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  path_id     SMALLINT NULL REFERENCES learning_paths (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  title       VARCHAR(120) NOT NULL,
  description VARCHAR(255) NULL,
  kind        VARCHAR(20) NOT NULL CHECK (kind IN ('practica', 'evaluacion', 'reto', 'diagnostico')),
  difficulty  SMALLINT NOT NULL DEFAULT 1 CHECK (difficulty BETWEEN 1 AND 3),
  base_xp     SMALLINT NOT NULL DEFAULT 10 CHECK (base_xp >= 0),
  pass_pct    SMALLINT NOT NULL DEFAULT 60 CHECK (pass_pct BETWEEN 0 AND 100),
  sort_order  SMALLINT NOT NULL DEFAULT 0
);
CREATE INDEX idx_activities_module ON activities (module_id, difficulty, sort_order);
CREATE INDEX idx_activities_lesson ON activities (lesson_id);
CREATE INDEX idx_activities_path ON activities (path_id);

CREATE TABLE questions (
  id            SERIAL PRIMARY KEY,
  activity_id   INTEGER NOT NULL REFERENCES activities (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  type          VARCHAR(20) NOT NULL CHECK (type IN ('seleccion', 'completar_codigo', 'patron', 'ordenar', 'relacionar')),
  statement     TEXT NOT NULL,
  code_snippet  TEXT NULL,
  explanation   TEXT NOT NULL,
  points        SMALLINT NOT NULL DEFAULT 1,
  sort_order    SMALLINT NOT NULL DEFAULT 0
);
CREATE INDEX idx_questions_activity ON questions (activity_id, sort_order);

CREATE TABLE answer_options (
  id             SERIAL PRIMARY KEY,
  question_id    INTEGER NOT NULL REFERENCES questions (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  option_text    VARCHAR(255) NOT NULL,
  is_correct     SMALLINT NOT NULL DEFAULT 0 CHECK (is_correct IN (0, 1)),
  correct_order  SMALLINT NULL,
  pair_text      VARCHAR(255) NULL,
  sort_order     SMALLINT NOT NULL DEFAULT 0
);
CREATE INDEX idx_answer_options_question ON answer_options (question_id, sort_order);

CREATE TABLE badges (
  id           SMALLSERIAL PRIMARY KEY,
  code         VARCHAR(40)  NOT NULL UNIQUE,
  name         VARCHAR(60)  NOT NULL,
  description  VARCHAR(255) NOT NULL,
  icon         VARCHAR(40)  NOT NULL,
  rule_type    VARCHAR(30) NOT NULL CHECK (rule_type IN ('actividades_completadas', 'xp_total',
                 'modulo_completado', 'puntaje_perfecto', 'reto_completado')),
  rule_value   INTEGER NOT NULL DEFAULT 1,
  module_id    SMALLINT NULL REFERENCES modules (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  xp_reward    SMALLINT NOT NULL DEFAULT 0
);
CREATE INDEX idx_badges_module ON badges (module_id);

-- ---------------------------------------------------------------------
-- 3. ESTUDIANTE
-- ---------------------------------------------------------------------

CREATE TABLE users (
  id             SERIAL PRIMARY KEY,
  full_name      VARCHAR(120) NOT NULL,
  email          VARCHAR(120) NOT NULL UNIQUE,
  password_hash  VARCHAR(255) NOT NULL,
  path_id        SMALLINT NULL REFERENCES learning_paths (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  level_id       SMALLINT NOT NULL DEFAULT 1 REFERENCES levels (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  xp_total       INTEGER NOT NULL DEFAULT 0 CHECK (xp_total >= 0),
  role           VARCHAR(20) NOT NULL DEFAULT 'estudiante' CHECK (role IN ('estudiante', 'admin')),
  created_at     TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_users_path ON users (path_id);
CREATE INDEX idx_users_level ON users (level_id);

-- Equivalente a "ON UPDATE CURRENT_TIMESTAMP" de MySQL.
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS trigger AS $$
BEGIN
  NEW.updated_at := CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---------------------------------------------------------------------
-- 4. RESULTADOS Y PROGRESO
-- ---------------------------------------------------------------------

CREATE TABLE attempts (
  id             SERIAL PRIMARY KEY,
  user_id        INTEGER NOT NULL REFERENCES users (id) ON UPDATE CASCADE ON DELETE CASCADE,
  activity_id    INTEGER NOT NULL REFERENCES activities (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  correct_count  SMALLINT NOT NULL,
  total_count    SMALLINT NOT NULL,
  score_pct      SMALLINT NOT NULL CHECK (score_pct BETWEEN 0 AND 100),
  passed         SMALLINT NOT NULL DEFAULT 0 CHECK (passed IN (0, 1)),
  xp_awarded     SMALLINT NOT NULL DEFAULT 0,
  submitted_at   TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (correct_count <= total_count)
);
CREATE INDEX idx_attempts_user_activity ON attempts (user_id, activity_id, score_pct);
CREATE INDEX idx_attempts_activity ON attempts (activity_id);

CREATE TABLE attempt_answers (
  id            SERIAL PRIMARY KEY,
  attempt_id    INTEGER NOT NULL REFERENCES attempts (id) ON UPDATE CASCADE ON DELETE CASCADE,
  question_id   INTEGER NOT NULL REFERENCES questions (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  answer_given  JSONB NOT NULL,
  is_correct    SMALLINT NOT NULL DEFAULT 0 CHECK (is_correct IN (0, 1)),
  UNIQUE (attempt_id, question_id)
);
CREATE INDEX idx_attempt_answers_question ON attempt_answers (question_id);

CREATE TABLE diagnostics (
  id                 SERIAL PRIMARY KEY,
  user_id            INTEGER NOT NULL UNIQUE REFERENCES users (id) ON UPDATE CASCADE ON DELETE CASCADE,
  attempt_id         INTEGER NULL REFERENCES attempts (id) ON UPDATE CASCADE ON DELETE SET NULL,
  experience_option  SMALLINT NOT NULL CHECK (experience_option BETWEEN 1 AND 3),
  test_score         SMALLINT NOT NULL CHECK (test_score BETWEEN 0 AND 5),
  assigned_path_id   SMALLINT NOT NULL REFERENCES learning_paths (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  completed_at       TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_diagnostics_attempt ON diagnostics (attempt_id);
CREATE INDEX idx_diagnostics_path ON diagnostics (assigned_path_id);

CREATE TABLE xp_transactions (
  id           SERIAL PRIMARY KEY,
  user_id      INTEGER NOT NULL REFERENCES users (id) ON UPDATE CASCADE ON DELETE CASCADE,
  amount       SMALLINT NOT NULL CHECK (amount >= 0),
  source       VARCHAR(20) NOT NULL CHECK (source IN ('actividad', 'insignia')),
  attempt_id   INTEGER NULL REFERENCES attempts (id) ON UPDATE CASCADE ON DELETE SET NULL,
  badge_id     SMALLINT NULL REFERENCES badges (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  description  VARCHAR(255) NOT NULL,
  created_at   TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_xp_user ON xp_transactions (user_id, created_at);
CREATE INDEX idx_xp_attempt ON xp_transactions (attempt_id);
CREATE INDEX idx_xp_badge ON xp_transactions (badge_id);

CREATE TABLE user_badges (
  user_id    INTEGER NOT NULL REFERENCES users (id) ON UPDATE CASCADE ON DELETE CASCADE,
  badge_id   SMALLINT NOT NULL REFERENCES badges (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  earned_at  TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, badge_id)
);
CREATE INDEX idx_user_badges_badge ON user_badges (badge_id);

CREATE TABLE lesson_progress (
  user_id       INTEGER NOT NULL REFERENCES users (id) ON UPDATE CASCADE ON DELETE CASCADE,
  lesson_id     INTEGER NOT NULL REFERENCES lessons (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  completed_at  TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, lesson_id)
);
CREATE INDEX idx_lesson_progress_lesson ON lesson_progress (lesson_id);

CREATE TABLE module_progress (
  user_id       INTEGER NOT NULL REFERENCES users (id) ON UPDATE CASCADE ON DELETE CASCADE,
  module_id     SMALLINT NOT NULL REFERENCES modules (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  percent       SMALLINT NOT NULL DEFAULT 0 CHECK (percent BETWEEN 0 AND 100),
  status        VARCHAR(20) NOT NULL DEFAULT 'no_iniciado' CHECK (status IN ('no_iniciado', 'en_curso', 'completado')),
  started_at    TIMESTAMP(0) NULL,
  completed_at  TIMESTAMP(0) NULL,
  PRIMARY KEY (user_id, module_id)
);
CREATE INDEX idx_module_progress_module ON module_progress (module_id);


-- =====================================================================
-- Datos de database/02_seed_catalogos.sql
-- =====================================================================

-- =====================================================================
-- CodeQuest: Aprende a programar
-- 02_seed_catalogos.sql - Datos iniciales de catálogo
--
-- Ejecutar DESPUÉS de 01_schema.sql.
-- El contenido educativo (lecciones, actividades y preguntas) se carga
-- en 03_seed_contenido.sql en las Etapas 5 y 6.
-- =====================================================================


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

-- =====================================================================
-- Datos de database/03_seed_diagnostico.sql
-- =====================================================================

-- =====================================================================
-- CodeQuest: Aprende a programar
-- 03_seed_diagnostico.sql - Prueba diagnóstica de 5 preguntas
--
-- Ejecutar DESPUÉS de 02_seed_catalogos.sql.
-- Una pregunta por concepto (abstracción, patrones, algoritmos) y dos
-- de lectura de pseudocódigo. Todas son de selección única.
-- =====================================================================


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
   E'x ← 5\nx ← x + 3\nmostrar x',
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
   E'para i desde 1 hasta 3\n    mostrar "Hola"\nfin para',
   'El ciclo repite su contenido para i = 1, 2 y 3: tres veces. Los ciclos aprovechan un patrón de repetición.',
   1, 5);
INSERT INTO answer_options (question_id, option_text, is_correct, sort_order) VALUES
  (5, '1', 0, 1),
  (5, '2', 0, 2),
  (5, '3', 1, 3),
  (5, '4', 0, 4);

-- =====================================================================
-- Datos de database/04_seed_contenido.sql
-- =====================================================================

-- =====================================================================
-- CodeQuest: Aprende a programar
-- 04_seed_contenido.sql - Lecciones de los módulos
--
-- Ejecutar DESPUÉS de 03_seed_diagnostico.sql.
-- Cada módulo tiene una lección común (path_id NULL) y dos lecciones
-- propias de cada ruta (1 = básica, 2 = intermedia).
-- Formato del contenido: párrafos separados por una línea en blanco,
-- viñetas con "- " y negrita con **texto**.
-- Las actividades de cada lección se agregan en la Etapa 7.
-- =====================================================================


INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (1, 1, NULL, '¿Qué es la abstracción?',
   E'La **abstracción** consiste en quedarse con lo importante de un problema y dejar de lado los detalles que no ayudan a resolverlo.\n\nPiensa en el mapa del sistema de transporte de una ciudad: no muestra calles, edificios ni árboles. Solo muestra estaciones, líneas y conexiones. Ese mapa es una abstracción: elimina detalles para que puedas responder una pregunta concreta, «¿cómo llego de una estación a otra?».\n\nEn programación hacemos lo mismo todo el tiempo:\n- Antes de escribir código, decidimos qué información necesita el programa y cuál sobra.\n- Damos nombres a las ideas (por ejemplo, **precio** o **nombreEstudiante**) en lugar de pensar en cómo se guardan los ceros y unos.\n- Usamos instrucciones como **mostrar** sin preocuparnos por cómo la pantalla dibuja cada letra.\n\nLa pregunta clave de la abstracción es: **¿qué necesito saber para lograr mi objetivo?**',
   E'Objetivo: explicarle a un amigo cómo llegar al colegio.\n\nLo importante:   calles principales, giros, puntos de referencia\nLo que sobra:    color de las casas, número de árboles, nombres de vecinos',
   1);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (2, 1, 1, 'Lo esencial y los detalles',
   E'Lo que es «importante» depende del **objetivo**. La misma realidad se puede resumir de formas distintas según para qué la necesitemos.\n\nImagina la información de un estudiante. Si la usa la **biblioteca**, le interesan el nombre, el curso y los libros prestados. Si la usa la **enfermería**, le interesan el nombre, el grupo sanguíneo y las alergias. El estudiante es el mismo, pero cada abstracción guarda datos diferentes.\n\nPara abstraer bien, sigue tres pasos:\n- Escribe con claridad cuál es el objetivo.\n- Haz una lista de toda la información disponible.\n- Tacha lo que no ayuda a cumplir el objetivo.\n\nLo que queda en la lista es tu abstracción. Un buen programa empieza con una buena abstracción: si guardamos datos de más, el programa se vuelve confuso; si nos faltan datos, no podrá resolver el problema.',
   E'Ficha para la biblioteca      Ficha para la enfermería\n- nombre                      - nombre\n- curso                       - grupo sanguíneo\n- libros prestados            - alergias',
   2);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (3, 1, 1, 'Usar sin conocer todos los detalles',
   E'Otra cara de la abstracción es poder **usar algo sin saber cómo funciona por dentro**.\n\nCuando usas el control remoto del televisor, solo ves botones: subir volumen, cambiar canal, apagar. No necesitas entender las señales infrarrojas ni los circuitos. El control **oculta los detalles** y te muestra solo lo que necesitas.\n\nEn programación pasa lo mismo. Cuando escribes la instrucción **mostrar "Hola"**, el computador hace muchísimas operaciones para dibujar cada letra en la pantalla, pero tú solo necesitas saber qué hace la instrucción, no cómo lo hace.\n\nGracias a esto podemos construir programas grandes a partir de piezas sencillas: cada pieza se usa por **lo que hace**, sin tener que recordar **cómo lo hace**.',
   E'// Tú escribes una sola línea...\nmostrar "Hola, CodeQuest"\n\n// ...y el computador se encarga de todos los detalles:\n// elegir la fuente, calcular píxeles, encender la pantalla...',
   3);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (4, 1, 2, 'Modelar datos: atributos relevantes',
   E'Cuando un programa trabaja con cosas del mundo real (estudiantes, productos, canciones), necesitamos **modelarlas**: describirlas con un conjunto de **atributos**.\n\nModelar es abstraer. Una canción tiene millones de características (cada nota, cada instrumento), pero una aplicación de música solo guarda algunas: título, artista, duración y género. Elegimos los atributos según lo que el programa debe hacer.\n\nBuenas preguntas para elegir atributos:\n- ¿Qué operaciones hará el programa? (buscar, ordenar, calcular)\n- ¿Qué dato necesita cada operación?\n- ¿Hay atributos que se pueden calcular a partir de otros? (por ejemplo, la edad a partir de la fecha de nacimiento)\n\nUn atributo que no se usa en ninguna operación es un detalle que sobra.',
   E'registro Cancion\n    titulo     : texto\n    artista    : texto\n    duracion   : entero   // en segundos\n    genero     : texto\nfin registro\n\n// Operación que usa los atributos:\nsi cancion.duracion > 300 entonces\n    mostrar "Canción larga"\nfin si',
   2);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (5, 1, 2, 'Funciones: esconder el cómo, mostrar el qué',
   E'Una **función** es un bloque de instrucciones con nombre que resuelve una tarea concreta. Es una de las herramientas de abstracción más poderosas: quien usa la función solo necesita saber **qué recibe** y **qué devuelve**.\n\nPor ejemplo, una función **calcularPromedio** recibe una lista de notas y devuelve su promedio. Quien la usa no tiene que repetir los pasos de sumar y dividir cada vez: simplemente la llama.\n\nVentajas de usar funciones:\n- **Reutilización:** se escribe una vez y se usa muchas veces.\n- **Claridad:** el programa principal se lee como una lista de ideas.\n- **Mantenimiento:** si hay un error, se corrige en un solo lugar.\n\nUn buen nombre de función describe el **qué** (calcularPromedio), no el **cómo** (sumarYDividir).',
   E'funcion calcularPromedio(notas)\n    suma ← 0\n    para cada nota en notas\n        suma ← suma + nota\n    fin para\n    devolver suma / cantidad(notas)\nfin funcion\n\n// Uso: no hace falta saber cómo se calcula\npromedio ← calcularPromedio([4.0, 3.5, 4.5])\nmostrar promedio   // 4.0',
   3);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (6, 2, NULL, '¿Qué es un patrón?',
   E'Un **patrón** es una regularidad: algo que se repite o que sigue una regla. Reconocer patrones nos permite predecir qué viene después y resolver problemas parecidos de la misma manera.\n\nEncontramos patrones en todas partes:\n- En los números: 2, 4, 6, 8… (de dos en dos).\n- En las figuras: ● ■ ● ■ ● ■… (se alternan).\n- En la vida diaria: el horario de clases se repite cada semana.\n- En la naturaleza: los pétalos de muchas flores siguen secuencias numéricas.\n\nEn programación, detectar un patrón es muy valioso: si una tarea se repite, no necesitamos escribir las instrucciones muchas veces. Podemos describir la regla una sola vez y dejar que el computador la repita.',
   E'Secuencia:  5, 10, 15, 20, ?\nRegla:      sumar 5 al número anterior\nSiguiente:  25',
   1);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (7, 2, 1, 'Secuencias de números y figuras',
   E'Para descubrir el patrón de una secuencia, compara cada elemento con el anterior y pregúntate **qué cambió**.\n\nLas reglas más comunes son:\n- **Sumar o restar** siempre lo mismo: 3, 7, 11, 15 (suma 4).\n- **Multiplicar o dividir** siempre por lo mismo: 2, 6, 18, 54 (multiplica por 3).\n- **Alternar** elementos: rojo, azul, rojo, azul.\n- **Crecer de forma ordenada:** ■, ■■, ■■■ (cada vez uno más).\n\nUn consejo: si sumar no funciona, prueba multiplicar. Si ninguna operación funciona, mira si hay dos secuencias intercaladas (por ejemplo, 1, 10, 2, 20, 3, 30).\n\nCuando encuentres la regla, compruébala con **todos** los elementos, no solo con los dos primeros.',
   E'1, 3, 9, 27, ?\n\n3 ÷ 1 = 3    9 ÷ 3 = 3    27 ÷ 9 = 3\nRegla: multiplicar por 3   →   siguiente: 81',
   2);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (8, 2, 1, 'Repetir sin repetirse',
   E'Imagina que debes darle instrucciones a un robot para dibujar un cuadrado:\n\navanzar, girar, avanzar, girar, avanzar, girar, avanzar, girar.\n\n¿Notas el patrón? El par «avanzar, girar» se repite **4 veces**. En lugar de escribir ocho instrucciones, podemos decir: **repetir 4 veces: avanzar y girar**.\n\nEsa es la idea de un **ciclo** (o bucle): una instrucción que repite un bloque de pasos varias veces. Los ciclos existen gracias a los patrones: primero reconocemos qué se repite y luego lo escribimos una sola vez.\n\nVentajas:\n- El programa es más corto y fácil de leer.\n- Si queremos un hexágono, solo cambiamos el 4 por un 6 (y el ángulo).\n- Hay menos posibilidades de equivocarse al copiar.',
   E'// Sin ciclo                 // Con ciclo\navanzar 10                  repetir 4 veces\ngirar 90                        avanzar 10\navanzar 10                      girar 90\ngirar 90                    fin repetir\navanzar 10\ngirar 90\navanzar 10\ngirar 90',
   3);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (9, 2, 2, 'Generalizar: la regla del término n',
   E'Reconocer un patrón es el primer paso; **generalizarlo** es escribir una regla que sirva para cualquier posición.\n\nEn la secuencia 4, 7, 10, 13… cada término suma 3. Pero si queremos el término número 100, no es práctico sumar 3 noventa y nueve veces. Mejor buscamos una fórmula en función de la posición **n**:\n\n- Posición 1 → 4 = 3·1 + 1\n- Posición 2 → 7 = 3·2 + 1\n- Posición 3 → 10 = 3·3 + 1\n\nLa regla general es **término(n) = 3n + 1**, y el término 100 es 301.\n\nGeneralizar es pasar de «veo que se repite» a «puedo calcular cualquier caso». Es exactamente lo que hace un programa: una regla general que funciona para todas las entradas posibles.',
   E'funcion termino(n)\n    devolver 3 * n + 1\nfin funcion\n\npara n desde 1 hasta 5\n    mostrar termino(n)     // 4, 7, 10, 13, 16\nfin para',
   2);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (10, 2, 2, 'Patrones con ciclos y condiciones',
   E'Muchos patrones combinan **repetición** con **decisiones**: algo se repite, pero no siempre de la misma forma.\n\nPor ejemplo, en un juego un enemigo aparece cada 3 turnos y un premio cada 5. Para saber si en un turno ocurre algo, usamos el **residuo** de la división (la operación **mod**): si turno mod 3 = 0, el turno es múltiplo de 3.\n\nEste tipo de patrón aparece en:\n- Calendarios (cada 7 días se repite el día de la semana).\n- Semáforos (ciclos de verde, amarillo y rojo).\n- Diseños (cada tercera baldosa es de otro color).\n\nPara programarlos: identifica qué se repite (el ciclo) y qué condición cambia el resultado (el si).',
   E'para turno desde 1 hasta 15\n    si turno mod 15 = 0 entonces\n        mostrar "¡Enemigo y premio!"\n    sino si turno mod 3 = 0 entonces\n        mostrar "Enemigo"\n    sino si turno mod 5 = 0 entonces\n        mostrar "Premio"\n    fin si\nfin para',
   3);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (11, 3, NULL, '¿Qué es un algoritmo?',
   E'Un **algoritmo** es una secuencia ordenada de pasos precisos que resuelve un problema. Una receta de cocina, las instrucciones para armar un mueble o la ruta para llegar al colegio son algoritmos.\n\nUn buen algoritmo cumple tres condiciones:\n- **Preciso:** cada paso dice exactamente qué hacer, sin ambigüedad.\n- **Ordenado:** los pasos tienen un orden y cambiarlo puede cambiar el resultado.\n- **Finito:** termina después de un número determinado de pasos.\n\nCasi todos los algoritmos siguen el esquema **entrada → proceso → salida**: reciben datos, los transforman y entregan un resultado.\n\nLos computadores no improvisan: solo siguen algoritmos. Por eso programar es, en gran parte, diseñar algoritmos claros.',
   E'Algoritmo: calcular el área de un rectángulo\n\nEntrada:  base y altura\nProceso:  área ← base × altura\nSalida:   mostrar el área',
   1);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (12, 3, 1, 'Paso a paso: secuencias',
   E'La forma más sencilla de algoritmo es una **secuencia**: pasos que se ejecutan uno después de otro, de arriba hacia abajo.\n\nPara escribir algoritmos usamos **pseudocódigo**: una forma de escribir instrucciones parecida al español, pero ordenada como un programa. No depende de ningún lenguaje de programación.\n\nReglas básicas del pseudocódigo de CodeQuest:\n- El algoritmo empieza con **inicio** y termina con **fin**.\n- **leer** recibe un dato y **mostrar** lo presenta en pantalla.\n- La flecha **←** guarda un valor en una variable: x ← 5 significa «x ahora vale 5».\n\nEl orden importa: si mostramos el resultado antes de calcularlo, el algoritmo falla.',
   E'inicio\n    leer precio\n    leer cantidad\n    total ← precio * cantidad\n    mostrar total\nfin',
   2);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (13, 3, 1, 'Tomar decisiones: si… entonces',
   E'No todos los algoritmos siguen siempre el mismo camino. A veces deben **decidir**: «si llueve, llevo paraguas; si no, llevo gorra».\n\nEn pseudocódigo usamos la estructura **si … entonces … sino … fin si**:\n- Después de **si** va una **condición**: una pregunta que se responde con verdadero o falso (por ejemplo, nota ≥ 3.0).\n- Si la condición es verdadera, se ejecutan los pasos de **entonces**.\n- Si es falsa, se ejecutan los pasos de **sino** (que es opcional).\n\nLas condiciones usan comparaciones: = (igual), ≠ (diferente), > (mayor), < (menor), ≥ (mayor o igual), ≤ (menor o igual).',
   E'inicio\n    leer nota\n    si nota ≥ 3.0 entonces\n        mostrar "Aprobaste"\n    sino\n        mostrar "Debes reforzar"\n    fin si\nfin',
   3);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (14, 3, 2, 'Variables, condiciones y ciclos juntos',
   E'Los algoritmos reales combinan las tres estructuras básicas:\n- **Secuencia:** pasos en orden.\n- **Decisión:** si … entonces.\n- **Repetición:** para … hasta o mientras.\n\nUn patrón muy común es el **acumulador**: una variable que empieza en 0 y en cada vuelta del ciclo suma un valor nuevo. Con un acumulador podemos calcular totales y promedios.\n\nOtro es el **contador**: una variable que suma 1 cada vez que se cumple una condición, por ejemplo, para contar cuántas notas son aprobatorias.\n\nAl diseñar un algoritmo así, define primero las variables, su valor inicial y en qué momento cambian.',
   E'inicio\n    suma ← 0\n    aprobadas ← 0\n    para i desde 1 hasta 5\n        leer nota\n        suma ← suma + nota\n        si nota ≥ 3.0 entonces\n            aprobadas ← aprobadas + 1\n        fin si\n    fin para\n    mostrar "Promedio: ", suma / 5\n    mostrar "Aprobadas: ", aprobadas\nfin',
   2);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (15, 3, 2, 'Diseñar y probar: encontrar el mayor',
   E'Diseñar un algoritmo no termina al escribirlo: hay que **probarlo**. Una técnica sencilla es la **prueba de escritorio**: seguir el algoritmo a mano con datos concretos y anotar cómo cambian las variables en cada paso.\n\nProblema: encontrar el número mayor de una lista. Idea: suponer que el primero es el mayor y recorrer el resto; cada vez que aparezca uno más grande, se reemplaza.\n\nPrueba con la lista [7, 3, 12, 5]:\n- mayor = 7\n- compara 3: no cambia\n- compara 12: mayor = 12\n- compara 5: no cambia → resultado 12\n\nPrueba también casos especiales: una lista con un solo número, números repetidos o negativos. Si el algoritmo funciona en todos, es confiable.',
   E'funcion encontrarMayor(lista)\n    mayor ← lista[1]\n    para i desde 2 hasta cantidad(lista)\n        si lista[i] > mayor entonces\n            mayor ← lista[i]\n        fin si\n    fin para\n    devolver mayor\nfin funcion',
   3);

-- =====================================================================
-- Datos de database/05_seed_actividades.sql
-- =====================================================================

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
  (13, 5, 'completar_codigo', 'Completa la palabra que cierra la decisión.', E'si cancion.duracion > 300 entonces\n    mostrar "Canción larga"\nfin ___', 'Toda estructura si … entonces se cierra con fin si.', 1, 2);
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
  (15, 6, 'completar_codigo', 'Completa la palabra que entrega el resultado de la función.', E'funcion doble(n)\n    ___ n * 2\nfin funcion', 'La instrucción devolver entrega el resultado de la función a quien la llamó.', 1, 2);
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
  (20, 9, 'completar_codigo', 'Completa el número para que el robot dibuje un cuadrado.', E'repetir ___ veces\n    avanzar 10\n    girar 90\nfin repetir', 'Un cuadrado tiene 4 lados: el par «avanzar, girar 90» se repite 4 veces.', 1, 1);
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
  (22, 10, 'patron', 'Si la regla es término(n) = 2n + 3, ¿cuál es el término 10?', E'termino(n) = 2n + 3\ntermino(10) = ___', '2 · 10 + 3 = 23.', 1, 1);
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
  (24, 11, 'completar_codigo', 'Completa la operación para mostrar los múltiplos de 5.', E'para i desde 1 hasta 20\n    si i ___ 5 = 0 entonces\n        mostrar i\n    fin si\nfin para', 'mod da el residuo de la división; si i mod 5 = 0, i es múltiplo de 5.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (24, 'mod', 1, NULL, NULL, 1);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (25, 11, 'seleccion', '¿Qué se muestra al ejecutar este pseudocódigo?', E'para i desde 1 hasta 6\n    si i mod 2 = 0 entonces\n        mostrar i\n    fin si\nfin para', 'Se muestran los números cuyo residuo al dividir entre 2 es 0: los pares 2, 4 y 6.', 1, 2);
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
  (29, 13, 'completar_codigo', 'Completa la instrucción que presenta el resultado.', E'inicio\n    leer precio\n    leer cantidad\n    total ← precio * cantidad\n    ___ total\nfin', 'mostrar presenta un valor en pantalla; es la salida del algoritmo.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (29, 'mostrar', 1, NULL, NULL, 1);

-- Práctica: tomar decisiones
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (14, 3, 13, 1, 'Práctica: tomar decisiones', 'practica', 3, 30, 60, 3);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (30, 14, 'seleccion', '¿Qué se muestra al ejecutar este pseudocódigo?', E'x ← 2\nsi x > 5 entonces\n    mostrar "Grande"\nsino\n    mostrar "Pequeño"\nfin si', 'La condición 2 > 5 es falsa, así que se ejecuta el bloque sino.', 1, 1);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (30, 'Grande', 0, NULL, NULL, 1),
  (30, 'Pequeño', 1, NULL, NULL, 2),
  (30, 'Grande y Pequeño', 0, NULL, NULL, 3),
  (30, 'Nada', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (31, 14, 'completar_codigo', 'Completa la palabra que falta en la decisión.', E'si nota ≥ 3.0 ___\n    mostrar "Aprobaste"\nfin si', 'La estructura es si condición entonces … fin si.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (31, 'entonces', 1, NULL, NULL, 1);

-- Práctica: acumuladores y contadores
INSERT INTO activities (id, module_id, lesson_id, path_id, title, kind, difficulty, base_xp, pass_pct, sort_order) VALUES
  (15, 3, 14, 2, 'Práctica: acumuladores y contadores', 'practica', 2, 20, 60, 2);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (32, 15, 'seleccion', '¿Qué se muestra al ejecutar este pseudocódigo?', E'suma ← 0\npara i desde 1 hasta 4\n    suma ← suma + i\nfin para\nmostrar suma', 'suma acumula 1 + 2 + 3 + 4 = 10.', 1, 1);
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
  (41, 18, 'completar_codigo', 'Completa el operador para calcular el área.', E'funcion area(base, altura)\n    devolver base ___ altura\nfin funcion', 'El área de un rectángulo es base multiplicada por altura.', 1, 2);
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
  (46, 19, 'completar_codigo', 'Completa el número para aplaudir 3 veces.', E'repetir ___ veces\n    aplaudir\nfin repetir', 'El ciclo repite su contenido el número de veces indicado.', 1, 3);
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
  (50, 20, 'completar_codigo', 'Completa la operación para que el enemigo aparezca cada 3 turnos.', E'si turno ___ 3 = 0 entonces\n    mostrar "Enemigo"\nfin si', 'turno mod 3 = 0 se cumple en los turnos 3, 6, 9…', 1, 3);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (50, 'mod', 1, NULL, NULL, 1);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (51, 20, 'seleccion', '¿Qué se muestra al ejecutar este pseudocódigo?', E'para i desde 1 hasta 10\n    si i mod 3 = 0 entonces\n        mostrar i\n    fin si\nfin para', 'Entre 1 y 10, los múltiplos de 3 son 3, 6 y 9.', 1, 4);
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
  (53, 21, 'seleccion', '¿Qué se muestra al ejecutar este pseudocódigo?', E'a ← 3\nb ← 4\nc ← a + b\nmostrar c', 'c guarda la suma de a y b: 3 + 4 = 7.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (53, '34', 0, NULL, NULL, 1),
  (53, '7', 1, NULL, NULL, 2),
  (53, 'a + b', 0, NULL, NULL, 3),
  (53, '12', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (54, 21, 'completar_codigo', 'Completa la palabra del camino alternativo.', E'leer edad\nsi edad ≥ 18 entonces\n    mostrar "Adulto"\n___\n    mostrar "Menor"\nfin si', 'sino indica qué hacer cuando la condición es falsa.', 1, 3);
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
  (56, 22, 'seleccion', '¿Qué se muestra al ejecutar este pseudocódigo?', E'contador ← 0\npara i desde 1 hasta 5\n    si i > 2 entonces\n        contador ← contador + 1\n    fin si\nfin para\nmostrar contador', 'La condición i > 2 se cumple para i = 3, 4 y 5: el contador llega a 3.', 1, 1);
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
  (58, 22, 'completar_codigo', 'Completa el operador de comparación para encontrar el mayor.', E'mayor ← lista[1]\npara i desde 2 hasta cantidad(lista)\n    si lista[i] ___ mayor entonces\n        mayor ← lista[i]\n    fin si\nfin para', 'Solo se reemplaza mayor cuando el elemento actual es más grande: lista[i] > mayor.', 1, 3);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (58, '>', 1, NULL, NULL, 1);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (59, 22, 'seleccion', 'Prueba de escritorio: con la lista [−3, −8, −1], ¿qué devuelve encontrarMayor?', NULL, 'mayor empieza en −3; −8 no es mayor; −1 sí lo es. Resultado: −1.', 1, 4);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (59, '−8', 0, NULL, NULL, 1),
  (59, '−3', 0, NULL, NULL, 2),
  (59, '−1', 1, NULL, NULL, 3),
  (59, '0', 0, NULL, NULL, 4);

-- =====================================================================
-- Datos de database/06_seed_retos.sql
-- =====================================================================

-- =====================================================================
-- CodeQuest: Aprende a programar
-- 06_seed_retos.sql - Retos de módulo (RF-24)
--
-- Ejecutar DESPUÉS de 05_seed_actividades.sql.
-- Un reto por módulo y ruta: 5 preguntas que combinan varios tipos,
-- dificultad 3, 60 XP y se aprueba con 70 %. Se desbloquea al aprobar
-- la evaluación del módulo. Superar el primero otorga la insignia Retador.
-- =====================================================================


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
  (63, 23, 'completar_codigo', 'Completa la instrucción que presenta el saludo en pantalla.', E'leer nombre\n___ "Hola, " + nombre', 'mostrar presenta información en pantalla sin que necesitemos saber cómo se dibuja.', 1, 4);
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
  (66, 24, 'completar_codigo', 'Completa el operador para que la función calcule el área de un rectángulo.', E'funcion area(base, altura)\n    devolver base ___ altura\nfin funcion', 'El área de un rectángulo es base × altura.', 1, 2);
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
  (68, 24, 'seleccion', '¿Qué se muestra al ejecutar este pseudocódigo?', E'funcion doble(n)\n    devolver n * 2\nfin funcion\n\nmostrar doble(doble(3))', 'Primero doble(3) = 6 y luego doble(6) = 12.', 1, 4);
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
  (72, 25, 'completar_codigo', 'Completa el número para que el robot dibuje un triángulo.', E'repetir ___ veces\n    avanzar 10\n    girar 120\nfin repetir', 'Un triángulo tiene 3 lados: el par «avanzar, girar 120» se repite 3 veces.', 1, 3);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (72, '3', 1, NULL, NULL, 1),
  (72, 'tres', 1, NULL, NULL, 2);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (73, 25, 'seleccion', '¿Cuántas veces se muestra la palabra "Hola"?', E'repetir 4 veces\n    mostrar "Hola"\n    mostrar "Hola"\nfin repetir', 'Cada vuelta muestra «Hola» 2 veces y hay 4 vueltas: 2 × 4 = 8.', 1, 4);
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
  (75, 26, 'patron', 'Si la regla es término(n) = 3n − 1, ¿cuál es el término 7?', E'termino(n) = 3n − 1\ntermino(7) = ___', '3 · 7 − 1 = 20.', 1, 1);
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
  (77, 26, 'completar_codigo', 'Completa la operación para mostrar los múltiplos de 5.', E'para i desde 1 hasta 20\n    si i ___ 5 = 0 entonces\n        mostrar i\n    fin si\nfin para', 'i mod 5 = 0 se cumple cuando i es múltiplo de 5: 5, 10, 15 y 20.', 1, 3);
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
  (79, 26, 'seleccion', '¿Qué se muestra al ejecutar este pseudocódigo?', E'para i desde 1 hasta 4\n    mostrar i * i\nfin para', 'Se muestran los cuadrados de 1 a 4: 1, 4, 9 y 16.', 1, 5);
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
  (81, 27, 'seleccion', 'Si se lee nota = 2.5, ¿qué se muestra?', E'leer nota\nsi nota ≥ 3 entonces\n    mostrar "Aprobó"\nsino\n    mostrar "Reprobó"\nfin si', '2.5 no es mayor o igual a 3, así que la condición es falsa y se ejecuta el camino sino.', 1, 2);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (81, 'Aprobó', 0, NULL, NULL, 1),
  (81, 'Reprobó', 1, NULL, NULL, 2),
  (81, 'Aprobó y Reprobó', 0, NULL, NULL, 3),
  (81, 'Nada', 0, NULL, NULL, 4);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (82, 27, 'completar_codigo', 'Completa el operador para que el algoritmo sume los dos números.', E'leer a\nleer b\nsuma ← a ___ b\nmostrar suma', 'La suma se calcula con el operador +.', 1, 3);
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
  (85, 28, 'seleccion', '¿Qué se muestra al ejecutar este pseudocódigo?', E'x ← 1\nmientras x < 20\n    x ← x * 2\nfin mientras\nmostrar x', 'x toma los valores 1, 2, 4, 8, 16 y 32; al llegar a 32 la condición x < 20 es falsa y el ciclo termina.', 1, 1);
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
  (87, 28, 'completar_codigo', 'Completa el operador para contar los números pares del 1 al 10.', E'pares ← 0\npara i desde 1 hasta 10\n    si i mod 2 = 0 entonces\n        pares ← pares ___ 1\n    fin si\nfin para', 'Un contador aumenta de 1 en 1: pares ← pares + 1.', 1, 3);
INSERT INTO answer_options (question_id, option_text, is_correct, correct_order, pair_text, sort_order) VALUES
  (87, '+', 1, NULL, NULL, 1);
INSERT INTO questions (id, activity_id, type, statement, code_snippet, explanation, points, sort_order) VALUES
  (88, 28, 'seleccion', 'Prueba de escritorio: ¿qué se muestra?', E'suma ← 0\npara i desde 1 hasta 4\n    suma ← suma + i\nfin para\nmostrar suma', 'suma pasa por 1, 3, 6 y 10.', 1, 4);
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

-- ---------------------------------------------------------------------
-- Los datos se insertaron con id fijo: se ajustan los contadores.
-- ---------------------------------------------------------------------

SELECT setval(pg_get_serial_sequence('learning_paths', 'id'), COALESCE((SELECT MAX(id) FROM learning_paths), 0) + 1, false);
SELECT setval(pg_get_serial_sequence('levels', 'id'), COALESCE((SELECT MAX(id) FROM levels), 0) + 1, false);
SELECT setval(pg_get_serial_sequence('modules', 'id'), COALESCE((SELECT MAX(id) FROM modules), 0) + 1, false);
SELECT setval(pg_get_serial_sequence('lessons', 'id'), COALESCE((SELECT MAX(id) FROM lessons), 0) + 1, false);
SELECT setval(pg_get_serial_sequence('activities', 'id'), COALESCE((SELECT MAX(id) FROM activities), 0) + 1, false);
SELECT setval(pg_get_serial_sequence('questions', 'id'), COALESCE((SELECT MAX(id) FROM questions), 0) + 1, false);
SELECT setval(pg_get_serial_sequence('answer_options', 'id'), COALESCE((SELECT MAX(id) FROM answer_options), 0) + 1, false);
SELECT setval(pg_get_serial_sequence('badges', 'id'), COALESCE((SELECT MAX(id) FROM badges), 0) + 1, false);
SELECT setval(pg_get_serial_sequence('users', 'id'), COALESCE((SELECT MAX(id) FROM users), 0) + 1, false);
SELECT setval(pg_get_serial_sequence('attempts', 'id'), COALESCE((SELECT MAX(id) FROM attempts), 0) + 1, false);
SELECT setval(pg_get_serial_sequence('attempt_answers', 'id'), COALESCE((SELECT MAX(id) FROM attempt_answers), 0) + 1, false);
SELECT setval(pg_get_serial_sequence('diagnostics', 'id'), COALESCE((SELECT MAX(id) FROM diagnostics), 0) + 1, false);
SELECT setval(pg_get_serial_sequence('xp_transactions', 'id'), COALESCE((SELECT MAX(id) FROM xp_transactions), 0) + 1, false);

-- ---------------------------------------------------------------------
-- Seguridad: Supabase publica las tablas de "public" en su API REST.
-- Se activa RLS sin políticas para que nadie pueda leerlas desde ahí
-- (por ejemplo, los hashes de contraseña). El backend PHP se conecta
-- como "postgres", dueño de las tablas, y no se ve afectado.
-- ---------------------------------------------------------------------
ALTER TABLE learning_paths ENABLE ROW LEVEL SECURITY;
ALTER TABLE levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE answer_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE attempt_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE diagnostics ENABLE ROW LEVEL SECURITY;
ALTER TABLE xp_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE module_progress ENABLE ROW LEVEL SECURITY;

COMMIT;
