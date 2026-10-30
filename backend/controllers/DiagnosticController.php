<?php
/**
 * Diagnóstico inicial: autoevaluación + prueba de 5 preguntas.
 *
 * GET  /api/diagnostic   (privada) Preguntas, sin respuestas correctas.
 * POST /api/diagnostic   (privada) Califica, guarda y asigna la ruta.
 */

declare(strict_types=1);

final class DiagnosticController
{
    public function show(array $params): never
    {
        $userId = $params['userId'];

        if ((new Diagnostic())->existsForUser($userId)) {
            Response::error('Ya realizaste el diagnóstico.', 409);
        }

        $activity = (new Activity())->findDiagnostic();
        if ($activity === null) {
            Response::error('La prueba diagnóstica no está cargada en la base de datos (03_seed_diagnostico.sql).', 500);
        }

        $options = [];
        foreach (PathService::EXPERIENCE_OPTIONS as $value => $label) {
            $options[] = ['value' => $value, 'label' => $label];
        }

        Response::json([
            'title'              => $activity['title'],
            'description'        => $activity['description'],
            'experience_options' => $options,
            'questions'          => (new Question())->forActivity((int) $activity['id']),
        ]);
    }

    public function submit(array $params): never
    {
        $userId = $params['userId'];
        $body = Request::json();

        // --- Validación de la entrada ---
        $experience = $body['experience_option'] ?? null;
        if (!is_int($experience) || !array_key_exists($experience, PathService::EXPERIENCE_OPTIONS)) {
            Response::error('Elige una opción válida en la autoevaluación.', 422, [
                'experience_option' => 'Elige una de las tres opciones.',
            ]);
        }

        $rawAnswers = $body['answers'] ?? null;
        if (!is_array($rawAnswers)) {
            Response::error('Faltan las respuestas de la prueba.', 422);
        }

        $answers = [];
        foreach ($rawAnswers as $item) {
            $questionId = is_array($item) ? ($item['question_id'] ?? null) : null;
            if (!is_int($questionId) || isset($answers[$questionId])) {
                Response::error('El formato de las respuestas no es válido.', 422);
            }
            $answers[$questionId] = ['option_id' => $item['option_id'] ?? null];
        }

        $activity = (new Activity())->findDiagnostic();
        if ($activity === null) {
            Response::error('La prueba diagnóstica no está cargada en la base de datos.', 500);
        }
        $activityId = (int) $activity['id'];

        // --- Calificación en el servidor ---
        $key = (new Question())->answerKey($activityId);
        try {
            $grade = (new GradingService())->grade($key, $answers);
        } catch (InvalidArgumentException $e) {
            Response::error($e->getMessage(), 422);
        }

        $decision = (new PathService())->decide($experience, $grade['correct'], $grade['total']);
        $path = (new LearningPath())->findByCode($decision['code']);

        // --- Guardado atómico ---
        $db = Database::connection();
        $users = new User();
        $diagnostics = new Diagnostic();

        $db->beginTransaction();
        try {
            // El bloqueo evita que dos envíos simultáneos creen dos diagnósticos.
            $users->lockForUpdate($userId);
            if ($diagnostics->existsForUser($userId)) {
                $db->rollBack();
                Response::error('Ya realizaste el diagnóstico.', 409);
            }

            $attempts = new Attempt();
            $attemptId = $attempts->create(
                $userId,
                $activityId,
                $grade['correct'],
                $grade['total'],
                $grade['score_pct'],
                $grade['score_pct'] >= (int) $activity['pass_pct'],
                0 // El diagnóstico no otorga XP: solo orienta la ruta.
            );

            foreach ($grade['results'] as $result) {
                $attempts->addAnswer($attemptId, $result['question_id'], $answers[$result['question_id']], $result['is_correct']);
            }

            $diagnostics->create($userId, $attemptId, $experience, $grade['correct'], $path['id']);
            $users->assignPath($userId, $path['id']);

            $db->commit();
        } catch (Throwable $e) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }
            throw $e;
        }

        Response::json([
            'correct' => $grade['correct'],
            'total'   => $grade['total'],
            'path'    => ['code' => $path['code'], 'name' => $path['name'], 'description' => $path['description']],
            'reason'  => $decision['reason'],
            'results' => $grade['results'],
        ], 201);
    }
}
