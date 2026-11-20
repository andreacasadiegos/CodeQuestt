# Configurar CodeBot con Google Gemini

CodeBot usa Gemini desde PHP en el servidor. El navegador nunca se conecta directamente a Google ni recibe la clave.

## 1. Crear la clave

1. Abre [Google AI Studio](https://aistudio.google.com/app/apikey).
2. Crea una API key para un proyecto de Google.
3. Copia la clave y guárdala en un gestor de secretos. No la pegues en el chat, en React ni en GitHub.

## 2. Configurar en Vercel

En el proyecto de Vercel abre **Settings → Environment Variables** y agrega:

| Variable | Valor |
| --- | --- |
| `GEMINI_API_KEY` | Tu clave de Google AI Studio |
| `GEMINI_MODEL` | `gemini-2.5-flash-lite` |

Selecciona los entornos que uses (Production, Preview y/o Development) y vuelve a desplegar para que las variables estén disponibles.

## 3. Configurar localmente con XAMPP

Configura las variables en el entorno de Apache/PHP, por ejemplo en la configuración del VirtualHost:

```apache
SetEnv GEMINI_API_KEY "TU_CLAVE_LOCAL"
SetEnv GEMINI_MODEL "gemini-2.5-flash-lite"
```

Reinicia Apache. No guardes la clave en un archivo que se suba al repositorio. Si tu configuración local no permite SetEnv, define las variables en el entorno del proceso Apache siguiendo la configuración de tu instalación.

## 4. Límites iniciales

- Máximo 20 mensajes del estudiante en una ventana móvil de 24 horas.
- Máximo 2.000 caracteres por mensaje.
- Máximo 12 mensajes previos enviados como contexto al modelo.
- Máximo 900 tokens de salida por respuesta.
- Máximo 50 conversaciones activas en la lista del estudiante.
- Timeout de 35 segundos para la llamada a Gemini.

Estos límites son un punto de partida para una prueba piloto, no un presupuesto monetario garantizado. Los límites de cuota y precios del proveedor pueden cambiar y se administran también desde Google AI Studio / Google Cloud.


### Límite por estudiante y presupuesto global

El límite de 20 mensajes se aplica por cuenta y por ventana móvil de 24 horas. Junto con el máximo de salida y el contexto corto, reduce el consumo individual. **No equivale a un tope monetario global garantizado**: el consumo total depende también del número de estudiantes activos. Para el piloto, configura y revisa cuotas del proyecto en Google AI Studio / Google Cloud y establece alertas de presupuesto en Cloud Billing cuando el proyecto tenga facturación habilitada. Las cuotas del proveedor son el límite técnico adicional.

## 5. Aplicar la migración de historial

Ejecuta **solo una** migración, según el motor de la base de datos:

- MySQL/XAMPP: `database/migrations/20261120_tutor_gemini_mysql.sql`
- Supabase/PostgreSQL: `database/supabase/migracion_codebot.sql`

Son migraciones aditivas. No ejecutes `database/01_schema.sql` para habilitar CodeBot, porque ese script elimina y vuelve a crear la base de datos.

## 6. Endpoints privados

Todos requieren sesión autenticada:

- `GET /api/tutor/conversations`
- `POST /api/tutor/conversations`
- `GET /api/tutor/conversations/{id}`
- `POST /api/tutor/conversations/{id}/messages` con `{"message":"..." }`
- `POST /api/tutor/conversations/{id}/archive`

El backend obtiene el identificador del estudiante desde la sesión y filtra cada conversación por propietario. La clave Gemini se envía al proveedor en el encabezado `x-goog-api-key`.

## 7. Antes de producción

1. Prueba el aislamiento entre dos cuentas: una cuenta no debe poder consultar, enviar mensajes ni archivar conversaciones de la otra.
2. Verifica el límite diario con una cuenta de prueba.
3. Confirma que los errores de Gemini no se guarden como respuestas en el historial.
4. Revisa el uso, cuota y facturación en Google AI Studio.
5. Informa a los estudiantes que los mensajes se guardan en el historial de CodeQuest y se envían a Google para generar las respuestas.
