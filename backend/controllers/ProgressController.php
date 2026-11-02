<?php
/**
 * Progreso detallado.
 *
 * GET /api/progress   (privada) Avance por módulo, mejor resultado e
 *                     intentos de cada actividad, historial de intentos
 *                     y movimientos de XP (RF-28, RF-29).
 */

declare(strict_types=1);

final class ProgressController
{
    public function show(array $params): never
    {
        $userId = $params['userId'];
        $pathId = PathMiddleware::requirePath($userId);
        $progress = new ProgressService();

        $modules = array_map(fn (array $module) => $module + [
            'progress'   => $progress->moduleSummary($userId, $module['id'], $pathId),
            'activities' => $progress->activitiesWithState($userId, $module['id'], $pathId),
        ], (new Module())->all());

        Response::json([
            'modules'    => $modules,
            'attempts'   => (new Attempt())->history($userId),
            'xp_history' => (new XpTransaction())->forUser($userId),
        ]);
    }
}
