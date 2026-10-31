import { useId } from 'react';

/**
 * Relacionar conceptos: a cada concepto se le elige su definición.
 * value: { pairs: { idConcepto: idDefinicion } }
 */
export default function MatchConcepts({ question, value, onChange }) {
  const baseId = useId();
  const pairs = value?.pairs ?? {};
  const used = new Set(Object.values(pairs));

  const select = (itemId, targetId) => {
    const next = { ...pairs };
    if (targetId) next[itemId] = targetId;
    else delete next[itemId];
    onChange({ pairs: next });
  };

  return (
    <div className="d-grid gap-2">
      {question.items.map((item) => {
        const selectId = `${baseId}-${item.id}`;
        return (
          <div key={item.id} className="cq-match-row">
            <label htmlFor={selectId} className="cq-match-concept">{item.text}</label>
            <i className="bi bi-arrow-right cq-muted d-none d-md-inline" aria-hidden="true" />
            <select
              id={selectId}
              className={`form-select cq-select ${pairs[item.id] ? 'is-filled' : ''}`}
              value={pairs[item.id] ?? ''}
              onChange={(event) => select(item.id, event.target.value)}
            >
              <option value="">Elige la definición…</option>
              {question.targets.map((target) => (
                <option key={target.id} value={target.id} disabled={used.has(target.id) && pairs[item.id] !== target.id}>
                  {target.text}
                </option>
              ))}
            </select>
          </div>
        );
      })}
    </div>
  );
}
