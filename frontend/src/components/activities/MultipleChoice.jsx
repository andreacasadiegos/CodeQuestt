import CodeBlock from '../ui/CodeBlock.jsx';

const LETTERS = ['A', 'B', 'C', 'D', 'E', 'F'];

/**
 * Selección múltiple con una sola respuesta.
 * value: { option_id }  ·  onChange(nuevoValor)
 */
export default function MultipleChoice({ question, value, onChange, showCode = true }) {
  return (
    <>
      {showCode && <CodeBlock code={question.code_snippet} />}
      <div className="d-grid gap-2" role="radiogroup" aria-label="Opciones de respuesta">
        {question.options.map((option, i) => {
          const selected = value?.option_id === option.id;
          return (
            <button
              key={option.id}
              type="button"
              role="radio"
              aria-checked={selected}
              className={`cq-choice ${selected ? 'is-selected' : ''}`}
              onClick={() => onChange({ option_id: option.id })}
            >
              <span className="cq-choice-key">{LETTERS[i]}</span>
              <span>{option.text}</span>
            </button>
          );
        })}
      </div>
    </>
  );
}
