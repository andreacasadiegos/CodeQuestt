<?php
/**
 * Acceso a la tabla diagnostics.
 */

declare(strict_types=1);

final class Diagnostic
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    public function existsForUser(int $userId): bool
    {
        $stmt = $this->db->prepare('SELECT 1 FROM diagnostics WHERE user_id = ? LIMIT 1');
        $stmt->execute([$userId]);
        return (bool) $stmt->fetchColumn();
    }

    public function create(int $userId, int $attemptId, int $experienceOption, int $testScore, int $pathId): void
    {
        $stmt = $this->db->prepare(
            'INSERT INTO diagnostics (user_id, attempt_id, experience_option, test_score, assigned_path_id)
             VALUES (?, ?, ?, ?, ?)'
        );
        $stmt->execute([$userId, $attemptId, $experienceOption, $testScore, $pathId]);
    }
}
