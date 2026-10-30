<?php
/**
 * Datos de la petición HTTP actual.
 */

declare(strict_types=1);

final class Request
{
    private static ?array $body = null;

    public static function method(): string
    {
        return strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET');
    }

    /**
     * Ruta pedida, sin la carpeta donde vive la API.
     * Ej.: /codequest/backend/api/auth/login  ->  /auth/login
     */
    public static function path(): string
    {
        $uri = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?? '/';
        $baseDir = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'])), '/');

        if ($baseDir !== '' && str_starts_with($uri, $baseDir)) {
            $uri = substr($uri, strlen($baseDir));
        }

        return '/' . trim($uri, '/');
    }

    /**
     * Cuerpo JSON de la petición como arreglo.
     * Las peticiones que envían datos deben usar Content-Type: application/json;
     * esto también impide que un formulario de otro sitio envíe datos a la API.
     */
    public static function json(): array
    {
        if (self::$body !== null) {
            return self::$body;
        }

        $contentType = $_SERVER['CONTENT_TYPE'] ?? '';
        if (!str_contains(strtolower($contentType), 'application/json')) {
            Response::error('El cuerpo debe enviarse como JSON (Content-Type: application/json).', 415);
        }

        $data = json_decode(file_get_contents('php://input') ?: '', true);
        if (!is_array($data)) {
            Response::error('El cuerpo de la petición no es un JSON válido.', 400);
        }

        return self::$body = $data;
    }

    /** Valor de texto del cuerpo, sin espacios al inicio y al final. */
    public static function string(string $key): string
    {
        $value = self::json()[$key] ?? '';
        return is_string($value) ? trim($value) : '';
    }
}
