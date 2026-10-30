import { useAuth } from '../hooks/useAuth.js';

/**
 * Panel del estudiante (versión de la Etapa 5).
 * Muestra los datos reales guardados en MySQL: nombre, ruta, nivel y XP.
 * En las Etapas 6 a 8 se agregan módulos, actividades, insignias y retos.
 */
export default function DashboardPage() {
  const { user } = useAuth();
  const firstName = user.full_name.split(' ')[0];

  return (
    <section className="container py-4 py-lg-5">
      <div className="cq-fade-up mb-4">
        <span className="cq-eyebrow">panel del estudiante</span>
        <h1 className="h2 fw-bold mt-3 mb-1">¡Bienvenido de nuevo, {firstName}!</h1>
        <p className="cq-muted mb-0">{user.full_name} · {user.email}</p>
      </div>

      <div className="row g-4">
        <div className="col-md-4">
          <div className="cq-card cq-stat-card cq-fade-up cq-delay-1">
            <span className="cq-icon-soft mb-3"><i className="bi bi-signpost-split" aria-hidden="true" /></span>
            <p className="cq-muted small mb-1">Ruta asignada</p>
            <p className="cq-stat-value mb-0">{user.path.name}</p>
          </div>
        </div>
        <div className="col-md-4">
          <div className="cq-card cq-stat-card cq-fade-up cq-delay-2">
            <span className="cq-icon-soft mb-3"><i className="bi bi-shield-fill-check" aria-hidden="true" /></span>
            <p className="cq-muted small mb-1">Nivel actual</p>
            <p className="cq-stat-value mb-0">{user.level.number} · {user.level.name}</p>
          </div>
        </div>
        <div className="col-md-4">
          <div className="cq-card cq-stat-card cq-fade-up cq-delay-3">
            <span className="cq-icon-soft mb-3" style={{ color: 'var(--cq-xp)' }}>
              <i className="bi bi-lightning-charge-fill" aria-hidden="true" />
            </span>
            <p className="cq-muted small mb-1">Puntos de experiencia</p>
            <p className="cq-stat-value mb-0">{user.xp_total} XP</p>
          </div>
        </div>
      </div>

      <div className="cq-card p-4 mt-4 d-flex align-items-center gap-3">
        <span className="cq-icon-tile"><i className="bi bi-map" aria-hidden="true" /></span>
        <p className="mb-0">
          Tu diagnóstico quedó guardado. Aquí aparecerán tus módulos, actividades e insignias a medida que avancemos
          en el desarrollo de la plataforma.
        </p>
      </div>
    </section>
  );
}
