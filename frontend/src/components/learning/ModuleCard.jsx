import { Link } from 'react-router-dom';

import ProgressBar from '../ui/ProgressBar.jsx';

const STATUS_LABELS = {
  no_iniciado: 'Sin empezar',
  en_curso: 'En curso',
  completado: 'Completado',
};

/** Tarjeta de un módulo con su avance, para el panel. */
export default function ModuleCard({ module }) {
  const { progress } = module;

  return (
    <Link to={`/modulos/${module.slug}`} className="cq-card cq-module-card text-reset">
      <div className="d-flex justify-content-between align-items-start mb-3">
        <span className="cq-icon-tile"><i className={`bi ${module.icon}`} aria-hidden="true" /></span>
        <span className={`cq-status cq-status-${progress.status}`}>{STATUS_LABELS[progress.status]}</span>
      </div>
      <h3 className="h5 fw-bold mb-1">{module.name}</h3>
      <p className="cq-muted small mb-3">{module.description}</p>
      <div className="mt-auto">
        <div className="d-flex justify-content-between small mb-2">
          <span className="cq-muted">
            {progress.lessons_completed}/{progress.lessons_total} lecciones
          </span>
          <span className="fw-semibold">{progress.percent}%</span>
        </div>
        <ProgressBar value={progress.percent} label={`Avance en ${module.name}`} />
      </div>
    </Link>
  );
}
