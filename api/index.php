<?php
/**
 * Punto de entrada de la API en Vercel (runtime vercel-php).
 *
 * vercel.json envía /api/<ruta> a /api/index.php?__route=<ruta>.
 * Aquí se reconstruye la URL original y se carga la API de backend/,
 * la misma que se usa con XAMPP.
 */

declare(strict_types=1);

if (isset($_GET['__route'])) {
    $query = $_GET;
    unset($query['__route']);
    $_SERVER['REQUEST_URI'] = '/api/' . ltrim((string) $_GET['__route'], '/')
        . ($query ? '?' . http_build_query($query) : '');
}
$_SERVER['SCRIPT_NAME'] = '/api/index.php';

require __DIR__ . '/../backend/api/index.php';
