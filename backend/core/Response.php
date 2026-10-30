<?php
/**
 * Respuestas JSON uniformes de la API.
 *
 * Éxito:  { "status": "ok", "data": { ... } }
 * Error:  { "status": "error", "error": "mensaje", "errors": { "campo": "mensaje" } }
 */

declare(strict_types=1);

final class Response
{
    public static function json(array $data, int $status = 200): never
    {
        http_response_code($status);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['status' => 'ok', 'data' => $data], JSON_UNESCAPED_UNICODE);
        exit;
    }

    public static function error(string $message, int $status = 400, array $errors = []): never
    {
        http_response_code($status);
        header('Content-Type: application/json; charset=utf-8');

        $body = ['status' => 'error', 'error' => $message];
        if ($errors !== []) {
            $body['errors'] = $errors;
        }

        echo json_encode($body, JSON_UNESCAPED_UNICODE);
        exit;
    }
}
