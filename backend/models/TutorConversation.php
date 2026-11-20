<?php
/**
 * Persistencia del historial privado de CodeBot.
 * Todas las consultas se limitan al usuario autenticado.
 */
declare(strict_types=1);

final class TutorConversation
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    public function allForUser(int $userId): array
    {
        $stmt = $this->db->prepare(
            "SELECT id, title, created_at, updated_at
             FROM tutor_conversations
             WHERE user_id = ? AND archived_at IS NULL
             ORDER BY updated_at DESC, id DESC
             LIMIT 50"
        );
        $stmt->execute([$userId]);
        return array_map([$this, 'formatConversation'], $stmt->fetchAll());
    }

    public function create(int $userId): int
    {
        $sql = 'INSERT INTO tutor_conversations (user_id, title) VALUES (?, ?)';
        if (Database::isPostgres()) {
            $stmt = $this->db->prepare($sql . ' RETURNING id');
            $stmt->execute([$userId, 'Nueva conversación']);
            return (int) $stmt->fetchColumn();
        }

        $stmt = $this->db->prepare($sql);
        $stmt->execute([$userId, 'Nueva conversación']);
        return (int) $this->db->lastInsertId();
    }

    public function findForUser(int $conversationId, int $userId): ?array
    {
        $stmt = $this->db->prepare(
            'SELECT id, title, created_at, updated_at
             FROM tutor_conversations
             WHERE id = ? AND user_id = ? AND archived_at IS NULL
             LIMIT 1'
        );
        $stmt->execute([$conversationId, $userId]);
        $row = $stmt->fetch();
        return $row ? $this->formatConversation($row) : null;
    }

    public function messages(int $conversationId, int $limit = 40): array
    {
        $limit = max(1, min(80, $limit));
        $stmt = $this->db->prepare(
            "SELECT id, role, content, created_at
             FROM tutor_messages
             WHERE conversation_id = ?
             ORDER BY id DESC
             LIMIT $limit"
        );
        $stmt->execute([$conversationId]);
        return array_reverse($stmt->fetchAll());
    }

    public function recentMessages(int $conversationId, int $limit = 12): array
    {
        return $this->messages($conversationId, $limit);
    }

    public function countUserMessagesSince(int $userId, string $since): int
    {
        $stmt = $this->db->prepare(
            "SELECT COUNT(*)
             FROM tutor_messages m
             INNER JOIN tutor_conversations c ON c.id = m.conversation_id
             WHERE c.user_id = ? AND m.role = 'user' AND m.created_at >= ?"
        );
        $stmt->execute([$userId, $since]);
        return (int) $stmt->fetchColumn();
    }

    public function saveExchange(int $conversationId, int $userId, string $question, string $answer): void
    {
        $this->db->beginTransaction();
        try {
            $user = $this->db->prepare(
                "INSERT INTO tutor_messages (conversation_id, user_id, role, content)
                 VALUES (?, ?, 'user', ?)"
            );
            $user->execute([$conversationId, $userId, $question]);

            $model = $this->db->prepare(
                "INSERT INTO tutor_messages (conversation_id, user_id, role, content)
                 VALUES (?, ?, 'model', ?)"
            );
            $model->execute([$conversationId, $userId, $answer]);

            $title = mb_substr(preg_replace('/\s+/u', ' ', $question) ?? $question, 0, 64);
            $update = $this->db->prepare(
                "UPDATE tutor_conversations
                 SET title = CASE WHEN title = 'Nueva conversación' THEN ? ELSE title END,
                     updated_at = CURRENT_TIMESTAMP
                 WHERE id = ? AND user_id = ?"
            );
            $update->execute([$title, $conversationId, $userId]);
            $this->db->commit();
        } catch (Throwable $e) {
            if ($this->db->inTransaction()) {
                $this->db->rollBack();
            }
            throw $e;
        }
    }

    public function archive(int $conversationId, int $userId): bool
    {
        $stmt = $this->db->prepare(
            'UPDATE tutor_conversations SET archived_at = CURRENT_TIMESTAMP
             WHERE id = ? AND user_id = ? AND archived_at IS NULL'
        );
        $stmt->execute([$conversationId, $userId]);
        return $stmt->rowCount() > 0;
    }

    private function formatConversation(array $row): array
    {
        return [
            'id' => (int) $row['id'],
            'title' => $row['title'],
            'created_at' => $row['created_at'],
            'updated_at' => $row['updated_at'],
        ];
    }
}
