import { Link, useParams } from 'react-router-dom';

import Difficulty from '../components/ui/Difficulty.jsx';
import ErrorState from '../components/ui/ErrorState.jsx';
import LoadingScreen from '../components/ui/LoadingScreen.jsx';
import ProgressBar from '../components/ui/ProgressBar.jsx';
import { useApi } from '../hooks/useApi.js';
import { getModule } from '../services/learningService.js';

/** Página de un módulo: descripción, avance, lecciones en orden y actividades. */
export default function ModulePage() {
  const { slug } = useParams();
  const { data, loading, error, reload } = useApi(() => getModule(slug), [slug]);

  if (loading) return <LoadingScreen message="Abriendo el módulo…" />;
  if (error) return <ErrorState error={error} onRetry={reload} />;

  const { module, progress, lessons, activities } = data;
  const nextLesson = lessons.find((lesson) => !lesson.completed && !lesson.locked);

  return (
    <section className="container py-4 py-lg-5">
      <nav aria-label="Ruta de navegación" className="small mb-3">
        <Link to="/panel" className="cq-muted">Panel</Link>
        <span className="cq-muted mx-2">/</span>
        <span>{module.name}</span>
      </nav>

      <header className="cq-card cq-module-header p-4 p-md-5 mb-4 cq-fade-up">
        <div className="d-flex flex-column flex-md-row gap-4 align-items-md-center">
          <span className="cq-icon-tile cq-icon-xl"><i className={`bi ${module.icon}`} aria-hidden="true" /></span>
          <div className="flex-grow-1">
            <span className="cq-eyebrow mb-2">módulo {module.sort_order}</span>
            <h1 className="h2 fw-bold mt-2 mb-1">{module.name}</h1>
            <p className="cq-muted mb-0">{module.description}</p>
          </div>
          <div className="cq-module-progress">
            <div className="d-flex justify-content-between small mb-2">
              <span className="cq-muted">Avance</span>
              <span className="fw-semibold">{progress.percent}%</span>
            </div>
            <ProgressBar value={progress.percent} label={`Avance en ${module.name}`} />
            {nextLesson && (
              <Link to={`/lecciones/${nextLesson.id}`} className="btn btn-cq btn-cq-primary w-100 mt-3">
                {progress.lessons_completed === 0 ? 'Empezar' : 'Continuar'} <i className="bi bi-play-fill" aria-hidden="true" />
              </Link>
            )}
          </div>
        </div>
      </header>

      <h2 className="h5 fw-bold mb-3">Lecciones</h2>
      <ol className="cq-lesson-list list-unstyled mb-0">
        {lessons.map((lesson, index) => {
          const icon = lesson.completed ? 'bi-check-lg' : lesson.locked ? 'bi-lock-fill' : 'bi-play-fill';
          const state = lesson.completed ? 'done' : lesson.locked ? 'locked' : 'open';
          const content = (
            <>
              <span className={`cq-lesson-dot is-${state}`}><i className={`bi ${icon}`} aria-hidden="true" /></span>
              <span className="flex-grow-1">
                <span className="cq-muted small d-block cq-code">Lección {index + 1}</span>
                <span className="fw-semibold">{lesson.title}</span>
              </span>
              <span className="cq-muted small">
                {lesson.completed ? 'Leída' : lesson.locked ? 'Bloqueada' : 'Disponible'}
              </span>
            </>
          );

          return (
            <li key={lesson.id}>
              {lesson.locked ? (
                <div className="cq-lesson-row is-locked" aria-disabled="true">{content}</div>
              ) : (
                <Link to={`/lecciones/${lesson.id}`} className="cq-lesson-row text-reset">{content}</Link>
              )}
            </li>
          );
        })}
      </ol>

      <h2 className="h5 fw-bold mt-5 mb-3">Actividades</h2>
      <div className="row g-3">
        {activities.map((activity) => (
          <div key={activity.id} className="col-md-6">
            <ActivityRow activity={activity} />
          </div>
        ))}
      </div>
    </section>
  );
}

const KIND_LABELS = { practica: 'Práctica', evaluacion: 'Evaluación', reto: 'Reto' };

function ActivityRow({ activity }) {
  const state = activity.passed ? 'done' : activity.locked ? 'locked' : 'open';
  const openIcon = activity.kind === 'reto' ? 'bi-controller' : 'bi-pencil-square';
  const icon = activity.passed ? 'bi-check-lg' : activity.locked ? 'bi-lock-fill' : openIcon;
  const status = activity.locked
    ? { practica: 'Lee su lección', evaluacion: 'Lee todas las lecciones', reto: 'Aprueba la evaluación' }[activity.kind]
    : activity.attempts > 0
      ? `Mejor: ${activity.best_score}%`
      : 'Sin intentos';

  const content = (
    <>
      <span className={`cq-lesson-dot is-${state}`}><i className={`bi ${icon}`} aria-hidden="true" /></span>
      <span className="flex-grow-1">
        <span className={`cq-kind cq-kind-${activity.kind}`}>{KIND_LABELS[activity.kind]}</span>
        <span className="fw-semibold d-block mt-1">{activity.title}</span>
        <span className="cq-muted small d-flex flex-wrap gap-2 mt-1">
          <Difficulty value={activity.difficulty} />
          <span><i className="bi bi-lightning-charge-fill cq-xp-text" aria-hidden="true" /> {activity.base_xp} XP</span>
          <span>{status}</span>
        </span>
      </span>
    </>
  );

  return activity.locked ? (
    <div className="cq-lesson-row is-locked h-100" aria-disabled="true">{content}</div>
  ) : (
    <Link to={`/actividades/${activity.id}`} className="cq-lesson-row text-reset h-100">{content}</Link>
  );
}
