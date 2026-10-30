<?php
/**
 * Tabla de rutas de la API.
 * El tercer argumento en true marca la ruta como privada (exige sesión).
 */

declare(strict_types=1);

/** @var Router $router */

$router->get('/health', [HealthController::class, 'show']);

// Autenticación
$router->post('/auth/register', [AuthController::class, 'register']);
$router->post('/auth/login', [AuthController::class, 'login']);
$router->post('/auth/logout', [AuthController::class, 'logout'], true);
$router->get('/auth/me', [AuthController::class, 'me'], true);
