<?php
/**
 * Acceso a las tablas lesson_progress y module_progress, y conteos
 * de actividades aprobadas para calcular el avance.
 */

declare(strict_types=1);

final class Progress
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    /** @return array<int, true> ids de lecciones leídas por el estudiante */
    public function completedLessonIds(int $userId): array
    {
        $stmt = $this->db->prepare('SELECT lesson_id FROM lesson_progress WHERE user_id = ?');
        $stmt->execute([$userId]);

        return array_fill_keys(array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN)), true);
    }

    /** Marca una lección como leída. Si ya lo estaba, no hace nada. */
    public function markLessonCompleted(int $userId, int $lessonId): void
    {
        $stmt = $this->db->prepare(
            'INSERT IGNORE INTO lesson_progress (user_id, lesson_id) VALUES (?, ?)'
        );
        $stmt->execute([$userId, $lessonId]);
    }

    /**
     * Actividades del módulo (sin contar el diagnóstico) visibles para la ruta,
     * y cuántas de ellas ha aprobado el estudiante.
     *
     * @return array{total: int, passed: int}
     */
    public function activityCounts(int $userId, int $moduleId, int $pathId): array
    {
        $stmt = $this->db->prepare(
            "SELECT COUNT(*) AS total,
                    COALESCE(SUM(EXISTS (
                        SELECT 1 FROM attempts t
                        WHERE t.user_id = ? AND t.activity_id = a.id AND t.passed = 1
                    )), 0) AS passed
             FROM activities a
             WHERE a.module_id = ? AND a.kind <> 'diagnostico'
               AND (a.path_id IS NULL OR a.path_id = ?)"
        );
        $stmt->execute([$userId, $moduleId, $pathId]);
        $row = $stmt->fetch();

        return ['total' => (int) $row['total'], 'passed' => (int) $row['passed']];
    }

    /** Guarda el avance del módulo (crea la fila la primera vez). */
    public function saveModuleProgress(int $userId, int $moduleId, int $percent, string $status): void
    {
        $stmt = $this->db->prepare(
            "INSERT INTO module_progress (user_id, module_id, percent, status, started_at, completed_at)
             VALUES (?, ?, ?, ?, IF(? <> 'no_iniciado', NOW(), NULL), IF(? = 'completado', NOW(), NULL))
             ON DUPLICATE KEY UPDATE
                percent      = VALUES(percent),
                status       = VALUES(status),
                started_at   = COALESCE(started_at, VALUES(started_at)),
                completed_at = IF(VALUES(status) = 'completado', COALESCE(completed_at, NOW()), NULL)"
        );
        $stmt->execute([$userId, $moduleId, $percent, $status, $status, $status]);
    }

    /** @return array<int, true> ids de módulos que el estudiante completó al 100 % */
    public function completedModuleIds(int $userId): array
    {
        $stmt = $this->db->prepare("SELECT module_id FROM module_progress WHERE user_id = ? AND status = 'completado'");
        $stmt->execute([$userId]);
        return array_fill_keys(array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN)), true);
    }
}
