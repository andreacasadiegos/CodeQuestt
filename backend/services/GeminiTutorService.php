<?php
/**
 * Adaptador del servicio Gemini. La clave se lee solo desde el entorno del servidor.
 */
declare(strict_types=1);

final class GeminiTutorService
{
    private const MAX_OUTPUT_TOKENS = 900;

    public function reply(array $history, string $pathName): string
    {
        // La clave vive solo en el servidor: variable de entorno (Vercel,
        // PHP-FPM) o, como alternativa, config.php (que no se sube a Git).
        $settings = self::settings();
        $apiKey = $settings['api_key'];
        if ($apiKey === '') {
            throw new TutorUnavailableException('CodeBot aún no está configurado. El administrador debe agregar GEMINI_API_KEY en el servidor.', 503);
        }

        $model = $settings['model'];
        if (!preg_match('/^[a-zA-Z0-9._-]{3,80}$/', $model)) {
            throw new TutorUnavailableException('La configuración del modelo de CodeBot no es válida.', 503);
        }

        $contents = [];
        foreach ($history as $message) {
            if (!in_array($message['role'], ['user', 'model'], true)) {
                continue;
            }
            $contents[] = [
                'role' => $message['role'],
                'parts' => [['text' => (string) $message['content']]],
            ];
        }

        $system = "Eres CodeBot, tutor educativo de CodeQuest para estudiantes de grado 11. "
            . "Enseñas abstracción, patrones y algoritmos con lenguaje claro, ejemplos cotidianos y fragmentos pequeños de pseudocódigo o código. "
            . "Explica paso a paso, numerando los pasos cuando el tema lo requiera, y ofrece un ejemplo concreto. "
            . "Cuando el estudiante quiera practicar, plantea un ejercicio corto acorde a su nivel y espera su respuesta antes de corregirlo. "
            . "La ruta actual del estudiante es: " . ($pathName !== '' ? $pathName : 'aún no definida') . ". "
            . "Adapta la dificultad a esa ruta. Da pistas graduales y pregunta qué intentó el estudiante antes de revelar una solución completa. "
            . "Explica los errores con respeto y termina con un pequeño paso práctico cuando sea útil. "
            . "No afirmes modificar XP, notas, insignias, cuentas ni progreso: no tienes acceso para hacerlo. "
            . "No solicites contraseñas, claves API, datos personales ni información sensible. "
            . "Si la pregunta no trata de aprendizaje, programación o uso educativo de CodeQuest, responde brevemente y redirige al propósito del tutor. "
            . "Responde en español, con formato legible y sin inventar datos del curso.";

        $payload = [
            'systemInstruction' => ['parts' => [['text' => $system]]],
            'contents' => $contents,
            'generationConfig' => [
                'temperature' => 0.55,
                'maxOutputTokens' => self::MAX_OUTPUT_TOKENS,
            ],
        ];

        $url = 'https://generativelanguage.googleapis.com/v1beta/models/'
            . rawurlencode($model) . ':generateContent';
        $body = json_encode($payload, JSON_UNESCAPED_UNICODE);
        if ($body === false) {
            throw new TutorUnavailableException('No se pudo preparar la solicitud de CodeBot.', 500);
        }

        $response = $this->postJson($url, $body, $apiKey);
        $decoded = json_decode($response['body'], true);
        if ($response['status'] < 200 || $response['status'] >= 300) {
            error_log('[CodeQuest Gemini] HTTP ' . $response['status'] . ': ' . substr($response['body'], 0, 500));
            if ($response['status'] === 429) {
                throw new TutorUnavailableException('CodeBot está recibiendo muchas solicitudes. Inténtalo en un momento.', 429);
            }
            throw new TutorUnavailableException('No fue posible obtener una respuesta de CodeBot. Inténtalo nuevamente.', 502);
        }

        // Gemini puede dividir la respuesta en varias partes: se unen todas.
        $text = '';
        foreach ($decoded['candidates'][0]['content']['parts'] ?? [] as $part) {
            if (is_array($part) && isset($part['text']) && is_string($part['text'])) {
                $text .= $part['text'];
            }
        }
        if (trim($text) === '') {
            $reason = $decoded['candidates'][0]['finishReason'] ?? ($decoded['promptFeedback']['blockReason'] ?? 'desconocido');
            error_log('[CodeQuest Gemini] Respuesta vacía. Motivo: ' . (is_string($reason) ? $reason : 'desconocido'));
            throw new TutorUnavailableException('CodeBot no pudo generar una respuesta a esa pregunta. Intenta reformularla.', 502);
        }

        return trim($text);
    }

    /** @return array{api_key: string, model: string} */
    private static function settings(): array
    {
        $fromConfig = [];
        try {
            $fromConfig = Config::get('gemini') ?? [];
        } catch (Throwable) {
            $fromConfig = [];
        }

        return [
            'api_key' => trim((string) (getenv('GEMINI_API_KEY') ?: ($fromConfig['api_key'] ?? ''))),
            'model'   => trim((string) (getenv('GEMINI_MODEL') ?: ($fromConfig['model'] ?? 'gemini-2.5-flash-lite'))),
        ];
    }

    private function postJson(string $url, string $body, string $apiKey): array
    {
        if (function_exists('curl_init')) {
            $curl = curl_init($url);
            curl_setopt_array($curl, [
                CURLOPT_POST => true,
                CURLOPT_POSTFIELDS => $body,
                CURLOPT_HTTPHEADER => ['Content-Type: application/json', 'x-goog-api-key: ' . $apiKey],
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_CONNECTTIMEOUT => 8,
                CURLOPT_TIMEOUT => 35,
            ]);
            $result = curl_exec($curl);
            $status = (int) curl_getinfo($curl, CURLINFO_HTTP_CODE);
            $error = curl_error($curl);
            curl_close($curl);
            if ($result === false) {
                error_log('[CodeQuest Gemini] cURL: ' . $error);
                throw new TutorUnavailableException('No se pudo conectar con CodeBot. Inténtalo nuevamente en un momento.', 502);
            }
            return ['status' => $status, 'body' => $result];
        }

        $context = stream_context_create(['http' => [
            'method' => 'POST',
            'header' => "Content-Type: application/json\r\n" . "x-goog-api-key: " . $apiKey . "\r\n",
            'content' => $body,
            'timeout' => 35,
            'ignore_errors' => true,
        ]]);
        $result = @file_get_contents($url, false, $context);
        $status = 0;
        foreach ($http_response_header ?? [] as $header) {
            if (preg_match('/^HTTP\/\S+\s+(\d{3})/', $header, $match)) {
                $status = (int) $match[1];
            }
        }
        if ($result === false) {
            error_log('[CodeQuest Gemini] No se pudo conectar (stream).');
            throw new TutorUnavailableException('No se pudo conectar con CodeBot. Inténtalo nuevamente en un momento.', 502);
        }
        return ['status' => $status, 'body' => $result];
    }
}
