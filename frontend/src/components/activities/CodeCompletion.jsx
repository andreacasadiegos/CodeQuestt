/**
 * Completar un fragmento de código: el hueco "___" se reemplaza por un
 * campo de texto dentro del propio código.
 * value: { text }
 */
export default function CodeCompletion({ question, value, onChange }) {
  const [before, after = ''] = (question.code_snippet ?? '___').split('___');

  return (
    <>
      <pre className="cq-codeblock cq-code-fill">
        <code>
          {before}
          <input
            type="text"
            className="cq-blank-input"
            value={value?.text ?? ''}
            onChange={(event) => onChange({ text: event.target.value })}
            maxLength={100}
            size={Math.max(6, (value?.text ?? '').length + 1)}
            aria-label="Escribe lo que falta en el código"
            autoComplete="off"
            autoCapitalize="off"
            spellCheck="false"
          />
          {after}
        </code>
      </pre>
      <p className="cq-muted small mb-0">
        <i className="bi bi-keyboard me-1" aria-hidden="true" /> Escribe en el espacio resaltado lo que falta.
      </p>
    </>
  );
}
