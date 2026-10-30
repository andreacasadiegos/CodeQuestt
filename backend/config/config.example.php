<?php
/**
 * Configuración de CodeQuest (plantilla).
 *
 * 1. Copia este archivo como config.php en esta misma carpeta.
 * 2. Ajusta los datos de conexión si tu MySQL tiene contraseña.
 *
 * config.php NO se sube a Git (está en .gitignore).
 */

return [
    'db' => [
        'host'     => '127.0.0.1',
        'port'     => 3306,
        'name'     => 'codequest_db',
        'user'     => 'root',
        'password' => '',          // En XAMPP, root no tiene contraseña por defecto.
        'charset'  => 'utf8mb4',
    ],

    'app' => [
        'env'      => 'development', // 'production' oculta los detalles de los errores.
        'timezone' => 'America/Bogota',
    ],

    'session' => [
        'name'            => 'CODEQUESTSESSID',
        'idle_timeout'    => 7200,   // Segundos de inactividad antes de cerrar la sesión (2 horas).
    ],
];
