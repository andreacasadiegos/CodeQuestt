# Publicar CodeQuest en internet

CodeQuest tiene tres partes y cada una necesita un lugar distinto:

| Parte | Tecnología | Dónde se publica |
| --- | --- | --- |
| Frontend | React (Vite) | Vercel |
| Backend (API) | PHP | Un hosting con PHP y Apache (por ejemplo, alwaysdata) |
| Base de datos | MySQL | El mismo hosting del backend |

**Vercel solo publica el frontend.** No ejecuta PHP ni tiene MySQL. Por eso,
si solo se sube el proyecto a Vercel, el registro muestra
«No se pudo conectar con la API (código 404)»: el navegador pide `/api/...`
y en Vercel no existe nada en esa dirección.

La solución es publicar el backend y la base de datos en un hosting PHP y
decirle a Vercel que reenvíe `/api` a ese servidor (archivo
`frontend/vercel.json`). Como el navegador sigue hablando con
`code-questt.vercel.app`, la cookie de sesión funciona igual que en XAMPP.

## 1. Publicar el backend y la base de datos (alwaysdata, gratis)

> Se recomienda alwaysdata porque su plan gratuito (100 MB) incluye PHP 8,
> Apache con `.htaccess` y MySQL, y no bloquea las peticiones que llegan
> desde Vercel. Evita InfinityFree: su protección anti‑bots bloquea las APIs.

1. Crea una cuenta en <https://www.alwaysdata.com> (plan **Free**).
   Elige un nombre de cuenta, por ejemplo `codequest`. Tu sitio será
   `https://codequest.alwaysdata.net`.
2. **Base de datos:** en el panel, **Databases → MySQL → Add a database**.
   Ponle un nombre (alwaysdata le agrega tu cuenta como prefijo, por ejemplo
   `codequest_db`). En **Databases → MySQL → Users** anota el usuario y la
   contraseña. El servidor es `mysql-codequest.alwaysdata.net`.
3. **Cargar las tablas:** abre **phpMyAdmin** desde el panel, selecciona tu
   base y en la pestaña **SQL** ejecuta, en orden, los archivos de
   `database/` (del 01 al 06).
   - Antes de ejecutar cada archivo, borra la línea `USE codequest_db;`
     (phpMyAdmin ya usa la base que seleccionaste).
   - En `01_schema.sql` borra además el bloque `DROP DATABASE ...` y
     `CREATE DATABASE ...`, porque en el hosting la base ya existe y no
     tienes permiso para crear otra.
4. **Subir el backend:** con un cliente FTP (FileZilla) o desde
   **Remote access → FTP**, sube la carpeta `backend/` completa dentro de
   `www/`. Debe quedar `www/backend/api/index.php`.
5. **Configuración:** dentro de `www/backend/config/` crea `config.php`
   copiando `config.example.php` y cambia:

   ```php
   'db' => [
       'host'     => 'mysql-codequest.alwaysdata.net',
       'port'     => 3306,
       'name'     => 'codequest_db',      // el nombre real de tu base
       'user'     => 'codequest',         // tu usuario MySQL
       'password' => 'TU_CONTRASEÑA',
       'charset'  => 'utf8mb4',
   ],
   'app' => [
       'env'      => 'production',
       'timezone' => 'America/Bogota',
   ],
   ```

6. **Comprobar:** abre `https://codequest.alwaysdata.net/backend/api/health`.
   Debe mostrar un JSON con `"status": "ok"`.

## 2. Conectar Vercel con el backend

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
| «No se pudo conectar con la API (código 404)» | `vercel.json` aún tiene `TU-BACKEND` o el Root Directory no es `frontend` | Revisa el paso 2 |
| `/api/health` responde 500 «Falta backend/config/config.php» | No se creó `config.php` en el hosting | Paso 1.5 |
| `/api/health` responde 500 con error de conexión | Datos de MySQL incorrectos | Revisa host, usuario, contraseña y nombre de la base |
| Al recargar una página (por ejemplo `/registro`) sale 404 de Vercel | Falta la regla final de `vercel.json` | No borres la regla que envía todo a `/index.html` |
| Se inicia sesión pero luego pide entrar otra vez | Se está llamando al backend directamente (otro dominio) | No uses `VITE_API_URL`; deja que `vercel.json` reenvíe `/api` |
