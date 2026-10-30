<?php
/**
 * Protección de rutas privadas.
 *
 * Si no hay un estudiante con sesión activa, responde 401 y la
 * petición no llega al controlador.
 */

declare(strict_types=1);

final class AuthMiddleware
{
    /** Devuelve el id del estudiante autenticado o corta con 401. */
    public static function requireUser(): int
    {
        $userId = Session::userId();

        if ($userId === null || !(new User())->exists($userId)) {
            Response::error('Debes iniciar sesión para continuar.', 401);
        }

        return $userId;
    }
}
