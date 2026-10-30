/**
 * Validaciones de formularios en el navegador.
 * Usan las mismas reglas que backend/core/Validator.php para que el
 * estudiante vea los errores antes de enviar. El backend vuelve a validar.
 */

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;
const NAME_REGEX = /^\p{L}[\p{L} '-]*$/u;

export function validateRegister({ full_name, email, password, password_confirmation }) {
  const errors = {};
  const name = full_name.trim().replace(/\s+/g, ' ');
  const mail = email.trim();

  if (!name) errors.full_name = 'Escribe tu nombre completo.';
  else if (name.length < 3 || name.length > 120) errors.full_name = 'El nombre completo debe tener entre 3 y 120 caracteres.';
  else if (!NAME_REGEX.test(name)) errors.full_name = 'El nombre solo puede contener letras y espacios.';

  if (!mail) errors.email = 'Escribe tu correo electrónico.';
  else if (!EMAIL_REGEX.test(mail)) errors.email = 'Escribe un correo electrónico válido.';
  else if (mail.length > 120) errors.email = 'El correo electrónico debe tener entre 5 y 120 caracteres.';

  if (!password) errors.password = 'Escribe una contraseña.';
  else if (password.length < 8 || password.length > 72) errors.password = 'La contraseña debe tener entre 8 y 72 caracteres.';
  else if (!/\p{L}/u.test(password) || !/\d/.test(password)) errors.password = 'La contraseña debe incluir al menos una letra y un número.';

  if (!password_confirmation) errors.password_confirmation = 'Confirma tu contraseña.';
  else if (password_confirmation !== password) errors.password_confirmation = 'Las contraseñas no coinciden.';

  return errors;
}

export function validateLogin({ email, password }) {
  const errors = {};
  const mail = email.trim();

  if (!mail) errors.email = 'Escribe tu correo electrónico.';
  else if (!EMAIL_REGEX.test(mail)) errors.email = 'Escribe un correo electrónico válido.';

  if (!password) errors.password = 'Escribe tu contraseña.';

  return errors;
}

/** Reglas de contraseña para mostrar como lista de verificación. */
export function passwordChecks(password) {
  return [
    { label: 'Mínimo 8 caracteres', ok: password.length >= 8 },
    { label: 'Al menos una letra', ok: /\p{L}/u.test(password) },
    { label: 'Al menos un número', ok: /\d/.test(password) },
  ];
}
