<?php
/**
 * Identificadores opacos para los elementos de las preguntas de ordenar
 * y relacionar.
 *
 * Si enviáramos al navegador los ids reales de answer_options, un
 * estudiante podría deducir la respuesta (por ejemplo, emparejando ids
 * iguales). Por eso cada elemento viaja con un token derivado de un
 * secreto guardado en su sesión, que solo el servidor puede recalcular.
 */

declare(strict_types=1);

final class AnswerToken
{
    public static function for(int $questionId, int $optionId, string $role): string
    {
        if (empty($_SESSION['answer_secret'])) {
            $_SESSION['answer_secret'] = bin2hex(random_bytes(16));
        }

        $hash = hash_hmac('sha256', "$questionId:$optionId:$role", $_SESSION['answer_secret']);
        return substr($hash, 0, 12);
    }
}
