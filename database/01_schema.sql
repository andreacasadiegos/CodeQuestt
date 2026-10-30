-- =====================================================================
-- CodeQuest: Aprende a programar
-- 01_schema.sql - Creación de la base de datos, tablas y relaciones
--
-- Ejecutar en phpMyAdmin (pestaña SQL) o con:
--   mysql -u root < 01_schema.sql
--
-- ATENCIÓN: borra y vuelve a crear la base codequest_db.
-- =====================================================================

DROP DATABASE IF EXISTS codequest_db;
CREATE DATABASE codequest_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE codequest_db;

-- ---------------------------------------------------------------------
-- 1. CATÁLOGO
-- ---------------------------------------------------------------------

-- Rutas de aprendizaje: básica e intermedia.
-- advance_min_pct: promedio mínimo en las evaluaciones de módulo para
-- poder avanzar a la ruta siguiente (NULL = no se avanza desde esta ruta).
CREATE TABLE learning_paths (
  id               TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code             VARCHAR(20)  NOT NULL,
  name             VARCHAR(60)  NOT NULL,
  description      VARCHAR(255) NOT NULL,
  advance_min_pct  TINYINT UNSIGNED NULL,
  sort_order       TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_learning_paths_code (code),
  CONSTRAINT chk_paths_advance CHECK (advance_min_pct IS NULL OR advance_min_pct BETWEEN 0 AND 100)
) ENGINE=InnoDB;

