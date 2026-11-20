<?php
/**
 * Error controlado de CodeBot. El código es el estado HTTP que verá el
 * estudiante (503 sin configurar, 429 límite de Gemini, 502 fallo externo)
 * y el mensaje es seguro para mostrar: nunca contiene la clave ni la
 * respuesta cruda de Gemini (esa solo va al log del servidor).
 */

declare(strict_types=1);

final class TutorUnavailableException extends RuntimeException
{
}
