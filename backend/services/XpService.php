<?php
/**
 * Puntos de experiencia y niveles.
 *
 * Reglas:
 *   - XP de una actividad = XP base × porcentaje de aciertos.
 *   - Solo se paga la mejora: si el estudiante repite una actividad, recibe
 *     la diferencia entre lo que gana ahora y lo que ya había recibido por
 *     ella. Repetir no permite acumular puntos sin límite.
 *   - Cada punto queda registrado en xp_transactions y el nivel se
 *     recalcula con la tabla levels.
 *
 * Debe llamarse dentro de una transacción con la fila del usuario bloqueada.
 */

declare(strict_types=1);

final class XpService
{
    /** XP que vale un resultado en una actividad. */
    public function earnedFor(int $baseXp, int $scorePct): int
    {
        return (int) round($baseXp * $scorePct / 100);
    }

    /** XP pendiente de pagar por una actividad (solo la mejora). */
    public function improvement(int $userId, int $activityId, int $earned): int
    {
        $alreadyAwarded = (new Attempt())->xpAwardedFor($userId, $activityId);
        return max(0, $earned - $alreadyAwarded);
    }

    /**
     * Suma XP al estudiante, lo registra y actualiza su nivel.
     *
     * @return array{xp_awarded: int, xp_total: int, level: array, level_up: bool}
     */
    public function award(int $userId, int $amount, string $source, ?int $attemptId, ?int $badgeId, string $description): array
    {
        $users = new User();
        $levels = new Level();

        $before = $users->xpTotal($userId);
        $previousLevel = $levels->forXp($before);

        if ($amount <= 0) {
            return ['xp_awarded' => 0, 'xp_total' => $before, 'level' => $previousLevel, 'level_up' => false];
        }

        $total = $before + $amount;
        $level = $levels->forXp($total);

        (new XpTransaction())->create($userId, $amount, $source, $attemptId, $badgeId, $description);
        $users->addXp($userId, $amount, $level['id']);

        return [
            'xp_awarded' => $amount,
            'xp_total'   => $total,
            'level'      => $level,
            'level_up'   => $level['number'] > $previousLevel['number'],
        ];
    }

    /**
     * XP total, nivel actual y siguiente nivel del estudiante.
     *
     * @return array{xp_total: int, level: array, next_level: ?array}
     */
    public function state(int $userId): array
    {
        $levels = new Level();
        $total = (new User())->xpTotal($userId);
        $level = $levels->forXp($total);

        return ['xp_total' => $total, 'level' => $level, 'next_level' => $levels->next($level['number'])];
    }
}
