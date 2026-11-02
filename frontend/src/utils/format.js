/** "2026-11-02 21:27:48" -> "2 nov. 2026" */
export function formatDate(value) {
  const date = new Date(value.replace(' ', 'T'));
  return Number.isNaN(date.getTime())
    ? value
    : date.toLocaleDateString('es-CO', { day: 'numeric', month: 'short', year: 'numeric' });
}
