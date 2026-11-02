import { Link } from 'react-router-dom';

import Difficulty from '../components/ui/Difficulty.jsx';
import ErrorState from '../components/ui/ErrorState.jsx';
import LoadingScreen from '../components/ui/LoadingScreen.jsx';
import ProgressBar from '../components/ui/ProgressBar.jsx';
import { useApi } from '../hooks/useApi.js';
import { getProgress } from '../services/gamificationService.js';
import { formatDate } from '../utils/format.js';

const KIND_LABELS = { practica: 'Práctica', evaluacion: 'Evaluación', reto: 'Reto' };

/**
 * Progreso detallado (RF-28, RF-29): avance por módulo, mejor resultado e
 * intentos por actividad, últimos intentos y movimientos de XP.
 */
export default function ProgressPage() {
  const { data, loading, error, reload } = useApi(getProgress);

  if (loading) return <LoadingScreen message="Cargando tu progreso…" />;
  if (error) return <ErrorState error={error} onRetry={reload} />;

  const { modules, attempts, xp_history: xpHistory } = data;

  return (
    <section className="container py-4 py-lg-5">
      <header className="mb-4 cq-fade-up">
        <span className="cq-eyebrow">seguimiento</span>
        <h1 className="h2 fw-bold mt-3 mb-1">Tu progreso</h1>
        <p className="cq-muted mb-0">Tu mejor resultado en cada actividad y todo lo que has hecho.</p>
      </header>

      <div className="d-grid gap-4">
        {modules.map((module) => (
          <article key={module.id} className="cq-card p-4">
            <div className="d-flex flex-wrap align-items-center gap-3 mb-3">
              <span className="cq-icon-tile"><i className={`bi ${module.icon}`} aria-hidden="true" /></span>
              <h2 className="h5 fw-bold mb-0 flex-grow-1">
                <Link to={`/modulos/${module.slug}`} className="text-reset">{module.name}</Link>
              </h2>
              <span className="fw-semibold">{module.progress.percent}%</span>
            </div>
            <ProgressBar value={module.progress.percent} label={`Avance en ${module.name}`} />
            <p className="cq-muted small mt-2">
              {module.progress.lessons_completed}/{module.progress.lessons_total} lecciones ·{' '}
              {module.progress.activities_passed}/{module.progress.activities_total} actividades aprobadas
            </p>

            <div className="table-responsive">
              <table className="table cq-table mb-0">
                <thead>
                  <tr>
                    <th scope="col">Actividad</th>
                    <th scope="col" className="d-none d-md-table-cell">Dificultad</th>
                    <th scope="col" className="text-end">Mejor</th>
                    <th scope="col" className="text-end">Intentos</th>
                  </tr>
                </thead>
                <tbody>
                  {module.activities.map((activity) => (
                    <tr key={activity.id}>
                      <td>
                        <span className={`cq-kind cq-kind-${activity.kind} me-2`}>{KIND_LABELS[activity.kind]}</span>
                        {activity.locked ? (
                          <span className="cq-muted">{activity.title}</span>
                        ) : (
                          <Link to={`/actividades/${activity.id}`}>{activity.title}</Link>
                        )}
                      </td>
                      <td className="d-none d-md-table-cell"><Difficulty value={activity.difficulty} /></td>
                      <td className="text-end">
                        {activity.best_score === null ? (
                          <span className="cq-muted">—</span>
                        ) : (
                          <span className={activity.passed ? 'text-success fw-semibold' : 'cq-warning-text'}>{activity.best_score}%</span>
                        )}
                      </td>
                      <td className="text-end">{activity.attempts}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </article>
        ))}
      </div>

      <div className="row g-4 mt-1">
        <div className="col-lg-7">
          <h2 className="h4 fw-bold mt-4 mb-3">Últimos intentos</h2>
          <div className="cq-card p-2 p-md-3">
            {attempts.length === 0 ? (
              <p className="cq-muted text-center my-3">Aún no has resuelto actividades.</p>
            ) : (
              <ul className="cq-history list-unstyled mb-0">
                {attempts.map((attempt) => (
                  <li key={attempt.id}>
                    <i className={`bi ${attempt.passed ? 'bi-check-circle-fill text-success' : 'bi-x-circle-fill cq-danger-text'}`} aria-hidden="true" />
                    <span className="flex-grow-1 min-w-0">
                      <span className="d-block fw-semibold text-truncate">{attempt.title}</span>
                      <span className="cq-muted small">
                        {attempt.module_name} · {attempt.correct}/{attempt.total} · {formatDate(attempt.submitted_at)}
                      </span>
                    </span>
                    <span className="text-end">
                      <span className="d-block fw-semibold">{attempt.score_pct}%</span>
                      <span className="small cq-xp-text">{attempt.xp_awarded > 0 ? `+${attempt.xp_awarded} XP` : ''}</span>
                    </span>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </div>
        <div className="col-lg-5">
          <h2 className="h4 fw-bold mt-4 mb-3">Historial de XP</h2>
          <div className="cq-card p-2 p-md-3">
            {xpHistory.length === 0 ? (
              <p className="cq-muted text-center my-3">Todavía no tienes XP.</p>
            ) : (
              <ul className="cq-history list-unstyled mb-0">
                {xpHistory.map((item) => (
                  <li key={item.id}>
                    <i className={`bi ${item.source === 'insignia' ? 'bi-award-fill' : 'bi-lightning-charge-fill'} cq-xp-text`} aria-hidden="true" />
                    <span className="flex-grow-1 min-w-0">
                      <span className="d-block text-truncate">{item.description}</span>
                      <span className="cq-muted small">{formatDate(item.created_at)}</span>
                    </span>
                    <span className="fw-semibold cq-xp-text">+{item.amount}</span>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </div>
      </div>
    </section>
  );
}
