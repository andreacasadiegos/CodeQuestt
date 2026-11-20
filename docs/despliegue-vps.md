# Publicar CodeQuest en un VPS (Linux)

Esta guía no supone una configuración previa del servidor. Primero revisa
qué hay instalado y elige la variante que corresponda.

```bash
lsb_release -a; nginx -v; apache2 -v; php -v; mysql --version; psql --version
```

## 1. Qué necesita CodeQuest

| Pieza | Requisito | Notas |
| --- | --- | --- |
| Frontend | Node.js 20+ **solo para compilar** | `npm run build` genera `frontend/dist/` (archivos estáticos) |
| Backend | PHP 8.2+ con `pdo_mysql` o `pdo_pgsql`, `mbstring`, `curl` (o `allow_url_fopen`) | Se ejecuta con PHP-FPM |
| Base de datos | MySQL 8 / MariaDB 10.6+ **o** PostgreSQL 14+ (o Supabase) | La misma que uses hoy |
| Servidor web | Nginx **o** Apache 2.4 | Ejemplos en `deploy/` |
| HTTPS | Certbot (Let's Encrypt) | Obligatorio: la cookie de sesión se marca `Secure` |

Frontend y API se publican **en el mismo dominio** (`/` y `/api`), igual que
en Vercel y en XAMPP. Así la cookie de sesión funciona sin CORS: no hace
falta `VITE_API_URL` ni cabeceras CORS. Si algún día la API vive en otro
dominio, habría que añadir CORS con credenciales y `SameSite=None`; hoy no
se necesita y por eso no está habilitado.

`vercel.json` y `api/index.php` se conservan: solo los usa Vercel y no
estorban en el VPS.

## 2. Paquetes (Ubuntu 22.04/24.04)

```bash
sudo apt update
sudo apt install nginx php8.3-fpm php8.3-mysql php8.3-pgsql php8.3-mbstring php8.3-curl \
                 certbot python3-certbot-nginx git
# Base local (elige una):
sudo apt install mariadb-server        # o: sudo apt install postgresql
# Node.js 20+ para compilar (por ejemplo con nodesource o nvm).
```

## 3. Código

```bash
sudo mkdir -p /var/www && cd /var/www
sudo git clone https://github.com/andreacasadiegos/CodeQuestt.git codequest
cd codequest && sudo git checkout feature/codequest-evolution   # o main tras el merge
cd frontend && npm ci && npm run build
```

Permisos: el código es de root y solo legible por PHP; nadie escribe en él.

```bash
sudo chown -R root:www-data /var/www/codequest
sudo find /var/www/codequest -type d -exec chmod 750 {} \;
sudo find /var/www/codequest -type f -exec chmod 640 {} \;
sudo mkdir -p /var/log/php && sudo chown www-data:www-data /var/log/php
```

## 4. Base de datos

**Nunca** ejecutes `database/01_schema.sql` ni `database/supabase/codequest_supabase.sql`
sobre una base con datos reales: borran y recrean todo. Úsalos solo para una
base **nueva**.

### Base nueva en MySQL/MariaDB

```bash
sudo mysql < database/01_schema.sql      # crea codequest_db (vacía)
for f in 02_seed_catalogos 03_seed_diagnostico 04_seed_contenido 05_seed_actividades 06_seed_retos; do
  sudo mysql < database/$f.sql
done
sudo mysql codequest_db < database/migrations/20261120_tutor_gemini_mysql.sql
sudo mysql -e "CREATE USER 'codequest'@'127.0.0.1' IDENTIFIED BY 'CONTRASEÑA_LARGA';
  GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX ON codequest_db.* TO 'codequest'@'127.0.0.1';"
```

(`CREATE` se necesita una sola vez: la API crea sola las tablas auxiliares
`php_sessions` y `api_rate_limits` con `CREATE TABLE IF NOT EXISTS`.)

### Base existente (migrar desde XAMPP o Supabase)

1. Haz una copia: `mysqldump --single-transaction codequest_db > respaldo.sql`
   o `pg_dump -Fc ... > respaldo.dump`.
2. Restaura esa copia en el VPS.
3. Aplica solo migraciones aditivas e idempotentes:
   - MySQL: `database/migrations/20261120_tutor_gemini_mysql.sql`
   - PostgreSQL/Supabase: `database/supabase/migracion_codebot.sql` (también activa RLS)

### Seguir usando Supabase

No hace falta base local: pon en `DATABASE_URL` la cadena **Session pooler**
de Supabase y deja `DB_SSLMODE` sin definir (usa `require`).

## 5. Variables de entorno (secretos)

Se declaran en el pool de PHP-FPM, porque PHP-FPM borra el entorno del
sistema. Copia y edita `deploy/php-fpm-codequest.conf`:

```bash
sudo cp deploy/php-fpm-codequest.conf /etc/php/8.3/fpm/pool.d/codequest.conf
sudo nano /etc/php/8.3/fpm/pool.d/codequest.conf
sudo chown root:root /etc/php/8.3/fpm/pool.d/codequest.conf && sudo chmod 600 /etc/php/8.3/fpm/pool.d/codequest.conf
sudo systemctl restart php8.3-fpm
```

| Variable | Obligatoria | Ejemplo / valor |
| --- | --- | --- |
| `DATABASE_URL` | Sí | `mysql://usuario:clave@127.0.0.1:3306/codequest_db` o `postgresql://usuario:clave@host:5432/db` |
| `DB_SSLMODE` | No | `disable` para PostgreSQL local; por defecto `require` |
| `APP_ENV` | No | `production` (por defecto): oculta detalles de errores |
| `APP_TIMEZONE` | No | `America/Bogota` (por defecto) |
| `SESSION_HANDLER` | No | `files` en un solo servidor; `database` (por defecto) si hay varios |
| `SESSION_COOKIE_SECURE` | Recomendada | `1`: la cookie solo viaja por HTTPS |
| `GEMINI_API_KEY` | Para CodeBot | Clave de Google AI Studio. Nunca en `VITE_*` ni en Git |
| `GEMINI_MODEL` | No | `gemini-2.5-flash-lite` (por defecto) |
| `TRUST_PROXY` | No | `1` solo si hay un balanceador delante de Nginx |

Si la contraseña de la base tiene `@`, `:` o `/`, escríbelos como `%40`, `%3A`, `%2F`.

Alternativa a las variables: `backend/config/config.php` (copiado de
`config.example.php`, con permisos `640 root:www-data`). Si existe, tiene
prioridad sobre `DATABASE_URL`.

## 6. Servidor web y HTTPS

### Nginx (recomendado)

```bash
sudo cp deploy/nginx-codequest.conf /etc/nginx/sites-available/codequest
sudo nano /etc/nginx/sites-available/codequest      # dominio y versión de PHP
sudo ln -s /etc/nginx/sites-available/codequest /etc/nginx/sites-enabled/
# Opcional (recomendado): en /etc/nginx/nginx.conf, dentro de http { }:
#   limit_req_zone $binary_remote_addr zone=codequest_api:10m rate=30r/s;
# y descomenta limit_req / limit_req_status en el sitio.
sudo nginx -t && sudo systemctl reload nginx
sudo certbot --nginx -d tu-dominio.edu.co
```

### Apache

```bash
sudo a2enmod rewrite headers ssl proxy_fcgi setenvif
sudo cp deploy/apache-codequest.conf /etc/apache2/sites-available/codequest.conf
sudo a2ensite codequest && sudo apache2ctl configtest && sudo systemctl reload apache2
sudo certbot --apache -d tu-dominio.edu.co
```

Ambas configuraciones publican solo `frontend/dist` y `backend/api/index.php`;
`config.php`, `database/`, `backend/tests/` y `.git` no son accesibles.
Las rutas de la SPA (`/panel`, `/tutor`, `/admin`…) devuelven `index.html`.

## 7. Comprobación

```bash
curl https://tu-dominio.edu.co/api/health        # "database": "conectada"
curl -I https://tu-dominio.edu.co/panel          # 200 (SPA)
```

Después regístrate desde la página y abre CodeBot. Para pruebas completas,
usa una **base de pruebas** (nunca la de producción):

```bash
CQ_API_URL=https://pruebas.tu-dominio/api CQ_ALLOW_TEST_WRITES=1 php backend/tests/api_integration_test.php
```

## 8. Administrador

Registra la cuenta normalmente y ejecuta (cambiando el correo):
`database/08_rol_admin.sql` (MySQL, solo la línea `UPDATE` si la columna ya
existe) o `database/supabase/migracion_admin.sql` (PostgreSQL).

## 9. Logs

| Qué | Dónde |
| --- | --- |
| Accesos y errores web | `/var/log/nginx/codequest.*.log` (o `${APACHE_LOG_DIR}/codequest.*`) |
| Errores PHP y de Gemini | `/var/log/php/codequest-error.log` |

Los logs de Gemini guardan el código HTTP y un fragmento del error del
proveedor, nunca la clave ni los mensajes del estudiante. Rota los logs con
logrotate (ya configurado para Nginx; agrega `/var/log/php/*.log`).

## 10. Copias de seguridad

```bash
sudo install -m 750 deploy/backup-codequest.sh /usr/local/bin/
sudo crontab -e     # 15 2 * * *  /usr/local/bin/backup-codequest.sh
```

Guarda las credenciales en `/root/.my.cnf` o `/root/.pgpass`, no en el
script. Copia periódicamente `/var/backups/codequest` fuera del VPS y prueba
restaurar una copia de vez en cuando.

## 11. Actualizar

```bash
cd /var/www/codequest && sudo git pull
cd frontend && npm ci && npm run build
sudo systemctl reload php8.3-fpm
```

Si la actualización trae una migración nueva, haz copia antes y aplícala.
