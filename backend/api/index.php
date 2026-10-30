<?php
/**
 * CodeQuest API - Punto de entrada único.
 *
 * Todas las peticiones a /api/... llegan aquí gracias a .htaccess:
 * se cargan las clases, se inicia la sesión y el enrutador
 * envía la petición al controlador correspondiente.
 */

declare(strict_types=1);

// Carga automática de clases desde las carpetas del backend.
spl_autoload_register(function (string $class): void {
    foreach (['core', 'controllers', 'models', 'services', 'middleware'] as $dir) {
        $file = __DIR__ . "/../$dir/$class.php";
        if (is_file($file)) {
            require $file;
            return;
        }
    }
});

// Los errores nunca se imprimen en la respuesta: se registran y se
// devuelve un JSON genérico (con detalle solo en desarrollo).
ini_set('display_errors', '0');
error_reporting(E_ALL);

set_exception_handler(function (Throwable $e): void {
    error_log('[CodeQuest] ' . $e);
    try {
        $detail = Config::get('app')['env'] === 'development' ? $e->getMessage() : null;
    } catch (Throwable) {
        $detail = $e->getMessage(); // Sin config.php no hay entorno: se muestra la causa.
    }
    Response::error('Ocurrió un error en el servidor.' . ($detail ? " ($detail)" : ''), 500);
});

set_error_handler(function (int $severity, string $message, string $file, int $line): bool {
    throw new ErrorException($message, 0, $severity, $file, $line);
});

date_default_timezone_set(Config::get('app')['timezone']);
header('X-Content-Type-Options: nosniff');

Session::start();

$router = new Router();
require __DIR__ . '/routes.php';
$router->dispatch(Request::method(), Request::path());
