<?php
/**
 * Acceso a la tabla activities.
 */

declare(strict_types=1);

final class Activity
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    /** La actividad de tipo diagnóstico (solo existe una). */
    public function findDiagnostic(): ?array
    {
        $stmt = $this->db->query(
            "SELECT id, title, description, pass_pct FROM activities WHERE kind = 'diagnostico' ORDER BY id LIMIT 1"
        );
        return $stmt->fetch() ?: null;
    }

    /**
     * Actividades de un módulo (sin diagnóstico) visibles para una ruta,
     * de menor a mayor dificultad.
     *
     * @return array<int, array>
     */
    public function forModule(int $moduleId, int $pathId): array
    {
        $stmt = $this->db->prepare(
            "SELECT id, module_id, lesson_id, title, kind, difficulty, base_xp, pass_pct
             FROM activities
             WHERE module_id = ? AND kind <> 'diagnostico' AND (path_id IS NULL OR path_id = ?)
             ORDER BY CASE kind WHEN 'practica' THEN 1 WHEN 'evaluacion' THEN 2 ELSE 3 END, difficulty, sort_order, id"
        );
        $stmt->execute([$moduleId, $pathId]);

        return array_map([$this, 'format'], $stmt->fetchAll());
    }

    /** Actividad de un módulo visible para la ruta (nunca el diagnóstico). */
    public function findForPath(int $id, int $pathId): ?array
    {
        $stmt = $this->db->prepare(
            "SELECT id, module_id, lesson_id, title, kind, difficulty, base_xp, pass_pct
             FROM activities
             WHERE id = ? AND kind <> 'diagnostico' AND (path_id IS NULL OR path_id = ?)"
        );
        $stmt->execute([$id, $pathId]);
        $row = $stmt->fetch();

        return $row ? $this->format($row) : null;
    }

    /** Práctica asociada a una lección, si existe. */
    public function practiceForLesson(int $lessonId): ?int
    {
        $stmt = $this->db->prepare(
            "SELECT id FROM activities WHERE lesson_id = ? AND kind = 'practica' ORDER BY id LIMIT 1"
        );
        $stmt->execute([$lessonId]);
        $id = $stmt->fetchColumn();

        return $id === false ? null : (int) $id;
    }

    private function format(array $row): array
    {
        return [
            'id'         => (int) $row['id'],
            'module_id'  => (int) $row['module_id'],
            'lesson_id'  => $row['lesson_id'] === null ? null : (int) $row['lesson_id'],
            'title'      => $row['title'],
            'kind'       => $row['kind'],
            'difficulty' => (int) $row['difficulty'],
            'base_xp'    => (int) $row['base_xp'],
            'pass_pct'   => (int) $row['pass_pct'],
        ];
    }
}
