<?php
/**
 * Pruebas de integración de la API de CodeQuest (HTTP real).
 *
 * Uso (SOLO contra una base de desarrollo o de pruebas, nunca producción:
 * crea cuentas de prueba con correos @codequest.test):
 *
 *   CQ_API_URL=http://127.0.0.1:8080/api CQ_ALLOW_TEST_WRITES=1 php backend/tests/api_integration_test.php
 *
 * Opcional: CQ_EXPECT_GEMINI=1 si el servidor tiene GEMINI_API_KEY válida;
 * entonces se envía una pregunta real a CodeBot y se exige respuesta.
 * Sin esa variable se comprueba que, sin clave, la API responde 503 y no
 * guarda mensajes.
 *
 * Termina con código 0 si todo pasa y 1 si algo falla.
 */

declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

$base = rtrim((string) (getenv('CQ_API_URL') ?: 'http://127.0.0.1:8080/api'), '/');
if (getenv('CQ_ALLOW_TEST_WRITES') !== '1') {
    fwrite(STDERR, "Define CQ_ALLOW_TEST_WRITES=1 para confirmar que $base NO es producción.\n");
    exit(2);
}
$expectGemini = getenv('CQ_EXPECT_GEMINI') === '1';

$passed = 0;
$failed = 0;

function check(string $name, bool $ok, string $detail = ''): void
{
    global $passed, $failed;
    if ($ok) {
        $passed++;
        echo "  ✔ $name\n";
    } else {
        $failed++;
        echo "  ✘ $name" . ($detail !== '' ? "  →  $detail" : '') . "\n";
    }
}

/** Cliente HTTP con su propio tarro de cookies (un navegador por estudiante). */
final class Client
{
    private string $jar;
    public array $lastHeaders = [];

    public function __construct(private string $base)
    {
        $this->jar = tempnam(sys_get_temp_dir(), 'cqjar');
    }

    public function __destruct()
    {
        @unlink($this->jar);
    }

    /** @return array{0:int,1:?array} */
    public function call(string $method, string $path, ?array $body = null, string $contentType = 'application/json'): array
    {
        $ch = curl_init($this->base . $path);
        $headers = [];
        $opts = [
            CURLOPT_CUSTOMREQUEST  => $method,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_COOKIEJAR      => $this->jar,
            CURLOPT_COOKIEFILE     => $this->jar,
            CURLOPT_TIMEOUT        => 60,
            CURLOPT_HEADERFUNCTION => function ($ch, string $line) use (&$headers): int {
                $headers[] = trim($line);
                return strlen($line);
            },
        ];
        if (getenv('CQ_CA_FILE')) {
            $opts[CURLOPT_CAINFO] = getenv('CQ_CA_FILE'); // certificado propio (pruebas)
        }
        if ($body !== null) {
            $opts[CURLOPT_POSTFIELDS] = json_encode($body);
            $opts[CURLOPT_HTTPHEADER] = ["Content-Type: $contentType"];
        }
        curl_setopt_array($ch, $opts);
        $raw = curl_exec($ch);
        $status = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        $this->lastHeaders = $headers;

        return [$status, is_string($raw) ? json_decode($raw, true) : null];
    }

    public function header(string $name): array
    {
        return array_values(array_filter(
            $this->lastHeaders,
            fn ($h) => stripos($h, $name . ':') === 0
        ));
    }
}

$run = bin2hex(random_bytes(4));
$password = 'codigo123';
$emailA = "estudiante.a.$run@codequest.test";
$emailB = "estudiante.b.$run@codequest.test";

echo "CodeQuest · pruebas de integración contra $base\n\n";

