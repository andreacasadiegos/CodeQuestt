<?php
/**
 * CodeQuest API - Punto de entrada único.
 *
 * Todas las peticiones a /api/... llegan aquí gracias a .htaccess.
 * En la Etapa 3 esta lógica se trasladará a core/Router.php; por ahora
 * solo existe el endpoint de salud para comprobar que PHP responde.
 */

declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');

// Ruta pedida, sin la carpeta donde vive la API.
// Ej.: /codequest/backend/api/health  ->  /health
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?? '/';
$baseDir = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'])), '/');
$path = '/' . trim(substr($uri, strlen($baseDir)), '/');
$method = $_SERVER['REQUEST_METHOD'];

// GET /api/health -> confirma que el backend está activo.
if ($method === 'GET' && $path === '/health') {
    echo json_encode([
        'status'  => 'ok',
        'mensaje' => 'La API de CodeQuest está funcionando',
        'php'     => PHP_VERSION,
        'fecha'   => date('c'),
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

http_response_code(404);
echo json_encode([
    'status' => 'error',
    'error'  => 'Ruta no encontrada: ' . $method . ' ' . $path,
], JSON_UNESCAPED_UNICODE);
