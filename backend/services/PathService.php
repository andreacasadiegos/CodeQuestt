<?php
/**
 * Asignación de la ruta de aprendizaje a partir del diagnóstico.
 *
 * Reglas (documento de propuesta + Etapa 0):
 *   1 «No tengo conocimientos»        -> básica.
 *   2 «Tengo conocimientos básicos»    -> intermedia con 4 o 5 aciertos; si no, básica (con posibilidad de avanzar).
 *   3 «Ya he estudiado programación»   -> intermedia con 3 o más aciertos; si no, básica (con posibilidad de avanzar).
 */

declare(strict_types=1);

final class PathService
{
    public const EXPERIENCE_OPTIONS = [
        1 => 'No tengo conocimientos',
        2 => 'Tengo conocimientos básicos',
        3 => 'Ya he estudiado programación',
    ];

    /** Aciertos mínimos para ir a la ruta intermedia según la autoevaluación. */
    private const MIN_SCORE_FOR_INTERMEDIATE = [2 => 4, 3 => 3];

    /**
     * @return array{code: string, reason: string}
     */
    public function decide(int $experienceOption, int $correct, int $total): array
    {
        $minimum = self::MIN_SCORE_FOR_INTERMEDIATE[$experienceOption] ?? null;

        if ($minimum === null) {
            return [
                'code'   => 'basica',
                'reason' => 'Empiezas desde los fundamentos. Si demuestras dominio en las evaluaciones, podrás avanzar a la ruta intermedia.',
            ];
        }

        if ($correct >= $minimum) {
            return [
                'code'   => 'intermedia',
                'reason' => "Acertaste $correct de $total preguntas: tus conocimientos previos se confirman y empiezas en la ruta intermedia.",
            ];
        }

        return [
            'code'   => 'basica',
            'reason' => "Acertaste $correct de $total preguntas. Empiezas en la ruta básica con posibilidad de avanzar a la intermedia cuando demuestres dominio.",
        ];
    }
}
