<?php
/**
 * Acceso a las tablas attempts y attempt_answers.
 */

declare(strict_types=1);

final class Attempt
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    /** Registra un intento ya calificado y devuelve su id. */
    public function create(int $userId, int $activityId, int $correct, int $total, int $scorePct, bool $passed, int $xpAwarded): int
    {
        $stmt = $this->db->prepare(
            'INSERT INTO attempts (user_id, activity_id, correct_count, total_count, score_pct, passed, xp_awarded)
             VALUES (?, ?, ?, ?, ?, ?, ?)'
        );
        $stmt->execute([$userId, $activityId, $correct, $total, $scorePct, (int) $passed, $xpAwarded]);
        return (int) $this->db->lastInsertId();
    }

    /** Guarda la respuesta dada a una pregunta dentro de un intento. */
    public function addAnswer(int $attemptId, int $questionId, array $answer, bool $isCorrect): void
    {
        $stmt = $this->db->prepare(
            'INSERT INTO attempt_answers (attempt_id, question_id, answer_given, is_correct) VALUES (?, ?, ?, ?)'
        );
        $stmt->execute([$attemptId, $questionId, json_encode($answer), (int) $isCorrect]);
    }
}
