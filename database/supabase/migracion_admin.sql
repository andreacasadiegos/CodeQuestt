-- =====================================================================
-- CodeQuest: rol de administrador (Supabase / PostgreSQL)
--
-- Para una base que ya existe. En Supabase: SQL Editor -> New query,
-- cambia el correo de la última línea por el de la cuenta que será
-- administradora (debe estar ya registrada en CodeQuest) y pulsa Run.
-- Se puede ejecutar varias veces sin problema.
-- =====================================================================

ALTER TABLE users ADD COLUMN IF NOT EXISTS role VARCHAR(20) NOT NULL DEFAULT 'estudiante';

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_users_role') THEN
    ALTER TABLE users ADD CONSTRAINT chk_users_role CHECK (role IN ('estudiante', 'admin'));
  END IF;
END $$;

-- Convertir una cuenta en administradora:
UPDATE users SET role = 'admin' WHERE email = lower('CORREO_DEL_ADMIN@ejemplo.com');

-- Comprobar quién es administrador:
SELECT id, full_name, email, role FROM users WHERE role = 'admin';
