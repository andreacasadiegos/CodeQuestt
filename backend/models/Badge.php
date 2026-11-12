<?php
/**
 * Acceso a las tablas badges y user_badges.
 */

declare(strict_types=1);

final class Badge
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    /** Catálogo completo de insignias. */
    public function all(): array
    {
        $stmt = $this->db->query(
            'SELECT id, code, name, description, icon, rule_type, rule_value, module_id, xp_reward
             FROM badges ORDER BY id'
        );

        return array_map(fn (array $row) => [
            'id'          => (int) $row['id'],
            'code'        => $row['code'],
            'name'        => $row['name'],
            'description' => $row['description'],
            'icon'        => $row['icon'],
            'rule_type'   => $row['rule_type'],
            'rule_value'  => (int) $row['rule_value'],
            'module_id'   => $row['module_id'] === null ? null : (int) $row['module_id'],
            'xp_reward'   => (int) $row['xp_reward'],
        ], $stmt->fetchAll());
    }

    /** @return array<int, string> [badge_id => fecha en que la obtuvo] */
    public function earnedBy(int $userId): array
    {
        $stmt = $this->db->prepare('SELECT badge_id, earned_at FROM user_badges WHERE user_id = ?');
        $stmt->execute([$userId]);

        $result = [];
        foreach ($stmt->fetchAll() as $row) {
            $result[(int) $row['badge_id']] = $row['earned_at'];
        }
        return $result;
    }

    /** Registra la insignia. Devuelve false si el estudiante ya la tenía. */
    public function grant(int $userId, int $badgeId): bool
    {
        $stmt = $this->db->prepare(Database::insertIgnore('user_badges', ['user_id', 'badge_id']));
        $stmt->execute([$userId, $badgeId]);
        return $stmt->rowCount() === 1;
    }
}
