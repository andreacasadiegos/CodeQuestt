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
     * Configuración a partir de variables de entorno (Vercel).
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

        return [
            'db' => [
                'driver'   => str_starts_with($scheme, 'mysql') ? 'mysql' : 'pgsql',
                'host'     => $parts['host'],
                'port'     => (int) ($parts['port'] ?? 5432),
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
                'handler'      => 'database',
            ],
        ];
    }
}
