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
    // Base de datos local (XAMPP / MySQL).
    // Para Supabase (PostgreSQL) usa el bloque comentado de abajo.
    'db' => [
        'driver'   => 'mysql',
        'host'     => '127.0.0.1',
        'port'     => 3306,
        'name'     => 'codequest_db',
        'user'     => 'root',
        'password' => '',          // En XAMPP, root no tiene contraseña por defecto.
        'charset'  => 'utf8mb4',
    ],

    // Supabase: Project Settings -> Database -> Connection string ->
    // "Session pooler" (funciona en cualquier hosting, también sin IPv6).
    // 'db' => [
    //     'driver'   => 'pgsql',
    //     'host'     => 'aws-0-us-east-1.pooler.supabase.com',
    //     'port'     => 5432,
    //     'name'     => 'postgres',
    //     'user'     => 'postgres.TU_ID_DE_PROYECTO',
    //     'password' => 'LA_CONTRASEÑA_DE_LA_BASE',
    //     'sslmode'  => 'require',
    // ],

    'app' => [
        'env'      => 'development', // 'production' oculta los detalles de los errores.
        'timezone' => 'America/Bogota',
    ],

    'session' => [
        'name'            => 'CODEQUESTSESSID',
        'idle_timeout'    => 7200,   // Segundos de inactividad antes de cerrar la sesión (2 horas).
    ],
];
