/** Mensaje de error o éxito con ícono. */
export default function Alert({ type = 'danger', children }) {
  if (!children) return null;

  const icon = type === 'success' ? 'bi-check-circle-fill' : 'bi-exclamation-triangle-fill';

  return (
    <div className={`cq-alert cq-alert-${type} mb-3`} role={type === 'danger' ? 'alert' : 'status'}>
      <i className={`bi ${icon} mt-1`} aria-hidden="true" />
      <div>{children}</div>
    </div>
  );
}
