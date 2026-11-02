<?php
/**
 * Avance de ruta (RF-31).
 *
 * POST /api/path/advance   (privada) Pasa de la ruta básica a la intermedia
 *                          si el servidor comprueba que se cumple la regla.
 */

declare(strict_types=1);

final class PathController
{
    public function advance(array $params): never
    {
        $userId = $params['userId'];
        $pathId = PathMiddleware::requirePath($userId);

        try {
            $target = (new PathAdvanceService())->advance($userId, $pathId);
        } catch (DomainException $e) {
            Response::error($e->getMessage(), 409);
        }

        Response::json([
            'message' => '¡Ahora estás en la ' . mb_strtolower($target['name']) . '!',
            'user'    => (new User())->findProfile($userId),
        ]);
    }
}
