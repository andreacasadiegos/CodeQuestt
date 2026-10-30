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
}
