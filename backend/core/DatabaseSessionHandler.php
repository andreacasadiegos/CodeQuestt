<?php
/**
 * Sesiones PHP guardadas en la base de datos (tabla php_sessions).
 *
 * Se usa en Vercel: cada petición puede atenderla un servidor distinto y
 * los archivos no se conservan, así que la sesión no puede vivir en disco.
 * La tabla se crea sola la primera vez.
 */

declare(strict_types=1);

final class DatabaseSessionHandler implements SessionHandlerInterface, SessionUpdateTimestampHandlerInterface
{
    private static bool $tableReady = false;

    private function db(): PDO
    {
        $db = Database::connection();

        if (!self::$tableReady) {
            if (Database::isPostgres()) {
                $db->exec(
                    'CREATE TABLE IF NOT EXISTS php_sessions (
                        id          VARCHAR(128) PRIMARY KEY,
                        data        TEXT NOT NULL,
                        updated_at  INTEGER NOT NULL
                    )'
                );
                // Sin políticas: la API pública de Supabase no puede leerla.
                $db->exec('ALTER TABLE php_sessions ENABLE ROW LEVEL SECURITY');
            } else {
                $db->exec(
                    'CREATE TABLE IF NOT EXISTS php_sessions (
                        id          VARCHAR(128) NOT NULL PRIMARY KEY,
                        data        MEDIUMTEXT NOT NULL,
                        updated_at  INT UNSIGNED NOT NULL
                    ) ENGINE=InnoDB'
                );
            }
            self::$tableReady = true;
        }

        return $db;
    }

    public function open(string $path, string $name): bool
    {
        return true;
    }

    public function close(): bool
    {
        return true;
    }

    public function read(string $id): string|false
    {
        $stmt = $this->db()->prepare('SELECT data FROM php_sessions WHERE id = ?');
        $stmt->execute([$id]);
        $data = $stmt->fetchColumn();

        return $data === false ? '' : (string) $data;
    }

    public function write(string $id, string $data): bool
    {
        $sql = Database::isPostgres()
            ? 'INSERT INTO php_sessions (id, data, updated_at) VALUES (?, ?, ?)
               ON CONFLICT (id) DO UPDATE SET data = EXCLUDED.data, updated_at = EXCLUDED.updated_at'
            : 'INSERT INTO php_sessions (id, data, updated_at) VALUES (?, ?, ?)
               ON DUPLICATE KEY UPDATE data = VALUES(data), updated_at = VALUES(updated_at)';

        return $this->db()->prepare($sql)->execute([$id, $data, time()]);
    }

    public function destroy(string $id): bool
    {
        return $this->db()->prepare('DELETE FROM php_sessions WHERE id = ?')->execute([$id]);
    }

    public function gc(int $max_lifetime): int|false
    {
        $stmt = $this->db()->prepare('DELETE FROM php_sessions WHERE updated_at < ?');
        $stmt->execute([time() - $max_lifetime]);

        return $stmt->rowCount();
    }

    /** Con use_strict_mode, PHP solo acepta identificadores que existan. */
    public function validateId(string $id): bool
    {
        $stmt = $this->db()->prepare('SELECT 1 FROM php_sessions WHERE id = ?');
        $stmt->execute([$id]);

        return (bool) $stmt->fetchColumn();
    }

    public function updateTimestamp(string $id, string $data): bool
    {
        return $this->db()->prepare('UPDATE php_sessions SET updated_at = ? WHERE id = ?')->execute([time(), $id]);
    }
}
