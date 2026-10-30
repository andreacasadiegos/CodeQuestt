<?php
/**
 * Acceso a la tabla learning_paths.
 */

declare(strict_types=1);

final class LearningPath
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    public function findByCode(string $code): ?array
    {
        $stmt = $this->db->prepare('SELECT id, code, name, description FROM learning_paths WHERE code = ?');
        $stmt->execute([$code]);
        $row = $stmt->fetch();

        return $row ? ['id' => (int) $row['id']] + $row : null;
    }
}
