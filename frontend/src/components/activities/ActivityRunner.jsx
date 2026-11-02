import { useState } from 'react';
import { Link } from 'react-router-dom';

import { useAuth } from '../../hooks/useAuth.js';
import { submitActivity } from '../../services/learningService.js';
import BadgeUnlocked from '../gamification/BadgeUnlocked.jsx';
import XpGain from '../gamification/XpGain.jsx';
import Alert from '../ui/Alert.jsx';
import ProgressBar from '../ui/ProgressBar.jsx';
import QuestionInput, { initialAnswer, isAnswered } from './QuestionInput.jsx';
import QuestionReview from './QuestionReview.jsx';

const TYPE_LABELS = {
  seleccion: 'Selección múltiple',
  patron: 'Identifica el patrón',
  completar_codigo: 'Completa el código',
  ordenar: 'Ordena los pasos',
  relacionar: 'Relaciona conceptos',
};

/**
 * Resuelve una actividad pregunta por pregunta y muestra el resultado.
 * La calificación y el XP los calcula el servidor; aquí solo se envían
 * las respuestas.
 */
export default function ActivityRunner({ activity, module, questions, onRetry }) {
  const { refreshUser } = useAuth();
  const [answers, setAnswers] = useState(() =>
    Object.fromEntries(questions.map((q) => [q.id, initialAnswer(q)])),
  );
  const [index, setIndex] = useState(0);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [result, setResult] = useState(null);

  const question = questions[index];
  const isLast = index === questions.length - 1;
  const answered = isAnswered(question, answers[question.id]);

  const handleSubmit = async () => {
    const missing = questions.findIndex((q) => !isAnswered(q, answers[q.id]));
    if (missing !== -1) {
      setIndex(missing);
      setError('Te falta responder esta pregunta.');
      return;
    }

    setSubmitting(true);
    setError('');
    try {
      const payload = questions.map((q) => ({ question_id: q.id, answer: answers[q.id] }));
      const graded = await submitActivity(activity.id, payload);
      setResult(graded);
      window.scrollTo({ top: 0 });
      refreshUser().catch(() => {});
    } catch (err) {
      setError(err.message);
    } finally {
      setSubmitting(false);
    }
  };

  // ---------- Resultado ----------
  if (result) {
    const continueTo = result.next_lesson_id ? `/lecciones/${result.next_lesson_id}` : `/modulos/${module.slug}`;
    return (
      <div className="cq-card p-4 p-md-5 cq-fade-up">
        <div className="cq-result-hero pt-0">
          <div className="cq-score-ring" style={{ '--score': result.score_pct }}>{result.score_pct}%</div>
          <h1 className="h3 fw-bold mb-1">
            {result.passed ? '¡Actividad aprobada!' : 'Aún no la apruebas'}
          </h1>
          <p className="cq-muted mb-0">
            {result.correct} de {result.total} correctas · se aprueba con {result.pass_pct}%
          </p>
        </div>

        <XpGain xp={result.xp} />
        {result.badges.length > 0 && <BadgeUnlocked badges={result.badges} />}

        <h2 className="h5 fw-bold mt-4 mb-2">Revisa tus respuestas</h2>
        {questions.map((q, i) => (
          <QuestionReview
            key={q.id}
            number={i + 1}
            question={q}
            review={result.results.find((r) => r.question_id === q.id)}
          />
        ))}

        <div className="d-flex flex-wrap justify-content-center gap-2 mt-4">
          <button type="button" className="btn btn-cq btn-cq-outline" onClick={onRetry}>
            <i className="bi bi-arrow-repeat" aria-hidden="true" /> Reintentar
          </button>
          <Link to={continueTo} className="btn btn-cq btn-cq-primary">
            {result.next_lesson_id ? 'Siguiente lección' : 'Volver al módulo'}
            <i className="bi bi-arrow-right" aria-hidden="true" />
          </Link>
        </div>
      </div>
    );
  }

  // ---------- Preguntas ----------
  return (
    <div className="cq-card p-4 p-md-5">
      <div className="d-flex justify-content-between align-items-center gap-3 mb-2">
        <span className="cq-eyebrow">{TYPE_LABELS[question.type]}</span>
        <span className="cq-muted small cq-code">{index + 1} / {questions.length}</span>
      </div>
      <ProgressBar value={index + 1} max={questions.length} label="Pregunta actual" />

      <div key={question.id} className="cq-fade-up">
        <h2 className="h5 fw-bold mt-4 mb-3">{question.statement}</h2>
        <QuestionInput
          question={question}
          value={answers[question.id]}
          onChange={(value) => {
            setAnswers((prev) => ({ ...prev, [question.id]: value }));
            setError('');
          }}
        />
      </div>

      <Alert>{error}</Alert>

      <div className="d-flex justify-content-between gap-2 mt-4">
        <button
          type="button"
          className="btn btn-cq btn-cq-outline"
          onClick={() => setIndex(index - 1)}
          disabled={index === 0 || submitting}
        >
          <i className="bi bi-arrow-left" aria-hidden="true" /> Anterior
        </button>
        {isLast ? (
          <button type="button" className="btn btn-cq btn-cq-primary" onClick={handleSubmit} disabled={submitting}>
            {submitting ? 'Calificando…' : <>Enviar respuestas <i className="bi bi-send" aria-hidden="true" /></>}
          </button>
        ) : (
          <button type="button" className="btn btn-cq btn-cq-primary" onClick={() => setIndex(index + 1)} disabled={!answered}>
            Siguiente <i className="bi bi-arrow-right" aria-hidden="true" />
          </button>
        )}
      </div>
    </div>
  );
}
