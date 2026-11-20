<?php
/**
 * API privada de CodeBot e historial persistente.
 */
declare(strict_types=1);

final class TutorController
{
    /** Preguntas a Gemini permitidas por estudiante cada 24 horas. */
    private const DAILY_MESSAGE_LIMIT = 20;
    private const MAX_NEW_CONVERSATIONS_PER_DAY = 30;

    private TutorConversation $conversations;

    public function __construct()
    {
        $this->conversations = new TutorConversation();
    }

    public function index(array $params): never
    {
        $userId = (int) $params['userId'];
        $used = $this->conversations->countUserMessagesSince($userId, date('Y-m-d H:i:s', time() - 86400));

        Response::json([
            'conversations' => $this->conversations->allForUser($userId),
            'usage' => [
                'daily_limit' => self::DAILY_MESSAGE_LIMIT,
                'remaining' => max(0, self::DAILY_MESSAGE_LIMIT - $used),
            ],
        ]);
    }

    public function create(array $params): never
    {
        $userId = (int) $params['userId'];

        // Si ya hay una conversación vacía, se reutiliza: no se duplican.
        $existing = $this->conversations->findEmptyForUser($userId);
        if ($existing !== null) {
            Response::json([
                'conversation' => $this->conversations->findForUser($existing, $userId),
                'messages' => [],
                'reused' => true,
            ]);
        }

        $limiter = new RateLimiter();
        $key = 'tutor-create:' . $userId;
        if ($limiter->tooMany($key, self::MAX_NEW_CONVERSATIONS_PER_DAY, 86400)) {
            Response::error('Creaste muchas conversaciones hoy. Continúa en una de las que ya tienes.', 429);
        }
        $limiter->hit($key, 86400);

        $id = $this->conversations->create($userId);
        $conversation = $this->conversations->findForUser($id, $userId);
        Response::json(['conversation' => $conversation, 'messages' => [], 'reused' => false], 201);
    }

    public function show(array $params): never
    {
        $userId = (int) $params['userId'];
        $id = filter_var($params['id'] ?? null, FILTER_VALIDATE_INT);
        if (!$id || $id < 1) {
            Response::error('La conversación solicitada no es válida.', 400);
        }

        $conversation = $this->conversations->findForUser($id, $userId);
        if ($conversation === null) {
            Response::error('No encontramos esa conversación.', 404);
        }

        Response::json([
            'conversation' => $conversation,
            'messages' => $this->conversations->messages($id),
        ]);
    }

    public function send(array $params): never
    {
        $userId = (int) $params['userId'];
        $id = filter_var($params['id'] ?? null, FILTER_VALIDATE_INT);
        if (!$id || $id < 1) {
            Response::error('La conversación solicitada no es válida.', 400);
        }

        $conversation = $this->conversations->findForUser($id, $userId);
        if ($conversation === null) {
            Response::error('No encontramos esa conversación.', 404);
        }

        $question = Request::string('message');
        if ($question === '' || mb_strlen($question) > 2000) {
            Response::error('Escribe un mensaje de máximo 2000 caracteres.', 422, [
                'message' => 'El mensaje es obligatorio y debe tener máximo 2000 caracteres.',
            ]);
        }

        // Límite controlado: máximo DAILY_MESSAGE_LIMIT mensajes del estudiante cada 24 horas.
        $since = date('Y-m-d H:i:s', time() - 86400);
        $used = $this->conversations->countUserMessagesSince($userId, $since);
        if ($used >= self::DAILY_MESSAGE_LIMIT) {
            Response::error('Alcanzaste el límite diario de CodeBot. Puedes volver a escribir mañana.', 429);
        }

        $profile = (new User())->findProfile($userId);
        $pathName = $profile['path']['name'] ?? '';
        $history = $this->conversations->recentMessages($id, 12);
        $history[] = ['role' => 'user', 'content' => $question];

        try {
            $answer = (new GeminiTutorService())->reply($history, $pathName);
        } catch (TutorUnavailableException $e) {
            Response::error($e->getMessage(), $e->getCode() ?: 502);
        }

        // Guardar el intercambio solo cuando Gemini respondió correctamente.
        $this->conversations->saveExchange($id, $userId, $question, $answer);
        Response::json([
            'conversation' => $this->conversations->findForUser($id, $userId),
            'user_message' => ['role' => 'user', 'content' => $question],
            'assistant_message' => ['role' => 'model', 'content' => $answer],
            'usage' => [
                'daily_limit' => self::DAILY_MESSAGE_LIMIT,
                'remaining' => max(0, self::DAILY_MESSAGE_LIMIT - $used - 1),
            ],
        ]);
    }

    public function archive(array $params): never
    {
        $userId = (int) $params['userId'];
        $id = filter_var($params['id'] ?? null, FILTER_VALIDATE_INT);
        if (!$id || $id < 1 || !$this->conversations->archive($id, $userId)) {
            Response::error('No encontramos esa conversación.', 404);
        }
        Response::json(['message' => 'Conversación archivada.']);
    }
}
