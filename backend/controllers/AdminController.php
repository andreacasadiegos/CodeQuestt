<?php
/**
 * Panel de administración: resultados de todos los estudiantes.
 *
 * GET /api/admin/students        (solo admin) Resumen de cada estudiante.
 * GET /api/admin/students/{id}   (solo admin) Detalle de un estudiante.
 */

declare(strict_types=1);

final class AdminController
{
    public function students(array $params): never
    {
        AdminMiddleware::requireAdmin($params['userId']);
        $report = new AdminReport();
        $students = $report->students();

        $scores = array_filter(array_column($students, 'average_score'), fn ($s) => $s !== null);

        Response::json([
            'summary' => [
                'students'         => count($students),
                'with_diagnostic'  => count(array_filter($students, fn ($s) => $s['path'] !== null)),
                'active'           => count(array_filter($students, fn ($s) => $s['attempts'] > 0)),
                'average_score'    => $scores === [] ? null : (int) round(array_sum($scores) / count($scores)),
                'activities_total' => $report->activitiesTotal(),
            ],
            'students' => $students,
        ]);
    }

    public function student(array $params): never
    {
        AdminMiddleware::requireAdmin($params['userId']);

        $id = filter_var($params['id'], FILTER_VALIDATE_INT);
        $users = new User();
        $profile = $id === false ? null : $users->findProfile($id);
        if ($profile === null || $profile['role'] === 'admin') {
            Response::error('No existe ese estudiante.', 404);
        }

        $report = new AdminReport();
        $summary = array_values(array_filter($report->students(), fn ($s) => $s['id'] === $id))[0] ?? null;

        Response::json([
            'student'          => $profile,
            'summary'          => $summary,
            'diagnostic'       => $report->diagnostic($id),
            'modules'          => $report->modules($id),
            'badges'           => $report->badges($id),
            'attempts'         => (new Attempt())->history($id, 100),
        ]);
    }
}
