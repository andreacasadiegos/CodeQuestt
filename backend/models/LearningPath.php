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

    /** Ruta por id, con la regla de avance (advance_min_pct). */
    public function find(int $id): ?array
    {
        $stmt = $this->db->prepare(
            'SELECT id, code, name, advance_min_pct, sort_order FROM learning_paths WHERE id = ?'
        );
        $stmt->execute([$id]);
        $row = $stmt->fetch();

        return $row ? $this->format($row) : null;
    }

    /** Ruta que sigue a otra según sort_order (la intermedia después de la básica). */
    public function next(int $id): ?array
    {
        $stmt = $this->db->prepare(
            'SELECT id, code, name, advance_min_pct, sort_order FROM learning_paths
             WHERE sort_order > (SELECT sort_order FROM learning_paths WHERE id = ?)
             ORDER BY sort_order LIMIT 1'
        );
        $stmt->execute([$id]);
        $row = $stmt->fetch();

        return $row ? $this->format($row) : null;
    }

    private function format(array $row): array
    {
        return [
            'id'              => (int) $row['id'],
            'code'            => $row['code'],
            'name'            => $row['name'],
            'advance_min_pct' => $row['advance_min_pct'] === null ? null : (int) $row['advance_min_pct'],
        ];
    }
}
