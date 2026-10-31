import { useState } from 'react';

/**
 * Ordenar los pasos de un algoritmo.
 * Se puede arrastrar y soltar (computador) o usar los botones subir/bajar
 * (celular y teclado).
 * value: { order: [idPaso, ...] }
 */
export default function OrderSteps({ question, value, onChange }) {
  const [dragIndex, setDragIndex] = useState(null);
  const order = value?.order ?? question.items.map((item) => item.id);
  const textById = Object.fromEntries(question.items.map((item) => [item.id, item.text]));

  const move = (from, to) => {
    if (to < 0 || to >= order.length || from === to) return;
    const next = [...order];
    const [moved] = next.splice(from, 1);
    next.splice(to, 0, moved);
    onChange({ order: next });
  };

  return (
    <ol className="cq-order-list list-unstyled mb-0">
      {order.map((id, index) => (
        <li
          key={id}
          className={`cq-order-item ${dragIndex === index ? 'is-dragging' : ''}`}
          draggable
          onDragStart={() => setDragIndex(index)}
          onDragOver={(event) => event.preventDefault()}
          onDrop={() => {
            move(dragIndex, index);
            setDragIndex(null);
          }}
          onDragEnd={() => setDragIndex(null)}
        >
          <i className="bi bi-grip-vertical cq-muted" aria-hidden="true" />
          <span className="cq-choice-key">{index + 1}</span>
          <span className="flex-grow-1">{textById[id]}</span>
          <span className="d-flex gap-1">
            <button
              type="button"
              className="btn btn-sm cq-icon-button"
              onClick={() => move(index, index - 1)}
              disabled={index === 0}
              aria-label={`Subir "${textById[id]}"`}
            >
              <i className="bi bi-chevron-up" aria-hidden="true" />
            </button>
            <button
              type="button"
              className="btn btn-sm cq-icon-button"
              onClick={() => move(index, index + 1)}
              disabled={index === order.length - 1}
              aria-label={`Bajar "${textById[id]}"`}
            >
              <i className="bi bi-chevron-down" aria-hidden="true" />
            </button>
          </span>
        </li>
      ))}
    </ol>
  );
}
