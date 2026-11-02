<?php
/**
 * Insignias (logros) automáticas (RF-27).
 *
 * Cada insignia tiene una regla (rule_type) y una meta (rule_value):
 *   actividades_completadas  actividades distintas aprobadas
 *   puntaje_perfecto         actividades con 100 %
 *   reto_completado          retos de módulo aprobados
 *   modulo_completado        el módulo module_id al 100 %
 *   xp_total                 XP acumulado
 *
 * Solo el servidor las otorga, después de calificar. Debe llamarse dentro
 * de la transacción de la calificación, con la fila del usuario bloqueada.
 */

declare(strict_types=1);

final class BadgeService
{
    /**
     * Todas las insignias con el avance del estudiante hacia cada una.
     *
     * @return array<int, array> insignia + current, target, earned, earned_at
     */
    public function progressFor(int $userId): array
    {
        $stats = (new Attempt())->stats($userId);
        $completedModules = (new Progress())->completedModuleIds($userId);
        $xpTotal = (new User())->xpTotal($userId);
        $earned = (new Badge())->earnedBy($userId);

        return array_map(function (array $badge) use ($stats, $completedModules, $xpTotal, $earned) {
            $current = match ($badge['rule_type']) {
                'actividades_completadas' => $stats['completed'],
                'puntaje_perfecto'        => $stats['perfect'],
                'reto_completado'         => $stats['retos'],
                'modulo_completado'       => isset($completedModules[$badge['module_id']]) ? 1 : 0,
                'xp_total'                => $xpTotal,
            };

            $isEarned = isset($earned[$badge['id']]);

            return $badge + [
                // Una insignia ganada se conserva aunque cambie el avance (p. ej. al cambiar de ruta).
                'current'   => $isEarned ? $badge['rule_value'] : min($current, $badge['rule_value']),
                'target'    => $badge['rule_value'],
                'earned'    => $isEarned,
                'earned_at' => $earned[$badge['id']] ?? null,
            ];
        }, (new Badge())->all());
    }

    /**
     * Otorga las insignias cuya meta ya se cumplió y suma su XP de premio.
     * Se repite porque el XP de una insignia puede completar la de XP total.
     *
     * @return array<int, array{id: int, name: string, description: string, icon: string, xp_reward: int}>
     */
    public function evaluate(int $userId): array
    {
        $badges = new Badge();
        $xp = new XpService();
        $new = [];

        do {
            $grantedNow = false;
            foreach ($this->progressFor($userId) as $badge) {
                if ($badge['earned'] || $badge['current'] < $badge['target']) {
                    continue;
                }
                if (!$badges->grant($userId, $badge['id'])) {
                    continue;
                }

                $xp->award($userId, $badge['xp_reward'], 'insignia', null, $badge['id'], 'Insignia: ' . $badge['name']);
                $new[] = [
                    'id'          => $badge['id'],
                    'name'        => $badge['name'],
                    'description' => $badge['description'],
                    'icon'        => $badge['icon'],
                    'xp_reward'   => $badge['xp_reward'],
                ];
                $grantedNow = true;
            }
        } while ($grantedNow);

        return $new;
    }
}
