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

    /** Últimos movimientos de XP del estudiante. */
    public function forUser(int $userId, int $limit = 20): array
    {
        $stmt = $this->db->prepare(
            'SELECT id, amount, source, description, created_at
             FROM xp_transactions WHERE user_id = ? ORDER BY id DESC LIMIT ?'
        );
        $stmt->bindValue(1, $userId, PDO::PARAM_INT);
        $stmt->bindValue(2, $limit, PDO::PARAM_INT);
        $stmt->execute();

        return array_map(fn (array $row) => [
            'id'          => (int) $row['id'],
            'amount'      => (int) $row['amount'],
            'source'      => $row['source'],
            'description' => $row['description'],
            'created_at'  => $row['created_at'],
        ], $stmt->fetchAll());
    }
}
