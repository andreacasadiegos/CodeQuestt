<?php
/**
 * Consultas de solo lectura para el panel de administración.
 * SQL estándar: funciona igual en MySQL y en PostgreSQL.
 */

declare(strict_types=1);

final class AdminReport
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    /** Una fila por estudiante con su resumen de resultados. */
    public function students(): array
    {
        $rows = $this->db->query(
            "SELECT u.id, u.full_name, u.email, u.xp_total, u.created_at,
                    l.number AS level_number, l.name AS level_name,
                    p.code AS path_code, p.name AS path_name,
                    (SELECT COUNT(DISTINCT t.activity_id) FROM attempts t
                       JOIN activities a ON a.id = t.activity_id
                      WHERE t.user_id = u.id AND t.passed = 1 AND a.kind <> 'diagnostico') AS activities_passed,
                    (SELECT COUNT(*) FROM attempts t
                       JOIN activities a ON a.id = t.activity_id
                      WHERE t.user_id = u.id AND a.kind <> 'diagnostico') AS attempts_count,
                    (SELECT AVG(t.score_pct) FROM attempts t
                       JOIN activities a ON a.id = t.activity_id
                      WHERE t.user_id = u.id AND a.kind <> 'diagnostico') AS average_score,
                    (SELECT COUNT(*) FROM user_badges b WHERE b.user_id = u.id) AS badges,
                    (SELECT COUNT(*) FROM module_progress mp
                      WHERE mp.user_id = u.id AND mp.status = 'completado') AS modules_completed,
                    (SELECT MAX(t.submitted_at) FROM attempts t WHERE t.user_id = u.id) AS last_activity
             FROM users u
             JOIN levels l ON l.id = u.level_id
             LEFT JOIN learning_paths p ON p.id = u.path_id
             WHERE u.role <> 'admin'
             ORDER BY u.full_name"
        )->fetchAll();

        return array_map(fn (array $r) => [
            'id'                => (int) $r['id'],
            'full_name'         => $r['full_name'],
            'email'             => $r['email'],
            'xp_total'          => (int) $r['xp_total'],
            'level'             => ['number' => (int) $r['level_number'], 'name' => $r['level_name']],
            'path'              => $r['path_code'] === null ? null : ['code' => $r['path_code'], 'name' => $r['path_name']],
            'activities_passed' => (int) $r['activities_passed'],
            'attempts'          => (int) $r['attempts_count'],
            'average_score'     => $r['average_score'] === null ? null : (int) round((float) $r['average_score']),
            'badges'            => (int) $r['badges'],
            'modules_completed' => (int) $r['modules_completed'],
            'last_activity'     => $r['last_activity'],
            'created_at'        => $r['created_at'],
        ], $rows);
    }

    /** Número de actividades que cuentan para el avance (sin el diagnóstico). */
    public function activitiesTotal(): int
    {
        return (int) $this->db->query("SELECT COUNT(*) FROM activities WHERE kind <> 'diagnostico'")->fetchColumn();
    }

    /** Resultado del diagnóstico de un estudiante, o null. */
    public function diagnostic(int $userId): ?array
    {
        $stmt = $this->db->prepare(
            'SELECT d.experience_option, d.test_score, d.completed_at, p.name AS path_name
             FROM diagnostics d JOIN learning_paths p ON p.id = d.assigned_path_id
             WHERE d.user_id = ?'
        );
        $stmt->execute([$userId]);
        $row = $stmt->fetch();

        return $row ? [
            'experience_option' => (int) $row['experience_option'],
            'test_score'        => (int) $row['test_score'],
            'assigned_path'     => $row['path_name'],
            'completed_at'      => $row['completed_at'],
        ] : null;
    }

    /** Avance guardado del estudiante en cada módulo. */
    public function modules(int $userId): array
    {
        $stmt = $this->db->prepare(
            "SELECT m.id, m.name, m.icon, COALESCE(mp.percent, 0) AS percent,
                    COALESCE(mp.status, 'no_iniciado') AS status
             FROM modules m
             LEFT JOIN module_progress mp ON mp.module_id = m.id AND mp.user_id = ?
             ORDER BY m.sort_order, m.id"
        );
        $stmt->execute([$userId]);

        return array_map(fn (array $r) => [
            'id'      => (int) $r['id'],
            'name'    => $r['name'],
            'icon'    => $r['icon'],
            'percent' => (int) $r['percent'],
            'status'  => $r['status'],
        ], $stmt->fetchAll());
    }

    /** Insignias obtenidas, de la más reciente a la más antigua. */
    public function badges(int $userId): array
    {
        $stmt = $this->db->prepare(
            'SELECT b.name, b.icon, ub.earned_at
             FROM user_badges ub JOIN badges b ON b.id = ub.badge_id
             WHERE ub.user_id = ? ORDER BY ub.earned_at DESC, b.id'
        );
        $stmt->execute([$userId]);

        return $stmt->fetchAll();
    }
}
