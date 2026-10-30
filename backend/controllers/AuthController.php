<?php
/**
 * Registro, inicio y cierre de sesión.
 *
 * POST /api/auth/register
 * POST /api/auth/login
 * POST /api/auth/logout   (privada)
 * GET  /api/auth/me       (pública: user = null si no hay sesión)
 */

declare(strict_types=1);

final class AuthController
{
    /** bcrypt solo usa los primeros 72 bytes de la contraseña. */
    private const PASSWORD_MAX_BYTES = 72;

    private User $users;

    public function __construct()
    {
        $this->users = new User();
    }

    public function register(array $params): never
    {
        $fullName = preg_replace('/\s+/u', ' ', Request::string('full_name'));
        $email    = mb_strtolower(Request::string('email'));
        $password = Request::json()['password'] ?? '';
        $confirm  = Request::json()['password_confirmation'] ?? '';
        $password = is_string($password) ? $password : '';
        $confirm  = is_string($confirm) ? $confirm : '';

        $v = new Validator();
        $v->required('full_name', $fullName, 'Escribe tu nombre completo.')
          ->length('full_name', $fullName, 3, 120, 'El nombre completo')
          ->personName('full_name', $fullName)
          ->required('email', $email, 'Escribe tu correo electrónico.')
          ->email('email', $email)
          ->length('email', $email, 5, 120, 'El correo electrónico')
          ->required('password', $password, 'Escribe una contraseña.')
          ->length('password', $password, 8, 72, 'La contraseña')
          ->strongPassword('password', $password)
          ->required('password_confirmation', $confirm, 'Confirma tu contraseña.')
          ->matches('password_confirmation', $confirm, $password, 'Las contraseñas no coinciden.');

        if (strlen($password) > self::PASSWORD_MAX_BYTES) {
            $v->add('password', 'La contraseña es demasiado larga.');
        }

        if (!$v->fails() && $this->users->emailExists($email)) {
            Response::error('Ya existe una cuenta con ese correo.', 409, ['email' => 'Este correo ya está registrado.']);
        }

        if ($v->fails()) {
            Response::error('Revisa los datos del formulario.', 422, $v->errors());
        }

        $hash = password_hash($password, PASSWORD_DEFAULT);
        $userId = $this->users->create($fullName, $email, $hash);

        // Tras registrarse, el estudiante queda con sesión iniciada
        // para pasar directamente al diagnóstico.
        Session::login($userId);

        Response::json(['user' => $this->users->findProfile($userId)], 201);
    }

    public function login(array $params): never
    {
        $email    = mb_strtolower(Request::string('email'));
        $password = Request::json()['password'] ?? '';
        $password = is_string($password) ? $password : '';

        $v = new Validator();
        $v->required('email', $email, 'Escribe tu correo electrónico.')
          ->email('email', $email)
          ->required('password', $password, 'Escribe tu contraseña.');

        if ($v->fails()) {
            Response::error('Revisa los datos del formulario.', 422, $v->errors());
        }

        $credentials = $this->users->findCredentialsByEmail($email);

        // Mismo mensaje si el correo no existe o la contraseña es incorrecta,
        // para no revelar qué correos están registrados.
        if ($credentials === null || !password_verify($password, $credentials['password_hash'])) {
            Response::error('Correo o contraseña incorrectos.', 401);
        }

        $userId = (int) $credentials['id'];

        if (password_needs_rehash($credentials['password_hash'], PASSWORD_DEFAULT)) {
            $this->users->updatePasswordHash($userId, password_hash($password, PASSWORD_DEFAULT));
        }

        Session::login($userId);

        Response::json(['user' => $this->users->findProfile($userId)]);
    }

    public function logout(array $params): never
    {
        Session::destroy();
        Response::json(['message' => 'Sesión cerrada correctamente.']);
    }

    /**
     * Estudiante con sesión activa, o null si no hay sesión.
     * Es pública para que React pueda preguntar sin provocar un error 401.
     */
    public function me(array $params): never
    {
        $userId = Session::userId();
        $user = $userId === null ? null : $this->users->findProfile($userId);

        Response::json(['user' => $user]);
    }
}
