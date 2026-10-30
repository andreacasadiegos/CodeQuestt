<?php
/**
 * GET /api/health
 * Comprueba que PHP responde y que la base de datos está disponible.
 */

declare(strict_types=1);

final class HealthController
{
    public function show(array $params): never
    {
        try {
            Database::connection()->query('SELECT 1');
            $database = 'conectada';
        } catch (PDOException) {
            $database = 'sin conexión';
        }

        Response::json([
            'mensaje'  => 'La API de CodeQuest está funcionando',
            'php'      => PHP_VERSION,
            'database' => $database,
            'fecha'    => date('c'),
        ]);
    }
}