-- Niveles de experiencia según el XP acumulado.
CREATE TABLE levels (
  id      TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  number  TINYINT UNSIGNED NOT NULL,
  name    VARCHAR(60) NOT NULL,
  min_xp  INT UNSIGNED NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_levels_number (number),
  UNIQUE KEY uq_levels_min_xp (min_xp)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. CONTENIDO
-- ---------------------------------------------------------------------

-- Módulos: Abstracción, Patrones, Algoritmos.
CREATE TABLE modules (
  id           TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  slug         VARCHAR(40)  NOT NULL,
  name         VARCHAR(60)  NOT NULL,
  description  VARCHAR(255) NOT NULL,
  icon         VARCHAR(40)  NOT NULL COMMENT 'Nombre del ícono de Bootstrap Icons',
  sort_order   TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_modules_slug (slug)
) ENGINE=InnoDB;

-- Lecciones de cada módulo. path_id NULL = aplica a ambas rutas.
CREATE TABLE lessons (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  module_id   TINYINT UNSIGNED NOT NULL,
  path_id     TINYINT UNSIGNED NULL,
  title       VARCHAR(120) NOT NULL,
  content     TEXT NOT NULL COMMENT 'Explicación del concepto',
  example     TEXT NULL     COMMENT 'Ejemplo sencillo',
  sort_order  TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_lessons_module (module_id, sort_order),
  KEY idx_lessons_path (path_id),
  CONSTRAINT fk_lessons_module FOREIGN KEY (module_id) REFERENCES modules (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_lessons_path FOREIGN KEY (path_id) REFERENCES learning_paths (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Actividades: prácticas, evaluaciones, retos y la prueba diagnóstica.
-- module_id NULL solo en el diagnóstico; lesson_id NULL en retos y diagnóstico.
CREATE TABLE activities (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  module_id   TINYINT UNSIGNED NULL,
  lesson_id   INT UNSIGNED NULL,
  path_id     TINYINT UNSIGNED NULL,
  title       VARCHAR(120) NOT NULL,
  description VARCHAR(255) NULL,
  kind        ENUM('practica', 'evaluacion', 'reto', 'diagnostico') NOT NULL,
  difficulty  TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1 fácil, 2 media, 3 desafiante',
  base_xp     SMALLINT UNSIGNED NOT NULL DEFAULT 10,
  pass_pct    TINYINT UNSIGNED NOT NULL DEFAULT 60,
  sort_order  TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_activities_module (module_id, difficulty, sort_order),
  KEY idx_activities_lesson (lesson_id),
  KEY idx_activities_path (path_id),
  CONSTRAINT fk_activities_module FOREIGN KEY (module_id) REFERENCES modules (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_activities_lesson FOREIGN KEY (lesson_id) REFERENCES lessons (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_activities_path FOREIGN KEY (path_id) REFERENCES learning_paths (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_activities_difficulty CHECK (difficulty BETWEEN 1 AND 3),
  CONSTRAINT chk_activities_pass CHECK (pass_pct BETWEEN 0 AND 100)
) ENGINE=InnoDB;

-- Preguntas. El tipo vive aquí para que una actividad pueda mezclar tipos.
CREATE TABLE questions (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  activity_id   INT UNSIGNED NOT NULL,
  type          ENUM('seleccion', 'completar_codigo', 'patron', 'ordenar', 'relacionar') NOT NULL,
  statement     TEXT NOT NULL,
  code_snippet  TEXT NULL COMMENT 'Fragmento de código o pseudocódigo; ___ marca el hueco',
  explanation   TEXT NOT NULL COMMENT 'Retroalimentación que se muestra al responder',
  points        TINYINT UNSIGNED NOT NULL DEFAULT 1,
  sort_order    TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_questions_activity (activity_id, sort_order),
  CONSTRAINT fk_questions_activity FOREIGN KEY (activity_id) REFERENCES activities (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Opciones de respuesta. Según el tipo de pregunta se usa:
--   seleccion / patron     -> option_text + is_correct
--   completar_codigo       -> option_text = respuesta aceptada, is_correct = 1
--   ordenar                -> option_text + correct_order (1, 2, 3...)
--   relacionar             -> option_text (concepto) + pair_text (definición)
-- Estas columnas NUNCA se envían al navegador antes de responder.
CREATE TABLE answer_options (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  question_id    INT UNSIGNED NOT NULL,
  option_text    VARCHAR(255) NOT NULL,
  is_correct     TINYINT(1) NOT NULL DEFAULT 0,
  correct_order  TINYINT UNSIGNED NULL,
  pair_text      VARCHAR(255) NULL,
  sort_order     TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_answer_options_question (question_id, sort_order),
  CONSTRAINT fk_answer_options_question FOREIGN KEY (question_id) REFERENCES questions (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Insignias (logros) y la regla que las otorga automáticamente.
CREATE TABLE badges (
  id           TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code         VARCHAR(40)  NOT NULL,
  name         VARCHAR(60)  NOT NULL,
  description  VARCHAR(255) NOT NULL,
  icon         VARCHAR(40)  NOT NULL COMMENT 'Nombre del ícono de Bootstrap Icons',
  rule_type    ENUM('actividades_completadas', 'xp_total', 'modulo_completado',
                    'puntaje_perfecto', 'reto_completado') NOT NULL,
  rule_value   INT UNSIGNED NOT NULL DEFAULT 1,
  module_id    TINYINT UNSIGNED NULL COMMENT 'Solo para modulo_completado',
  xp_reward    SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_badges_code (code),
  KEY idx_badges_module (module_id),
  CONSTRAINT fk_badges_module FOREIGN KEY (module_id) REFERENCES modules (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. ESTUDIANTE
-- ---------------------------------------------------------------------

-- Estudiantes. xp_total y level_id solo los modifica el backend
-- (XpService), nunca un dato enviado por el navegador.
CREATE TABLE users (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  full_name      VARCHAR(120) NOT NULL,
  email          VARCHAR(120) NOT NULL,
  password_hash  VARCHAR(255) NOT NULL,
  path_id        TINYINT UNSIGNED NULL COMMENT 'NULL hasta completar el diagnóstico',
  level_id       TINYINT UNSIGNED NOT NULL DEFAULT 1,
  xp_total       INT UNSIGNED NOT NULL DEFAULT 0,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email),
  KEY idx_users_path (path_id),
  KEY idx_users_level (level_id),
  CONSTRAINT fk_users_path FOREIGN KEY (path_id) REFERENCES learning_paths (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_users_level FOREIGN KEY (level_id) REFERENCES levels (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. RESULTADOS Y PROGRESO
-- ---------------------------------------------------------------------

-- Cada intento de una actividad (el resultado).
CREATE TABLE attempts (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id        INT UNSIGNED NOT NULL,
  activity_id    INT UNSIGNED NOT NULL,
  correct_count  TINYINT UNSIGNED NOT NULL,
  total_count    TINYINT UNSIGNED NOT NULL,
  score_pct      TINYINT UNSIGNED NOT NULL,
  passed         TINYINT(1) NOT NULL DEFAULT 0,
  xp_awarded     SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  submitted_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_attempts_user_activity (user_id, activity_id, score_pct),
  KEY idx_attempts_activity (activity_id),
  CONSTRAINT fk_attempts_user FOREIGN KEY (user_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_attempts_activity FOREIGN KEY (activity_id) REFERENCES activities (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_attempts_score CHECK (score_pct BETWEEN 0 AND 100),
  CONSTRAINT chk_attempts_counts CHECK (correct_count <= total_count)
) ENGINE=InnoDB;

-- Respuesta del estudiante a cada pregunta de un intento.
-- answer_given guarda la respuesta en JSON, por ejemplo:
--   seleccion  -> {"option_id": 12}
--   ordenar    -> {"order": [7, 5, 6, 8]}
CREATE TABLE attempt_answers (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  attempt_id    INT UNSIGNED NOT NULL,
  question_id   INT UNSIGNED NOT NULL,
  answer_given  JSON NOT NULL,
  is_correct    TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_attempt_answers (attempt_id, question_id),
  KEY idx_attempt_answers_question (question_id),
  CONSTRAINT fk_attempt_answers_attempt FOREIGN KEY (attempt_id) REFERENCES attempts (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_attempt_answers_question FOREIGN KEY (question_id) REFERENCES questions (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Resultado del diagnóstico inicial (uno por estudiante).
-- assigned_path_id conserva la ruta inicial aunque luego el estudiante avance.
CREATE TABLE diagnostics (
  id                 INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id            INT UNSIGNED NOT NULL,
  attempt_id         INT UNSIGNED NULL,
  experience_option  TINYINT UNSIGNED NOT NULL COMMENT '1 sin conocimientos, 2 básicos, 3 ya estudió',
  test_score         TINYINT UNSIGNED NOT NULL COMMENT 'Aciertos en la prueba de 5 preguntas',
  assigned_path_id   TINYINT UNSIGNED NOT NULL,
  completed_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_diagnostics_user (user_id),
  KEY idx_diagnostics_attempt (attempt_id),
  KEY idx_diagnostics_path (assigned_path_id),
  CONSTRAINT fk_diagnostics_user FOREIGN KEY (user_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_diagnostics_attempt FOREIGN KEY (attempt_id) REFERENCES attempts (id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_diagnostics_path FOREIGN KEY (assigned_path_id) REFERENCES learning_paths (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_diagnostics_option CHECK (experience_option BETWEEN 1 AND 3),
  CONSTRAINT chk_diagnostics_score CHECK (test_score BETWEEN 0 AND 5)
) ENGINE=InnoDB;

-- Registro auditable de cada punto de XP otorgado.
-- users.xp_total es siempre la suma de amount de este usuario.
CREATE TABLE xp_transactions (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id      INT UNSIGNED NOT NULL,
  amount       SMALLINT UNSIGNED NOT NULL,
  source       ENUM('actividad', 'insignia') NOT NULL,
  attempt_id   INT UNSIGNED NULL,
  badge_id     TINYINT UNSIGNED NULL,
  description  VARCHAR(255) NOT NULL,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_xp_user (user_id, created_at),
  KEY idx_xp_attempt (attempt_id),
  KEY idx_xp_badge (badge_id),
  CONSTRAINT fk_xp_user FOREIGN KEY (user_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_xp_attempt FOREIGN KEY (attempt_id) REFERENCES attempts (id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_xp_badge FOREIGN KEY (badge_id) REFERENCES badges (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Insignias obtenidas por cada estudiante.
CREATE TABLE user_badges (
  user_id    INT UNSIGNED NOT NULL,
  badge_id   TINYINT UNSIGNED NOT NULL,
  earned_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, badge_id),
  KEY idx_user_badges_badge (badge_id),
  CONSTRAINT fk_user_badges_user FOREIGN KEY (user_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_user_badges_badge FOREIGN KEY (badge_id) REFERENCES badges (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Lecciones leídas por cada estudiante.
CREATE TABLE lesson_progress (
  user_id       INT UNSIGNED NOT NULL,
  lesson_id     INT UNSIGNED NOT NULL,
  completed_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, lesson_id),
  KEY idx_lesson_progress_lesson (lesson_id),
  CONSTRAINT fk_lesson_progress_user FOREIGN KEY (user_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_lesson_progress_lesson FOREIGN KEY (lesson_id) REFERENCES lessons (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Avance de cada estudiante en cada módulo.
CREATE TABLE module_progress (
  user_id       INT UNSIGNED NOT NULL,
  module_id     TINYINT UNSIGNED NOT NULL,
  percent       TINYINT UNSIGNED NOT NULL DEFAULT 0,
  status        ENUM('no_iniciado', 'en_curso', 'completado') NOT NULL DEFAULT 'no_iniciado',
  started_at    DATETIME NULL,
  completed_at  DATETIME NULL,
  PRIMARY KEY (user_id, module_id),
  KEY idx_module_progress_module (module_id),
  CONSTRAINT fk_module_progress_user FOREIGN KEY (user_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_module_progress_module FOREIGN KEY (module_id) REFERENCES modules (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_module_progress_percent CHECK (percent BETWEEN 0 AND 100)
) ENGINE=InnoDB;
