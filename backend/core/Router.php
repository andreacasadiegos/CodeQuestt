<?php
/**
 * Enrutador sencillo.
 *
 * Asocia un método HTTP y una ruta (con parámetros como {id}) a un
 * controlador. Las rutas privadas pasan antes por AuthMiddleware.
 */

declare(strict_types=1);

final class Router
{
    /** @var array<int, array{method: string, regex: string, handler: array, private: bool}> */
    private array $routes = [];

    public function get(string $pattern, array $handler, bool $private = false): void
    {
        $this->add('GET', $pattern, $handler, $private);
    }

    public function post(string $pattern, array $handler, bool $private = false): void
    {
        $this->add('POST', $pattern, $handler, $private);
    }

    private function add(string $method, string $pattern, array $handler, bool $private): void
    {
        // /lessons/{id} -> #^/lessons/(?P<id>[^/]+)$#
        $regex = '#^' . preg_replace('#\{(\w+)\}#', '(?P<$1>[^/]+)', $pattern) . '$#';

        $this->routes[] = [
            'method'  => $method,
            'regex'   => $regex,
            'handler' => $handler,
            'private' => $private,
        ];
    }

    public function dispatch(string $method, string $path): never
    {
        $pathExists = false;

        foreach ($this->routes as $route) {
            if (!preg_match($route['regex'], $path, $matches)) {
                continue;
            }

            $pathExists = true;
            if ($route['method'] !== $method) {
                continue;
            }

            $params = array_filter($matches, 'is_string', ARRAY_FILTER_USE_KEY);

            if ($route['private']) {
                $params['userId'] = AuthMiddleware::requireUser();
            }

            [$class, $action] = $route['handler'];
            (new $class())->$action($params);

            // Todo controlador termina con Response::json o Response::error.
            Response::error('El controlador no devolvió respuesta.', 500);
        }

        if ($pathExists) {
            Response::error('Método no permitido.', 405);
        }

        Response::error('Ruta no encontrada: ' . $method . ' ' . $path, 404);
    }
}
