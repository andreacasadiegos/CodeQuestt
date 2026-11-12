# Publicar CodeQuest en internet

CodeQuest tiene tres partes y cada una necesita un lugar distinto:

| Parte | Tecnología | Dónde se publica |
| --- | --- | --- |
| Frontend | React (Vite) | Vercel |
| Backend (API) | PHP | Un hosting con PHP y Apache (por ejemplo, alwaysdata) |
| Base de datos | PostgreSQL | Supabase |

**Vercel solo publica el frontend.** No ejecuta PHP ni guarda datos. Por eso,
si solo se sube el proyecto a Vercel, el registro muestra
«No se pudo conectar con la API (código 404)»: el navegador pide `/api/...`
y en Vercel no existe nada en esa dirección.

La solución es:

1. Crear la base de datos en Supabase.
2. Publicar el backend PHP en un hosting y conectarlo con Supabase.
3. Hacer que Vercel reenvíe `/api` a ese backend (archivo `frontend/vercel.json`).

Como el navegador sigue hablando con `code-questt.vercel.app`, la cookie de
sesión funciona igual que en XAMPP.

> El backend funciona con las dos bases: MySQL en XAMPP para trabajar en el
> computador, y PostgreSQL (Supabase) en internet. Solo cambia `config.php`.

## 1. Crear la base de datos en Supabase

1. Entra a <https://supabase.com>, inicia sesión y pulsa **New project**.
   - **Name:** `codequest`.
   - **Database Password:** pulsa **Generate a password** y **guárdala**;
     la necesitarás en el paso 2.
   - **Region:** la más cercana (por ejemplo, *East US*).
2. Cuando el proyecto termine de crearse, abre **SQL Editor → New query**.
3. Abre el archivo `database/supabase/codequest_supabase.sql` del
   repositorio, copia **todo** su contenido, pégalo y pulsa **Run**.
   Debe terminar con «Success. No rows returned».
4. Comprueba en **Table Editor** que aparecen 16 tablas. Por ejemplo,
   `activities` debe tener 28 filas y `questions` 89.

El archivo ya incluye todo lo de `database/01` a `06` (tablas, lecciones,
actividades, retos e insignias), traducido a PostgreSQL. También activa
RLS en todas las tablas para que nadie pueda leerlas desde la API pública
de Supabase; el backend PHP no se ve afectado.

### Datos de conexión

En Supabase pulsa **Connect** (arriba) y busca **Session pooler**. Verás
algo como:

```text
postgresql://postgres.abcdefghijk:[YOUR-PASSWORD]@aws-0-us-east-1.pooler.supabase.com:5432/postgres
```

De ahí salen los datos para `config.php`:

| Dato | Ejemplo |
| --- | --- |
| host | `aws-0-us-east-1.pooler.supabase.com` |
| port | `5432` |
| name | `postgres` |
| user | `postgres.abcdefghijk` |
| password | La contraseña que guardaste al crear el proyecto |

> Usa **Session pooler** y no «Direct connection»: la conexión directa
> solo funciona con IPv6, y muchos hostings no lo tienen.

## 2. Publicar el backend PHP (alwaysdata, gratis)

> Se recomienda alwaysdata porque su plan gratuito incluye PHP 8 y Apache
> con `.htaccess`, y no bloquea las peticiones que llegan desde Vercel.
> Evita InfinityFree: su protección anti‑bots bloquea las APIs.

1. Crea una cuenta en <https://www.alwaysdata.com> (plan **Free**).
   Elige un nombre de cuenta, por ejemplo `codequest`. Tu sitio será
   `https://codequest.alwaysdata.net`.
2. Con un cliente FTP (FileZilla) o desde **Remote access → FTP**, sube la
   carpeta `backend/` completa dentro de `www/`. Debe quedar
   `www/backend/api/index.php`.
3. Dentro de `www/backend/config/` crea `config.php` copiando
   `config.example.php`, y cambia el bloque `db` y el entorno:

   ```php
   'db' => [
       'driver'   => 'pgsql',
       'host'     => 'aws-0-us-east-1.pooler.supabase.com',
       'port'     => 5432,
       'name'     => 'postgres',
       'user'     => 'postgres.abcdefghijk',
       'password' => 'LA_CONTRASEÑA_DE_SUPABASE',
       'sslmode'  => 'require',
   ],
   'app' => [
       'env'      => 'production',
       'timezone' => 'America/Bogota',
   ],
   ```

4. Abre `https://codequest.alwaysdata.net/backend/api/health`. Debe mostrar
   `"status": "ok"` y `"database": "conectada"`.

## 3. Conectar Vercel con el backend

1. En `frontend/vercel.json` reemplaza `https://TU-BACKEND.alwaysdata.net`
   por la dirección real del paso anterior, por ejemplo:

   ```json
   "destination": "https://codequest.alwaysdata.net/backend/api/:path*"
   ```

2. Guarda, haz commit y push. Vercel vuelve a publicar solo.
3. En Vercel, **Settings → General → Root Directory** debe ser `frontend`
   (así Vercel encuentra `vercel.json` y `package.json`).
4. Prueba: `https://code-questt.vercel.app/api/health` debe mostrar el mismo
   JSON del backend. Luego regístrate desde la página.

## Problemas frecuentes

| Síntoma | Causa | Solución |
| --- | --- | --- |
| «No se pudo conectar con la API (código 404)» | `vercel.json` aún tiene `TU-BACKEND` o el Root Directory no es `frontend` | Revisa el paso 3 |
| `/api/health` responde 500 «Falta backend/config/config.php» | No se creó `config.php` en el hosting | Paso 2.3 |
| `/api/health` dice `"database": "sin conexión"` | Datos de Supabase incorrectos | Revisa host, usuario (`postgres.` + id del proyecto) y contraseña. Usa el **Session pooler** |
| Supabase muestra «Tenant or user not found» | El usuario no lleva el id del proyecto | El usuario es `postgres.abcdefghijk`, no solo `postgres` |
| Al recargar una página (por ejemplo `/registro`) sale 404 de Vercel | Falta la regla final de `vercel.json` | No borres la regla que envía todo a `/index.html` |
| Se inicia sesión pero luego pide entrar otra vez | Se está llamando al backend directamente (otro dominio) | No uses `VITE_API_URL`; deja que `vercel.json` reenvíe `/api` |
| El proyecto de Supabase aparece en pausa | Los proyectos gratis se pausan tras una semana sin uso | En el panel de Supabase pulsa **Restore project** |
