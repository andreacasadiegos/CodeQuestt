import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';

import Alert from '../components/ui/Alert.jsx';
import CodeBlock from '../components/ui/CodeBlock.jsx';
import LoadingScreen from '../components/ui/LoadingScreen.jsx';
import ProgressBar from '../components/ui/ProgressBar.jsx';
import { useAuth } from '../hooks/useAuth.js';
import { getDiagnostic, submitDiagnostic } from '../services/learningService.js';

const EXPERIENCE_ICONS = { 1: 'bi-egg', 2: 'bi-tree', 3: 'bi-rocket-takeoff' };
const LETTERS = ['A', 'B', 'C', 'D', 'E'];

/**
 * Diagnóstico inicial en tres fases:
 *   1. Autoevaluación (¿cuál es tu experiencia?).
 *   2. Prueba de 5 preguntas, una por pantalla.
 *   3. Resultado: ruta asignada y retroalimentación de cada pregunta.
 * La calificación y la ruta las decide el servidor.
 */
export default function DiagnosticPage() {
  const { user, refreshUser } = useAuth();
  const navigate = useNavigate();

  const [diagnostic, setDiagnostic] = useState(null);
  const [phase, setPhase] = useState('loading'); // loading | intro | quiz | result
  const [experience, setExperience] = useState(null);
  const [index, setIndex] = useState(0);
  const [answers, setAnswers] = useState({});
  const [result, setResult] = useState(null);
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    getDiagnostic()
      .then((data) => {
        setDiagnostic(data);
        setPhase('intro');
      })
      .catch(async (err) => {
        // Si ya lo hizo (409), actualizamos la sesión y la ruta protegida lo lleva al panel.
        if (err.status === 409) {
          await refreshUser();
          return;
        }
        setError(err.message);
        setPhase('intro');
      });
  }, [refreshUser]);

  if (phase === 'loading') return <LoadingScreen message="Preparando tu diagnóstico…" />;

  const questions = diagnostic?.questions ?? [];
  const question = questions[index];
  const isLast = index === questions.length - 1;

  const handleSubmit = async () => {
    setSubmitting(true);
    setError('');
    try {
      const payload = questions.map((q) => ({ question_id: q.id, option_id: answers[q.id] }));
      const data = await submitDiagnostic(experience, payload);
      setResult(data);
      setPhase('result');
      window.scrollTo({ top: 0, behavior: 'smooth' });
    } catch (err) {
      setError(err.message);
    } finally {
      setSubmitting(false);
    }
  };

  const goToDashboard = async () => {
    await refreshUser();
    navigate('/panel', { replace: true });
  };

  return (
    <section className="container py-4 py-lg-5">
      <div className="mx-auto" style={{ maxWidth: 760 }}>
        {/* ---------- Fase 1: autoevaluación ---------- */}
        {phase === 'intro' && (
          <div className="cq-card p-4 p-md-5 cq-fade-up">
            <span className="cq-eyebrow mb-3">paso 1 de 2 · autoevaluación</span>
            <h1 className="h3 fw-bold mt-3">
              ¡Hola, {user.full_name.split(' ')[0]}! ¿Cuál es tu experiencia en programación?
            </h1>
            <p className="cq-muted mb-4">
              No hay respuestas buenas ni malas: nos ayuda a elegir tu punto de partida.
            </p>

            <Alert>{error}</Alert>

            {diagnostic && (
              <div className="d-grid gap-3" role="radiogroup" aria-label="Experiencia en programación">
                {diagnostic.experience_options.map((option) => (
                  <button
                    key={option.value}
                    type="button"
                    role="radio"
                    aria-checked={experience === option.value}
                    className={`cq-choice cq-choice-lg ${experience === option.value ? 'is-selected' : ''}`}
                    onClick={() => setExperience(option.value)}
                  >
                    <i className={`bi ${EXPERIENCE_ICONS[option.value]}`} aria-hidden="true" />
                    <span className="fw-semibold">{option.label}</span>
                  </button>
                ))}
              </div>
            )}

            <div className="d-flex justify-content-end mt-4">
              <button
                type="button"
                className="btn btn-cq btn-cq-primary"
                disabled={!experience}
                onClick={() => setPhase('quiz')}
              >
                Continuar a la prueba <i className="bi bi-arrow-right" aria-hidden="true" />
              </button>
            </div>
          </div>
        )}

        {/* ---------- Fase 2: prueba ---------- */}
        {phase === 'quiz' && question && (
          <div key={question.id} className="cq-card p-4 p-md-5 cq-fade-up">
            <div className="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
              <span className="cq-eyebrow">paso 2 de 2 · prueba corta</span>
              <span className="cq-muted cq-code small">
                Pregunta {index + 1} de {questions.length}
              </span>
            </div>
            <ProgressBar value={index + 1} max={questions.length} label="Avance de la prueba" />

            <h2 className="h4 fw-bold mt-4 mb-3">{question.statement}</h2>
            <CodeBlock code={question.code_snippet} />

            <div className="d-grid gap-2" role="radiogroup" aria-label="Opciones de respuesta">
              {question.options.map((option, i) => {
                const selected = answers[question.id] === option.id;
                return (
                  <button
                    key={option.id}
                    type="button"
                    role="radio"
                    aria-checked={selected}
                    className={`cq-choice ${selected ? 'is-selected' : ''}`}
                    onClick={() => setAnswers((current) => ({ ...current, [question.id]: option.id }))}
                  >
                    <span className="cq-choice-key">{LETTERS[i]}</span>
                    <span>{option.text}</span>
                  </button>
                );
              })}
            </div>

            <div className="mt-4">
              <Alert>{error}</Alert>
            </div>

            <div className="d-flex justify-content-between">
              <button
                type="button"
                className="btn btn-cq btn-cq-outline"
                onClick={() => (index === 0 ? setPhase('intro') : setIndex(index - 1))}
              >
                <i className="bi bi-arrow-left" aria-hidden="true" /> Anterior
              </button>
              {isLast ? (
                <button
                  type="button"
                  className="btn btn-cq btn-cq-primary"
                  disabled={!answers[question.id] || submitting}
                  onClick={handleSubmit}
                >
                  {submitting ? 'Calificando…' : <>Ver mi resultado <i className="bi bi-flag" aria-hidden="true" /></>}
                </button>
              ) : (
                <button
                  type="button"
                  className="btn btn-cq btn-cq-primary"
                  disabled={!answers[question.id]}
                  onClick={() => setIndex(index + 1)}
                >
                  Siguiente <i className="bi bi-arrow-right" aria-hidden="true" />
                </button>
              )}
            </div>
          </div>
        )}

        {/* ---------- Fase 3: resultado ---------- */}
        {phase === 'result' && result && (
          <div className="cq-card p-4 p-md-5 cq-fade-up">
            <div className="cq-result-hero">
              <div className="cq-score-ring" style={{ '--score': (result.correct * 100) / result.total }}>
                {result.correct}/{result.total}
              </div>
              <p className="cq-muted mb-1">Tu ruta de aprendizaje es</p>
              <h1 className="h2 fw-bold cq-gradient-text">{result.path.name}</h1>
              <p className="mx-auto mb-0" style={{ maxWidth: 520 }}>{result.reason}</p>
            </div>

            <h2 className="h5 fw-bold mt-4 mb-2">Revisa tus respuestas</h2>
            {questions.map((q, i) => {
              const review = result.results.find((r) => r.question_id === q.id);
              const correctText = q.options.find((o) => o.id === review.correct_option_id)?.text;
              return (
                <div key={q.id} className="cq-review-item">
                  <i className={`bi ${review.is_correct ? 'bi-check-circle-fill' : 'bi-x-circle-fill'} fs-4`} aria-hidden="true" />
                  <div>
                    <p className="fw-semibold mb-1">{i + 1}. {q.statement}</p>
                    {!review.is_correct && (
                      <p className="small mb-1">
                        Respuesta correcta: <strong>{correctText}</strong>
                      </p>
                    )}
                    <p className="cq-muted small mb-0">{review.explanation}</p>
                  </div>
                </div>
              );
            })}

            <div className="text-center mt-4">
              <button type="button" className="btn btn-cq btn-cq-primary btn-lg" onClick={goToDashboard}>
                Ir a mi panel <i className="bi bi-arrow-right" aria-hidden="true" />
              </button>
            </div>
          </div>
        )}
      </div>
    </section>
  );
}