// ------------------------------------------------------------------ salud
echo "Salud y cabeceras\n";
$anon = new Client($base);
[$s, $r] = $anon->call('GET', '/health');
check('GET /health responde 200 con base conectada', $s === 200 && ($r['data']['database'] ?? '') === 'conectada', "HTTP $s");
check('Cabecera Cache-Control: no-store', (bool) preg_grep('/no-store/i', $anon->header('Cache-Control')));
check('Cabecera X-Content-Type-Options: nosniff', (bool) $anon->header('X-Content-Type-Options'));
[$s] = $anon->call('GET', '/no-existe');
check('Ruta inexistente → 404', $s === 404, "HTTP $s");
[$s] = $anon->call('GET', '/auth/login');
check('Método incorrecto → 405', $s === 405, "HTTP $s");

// ------------------------------------------------------------ autenticación
echo "\nAutenticación\n";
[$s, $r] = $anon->call('POST', '/auth/register', ['full_name' => 'A', 'email' => 'malo', 'password' => 'abc', 'password_confirmation' => 'x']);
check('Registro inválido → 422 con errores por campo', $s === 422 && isset($r['errors']['email'], $r['errors']['password']), "HTTP $s");
[$s] = $anon->call('POST', '/auth/register', ['email' => 'x'], 'text/plain');
check('Cuerpo sin JSON → 415', $s === 415, "HTTP $s");

$a = new Client($base);
[$s, $r] = $a->call('POST', '/auth/register', ['full_name' => 'Ana Prueba', 'email' => $emailA, 'password' => $password, 'password_confirmation' => $password]);
check('Registro válido → 201 y requiere diagnóstico', $s === 201 && ($r['data']['user']['needs_diagnostic'] ?? false) === true, "HTTP $s");
$cookie = implode(' ', $a->header('Set-Cookie'));
check('Cookie de sesión HttpOnly', stripos($cookie, 'httponly') !== false, $cookie);
check('Cookie de sesión SameSite=Lax', stripos($cookie, 'samesite=lax') !== false, $cookie);
if (str_starts_with($base, 'https://')) {
    check('Cookie de sesión Secure (HTTPS)', stripos($cookie, 'secure') !== false, $cookie);
}
check('La respuesta no expone password_hash', !str_contains(json_encode($r), 'password'));
[$s] = $anon->call('POST', '/auth/register', ['full_name' => 'Ana Prueba', 'email' => $emailA, 'password' => $password, 'password_confirmation' => $password]);
check('Correo duplicado → 409', $s === 409, "HTTP $s");
[$s, $r] = $a->call('GET', '/auth/me');
check('GET /auth/me con sesión devuelve al usuario', $s === 200 && ($r['data']['user']['email'] ?? '') === $emailA);
[$s] = $a->call('POST', '/auth/logout', []);
[$s2, $r] = $a->call('GET', '/auth/me');
check('Logout cierra la sesión', $s === 200 && $s2 === 200 && array_key_exists('user', $r['data'] ?? []) && $r['data']['user'] === null);
[$s] = $a->call('POST', '/auth/login', ['email' => $emailA, 'password' => 'otra1234']);
check('Contraseña incorrecta → 401', $s === 401, "HTTP $s");
[$s, $r] = $a->call('POST', '/auth/login', ['email' => strtoupper($emailA), 'password' => $password]);
check('Login correcto (correo sin distinguir mayúsculas) → 200', $s === 200 && ($r['data']['user']['email'] ?? '') === $emailA, "HTTP $s");

// ---------------------------------------------------------- rutas privadas
echo "\nRutas privadas sin sesión → 401\n";
foreach (['/dashboard', '/modules', '/progress', '/badges', '/diagnostic', '/tutor/conversations', '/admin/students'] as $path) {
    [$s] = $anon->call('GET', $path);
    check("GET $path", $s === 401, "HTTP $s");
}
[$s] = $anon->call('POST', '/tutor/conversations', []);
check('POST /tutor/conversations', $s === 401, "HTTP $s");

