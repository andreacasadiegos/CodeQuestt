<?php
/**
 * Exige que el estudiante ya tenga una ruta asignada (diagnóstico hecho).
 */

declare(strict_types=1);

final class PathMiddleware
{
    /** Devuelve el id de la ruta del estudiante o corta con 403. */
    public static function requirePath(int $userId): int
    {
        $pathId = (new User())->pathId($userId);

        if ($pathId === null) {
            Response::error('Primero debes completar el diagnóstico.', 403);
        }

        return $pathId;
    }
}
