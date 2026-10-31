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

    /** XP ya otorgado al estudiante por una actividad (suma de todos sus intentos). */
    public function xpAwardedFor(int $userId, int $activityId): int
    {
        $stmt = $this->db->prepare(
            'SELECT COALESCE(SUM(xp_awarded), 0) FROM attempts WHERE user_id = ? AND activity_id = ?'
        );
        $stmt->execute([$userId, $activityId]);
        return (int) $stmt->fetchColumn();
    }

    /**
     * Mejor resultado del estudiante en cada actividad.
     *
     * @return array<int, array{best_score: int, passed: bool, attempts: int}> indexado por activity_id
     */
    public function bestByActivity(int $userId): array
    {
        $stmt = $this->db->prepare(
            'SELECT activity_id, MAX(score_pct) AS best_score, MAX(passed) AS passed, COUNT(*) AS attempts
             FROM attempts WHERE user_id = ? GROUP BY activity_id'
        );
        $stmt->execute([$userId]);

        $result = [];
        foreach ($stmt->fetchAll() as $row) {
            $result[(int) $row['activity_id']] = [
                'best_score' => (int) $row['best_score'],
                'passed'     => (bool) $row['passed'],
                'attempts'   => (int) $row['attempts'],
            ];
        }
        return $result;
    }
}
