<?php
/**
 * Acceso a la tabla xp_transactions (registro auditable de puntos).
 */

declare(strict_types=1);

final class XpTransaction
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    public function create(int $userId, int $amount, string $source, ?int $attemptId, ?int $badgeId, string $description): void
    {
        $stmt = $this->db->prepare(
            'INSERT INTO xp_transactions (user_id, amount, source, attempt_id, badge_id, description)
             VALUES (?, ?, ?, ?, ?, ?)'
        );
        $stmt->execute([$userId, $amount, $source, $attemptId, $badgeId, $description]);
    }
}
