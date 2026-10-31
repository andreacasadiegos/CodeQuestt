import { Fragment } from 'react';

/**
 * Muestra el texto de una lección guardado en MySQL.
 * Formato admitido (sin HTML, para evitar inyección de código):
 *   - Párrafos separados por una línea en blanco.
 *   - Viñetas: líneas que empiezan con "- ".
 *   - Negrita: **texto**.
 */
function renderInline(text) {
  return text.split(/(\*\*[^*]+\*\*)/g).map((part, i) =>
    part.startsWith('**') && part.endsWith('**')
      ? <strong key={i}>{part.slice(2, -2)}</strong>
      : <Fragment key={i}>{part}</Fragment>,
  );
}

export default function LessonContent({ text }) {
  const blocks = text.split(/\n\s*\n/);

  return (
    <div className="cq-lesson-content">
      {blocks.map((block, i) => {
        const lines = block.split('\n');
        const isList = lines.every((line) => line.startsWith('- '));

        if (isList) {
          return (
            <ul key={i}>
              {lines.map((line, j) => <li key={j}>{renderInline(line.slice(2))}</li>)}
            </ul>
          );
        }

        // Un párrafo seguido de viñetas en el mismo bloque.
        const firstBullet = lines.findIndex((line) => line.startsWith('- '));
        if (firstBullet > 0) {
          return (
            <Fragment key={i}>
              <p>{renderInline(lines.slice(0, firstBullet).join(' '))}</p>
              <ul>
                {lines.slice(firstBullet).map((line, j) => <li key={j}>{renderInline(line.replace(/^- /, ''))}</li>)}
              </ul>
            </Fragment>
          );
        }

        return <p key={i}>{renderInline(lines.join(' '))}</p>;
      })}
    </div>
  );
}
