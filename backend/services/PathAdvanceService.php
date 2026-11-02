<?php
/**
 * Avance de ruta (RF-31).
 *
 * Un estudiante de ruta básica pasa a la intermedia cuando aprobó las
 * evaluaciones de los 3 módulos y el promedio de sus mejores puntajes es
 * igual o mayor a learning_paths.advance_min_pct (80 %).
 * El servidor comprueba la regla; el navegador solo pide el cambio.
 */

declare(strict_types=1);

final class PathAdvanceService
{
    /**
     * Estado del avance para el panel.
     *
     * @return array{available: bool, eligible?: bool, required_pct?: int, average?: int,
     *               target?: array, evaluations?: array}
     */
    public function status(int $userId, int $pathId): array
    {
        $paths = new LearningPath();
        $current = $paths->find($pathId);
        $target = $paths->next($pathId);

        if ($current === null || $current['advance_min_pct'] === null || $target === null) {
            return ['available' => false];
        }

        $best = (new Attempt())->bestByActivity($userId);
        $activities = new Activity();
        $evaluations = [];

        foreach ((new Module())->all() as $module) {
            foreach ($activities->forModule($module['id'], $pathId) as $activity) {
                if ($activity['kind'] !== 'evaluacion') {
                    continue;
                }
                $evaluations[] = [
                    'activity_id' => $activity['id'],
                    'module_name' => $module['name'],
                    'best_score'  => $best[$activity['id']]['best_score'] ?? null,
                    'passed'      => $best[$activity['id']]['passed'] ?? false,
                ];
            }
        }

        $scores = array_map(fn ($e) => $e['best_score'] ?? 0, $evaluations);
        $average = $scores === [] ? 0 : (int) floor(array_sum($scores) / count($scores));
        $allPassed = $evaluations !== [] && !in_array(false, array_column($evaluations, 'passed'), true);

        return [
            'available'    => true,
            'eligible'     => $allPassed && $average >= $current['advance_min_pct'],
            'required_pct' => $current['advance_min_pct'],
            'average'      => $average,
            'target'       => ['code' => $target['code'], 'name' => $target['name']],
            'evaluations'  => $evaluations,
        ];
    }

    /**
     * Cambia al estudiante a la siguiente ruta si cumple la regla.
     * Conserva XP, insignias e intentos; recalcula el avance de los módulos.
     *
     * @throws DomainException si no cumple la regla.
     */
    public function advance(int $userId, int $pathId): array
    {
        $db = Database::connection();
        $db->beginTransaction();
        try {
            $users = new User();
            $users->lockForUpdate($userId);

            $status = $this->status($userId, $pathId);
            if (!($status['eligible'] ?? false)) {
                throw new DomainException('Aún no cumples la regla para avanzar de ruta.');
            }

            $target = (new LearningPath())->next($pathId);
            $users->assignPath($userId, $target['id']);

            $progress = new ProgressService();
            foreach ((new Module())->all() as $module) {
                $progress->refreshModule($userId, $module['id'], $target['id']);
            }

            $db->commit();
        } catch (Throwable $e) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }
            throw $e;
        }

        return $target;
    }
}
