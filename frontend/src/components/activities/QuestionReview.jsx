/**
 * Revisión de una pregunta después de calificar: muestra si fue correcta,
 * la respuesta esperada (cuando se equivocó) y la explicación.
 */
export default function QuestionReview({ number, question, review }) {
  return (
    <div className="cq-review-item">
      <i className={`bi ${review.is_correct ? 'bi-check-circle-fill' : 'bi-x-circle-fill'} fs-4`} aria-hidden="true" />
      <div className="flex-grow-1">
        <p className="fw-semibold mb-1">{number}. {question.statement}</p>
        {!review.is_correct && <CorrectAnswer question={question} review={review} />}
        {review.explanation && <p className="cq-muted small mb-0">{review.explanation}</p>}
      </div>
    </div>
  );
}

function CorrectAnswer({ question, review }) {
  switch (question.type) {
    case 'seleccion':
    case 'patron': {
      const text = question.options.find((option) => option.id === review.correct_option_id)?.text;
      return <p className="small mb-1">Respuesta correcta: <strong>{text}</strong></p>;
    }
    case 'completar_codigo':
      return (
        <p className="small mb-1">
          Respuesta correcta: <code className="cq-inline-code">{review.correct_answer}</code>
        </p>
      );
    case 'ordenar': {
      const textById = Object.fromEntries(question.items.map((item) => [item.id, item.text]));
      return (
        <div className="small mb-1">
          Orden correcto:
          <ol className="cq-review-list mb-0">
            {review.correct_order.map((id) => <li key={id}>{textById[id]}</li>)}
          </ol>
        </div>
      );
    }
    case 'relacionar': {
      const targetById = Object.fromEntries(question.targets.map((target) => [target.id, target.text]));
      return (
        <div className="small mb-1">
          Relación correcta:
          <ul className="cq-review-list mb-0">
            {question.items.map((item) => (
              <li key={item.id}>
                <strong>{item.text}</strong> → {targetById[review.correct_pairs[item.id]]}
              </li>
            ))}
          </ul>
        </div>
      );
    }
    default:
      return null;
  }
}
