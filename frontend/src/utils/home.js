/** Página de inicio de cada usuario según su rol y si ya hizo el diagnóstico. */
export function homeFor(user) {
  if (user.role === 'admin') return '/admin';
  return user.needs_diagnostic ? '/diagnostico' : '/panel';
}