// ------------------------------------------------------------- diagnóstico
echo "\nDiagnóstico, contenido y progreso\n";
[$s] = $a->call('GET', '/modules');
check('Sin diagnóstico, /modules → 403', $s === 403, "HTTP $s");
[$s, $r] = $a->call('GET', '/diagnostic');
$questions = $r['data']['questions'] ?? [];
check('GET /diagnostic trae preguntas sin respuestas correctas', $s === 200 && $questions !== [] && !str_contains(json_encode($questions), 'is_correct'));
$answers = array_map(fn ($q) => ['question_id' => $q['id'], 'option_id' => $q['options'][0]['id']], $questions);
[$s, $r] = $a->call('POST', '/diagnostic', ['experience_option' => 1, 'answers' => $answers]);
check('POST /diagnostic asigna una ruta', $s === 200 || $s === 201, "HTTP $s " . json_encode($r['error'] ?? ''));
[$s] = $a->call('POST', '/diagnostic', ['experience_option' => 1, 'answers' => $answers]);
check('No se puede repetir el diagnóstico', $s >= 400 && $s < 500, "HTTP $s");
[$s, $r] = $a->call('GET', '/modules');
$modules = $r['data']['modules'] ?? [];
check('GET /modules → 200 con módulos', $s === 200 && $modules !== [], "HTTP $s");
foreach (['/dashboard', '/progress', '/badges'] as $path) {
    [$s] = $a->call('GET', $path);
    check("GET $path → 200", $s === 200, "HTTP $s");
}
if ($modules !== []) {
    [$s, $r] = $a->call('GET', '/modules/' . $modules[0]['slug']);
    check('GET /modules/{slug} → 200', $s === 200, "HTTP $s");
    $lessons = $r['data']['lessons'] ?? [];
    if ($lessons !== []) {
        [$s] = $a->call('GET', '/lessons/' . $lessons[0]['id']);
        check('Primera lección accesible', $s === 200, "HTTP $s");
        if (count($lessons) > 1) {
            [$s] = $a->call('GET', '/lessons/' . $lessons[count($lessons) - 1]['id']);
            check('Última lección bloqueada hasta leer las anteriores → 403', $s === 403, "HTTP $s");
        }
        [$s, $r] = $a->call('POST', '/lessons/' . $lessons[0]['id'] . '/complete', []);
        check('Completar lección → 200', $s === 200 && ($r['data']['completed'] ?? false) === true, "HTTP $s");
    }
}
[$s] = $a->call('GET', '/lessons/abc');
check('Lección con id no numérico → 404', $s === 404, "HTTP $s");
[$s] = $a->call('GET', '/admin/students');
check('Estudiante en /admin/students → 403', $s === 403, "HTTP $s");
[$s] = $a->call('GET', '/admin/students/1');
check('Estudiante en /admin/students/{id} → 403', $s === 403, "HTTP $s");

// ------------------------------------------------------------------ CodeBot
echo "\nCodeBot: historial, duplicados y aislamiento entre estudiantes\n";
[$s, $r] = $a->call('POST', '/tutor/conversations', []);
$convA = (int) ($r['data']['conversation']['id'] ?? 0);
check('Crear conversación → 201', $s === 201 && $convA > 0, "HTTP $s");
[$s, $r] = $a->call('POST', '/tutor/conversations', []);
check('Segunda creación sin mensajes reutiliza la misma (sin duplicados)', in_array($s, [200, 201], true) && (int) ($r['data']['conversation']['id'] ?? 0) === $convA, "HTTP $s");
[$s, $r] = $a->call('GET', '/tutor/conversations');
$own = array_filter($r['data']['conversations'] ?? [], fn ($c) => $c['id'] === $convA);
check('El historial lista la conversación una sola vez', $s === 200 && count($own) === 1 && count($r['data']['conversations']) === 1);
check('El historial informa el límite diario', isset($r['data']['usage']['remaining']));

