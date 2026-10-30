<?php
/**
 * Acceso a la tabla users.
 * Todas las consultas son preparadas.
 */

declare(strict_types=1);

final class User
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    public function emailExists(string $email): bool
    {
        $stmt = $this->db->prepare('SELECT 1 FROM users WHERE email = ? LIMIT 1');
        $stmt->execute([$email]);
        return (bool) $stmt->fetchColumn();
    }

    public function exists(int $id): bool
    {
        $stmt = $this->db->prepare('SELECT 1 FROM users WHERE id = ? LIMIT 1');
        $stmt->execute([$id]);
        return (bool) $stmt->fetchColumn();
    }

    /** Crea el estudiante y devuelve su id. Recibe la contraseña ya cifrada. */
    public function create(string $fullName, string $email, string $passwordHash): int
    {
        $stmt = $this->db->prepare(
            'INSERT INTO users (full_name, email, password_hash) VALUES (?, ?, ?)'
        );
        $stmt->execute([$fullName, $email, $passwordHash]);
        return (int) $this->db->lastInsertId();
    }

    /** Datos mínimos para validar el inicio de sesión. */
    public function findCredentialsByEmail(string $email): ?array
    {
        $stmt = $this->db->prepare('SELECT id, password_hash FROM users WHERE email = ? LIMIT 1');
        $stmt->execute([$email]);
        return $stmt->fetch() ?: null;
    }

    public function updatePasswordHash(int $id, string $passwordHash): void
    {
        $stmt = $this->db->prepare('UPDATE users SET password_hash = ? WHERE id = ?');
        $stmt->execute([$passwordHash, $id]);
    }

    /**
     * Perfil público del estudiante (sin contraseña), con su ruta y nivel.
     */
    public function findProfile(int $id): ?array
    {
        $stmt = $this->db->prepare(
            'SELECT u.id, u.full_name, u.email, u.xp_total, u.created_at,
                    l.number AS level_number, l.name AS level_name,
                    p.code AS path_code, p.name AS path_name
             FROM users u
             JOIN levels l ON l.id = u.level_id
             LEFT JOIN learning_paths p ON p.id = u.path_id
             WHERE u.id = ?'
        );
        $stmt->execute([$id]);
        $row = $stmt->fetch();

        if (!$row) {
            return null;
        }

        return [
            'id'               => (int) $row['id'],
            'full_name'        => $row['full_name'],
            'email'            => $row['email'],
            'xp_total'         => (int) $row['xp_total'],
            'level'            => ['number' => (int) $row['level_number'], 'name' => $row['level_name']],
            'path'             => $row['path_code'] === null
                ? null
                : ['code' => $row['path_code'], 'name' => $row['path_name']],
            'needs_diagnostic' => $row['path_code'] === null,
            'created_at'       => $row['created_at'],
        ];
    }
}
