<?php
/**
 * Módulos de aprendizaje.
 *
 * GET /api/modules          (privada) Los 3 módulos con el avance del estudiante.
 * GET /api/modules/{slug}   (privada) Un módulo con sus lecciones y actividades según la ruta.
 */

declare(strict_types=1);

final class ModuleController
{
    public function index(array $params): never
    {
        $userId = $params['userId'];
        $pathId = PathMiddleware::requirePath($userId);
        $service = new ProgressService();

        $modules = array_map(
            fn (array $module) => $module + ['progress' => $service->moduleSummary($userId, $module['id'], $pathId)],
            (new Module())->all()
        );

        Response::json(['modules' => $modules]);
    }

    public function show(array $params): never
    {
        $userId = $params['userId'];
        $pathId = PathMiddleware::requirePath($userId);

        $module = (new Module())->findBySlug((string) $params['slug']);
        if ($module === null) {
            Response::error('Ese módulo no existe.', 404);
        }

        $service = new ProgressService();

        Response::json([
            'module'   => $module,
            'progress' => $service->moduleSummary($userId, $module['id'], $pathId),
            'lessons'    => $service->lessonsWithState($userId, $module['id'], $pathId),
            'activities' => $service->activitiesWithState($userId, $module['id'], $pathId),
        ]);
    }
}
