-- CodeBot: migración aditiva para MySQL / MariaDB.
-- Ejecutar una sola vez sobre la base existente. No elimina ni recrea tablas.
CREATE TABLE tutor_conversations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  title VARCHAR(120) NOT NULL DEFAULT 'Nueva conversación',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  archived_at DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_tutor_conversations_user_updated (user_id, updated_at),
  CONSTRAINT fk_tutor_conversations_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tutor_messages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  conversation_id BIGINT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  role VARCHAR(12) NOT NULL,
  content TEXT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_tutor_messages_conversation_created (conversation_id, created_at),
  KEY idx_tutor_messages_user_created (user_id, created_at),
  CONSTRAINT chk_tutor_messages_role CHECK (role IN ('user', 'model')),
  CONSTRAINT fk_tutor_messages_conversation FOREIGN KEY (conversation_id)
    REFERENCES tutor_conversations (id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_tutor_messages_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
