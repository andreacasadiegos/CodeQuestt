# Publicar CodeQuest en internet

En internet CodeQuest usa dos servicios gratuitos:

| Parte | Tecnología | Dónde se publica |
| --- | --- | --- |
| Frontend | React (Vite) | Vercel (página estática) |
| Backend (API) | PHP | Vercel (función `api/index.php` con el runtime `vercel-php`) |
| Base de datos | PostgreSQL | Supabase |

`vercel.json` (en la raíz del repositorio) le dice a Vercel que:

- compile el frontend (`frontend/`) y publique `frontend/dist`;
- envíe todo lo que empiece por `/api/` a la función PHP `api/index.php`,
  que carga la misma API de `backend/` que se usa con XAMPP;
- devuelva `index.html` en las demás rutas (para que recargar `/registro`
  no dé 404).

Como frontend y API comparten dominio, la cookie de sesión funciona igual
que en XAMPP. En Vercel la sesión se guarda en la tabla `php_sessions` de
Supabase (se crea sola), porque cada petición puede ir a un servidor distinto.

> En el computador nada cambia: XAMPP + MySQL + `backend/config/config.php`.
> En Vercel no hay `config.php`; la conexión se lee de la variable
> `DATABASE_URL`.

## 1. Crear la base de datos en Supabase

1. Entra a <https://supabase.com>, pulsa **New project**, ponle un nombre,
   genera una contraseña de base de datos y **guárdala**.
2. Abre **SQL Editor → New query**, pega **todo** el archivo
   `database/supabase/codequest_supabase.sql` y pulsa **Run**.
   (Al final se ve una fila `setval = 1`: es normal.)
3. En **Table Editor** deben aparecer 16 tablas; `activities` tiene 28 filas.

El archivo incluye todo lo de `database/01` a `06` traducido a PostgreSQL
y activa RLS en todas las tablas, para que nadie pueda leerlas desde la API
pública de Supabase. La función PHP se conecta como `postgres`, dueño de
las tablas, y no se ve afectada.

## 2. Configurar Vercel

En el proyecto de Vercel:

1. **Settings → General → Root Directory:** déjalo **vacío** (la raíz del
   repositorio) y pulsa **Save**. Si dice `frontend`, Vercel no ve
   `vercel.json` ni la carpeta `api/`.
2. **Settings → Environment Variables → Add:**
   - **Key:** `DATABASE_URL`
   - **Value:** la cadena de Supabase **Connect → Session pooler**, con tu
     contraseña en lugar de `[YOUR-PASSWORD]` (sin corchetes):

     ```text
     postgresql://postgres.abcdefghijk:TU_CONTRASEÑA@aws-0-us-east-1.pooler.supabase.com:5432/postgres
     ```

   - Marca **Production** y **Preview**, y pulsa **Save**.
3. **Deployments →** los tres puntos del último despliegue **→ Redeploy**
   (o haz merge/push y Vercel publica solo).
4. Comprueba `https://TU-PROYECTO.vercel.app/api/health`: debe mostrar
   `"database": "conectada"`. Luego regístrate desde la página.

> Usa **Session pooler** y no «Direct connection»: la conexión directa
> solo funciona con IPv6 y Vercel no la soporta.

## Problemas frecuentes

| Síntoma | Causa | Solución |
| --- | --- | --- |
| «No se pudo conectar con la API (código 404)» | Root Directory sigue en `frontend` | Paso 2.1 y vuelve a desplegar |
| `/api/health` responde 500 «Falta backend/config/config.php» | No existe la variable `DATABASE_URL` o se agregó después del despliegue | Paso 2.2 y **Redeploy** |
| `/api/health` dice `"database": "sin conexión"` | Contraseña o cadena incorrecta | Revisa que el usuario sea `postgres.` + id del proyecto y que no queden corchetes |
| La contraseña tiene `@`, `:` o `/` | Rompen la URL | Cambia la contraseña en Supabase por una sin esos símbolos, o escríbelos como `%40`, `%3A`, `%2F` |
| Se inicia sesión pero luego pide entrar otra vez | Se llama a la API desde otro dominio | No uses `VITE_API_URL`; deja que `vercel.json` envíe `/api` |
| El proyecto de Supabase aparece en pausa | Los proyectos gratis se pausan tras una semana sin uso | En Supabase pulsa **Restore project** |

## Alternativa: backend en un hosting PHP

Si prefieres no usar la función de Vercel, sube `backend/` a cualquier
hosting con PHP 8.2+ (por ejemplo alwaysdata), crea allí
`backend/config/config.php` con `'driver' => 'pgsql'` y los datos de
Supabase (ver `config.example.php`), y cambia la primera regla de
`vercel.json` para que apunte a ese hosting:

```json
{ "source": "/api/:path*", "destination": "https://TU-HOSTING/backend/api/:path*" }
```
