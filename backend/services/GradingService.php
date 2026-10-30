<?php
/**
 * Calificación de respuestas en el servidor.
 *
 * El navegador solo envía lo que el estudiante eligió; aquí se compara
 * con la clave de respuestas guardada en MySQL. En la Etapa 7 se agregan
 * los tipos completar_codigo, ordenar y relacionar.
 */

declare(strict_types=1);

final class GradingService
{
    /** Tipos que se responden eligiendo una sola opción. */
    private const SINGLE_CHOICE = ['seleccion', 'patron'];

    /**
     * Califica las respuestas de una actividad.
     *
     * @param array $key      Clave de respuestas (Question::answerKey).
     * @param array $answers  Respuestas enviadas: [question_id => ['option_id' => n], ...]
     * @return array{correct: int, total: int, score_pct: int, points: int, max_points: int, results: array}
     * @throws InvalidArgumentException si falta una pregunta o una respuesta no es válida.
     */
    public function grade(array $key, array $answers): array
    {
        $correct = 0;
        $points = 0;
        $maxPoints = 0;
        $results = [];

        foreach ($key as $questionId => $question) {
            if (!array_key_exists($questionId, $answers)) {
                throw new InvalidArgumentException('Debes responder todas las preguntas.');
            }

            $isCorrect = match (true) {
                in_array($question['type'], self::SINGLE_CHOICE, true)
                    => $this->gradeSingleChoice($question, $answers[$questionId]),
                default => throw new LogicException("Tipo de pregunta no soportado aún: {$question['type']}"),
            };

            $maxPoints += $question['points'];
            if ($isCorrect) {
                $correct++;
                $points += $question['points'];
            }

            $results[] = [
                'question_id'       => $questionId,
                'is_correct'        => $isCorrect,
                'correct_option_id' => $this->correctOptionId($question),
                'explanation'       => $question['explanation'],
            ];
        }

        $extra = array_diff(array_keys($answers), array_keys($key));
        if ($extra !== []) {
            throw new InvalidArgumentException('Se enviaron respuestas a preguntas que no pertenecen a esta actividad.');
        }

        return [
            'correct'    => $correct,
            'total'      => count($key),
            'score_pct'  => $maxPoints > 0 ? (int) round($points * 100 / $maxPoints) : 0,
            'points'     => $points,
            'max_points' => $maxPoints,
            'results'    => $results,
        ];
    }

    private function gradeSingleChoice(array $question, mixed $answer): bool
    {
        $optionId = is_array($answer) ? ($answer['option_id'] ?? null) : null;

        if (!is_int($optionId) || !isset($question['options'][$optionId])) {
            throw new InvalidArgumentException('Hay una respuesta con una opción que no existe.');
        }

        return $question['options'][$optionId]['is_correct'];
    }

    private function correctOptionId(array $question): ?int
    {
        foreach ($question['options'] as $id => $option) {
            if ($option['is_correct']) {
                return $id;
            }
        }
        return null;
    }
}
