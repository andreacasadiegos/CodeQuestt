import CodeBlock from '../ui/CodeBlock.jsx';
import MultipleChoice from './MultipleChoice.jsx';

/**
 * Identificar patrones: muestra la secuencia como fichas y el hueco "___"
 * resaltado; si no es una lista separada por comas, la muestra como código.
 */
export default function PatternSequence({ question, value, onChange }) {
  const snippet = question.code_snippet ?? '';
  const isSequence = snippet.includes(', ') && !snippet.includes('\n');
  const tiles = isSequence ? snippet.split(', ') : [];

  return (
    <>
      {isSequence ? (
        <div className="cq-sequence" aria-label={`Secuencia: ${snippet.replace('___', 'espacio en blanco')}`}>
          {tiles.map((tile, i) => (
            <span key={i} className={`cq-tile ${tile === '___' ? 'is-blank' : ''}`}>
              {tile === '___' ? '?' : tile}
            </span>
          ))}
        </div>
      ) : (
        <CodeBlock code={snippet} />
      )}
      <MultipleChoice question={question} value={value} onChange={onChange} showCode={false} />
    </>
  );
}
