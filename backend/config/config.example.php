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
        // 'handler' => 'database', // Opcional: guardar sesiones en la base (varios servidores).
        // 'secure'  => true,       // En producción con HTTPS: la cookie solo viaja cifrada.
    ],

    // CodeBot (Google Gemini). Lo recomendado es la variable de entorno
    // GEMINI_API_KEY; este bloque es una alternativa para servidores donde
    // no se pueden definir variables. Nunca pongas la clave en el frontend.
    // 'gemini' => [
    //     'api_key' => 'TU_CLAVE_DE_GEMINI',
    //     'model'   => 'gemini-2.5-flash-lite',
    // ],
];
