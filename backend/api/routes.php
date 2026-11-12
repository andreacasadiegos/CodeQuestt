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
$router->get('/auth/me', [AuthController::class, 'me']); // Pública: devuelve user = null sin sesión.

// Diagnóstico inicial
$router->get('/diagnostic', [DiagnosticController::class, 'show'], true);
$router->post('/diagnostic', [DiagnosticController::class, 'submit'], true);

// Módulos y lecciones
$router->get('/modules', [ModuleController::class, 'index'], true);
$router->get('/modules/{slug}', [ModuleController::class, 'show'], true);
$router->get('/lessons/{id}', [LessonController::class, 'show'], true);
$router->post('/lessons/{id}/complete', [LessonController::class, 'complete'], true);

// Actividades
$router->get('/activities/{id}', [ActivityController::class, 'show'], true);
$router->post('/activities/{id}/submit', [ActivityController::class, 'submit'], true);

// Gamificación y seguimiento
$router->get('/dashboard', [DashboardController::class, 'show'], true);
$router->get('/badges', [BadgeController::class, 'index'], true);
$router->get('/progress', [ProgressController::class, 'show'], true);
$router->post('/path/advance', [PathController::class, 'advance'], true);

// Administración (solo rol admin)
$router->get('/admin/students', [AdminController::class, 'students'], true);
$router->get('/admin/students/{id}', [AdminController::class, 'student'], true);
