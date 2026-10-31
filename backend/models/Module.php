<?php
/**
 * Acceso a la tabla modules.
 */

declare(strict_types=1);

final class Module
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    /** @return array<int, array> */
    public function all(): array
    {
        $rows = $this->db->query(
            'SELECT id, slug, name, description, icon, sort_order FROM modules ORDER BY sort_order, id'
        )->fetchAll();

        return array_map([$this, 'format'], $rows);
    }

    public function findBySlug(string $slug): ?array
    {
        $stmt = $this->db->prepare(
            'SELECT id, slug, name, description, icon, sort_order FROM modules WHERE slug = ?'
        );
        $stmt->execute([$slug]);
        $row = $stmt->fetch();

        return $row ? $this->format($row) : null;
    }

    private function format(array $row): array
    {
        return [
            'id'          => (int) $row['id'],
            'slug'        => $row['slug'],
            'name'        => $row['name'],
            'description' => $row['description'],
            'icon'        => $row['icon'],
            'sort_order'  => (int) $row['sort_order'],
        ];
    }
}
