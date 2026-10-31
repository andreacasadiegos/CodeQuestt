import { useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';

import LessonContent from '../components/learning/LessonContent.jsx';
import Alert from '../components/ui/Alert.jsx';
import CodeBlock from '../components/ui/CodeBlock.jsx';
import ErrorState from '../components/ui/ErrorState.jsx';
import LoadingScreen from '../components/ui/LoadingScreen.jsx';
import ProgressBar from '../components/ui/ProgressBar.jsx';
import { useApi } from '../hooks/useApi.js';
import { completeLesson, getLesson } from '../services/learningService.js';

/** Página de una lección: explicación, ejemplo y botón para continuar. */
export default function LessonPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { data, loading, error, reload } = useApi(() => getLesson(id), [id]);
  const [saving, setSaving] = useState(false);
  const [saveError, setSaveError] = useState('');

  if (loading) return <LoadingScreen message="Cargando la lección…" />;
  if (error) return <ErrorState error={error} onRetry={reload} />;

  const { lesson, module, position, total, previous_lesson_id: previousId } = data;

  const handleComplete = async () => {
    setSaving(true);
    setSaveError('');
    try {
      const result = await completeLesson(lesson.id);
      navigate(result.next_lesson_id ? `/lecciones/${result.next_lesson_id}` : `/modulos/${module.slug}`);
      window.scrollTo({ top: 0 });
    } catch (err) {
      setSaveError(err.message);
    } finally {
      setSaving(false);
    }
  };

  return (
    <section className="container py-4 py-lg-5">
      <div className="mx-auto" style={{ maxWidth: 820 }}>
        <nav aria-label="Ruta de navegación" className="small mb-3">
          <Link to="/panel" className="cq-muted">Panel</Link>
          <span className="cq-muted mx-2">/</span>
          <Link to={`/modulos/${module.slug}`} className="cq-muted">{module.name}</Link>
          <span className="cq-muted mx-2">/</span>
          <span>Lección {position}</span>
        </nav>

        <article key={lesson.id} className="cq-card p-4 p-md-5 cq-fade-up">
          <div className="d-flex justify-content-between align-items-center gap-3 mb-2">
            <span className="cq-eyebrow">
              <i className={`bi ${module.icon}`} aria-hidden="true" /> {module.name}
            </span>
            <span className="cq-muted small cq-code">{position} / {total}</span>
          </div>
          <ProgressBar value={position} max={total} label="Posición en el módulo" />

          <h1 className="h2 fw-bold mt-4 mb-4">{lesson.title}</h1>
          <LessonContent text={lesson.content} />

          {lesson.example && (
            <>
              <h2 className="h6 fw-bold mt-4 mb-2">
                <i className="bi bi-lightbulb me-2" style={{ color: 'var(--cq-xp)' }} aria-hidden="true" />
                Ejemplo
              </h2>
              <CodeBlock code={lesson.example} />
            </>
          )}

          <Alert>{saveError}</Alert>

          <div className="d-flex flex-wrap justify-content-between gap-2 mt-4">
            {previousId ? (
              <Link to={`/lecciones/${previousId}`} className="btn btn-cq btn-cq-outline">
                <i className="bi bi-arrow-left" aria-hidden="true" /> Anterior
              </Link>
            ) : (
              <Link to={`/modulos/${module.slug}`} className="btn btn-cq btn-cq-outline">
                <i className="bi bi-arrow-left" aria-hidden="true" /> Módulo
              </Link>
            )}
            <button type="button" className="btn btn-cq btn-cq-primary" onClick={handleComplete} disabled={saving}>
              {saving ? 'Guardando…' : (
                <>
                  {lesson.completed ? 'Continuar' : 'Entendido, continuar'}
                  <i className="bi bi-arrow-right" aria-hidden="true" />
                </>
              )}
            </button>
          </div>
        </article>
      </div>
    </section>
  );
}
