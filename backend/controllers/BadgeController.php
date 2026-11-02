<?php
/**
 * Insignias.
 *
 * GET /api/badges   (privada) Todas las insignias, cuáles tiene el
 *                   estudiante y su avance hacia las que le faltan.
 */

declare(strict_types=1);

final class BadgeController
{
    public function index(array $params): never
    {
        $userId = $params['userId'];
        PathMiddleware::requirePath($userId);

        Response::json(['badges' => (new BadgeService())->progressFor($userId)]);
    }
}
