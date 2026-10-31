<?php
/**
 * Lecciones.
 *
 * GET  /api/lessons/{id}            (privada) Contenido de la lección.
 * POST /api/lessons/{id}/complete   (privada) Marca la lección como leída.
 *
 * Solo se puede abrir una lección de la ruta del estudiante y que ya esté
 * desbloqueada (la anterior del módulo debe estar leída).
 */

declare(strict_types=1);

final class LessonController
{
    public function show(array $params): never
    {
        $userId = $params['userId'];
        $pathId = PathMiddleware::requirePath($userId);
        [$lesson, $siblings, $position] = $this->loadAccessible($userId, $pathId, $params['id']);

        $module = $this->moduleById($lesson['module_id']);

        Response::json([
            'lesson' => $lesson + ['completed' => $siblings[$position]['completed']],
            'module' => ['slug' => $module['slug'], 'name' => $module['name'], 'icon' => $module['icon']],
            'position' => $position + 1,
            'total'    => count($siblings),
            'previous_lesson_id' => $siblings[$position - 1]['id'] ?? null,
            'next_lesson_id'     => $siblings[$position + 1]['id'] ?? null,
        ]);
    }

    public function complete(array $params): never
    {
        $userId = $params['userId'];
        $pathId = PathMiddleware::requirePath($userId);
        [$lesson, $siblings, $position] = $this->loadAccessible($userId, $pathId, $params['id']);

        (new Progress())->markLessonCompleted($userId, $lesson['id']);
        $summary = (new ProgressService())->refreshModule($userId, $lesson['module_id'], $pathId);

        Response::json([
            'completed'      => true,
            'progress'       => $summary,
            'next_lesson_id' => $siblings[$position + 1]['id'] ?? null,
        ]);
    }

    /**
     * Carga la lección comprobando ruta y desbloqueo.
     *
     * @return array{0: array, 1: array, 2: int} lección, lecciones del módulo con estado, posición
     */
    private function loadAccessible(int $userId, int $pathId, string $rawId): array
    {
        $id = ctype_digit($rawId) ? (int) $rawId : 0;
        $lesson = (new Lesson())->findForPath($id, $pathId);
        if ($lesson === null) {
            Response::error('Esa lección no existe en tu ruta.', 404);
        }

        $siblings = (new ProgressService())->lessonsWithState($userId, $lesson['module_id'], $pathId);
        $position = (int) array_search($lesson['id'], array_column($siblings, 'id'), true);

        if ($siblings[$position]['locked']) {
            Response::error('Completa la lección anterior para desbloquear esta.', 403);
        }

        return [$lesson, $siblings, $position];
    }

    private function moduleById(int $moduleId): array
    {
        foreach ((new Module())->all() as $module) {
            if ($module['id'] === $moduleId) {
                return $module;
            }
        }
        throw new RuntimeException("Módulo $moduleId no encontrado.");
    }
}
