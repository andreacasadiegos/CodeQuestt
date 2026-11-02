<?php
/**
 * Actividades: prácticas y evaluaciones de los módulos.
 *
 * GET  /api/activities/{id}          (privada) Preguntas sin respuestas correctas.
 * POST /api/activities/{id}/submit   (privada) Califica, guarda el intento y otorga XP.
 *
 * El navegador solo envía respuestas. El servidor califica, calcula el XP,
 * actualiza el nivel y el avance y otorga las insignias; ningún dato de
 * puntaje se acepta del cliente.
 */

declare(strict_types=1);

final class ActivityController
{
    public function show(array $params): never
    {
        $userId = $params['userId'];
        $pathId = PathMiddleware::requirePath($userId);
        [$activity, $module] = $this->loadAccessible($userId, $pathId, $params['id']);

        $best = (new Attempt())->bestByActivity($userId)[$activity['id']] ?? null;

        Response::json([
            'activity'  => $activity,
            'module'    => ['slug' => $module['slug'], 'name' => $module['name'], 'icon' => $module['icon']],
            'questions' => (new Question())->forActivity($activity['id']),
            'best'      => $best,
            'potential_xp' => $this->pendingXp($userId, $activity),
        ]);
    }

    public function submit(array $params): never
    {
        $userId = $params['userId'];
        $pathId = PathMiddleware::requirePath($userId);
        [$activity, $module, $lessons] = $this->loadAccessible($userId, $pathId, $params['id']);

        // --- Lectura de respuestas: [{question_id, answer: {...}}] ---
        $raw = Request::json()['answers'] ?? null;
        if (!is_array($raw) || !array_is_list($raw)) {
            Response::error('Faltan las respuestas de la actividad.', 422);
        }

        $answers = [];
        foreach ($raw as $item) {
            $questionId = is_array($item) ? ($item['question_id'] ?? null) : null;
            $answer = is_array($item) ? ($item['answer'] ?? null) : null;
            if (!is_int($questionId) || !is_array($answer) || isset($answers[$questionId])) {
                Response::error('El formato de las respuestas no es válido.', 422);
            }
            $answers[$questionId] = $answer;
        }

        // --- Calificación en el servidor ---
        try {
            $grade = (new GradingService())->grade((new Question())->answerKey($activity['id']), $answers);
        } catch (InvalidArgumentException $e) {
            Response::error($e->getMessage(), 422);
        }

        $passed = $grade['score_pct'] >= $activity['pass_pct'];
        $xpService = new XpService();
        $earned = $xpService->earnedFor($activity['base_xp'], $grade['score_pct']);

        // --- Guardado atómico: intento, respuestas, XP, nivel y avance ---
        $db = Database::connection();
        $db->beginTransaction();
        try {
            (new User())->lockForUpdate($userId);
            $levelBefore = $xpService->state($userId)['level'];

            $award = $xpService->improvement($userId, $activity['id'], $earned);
            $attempts = new Attempt();
            $attemptId = $attempts->create(
                $userId, $activity['id'], $grade['correct'], $grade['total'], $grade['score_pct'], $passed, $award
            );
            foreach ($grade['results'] as $result) {
                $attempts->addAnswer($attemptId, $result['question_id'], $answers[$result['question_id']], $result['is_correct']);
            }

            $xp = $xpService->award($userId, $award, 'actividad', $attemptId, null, 'Actividad: ' . $activity['title']);
            $progress = (new ProgressService())->refreshModule($userId, $module['id'], $pathId);
            $newBadges = (new BadgeService())->evaluate($userId);
            $final = $xpService->state($userId);

            $db->commit();
        } catch (Throwable $e) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }
            throw $e;
        }

        Response::json([
            'correct'    => $grade['correct'],
            'total'      => $grade['total'],
            'score_pct'  => $grade['score_pct'],
            'passed'     => $passed,
            'pass_pct'   => $activity['pass_pct'],
            'results'    => $grade['results'],
            'xp'         => [
                'xp_awarded' => $xp['xp_awarded'],
                'badge_xp'   => array_sum(array_column($newBadges, 'xp_reward')),
                'earned'     => $earned,
                'level_up'   => $final['level']['number'] > $levelBefore['number'],
            ] + $final,
            'badges'     => $newBadges,
            'progress'   => $progress,
            'next_lesson_id' => $this->nextLessonId($activity, $lessons),
        ], 201);
    }

    /**
     * Carga la actividad comprobando ruta y desbloqueo.
     *
     * @return array{0: array, 1: array, 2: array} actividad, módulo, lecciones con estado
     */
    private function loadAccessible(int $userId, int $pathId, string $rawId): array
    {
        $id = ctype_digit($rawId) ? (int) $rawId : 0;
        $activity = (new Activity())->findForPath($id, $pathId);
        if ($activity === null) {
            Response::error('Esa actividad no existe en tu ruta.', 404);
        }

        $service = new ProgressService();
        $lessons = $service->lessonsWithState($userId, $activity['module_id'], $pathId);
        $evaluationPassed = $activity['kind'] === 'reto'
            && $service->evaluationPassed($userId, $activity['module_id'], $pathId);
        if (!$service->isUnlocked($activity, $lessons, $evaluationPassed)) {
            $message = match ($activity['kind']) {
                'practica' => 'Lee primero la lección de esta práctica.',
                'reto'     => 'Aprueba la evaluación del módulo para desbloquear el reto.',
                default    => 'Lee todas las lecciones del módulo para desbloquear esta actividad.',
            };
            Response::error($message, 403);
        }

        $module = null;
        foreach ((new Module())->all() as $candidate) {
            if ($candidate['id'] === $activity['module_id']) {
                $module = $candidate;
            }
        }

        return [$activity, $module, $lessons];
    }

    /** XP que aún puede ganar en esta actividad (si saca 100 %). */
    private function pendingXp(int $userId, array $activity): int
    {
        return (new XpService())->improvement($userId, $activity['id'], $activity['base_xp']);
    }

    /** Después de una práctica se sigue con la lección siguiente; si no hay, se vuelve al módulo. */
    private function nextLessonId(array $activity, array $lessons): ?int
    {
        if ($activity['kind'] !== 'practica') {
            return null;
        }

        $ids = array_column($lessons, 'id');
        $position = array_search($activity['lesson_id'], $ids, true);

        return $position === false ? null : ($ids[$position + 1] ?? null);
    }
}
