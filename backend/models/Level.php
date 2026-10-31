<?php
/**
 * Acceso a la tabla levels.
 */

declare(strict_types=1);

final class Level
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    /** Nivel que corresponde a una cantidad de XP. */
    public function forXp(int $xp): array
    {
        $stmt = $this->db->prepare(
            'SELECT id, number, name, min_xp FROM levels WHERE min_xp <= ? ORDER BY min_xp DESC LIMIT 1'
        );
        $stmt->execute([$xp]);
        return $this->format($stmt->fetch());
    }

    /** Siguiente nivel, o null si ya está en el máximo. */
    public function next(int $number): ?array
    {
        $stmt = $this->db->prepare(
            'SELECT id, number, name, min_xp FROM levels WHERE number > ? ORDER BY number LIMIT 1'
        );
        $stmt->execute([$number]);
        $row = $stmt->fetch();
        return $row ? $this->format($row) : null;
    }

    private function format(array $row): array
    {
        return [
            'id'     => (int) $row['id'],
            'number' => (int) $row['number'],
            'name'   => $row['name'],
            'min_xp' => (int) $row['min_xp'],
        ];
    }
}