$b = new Client($base);
[$s] = $b->call('POST', '/auth/register', ['full_name' => 'Beto Prueba', 'email' => $emailB, 'password' => $password, 'password_confirmation' => $password]);
check('Registro del estudiante B → 201', $s === 201, "HTTP $s");
[$s] = $b->call('GET', "/tutor/conversations/$convA");
check('B no puede leer la conversación de A → 404', $s === 404, "HTTP $s");
[$s] = $b->call('POST', "/tutor/conversations/$convA/messages", ['message' => 'hola']);
check('B no puede escribir en la conversación de A → 404', $s === 404, "HTTP $s");
[$s] = $b->call('POST', "/tutor/conversations/$convA/archive", []);
check('B no puede archivar la conversación de A → 404', $s === 404, "HTTP $s");
[$s, $r] = $b->call('GET', '/tutor/conversations');
check('El historial de B no incluye conversaciones de A', $s === 200 && ($r['data']['conversations'] ?? null) === []);
[$s] = $a->call('GET', '/tutor/conversations/abc');
check('Id de conversación inválido → 400', $s === 400, "HTTP $s");
[$s] = $a->call('POST', "/tutor/conversations/$convA/messages", ['message' => '']);
check('Mensaje vacío → 422', $s === 422, "HTTP $s");
[$s] = $a->call('POST', "/tutor/conversations/$convA/messages", ['message' => str_repeat('a', 2001)]);
check('Mensaje de más de 2000 caracteres → 422', $s === 422, "HTTP $s");

[$s, $r] = $a->call('POST', "/tutor/conversations/$convA/messages", ['message' => 'Explícame en tres pasos qué es la abstracción.']);
if ($expectGemini) {
    $answer = $r['data']['assistant_message']['content'] ?? '';
    check('Gemini responde de verdad (HTTP 200, texto no vacío)', $s === 200 && trim($answer) !== '', "HTTP $s " . ($r['error'] ?? ''));
    [$s, $r] = $a->call('GET', "/tutor/conversations/$convA");
    $roles = array_column($r['data']['messages'] ?? [], 'role');
    check('El intercambio queda guardado (user + model)', $roles === ['user', 'model'], json_encode($roles));
    check('El título se toma de la primera pregunta', ($r['data']['conversation']['title'] ?? '') !== 'Nueva conversación');
    [$s, $r] = $a->call('POST', '/tutor/conversations', []);
    check('Con mensajes, "Nueva conversación" crea otra distinta', $s === 201 && (int) ($r['data']['conversation']['id'] ?? 0) !== $convA, "HTTP $s");
} else {
    check('Sin GEMINI_API_KEY la API responde 503 con mensaje claro', $s === 503 && str_contains((string) ($r['error'] ?? ''), 'GEMINI_API_KEY'), "HTTP $s");
    [$s, $r] = $a->call('GET', "/tutor/conversations/$convA");
    check('Si Gemini no responde no se guardan mensajes a medias', $s === 200 && ($r['data']['messages'] ?? null) === []);
}

[$s] = $a->call('POST', "/tutor/conversations/$convA/archive", []);
check('Archivar conversación propia → 200', $s === 200, "HTTP $s");
[$s] = $a->call('GET', "/tutor/conversations/$convA");
check('La conversación archivada ya no se puede abrir → 404', $s === 404, "HTTP $s");

// --------------------------------------------------------- fuerza bruta
echo "\nLimitación de intentos de inicio de sesión\n";
$c = new Client($base);
$codes = [];
for ($i = 0; $i < 9; $i++) {
    [$codes[]] = $c->call('POST', '/auth/login', ['email' => $emailB, 'password' => 'incorrecta1']);
}
check('Tras 8 intentos fallidos el 9.º recibe 429', array_slice($codes, 0, 8) === array_fill(0, 8, 401) && $codes[8] === 429, json_encode($codes));
[$s] = $c->call('POST', '/auth/login', ['email' => $emailB, 'password' => $password]);
check('Durante el bloqueo, incluso la contraseña correcta espera (429)', $s === 429, "HTTP $s");

echo "\nResultado: $passed correctas, $failed fallidas.\n";
exit($failed === 0 ? 0 : 1);
