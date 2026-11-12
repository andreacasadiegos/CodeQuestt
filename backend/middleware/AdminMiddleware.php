<?php
/**
 * Rutas de administración: además de la sesión, exige el rol admin.
 */

declare(strict_types=1);

final class AdminMiddleware
{
    public static function requireAdmin(int $userId): void
    {
        if ((new User())->role($userId) !== 'admin') {
            Response::error('Esta sección es solo para administradores.', 403);
        }
    }
}
