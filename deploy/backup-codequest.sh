#!/usr/bin/env bash
# Copia de seguridad diaria de la base de CodeQuest (solo lectura: no modifica datos).
# Instalar:  sudo install -m 750 deploy/backup-codequest.sh /usr/local/bin/
# Cron:      15 2 * * *  /usr/local/bin/backup-codequest.sh
# Credenciales: MySQL en /root/.my.cnf ([mysqldump] user=… password=…),
#               PostgreSQL en /root/.pgpass. Nunca en este script.
set -euo pipefail

DEST=/var/backups/codequest
KEEP_DAYS=14
ENGINE=${CODEQUEST_DB_ENGINE:-mysql}   # mysql | pgsql
DB=${CODEQUEST_DB_NAME:-codequest_db}
STAMP=$(date +%Y%m%d-%H%M)

umask 077
mkdir -p "$DEST"

if [ "$ENGINE" = "pgsql" ]; then
  pg_dump --no-owner --format=custom -h 127.0.0.1 -U "${CODEQUEST_DB_USER:-codequest}" "$DB" \
    > "$DEST/codequest-$STAMP.dump"
else
  mysqldump --single-transaction --routines --triggers "$DB" | gzip > "$DEST/codequest-$STAMP.sql.gz"
fi

find "$DEST" -type f -mtime +"$KEEP_DAYS" -name 'codequest-*' -delete
echo "Copia creada en $DEST ($STAMP)"
