<?php
/**
 * Panel del estudiante.
 *
 * GET /api/dashboard   (privada) Resumen: nivel y XP, actividades completadas,
 *                      insignias, retos disponibles, módulos y avance de ruta.
 */

declare(strict_types=1);

final class DashboardController
{
    public function show(array $params): never
    {
        $userId = $params['userId'];
        $pathId = PathMiddleware::requirePath($userId);
        $progress = new ProgressService();

        $modules = [];
        $retos = [];
        $activitiesTotal = 0;
        $activitiesPassed = 0;
        foreach ((new Module())->all() as $module) {
            $activities = $progress->activitiesWithState($userId, $module['id'], $pathId);
            $activitiesTotal += count($activities);
            $activitiesPassed += count(array_filter($activities, fn ($a) => $a['passed']));
            $modules[] = $module + ['progress' => $progress->moduleSummary($userId, $module['id'], $pathId)];

            foreach ($activities as $activity) {
                if ($activity['kind'] === 'reto') {
                    $retos[] = [
                        'id'          => $activity['id'],
                        'title'       => $activity['title'],
                        'base_xp'     => $activity['base_xp'],
                        'locked'      => $activity['locked'],
                        'passed'      => $activity['passed'],
                        'best_score'  => $activity['best_score'],
                        'module'      => ['slug' => $module['slug'], 'name' => $module['name'], 'icon' => $module['icon']],
                    ];
                }
            }
        }

        $badges = (new BadgeService())->progressFor($userId);
        $earned = array_values(array_filter($badges, fn ($b) => $b['earned']));
        usort($earned, fn ($a, $b) => strcmp($b['earned_at'], $a['earned_at']));
        $stats = (new Attempt())->stats($userId);

        Response::json([
            'user'  => (new User())->findProfile($userId),
            'xp'    => (new XpService())->state($userId),
            'stats' => [
                'activities_completed' => $activitiesPassed, // de la ruta actual
                'activities_total'     => $activitiesTotal,
                'badges_earned'        => count($earned),
                'badges_total'         => count($badges),
                'retos_completed'      => $stats['retos'],
            ],
            'recent_badges' => array_slice($earned, 0, 3),
            'retos'         => $retos,
            'modules'       => $modules,
            'path_advance'  => (new PathAdvanceService())->status($userId, $pathId),
        ]);
    }
}
