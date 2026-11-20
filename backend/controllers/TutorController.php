<?php
/**
 * API privada de CodeBot e historial persistente.
 */
declare(strict_types=1);

final class TutorController
{
    private TutorConversation $conversations;

    public function __construct()
    {
        $this->conversations = new TutorConversation();
    }

    public function index(array $params): never
    {
        Response::json(['conversations' => $this->conversations->allForUser((int) $params['userId'])]);
    }

    public function create(array $params): never
    {
        $id = $this->conversations->create((int) $params['userId']);
        $conversation = $this->conversations->findForUser($id, (int) $params['userId']);
        Response::json(['conversation' => $conversation, 'messages' => []], 201);
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

        // Límite controlado: máximo 20 mensajes del estudiante cada 24 horas.
        $since = date('Y-m-d H:i:s', time() - 86400);
        if ($this->conversations->countUserMessagesSince($userId, $since) >= 20) {
            Response::error('Alcanzaste el límite diario de CodeBot. Puedes volver a escribir mañana.', 429);
        }

        $profile = (new User())->findProfile($userId);
        $pathName = $profile['path']['name'] ?? '';
        $history = $this->conversations->recentMessages($id, 12);
        $history[] = ['role' => 'user', 'content' => $question];

        try {
            $answer = (new GeminiTutorService())->reply($history, $pathName);
        } catch (RuntimeException $e) {
            $status = str_contains($e->getMessage(), 'configurado') ? 503 : (str_contains($e->getMessage(), 'muchas solicitudes') ? 429 : 502);
            Response::error($e->getMessage(), $status);
        }

        // Guardar el intercambio solo cuando Gemini respondió correctamente.
        $this->conversations->saveExchange($id, $userId, $question, $answer);
        Response::json([
            'conversation' => $this->conversations->findForUser($id, $userId),
            'user_message' => ['role' => 'user', 'content' => $question],
            'assistant_message' => ['role' => 'model', 'content' => $answer],
            'usage' => ['daily_limit' => 20],
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
