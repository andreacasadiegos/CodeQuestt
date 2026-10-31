import ModuleCard from '../components/learning/ModuleCard.jsx';
import LoadingScreen from '../components/ui/LoadingScreen.jsx';
import { useApi } from '../hooks/useApi.js';
import { useAuth } from '../hooks/useAuth.js';
import { getModules } from '../services/learningService.js';

/**
 * Panel del estudiante (versión de la Etapa 6).
 * Muestra los datos reales guardados en MySQL: nombre, ruta, nivel, XP
 * y el avance en los tres módulos.
 * En las Etapas 7 y 8 se agregan actividades, insignias y retos.
 */
export default function DashboardPage() {
  const { user } = useAuth();
  const firstName = user.full_name.split(' ')[0];
  const { data, loading, error, reload } = useApi(getModules);

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

      <div className="d-flex align-items-end justify-content-between mt-5 mb-3">
        <h2 className="h4 fw-bold mb-0">Tus módulos</h2>
        <span className="cq-muted small">Contenido de la {user.path.name.toLowerCase()}</span>
      </div>

      {loading && <LoadingScreen message="Cargando tus módulos…" />}
      {error && (
        <div className="cq-alert cq-alert-danger">
          <i className="bi bi-exclamation-triangle-fill mt-1" aria-hidden="true" />
          <div>
            {error.message}{' '}
            <button type="button" className="btn btn-link p-0 align-baseline" onClick={reload}>Reintentar</button>
          </div>
        </div>
      )}
      {data && (
        <div className="row g-4">
          {data.modules.map((module) => (
            <div key={module.id} className="col-md-6 col-lg-4">
              <ModuleCard module={module} />
            </div>
          ))}
        </div>
      )}
    </section>
  );
}
