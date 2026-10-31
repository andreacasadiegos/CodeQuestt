/** Dificultad de 1 a 3 en estrellas. */
export default function Difficulty({ value }) {
  return (
    <span aria-label={`Dificultad ${value} de 3`} title={`Dificultad ${value} de 3`}>
      {[1, 2, 3].map((n) => (
        <i key={n} className={`bi ${n <= value ? 'bi-star-fill' : 'bi-star'} cq-star`} aria-hidden="true" />
      ))}
    </span>
  );
}
