import { Link } from 'react-router-dom';

/** Mensaje de error de una página, con opción de reintentar o volver. */
export default function ErrorState({ error, onRetry, backTo = '/panel', backLabel = 'Volver al panel' }) {
  return (
    <section className="container py-5">
      <div className="cq-card p-4 p-md-5 mx-auto text-center" style={{ maxWidth: 560 }}>
        <span className="cq-icon-soft mb-3" style={{ color: 'var(--cq-danger)' }}>
          <i className="bi bi-exclamation-triangle" aria-hidden="true" />
        </span>
        <p className="mb-4">{error?.message ?? 'Ocurrió un error inesperado.'}</p>
        <div className="d-flex justify-content-center gap-2 flex-wrap">
          {onRetry && (
            <button type="button" className="btn btn-cq btn-cq-outline" onClick={onRetry}>
              <i className="bi bi-arrow-clockwise" aria-hidden="true" /> Reintentar
            </button>
          )}
          <Link to={backTo} className="btn btn-cq btn-cq-primary">{backLabel}</Link>
        </div>
      </div>
    </section>
  );
}
