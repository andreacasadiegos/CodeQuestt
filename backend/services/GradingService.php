<?php
/**
 * Calificación de respuestas en el servidor.
 *
 * El navegador solo envía lo que el estudiante respondió; aquí se compara
 * con la clave de respuestas guardada en MySQL. Formato de cada respuesta:
 *
 *   seleccion / patron  {"option_id": 12}
 *   completar_codigo    {"text": "mostrar"}
 *   ordenar             {"order": ["token1", "token2", ...]}
 *   relacionar          {"pairs": {"tokenConcepto": "tokenDefinicion", ...}}
 */

declare(strict_types=1);

final class GradingService
{
    private const MAX_TEXT_LENGTH = 100;

    /**
     * Califica las respuestas de una actividad.
     *
     * @param array $key      Clave de respuestas (Question::answerKey).
     * @param array $answers  Respuestas enviadas: [question_id => respuesta, ...]
     * @return array{correct: int, total: int, score_pct: int, points: int, max_points: int, results: array}
     * @throws InvalidArgumentException si falta una pregunta o una respuesta no es válida.
     */
    public function grade(array $key, array $answers): array
    {
        $extra = array_diff(array_keys($answers), array_keys($key));
        if ($extra !== []) {
            throw new InvalidArgumentException('Se enviaron respuestas a preguntas que no pertenecen a esta actividad.');
        }

        $correct = 0;
        $points = 0;
        $maxPoints = 0;
        $results = [];

        foreach ($key as $questionId => $question) {
            if (!array_key_exists($questionId, $answers) || !is_array($answers[$questionId])) {
                throw new InvalidArgumentException('Debes responder todas las preguntas.');
            }

            $answer = $answers[$questionId];
            [$isCorrect, $solution] = match ($question['type']) {
                'seleccion', 'patron' => $this->gradeSingleChoice($question, $answer),
                'completar_codigo'    => $this->gradeCompletion($question, $answer),
                'ordenar'             => $this->gradeOrder($questionId, $question, $answer),
                'relacionar'          => $this->gradeMatch($questionId, $question, $answer),
            };

            $maxPoints += $question['points'];
            if ($isCorrect) {
                $correct++;
                $points += $question['points'];
            }

            $results[] = [
                'question_id' => $questionId,
                'is_correct'  => $isCorrect,
                'explanation' => $question['explanation'],
            ] + $solution;
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

    // ------------------------------------------------------------------

    private function gradeSingleChoice(array $question, array $answer): array
    {
        $optionId = $answer['option_id'] ?? null;
        if (!is_int($optionId) || !isset($question['options'][$optionId])) {
            throw new InvalidArgumentException('Hay una respuesta con una opción que no existe.');
        }

        $correctId = null;
        foreach ($question['options'] as $id => $option) {
            if ($option['is_correct']) {
                $correctId = $id;
            }
        }

        return [$optionId === $correctId, ['correct_option_id' => $correctId]];
    }

    private function gradeCompletion(array $question, array $answer): array
    {
        $text = $answer['text'] ?? null;
        if (!is_string($text) || mb_strlen($text) > self::MAX_TEXT_LENGTH) {
            throw new InvalidArgumentException('Hay una respuesta de completar código que no es válida.');
        }

        $given = $this->normalize($text);
        $accepted = array_column($question['options'], 'text');
        $isCorrect = $given !== '' && in_array($given, array_map([$this, 'normalize'], $accepted), true);

        return [$isCorrect, ['correct_answer' => $accepted[0] ?? '']];
    }

    private function gradeOrder(int $questionId, array $question, array $answer): array
    {
        $order = $answer['order'] ?? null;

        // Orden correcto expresado con los mismos tokens que vio el estudiante.
        $byPosition = [];
        foreach ($question['options'] as $optionId => $option) {
            $byPosition[$option['correct_order']] = AnswerToken::for($questionId, $optionId, 'item');
        }
        ksort($byPosition);
        $expected = array_values($byPosition);

        $sortedGiven = is_array($order) ? $order : [];
        $sortedExpected = $expected;
        sort($sortedGiven);
        sort($sortedExpected);
        if (!is_array($order) || !array_is_list($order) || $sortedGiven !== $sortedExpected) {
            throw new InvalidArgumentException('Debes ordenar todos los pasos de la actividad.');
        }

        return [$order === $expected, ['correct_order' => $expected]];
    }

    private function gradeMatch(int $questionId, array $question, array $answer): array
    {
        $pairs = $answer['pairs'] ?? null;

        $expected = [];
        foreach (array_keys($question['options']) as $optionId) {
            $expected[AnswerToken::for($questionId, $optionId, 'item')] = AnswerToken::for($questionId, $optionId, 'target');
        }

        if (!is_array($pairs) || count($pairs) !== count($expected)) {
            throw new InvalidArgumentException('Debes relacionar todos los conceptos.');
        }

        $isCorrect = true;
        foreach ($expected as $item => $target) {
            if (!array_key_exists($item, $pairs) || !is_string($pairs[$item])) {
                throw new InvalidArgumentException('Debes relacionar todos los conceptos.');
            }
            if ($pairs[$item] !== $target) {
                $isCorrect = false;
            }
        }

        return [$isCorrect, ['correct_pairs' => $expected]];
    }

    /** Minúsculas, sin espacios sobrantes ni comillas alrededor. */
    private function normalize(string $text): string
    {
        $text = mb_strtolower(trim($text));
        $text = preg_replace('/\s+/u', ' ', $text);
        return trim($text, " \"'«»“”");
    }
}
