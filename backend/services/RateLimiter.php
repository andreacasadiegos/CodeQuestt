<?php
/**
 * Limitador de solicitudes por ventana fija, guardado en la base de datos.
 *
 * Se usa para frenar ataques de fuerza bruta en el inicio de sesión, el
 * registro masivo de cuentas y la creación repetida de conversaciones.
 * Se guarda en la base (no en la sesión ni en archivos) para que funcione
 * igual en XAMPP, en un VPS con varios procesos PHP-FPM y en Vercel.
 *
 * La tabla api_rate_limits es aditiva: se crea sola la primera vez con
 * CREATE TABLE IF NOT EXISTS y nunca borra datos de otras tablas.
 * Las claves se guardan como hash SHA-256: no contienen correos ni IP.
 */

declare(strict_types=1);

final class RateLimiter
{
    private static bool $tableReady = false;

    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
        $this->ensureTable();
    }

    /** Cuántas veces se usó la clave dentro de la ventana actual. */
    public function hits(string $key, int $windowSeconds): int
    {
        $stmt = $this->db->prepare(
            'SELECT hits FROM api_rate_limits WHERE bucket = ? AND window_start = ?'
        );
        $stmt->execute([self::bucket($key), self::windowStart($windowSeconds)]);

        return (int) ($stmt->fetchColumn() ?: 0);
    }

    public function tooMany(string $key, int $maxHits, int $windowSeconds): bool
    {
        return $this->hits($key, $windowSeconds) >= $maxHits;
    }

    /** Suma un uso a la clave en la ventana actual. */
    public function hit(string $key, int $windowSeconds): void
    {
        $sql = Database::isPostgres()
            ? 'INSERT INTO api_rate_limits (bucket, window_start, hits) VALUES (?, ?, 1)
               ON CONFLICT (bucket, window_start) DO UPDATE SET hits = api_rate_limits.hits + 1'
            : 'INSERT INTO api_rate_limits (bucket, window_start, hits) VALUES (?, ?, 1)
               ON DUPLICATE KEY UPDATE hits = hits + 1';
        $this->db->prepare($sql)->execute([self::bucket($key), self::windowStart($windowSeconds)]);

        // Limpieza ocasional de ventanas viejas (más de un día).
        if (random_int(1, 50) === 1) {
            $this->db->prepare('DELETE FROM api_rate_limits WHERE window_start < ?')
                ->execute([time() - 86400]);
        }
    }

    /** Olvida la clave (por ejemplo, tras un inicio de sesión correcto). */
    public function clear(string $key, int $windowSeconds): void
    {
        $this->db->prepare('DELETE FROM api_rate_limits WHERE bucket = ? AND window_start = ?')
            ->execute([self::bucket($key), self::windowStart($windowSeconds)]);
    }

    /** IP del cliente. Solo confía en X-Forwarded-For si TRUST_PROXY=1. */
    public static function clientIp(): string
    {
        if (getenv('TRUST_PROXY') === '1' && !empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
            $first = trim(explode(',', (string) $_SERVER['HTTP_X_FORWARDED_FOR'])[0]);
            if (filter_var($first, FILTER_VALIDATE_IP)) {
                return $first;
            }
        }

        return (string) ($_SERVER['REMOTE_ADDR'] ?? 'desconocida');
    }

    private static function bucket(string $key): string
    {
        return hash('sha256', $key);
    }

    private static function windowStart(int $windowSeconds): int
    {
        return intdiv(time(), $windowSeconds) * $windowSeconds;
    }

    private function ensureTable(): void
    {
        if (self::$tableReady) {
            return;
        }

        if (Database::isPostgres()) {
            $this->db->exec(
                'CREATE TABLE IF NOT EXISTS api_rate_limits (
                    bucket        CHAR(64) NOT NULL,
                    window_start  INTEGER NOT NULL,
                    hits          INTEGER NOT NULL DEFAULT 0,
                    PRIMARY KEY (bucket, window_start)
                )'
            );
            // Sin políticas: la API pública de Supabase no puede leerla.
            $this->db->exec('ALTER TABLE api_rate_limits ENABLE ROW LEVEL SECURITY');
        } else {
            $this->db->exec(
                'CREATE TABLE IF NOT EXISTS api_rate_limits (
                    bucket        CHAR(64) NOT NULL,
                    window_start  INT UNSIGNED NOT NULL,
                    hits          INT UNSIGNED NOT NULL DEFAULT 0,
                    PRIMARY KEY (bucket, window_start)
                ) ENGINE=InnoDB'
            );
        }

        self::$tableReady = true;
    }
}
