<?php
/**
 * Conexión única a MySQL mediante PDO.
 *
 * - Errores como excepciones.
 * - Consultas preparadas reales (sin emulación).
 * - Resultados como arreglos asociativos.
 *
 * Funciona con MySQL (XAMPP) o con PostgreSQL (Supabase), según
 * 'driver' en config.php.
 */

declare(strict_types=1);

final class Database
{
    private static ?PDO $connection = null;

    public static function connection(): PDO
    {
        if (self::$connection === null) {
            $db = Config::get('db');

            if (self::isPostgres()) {
                $dsn = sprintf(
                    'pgsql:host=%s;port=%d;dbname=%s;sslmode=%s',
                    $db['host'],
                    $db['port'],
                    $db['name'],
                    $db['sslmode'] ?? 'require'
                );
            } else {
                $dsn = sprintf(
                    'mysql:host=%s;port=%d;dbname=%s;charset=%s',
                    $db['host'],
                    $db['port'],
                    $db['name'],
                    $db['charset'] ?? 'utf8mb4'
                );
            }

            self::$connection = new PDO($dsn, $db['user'], $db['password'], [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
            ]);

            if (self::isPostgres()) {
                // Las fechas se guardan en la hora local de la aplicación,
                // igual que en MySQL (Supabase usa UTC por defecto).
                $stmt = self::$connection->prepare('SELECT set_config(\'TimeZone\', ?, false)');
                $stmt->execute([Config::get('app')['timezone']]);
            }
        }

        return self::$connection;
    }

    /** true si config.php usa PostgreSQL (Supabase). */
    public static function isPostgres(): bool
    {
        return (Config::get('db')['driver'] ?? 'mysql') === 'pgsql';
    }

    /**
     * "Insertar si no existe": INSERT IGNORE en MySQL,
     * ON CONFLICT DO NOTHING en PostgreSQL.
     */
    public static function insertIgnore(string $table, array $columns): string
    {
        $cols = implode(', ', $columns);
        $marks = implode(', ', array_fill(0, count($columns), '?'));

        return self::isPostgres()
            ? "INSERT INTO $table ($cols) VALUES ($marks) ON CONFLICT DO NOTHING"
            : "INSERT IGNORE INTO $table ($cols) VALUES ($marks)";
    }
}
