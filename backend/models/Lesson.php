<?php
/**
 * Acceso a la tabla lessons.
 * Una lección con path_id NULL pertenece a ambas rutas.
 */

declare(strict_types=1);

final class Lesson
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    /**
     * Lecciones de un módulo visibles para una ruta, en orden.
     *
     * @return array<int, array{id: int, module_id: int, title: string, sort_order: int}>
     */
    public function forModule(int $moduleId, int $pathId): array
    {
        $stmt = $this->db->prepare(
            'SELECT id, module_id, title, sort_order
             FROM lessons
             WHERE module_id = ? AND (path_id IS NULL OR path_id = ?)
             ORDER BY sort_order, id'
        );
        $stmt->execute([$moduleId, $pathId]);

        return array_map(fn (array $r) => [
            'id'         => (int) $r['id'],
            'module_id'  => (int) $r['module_id'],
            'title'      => $r['title'],
            'sort_order' => (int) $r['sort_order'],
        ], $stmt->fetchAll());
    }

    /** Lección completa, solo si es visible para la ruta indicada. */
    public function findForPath(int $id, int $pathId): ?array
    {
        $stmt = $this->db->prepare(
            'SELECT id, module_id, title, content, example, sort_order
             FROM lessons
             WHERE id = ? AND (path_id IS NULL OR path_id = ?)'
        );
        $stmt->execute([$id, $pathId]);
        $row = $stmt->fetch();

        if (!$row) {
            return null;
        }

        return [
            'id'        => (int) $row['id'],
            'module_id' => (int) $row['module_id'],
            'title'     => $row['title'],
            'content'   => $row['content'],
            'example'   => $row['example'],
        ];
    }
}
