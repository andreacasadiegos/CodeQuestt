<?php
/**
 * Avance del estudiante en los módulos.
 *
 * - Las lecciones se desbloquean en orden: la primera siempre está
 *   disponible y cada una se abre al leer la anterior (RF-17).
 * - La práctica de una lección se abre al leer esa lección; la evaluación
 *   (y en la Etapa 8 el reto) se abre al leer todas las lecciones del módulo.
 * - El avance de un módulo es el porcentaje de elementos completados:
 *   lecciones leídas + actividades aprobadas, sobre el total visible
 *   para la ruta del estudiante.
 */

declare(strict_types=1);

final class ProgressService
{
    private Lesson $lessons;
    private Progress $progress;

    public function __construct()
    {
        $this->lessons = new Lesson();
        $this->progress = new Progress();
    }

    /**
     * Lecciones del módulo con su estado para el estudiante.
     *
     * @return array<int, array{id: int, title: string, completed: bool, locked: bool}>
     */
    public function lessonsWithState(int $userId, int $moduleId, int $pathId): array
    {
        $completed = $this->progress->completedLessonIds($userId);
        $previousDone = true;
        $result = [];

        foreach ($this->lessons->forModule($moduleId, $pathId) as $lesson) {
            $isDone = isset($completed[$lesson['id']]);
            $result[] = [
                'id'        => $lesson['id'],
                'title'     => $lesson['title'],
                'completed' => $isDone,
                'locked'    => !$previousDone,
            ];
            $previousDone = $isDone;
        }

        return $result;
    }

    /**
     * Actividades del módulo con su estado para el estudiante.
     *
     * @return array<int, array> cada actividad con locked, passed, best_score y attempts
     */
    public function activitiesWithState(int $userId, int $moduleId, int $pathId): array
    {
        $lessons = $this->lessonsWithState($userId, $moduleId, $pathId);
        $best = (new Attempt())->bestByActivity($userId);

        return array_map(function (array $activity) use ($lessons, $best) {
            $result = $best[$activity['id']] ?? ['best_score' => null, 'passed' => false, 'attempts' => 0];
            return $activity + $result + ['locked' => !$this->isUnlocked($activity, $lessons)];
        }, (new Activity())->forModule($moduleId, $pathId));
    }

    /** Una actividad está disponible según las lecciones leídas del módulo. */
    public function isUnlocked(array $activity, array $lessonsWithState): bool
    {
        if ($activity['kind'] === 'practica') {
            foreach ($lessonsWithState as $lesson) {
                if ($lesson['id'] === $activity['lesson_id']) {
                    return $lesson['completed'];
                }
            }
            return false;
        }

        // Evaluaciones y retos: todas las lecciones del módulo leídas.
        foreach ($lessonsWithState as $lesson) {
            if (!$lesson['completed']) {
                return false;
            }
        }
        return true;
    }

    /**
     * Calcula el avance de un módulo.
     *
     * @return array{percent: int, status: string, lessons_total: int, lessons_completed: int,
     *               activities_total: int, activities_passed: int}
     */
    public function moduleSummary(int $userId, int $moduleId, int $pathId): array
    {
        $lessons = $this->lessonsWithState($userId, $moduleId, $pathId);
        $lessonsDone = count(array_filter($lessons, fn ($l) => $l['completed']));
        $activities = $this->progress->activityCounts($userId, $moduleId, $pathId);

        $total = count($lessons) + $activities['total'];
        $done = $lessonsDone + $activities['passed'];
        $percent = $total > 0 ? (int) floor($done * 100 / $total) : 0;

        $status = match (true) {
            $percent >= 100 => 'completado',
            $done > 0       => 'en_curso',
            default         => 'no_iniciado',
        };

        return [
            'percent'           => $percent,
            'status'            => $status,
            'lessons_total'     => count($lessons),
            'lessons_completed' => $lessonsDone,
            'activities_total'  => $activities['total'],
            'activities_passed' => $activities['passed'],
        ];
    }

    /** Recalcula y guarda en module_progress el avance de un módulo. */
    public function refreshModule(int $userId, int $moduleId, int $pathId): array
    {
        $summary = $this->moduleSummary($userId, $moduleId, $pathId);
        $this->progress->saveModuleProgress($userId, $moduleId, $summary['percent'], $summary['status']);

        return $summary;
    }
}
