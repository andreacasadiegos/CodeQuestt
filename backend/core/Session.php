<?php
/**
 * Manejo seguro de la sesión PHP.
 *
 * - Cookie HttpOnly (JavaScript no puede leerla) y SameSite=Lax.
 * - Nuevo identificador al iniciar sesión (evita la fijación de sesión).
 * - Cierre automático tras un tiempo de inactividad.
 */

declare(strict_types=1);

final class Session
{
    public static function start(): void
    {
        if (session_status() === PHP_SESSION_ACTIVE) {
            return;
        }

        $config = Config::get('session');

        if (($config['handler'] ?? 'files') === 'database') {
            session_set_save_handler(new DatabaseSessionHandler(), true);
        }

        ini_set('session.use_strict_mode', '1');
        ini_set('session.use_only_cookies', '1');
        session_name($config['name']);
        session_set_cookie_params([
            'lifetime' => 0,
            'path'     => '/',
            'secure'   => (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
                || ($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https',
            'httponly' => true,
            'samesite' => 'Lax',
        ]);
        session_start();

        // Cierre por inactividad.
        $last = $_SESSION['last_activity'] ?? null;
        if ($last !== null && time() - $last > $config['idle_timeout']) {
            self::destroy();
            session_start();
        }
        // Solo se actualiza cada minuto: así la mayoría de peticiones no
        // reescriben la sesión (importante cuando se guarda en la base).
        if ($last === null || time() - $last >= 60) {
            $_SESSION['last_activity'] = time();
        }
    }

    /** Guarda al usuario en la sesión con un identificador nuevo. */
    public static function login(int $userId): void
    {
        session_regenerate_id(true);
        $_SESSION['user_id'] = $userId;
        $_SESSION['last_activity'] = time();
    }

    public static function userId(): ?int
    {
        return isset($_SESSION['user_id']) ? (int) $_SESSION['user_id'] : null;
    }

    /** Borra los datos, la cookie y la sesión del servidor. */
    public static function destroy(): void
    {
        $_SESSION = [];

        $params = session_get_cookie_params();
        setcookie(session_name(), '', [
            'expires'  => time() - 3600,
            'path'     => $params['path'],
            'secure'   => $params['secure'],
            'httponly' => $params['httponly'],
            'samesite' => $params['samesite'],
        ]);

        session_destroy();
    }
}
