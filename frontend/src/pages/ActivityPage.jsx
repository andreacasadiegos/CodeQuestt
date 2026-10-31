import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';

import ActivityRunner from '../components/activities/ActivityRunner.jsx';
import Difficulty from '../components/ui/Difficulty.jsx';
import ErrorState from '../components/ui/ErrorState.jsx';
import LoadingScreen from '../components/ui/LoadingScreen.jsx';
import { useApi } from '../hooks/useApi.js';
import { getActivity } from '../services/learningService.js';

const KIND_LABELS = { practica: 'Práctica', evaluacion: 'Evaluación del módulo', reto: 'Reto' };

/** Página de una actividad: encabezado con datos y el ejecutor de preguntas. */
export default function ActivityPage() {
  const { id } = useParams();
  const [round, setRound] = useState(0);
  const { data, loading, error, reload } = useApi(() => getActivity(id), [id, round]);

  if (loading) return <LoadingScreen message="Preparando la actividad…" />;
  if (error) return <ErrorState error={error} onRetry={reload} />;

  const { activity, module, questions, best, potential_xp: potentialXp } = data;

  return (
    <section className="container py-4 py-lg-5">
      <div className="mx-auto" style={{ maxWidth: 820 }}>
        <nav aria-label="Ruta de navegación" className="small mb-3">
          <Link to="/panel" className="cq-muted">Panel</Link>
          <span className="cq-muted mx-2">/</span>
          <Link to={`/modulos/${module.slug}`} className="cq-muted">{module.name}</Link>
          <span className="cq-muted mx-2">/</span>
          <span>{KIND_LABELS[activity.kind]}</span>
        </nav>

        <header className="cq-activity-header mb-3">
          <span className="cq-eyebrow">
            <i className={`bi ${module.icon}`} aria-hidden="true" /> {KIND_LABELS[activity.kind]}
          </span>
          <h1 className="h3 fw-bold mt-2 mb-2">{activity.title}</h1>
          <div className="d-flex flex-wrap gap-2 small">
            <span className="cq-chip"><Difficulty value={activity.difficulty} /></span>
            <span className="cq-chip"><i className="bi bi-question-circle" aria-hidden="true" /> {questions.length} preguntas</span>
            <span className="cq-chip"><i className="bi bi-check2-circle" aria-hidden="true" /> Aprueba con {activity.pass_pct}%</span>
            <span className="cq-chip cq-chip-xp">
              <i className="bi bi-lightning-charge-fill" aria-hidden="true" />
              {potentialXp > 0 ? ` Hasta ${potentialXp} XP` : ' XP ya obtenido'}
            </span>
            {best && <span className="cq-chip"><i className="bi bi-trophy" aria-hidden="true" /> Mejor: {best.best_score}%</span>}
          </div>
        </header>

        <ActivityRunner
          key={`${id}-${round}`}
          activity={activity}
          module={module}
          questions={questions}
          onRetry={() => {
            setRound((r) => r + 1);
            window.scrollTo({ top: 0 });
          }}
        />
      </div>
    </section>
  );
}

