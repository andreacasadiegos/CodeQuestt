<?php
/**
 * Acceso a las tablas questions y answer_options.
 *
 * forActivity() devuelve lo que puede ver el estudiante (sin respuestas).
 * Las opciones de ordenar y relacionar viajan con tokens opacos (AnswerToken).
 * answerKey() devuelve las respuestas correctas y solo la usa el backend.
 */

declare(strict_types=1);

final class Question
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    /**
     * Preguntas de una actividad con sus opciones, SIN indicar cuáles son correctas.
     *
     * @return array<int, array>
     */
    public function forActivity(int $activityId): array
    {
        $stmt = $this->db->prepare(
            'SELECT id, type, statement, code_snippet, points
             FROM questions WHERE activity_id = ? ORDER BY sort_order, id'
        );
        $stmt->execute([$activityId]);
        $questions = $stmt->fetchAll();

        if ($questions === []) {
            return [];
        }

        $options = $this->db->prepare(
            'SELECT o.id, o.question_id, o.option_text, o.pair_text
             FROM answer_options o
             JOIN questions q ON q.id = o.question_id
             WHERE q.activity_id = ?
             ORDER BY o.question_id, o.sort_order, o.id'
        );
        $options->execute([$activityId]);

        $byQuestion = [];
        foreach ($options->fetchAll() as $option) {
            $byQuestion[(int) $option['question_id']][] = [
                'id'        => (int) $option['id'],
                'text'      => $option['option_text'],
                'pair_text' => $option['pair_text'],
            ];
        }

        $result = [];
        foreach ($questions as $q) {
            $id = (int) $q['id'];
            $result[] = [
                'id'           => $id,
                'type'         => $q['type'],
                'statement'    => $q['statement'],
                'code_snippet' => $q['code_snippet'],
                'points'       => (int) $q['points'],
            ] + $this->publicOptions($id, $q['type'], $byQuestion[$id] ?? []);
        }

        return $result;
    }

    /**
     * Opciones que puede ver el estudiante según el tipo de pregunta:
     *   seleccion / patron -> options (id real, sin is_correct)
     *   completar_codigo   -> nada (las opciones son las respuestas aceptadas)
     *   ordenar            -> items con token, en orden aleatorio
     *   relacionar         -> items (conceptos) y targets (definiciones) con token, desordenados
     */
    private function publicOptions(int $questionId, string $type, array $options): array
    {
        switch ($type) {
            case 'seleccion':
            case 'patron':
                return ['options' => array_map(
                    fn ($o) => ['id' => $o['id'], 'text' => $o['text']],
                    $options
                )];

            case 'completar_codigo':
                return [];

            case 'ordenar':
                $items = array_map(fn ($o) => [
                    'id'   => AnswerToken::for($questionId, $o['id'], 'item'),
                    'text' => $o['text'],
                ], $options);
                shuffle($items);
                return ['items' => $items];

            case 'relacionar':
                $items = array_map(fn ($o) => [
                    'id'   => AnswerToken::for($questionId, $o['id'], 'item'),
                    'text' => $o['text'],
                ], $options);
                $targets = array_map(fn ($o) => [
                    'id'   => AnswerToken::for($questionId, $o['id'], 'target'),
                    'text' => $o['pair_text'],
                ], $options);
                shuffle($items);
                shuffle($targets);
                return ['items' => $items, 'targets' => $targets];
        }

        return [];
    }

    /**
     * Clave de respuestas de una actividad, indexada por id de pregunta.
     * Uso exclusivo del servidor para calificar.
     *
     * @return array<int, array{type: string, explanation: string, points: int, options: array<int, array>}>
     */
    public function answerKey(int $activityId): array
    {
        $stmt = $this->db->prepare(
            'SELECT q.id AS question_id, q.type, q.explanation, q.points,
                    o.id AS option_id, o.option_text, o.is_correct, o.correct_order, o.pair_text
             FROM questions q
             JOIN answer_options o ON o.question_id = q.id
             WHERE q.activity_id = ?
             ORDER BY q.sort_order, q.id, o.sort_order, o.id'
        );
        $stmt->execute([$activityId]);

        $key = [];
        foreach ($stmt->fetchAll() as $row) {
            $questionId = (int) $row['question_id'];
            $key[$questionId] ??= [
                'type'        => $row['type'],
                'explanation' => $row['explanation'],
                'points'      => (int) $row['points'],
                'options'     => [],
            ];
            $key[$questionId]['options'][(int) $row['option_id']] = [
                'text'          => $row['option_text'],
                'is_correct'    => (bool) $row['is_correct'],
                'correct_order' => $row['correct_order'] === null ? null : (int) $row['correct_order'],
                'pair_text'     => $row['pair_text'],
            ];
        }

        return $key;
    }
}
