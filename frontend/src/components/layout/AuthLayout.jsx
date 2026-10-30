import { Link } from 'react-router-dom';

/**
 * Diseño de las páginas de registro e inicio de sesión:
 * a la izquierda un panel de marca y a la derecha el formulario.
 */
export default function AuthLayout({ title, subtitle, children, footer }) {
  return (
    <section className="container py-4 py-lg-5">
      <div className="row g-0 cq-card overflow-hidden cq-fade-up mx-auto" style={{ maxWidth: 1040 }}>
        <aside className="col-lg-5 cq-auth-aside d-none d-lg-flex flex-column justify-content-between p-5">
          <div>
            <span className="cq-eyebrow mb-4">
              <i className="bi bi-joystick" aria-hidden="true" /> modo aventura
            </span>
            <h2 className="fw-bold mt-3 mb-3">Cada reto superado es un nivel más.</h2>
            <p className="cq-muted mb-0">
              Aprende abstracción, patrones y algoritmos jugando, ganando XP y desbloqueando insignias.
            </p>
          </div>
          <ul className="list-unstyled cq-auth-perks mb-0">
            <li><i className="bi bi-signpost-split" aria-hidden="true" /> Ruta según lo que ya sabes</li>
            <li><i className="bi bi-lightning-charge" aria-hidden="true" /> Puntos XP por cada acierto</li>
            <li><i className="bi bi-award" aria-hidden="true" /> Insignias y niveles</li>
          </ul>
        </aside>

        <div className="col-lg-7 p-4 p-sm-5">
          <h1 className="h3 fw-bold mb-1">{title}</h1>
          <p className="cq-muted mb-4">{subtitle}</p>
          {children}
          {footer && <p className="cq-muted text-center mt-4 mb-0">{footer}</p>}
          <p className="text-center mt-3 mb-0 small">
            <Link to="/" className="cq-muted">
              <i className="bi bi-arrow-left me-1" aria-hidden="true" /> Volver al inicio
            </Link>
          </p>
        </div>
      </div>
    </section>
  );
}
