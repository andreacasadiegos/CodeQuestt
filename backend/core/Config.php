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
            if (!is_file($file)) {
                throw new RuntimeException('Falta backend/config/config.php. Copia config.example.php como config.php.');
            }
            self::$values = require $file;
        }

        return self::$values[$key] ?? null;
    }
}
