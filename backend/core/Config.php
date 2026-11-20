<?php
/**
 * Acceso de solo lectura a config/config.php.
 */

declare(strict_types=1);

final class Config
{
    private static ?array $values = null;

    public static function get(string $key): mixed
    {
        if (self::$values === null) {
            $file = __DIR__ . '/../config/config.php';
            if (is_file($file)) {
                self::$values = require $file;
            } elseif (getenv('DATABASE_URL')) {
                self::$values = self::fromEnvironment((string) getenv('DATABASE_URL'));
            } else {
                throw new RuntimeException('Falta backend/config/config.php. Copia config.example.php como config.php.');
            }
        }

        return self::$values[$key] ?? null;
    }

    /**
     * Configuración a partir de variables de entorno (Vercel o VPS).
     * DATABASE_URL es la cadena "Session pooler" de Supabase, por ejemplo:
     * postgresql://postgres.abc:CONTRASEÑA@aws-0-us-east-1.pooler.supabase.com:5432/postgres
     */
    private static function fromEnvironment(string $url): array
    {
        $parts = parse_url($url);
        if ($parts === false || empty($parts['host'])) {
            throw new RuntimeException('DATABASE_URL no tiene un formato válido.');
        }

        $scheme = $parts['scheme'] ?? 'postgresql';
        $isMysql = str_starts_with($scheme, 'mysql') || str_starts_with($scheme, 'mariadb');

        return [
            'db' => [
                'driver'   => $isMysql ? 'mysql' : 'pgsql',
                'host'     => $parts['host'],
                // Puerto por defecto según el motor (antes siempre era 5432).
                'port'     => (int) ($parts['port'] ?? ($isMysql ? 3306 : 5432)),
                'name'     => ltrim($parts['path'] ?? '/postgres', '/') ?: 'postgres',
                'user'     => rawurldecode($parts['user'] ?? 'postgres'),
                'password' => rawurldecode($parts['pass'] ?? ''),
                'sslmode'  => getenv('DB_SSLMODE') ?: 'require',
                'charset'  => 'utf8mb4',
            ],
            'app' => [
                'env'      => getenv('APP_ENV') ?: 'production',
                'timezone' => getenv('APP_TIMEZONE') ?: 'America/Bogota',
            ],
            'session' => [
                'name'         => 'CODEQUESTSESSID',
                'idle_timeout' => 7200,
                // En Vercel cada petición puede ir a un servidor distinto:
                // la sesión se guarda en la base de datos, no en archivos.
                // En un VPS puede usarse SESSION_HANDLER=files.
                'handler'      => getenv('SESSION_HANDLER') ?: 'database',
                // SESSION_COOKIE_SECURE=1 obliga a enviar la cookie solo por HTTPS.
                'secure'       => getenv('SESSION_COOKIE_SECURE') === '1',
            ],
        ];
    }
}
