import ProgressBar from '../ui/ProgressBar.jsx';

/** Nivel actual, XP total y barra hacia el siguiente nivel. */
export default function LevelCard({ xp }) {
  const { xp_total: total, level, next_level: next } = xp;

  return (
    <div className="cq-card cq-level-card p-4 h-100">
      <div className="d-flex flex-wrap align-items-center gap-3 mb-3">
        <span className="cq-level-number" aria-hidden="true">{level.number}</span>
        <div>
          <p className="cq-muted small mb-0">Nivel {level.number}</p>
          <p className="h4 fw-bold mb-0">{level.name}</p>
        </div>
        <span className="ms-auto cq-chip cq-chip-xp">
          <i className="bi bi-lightning-charge-fill" aria-hidden="true" /> {total} XP
        </span>
      </div>
      <ProgressBar
        value={next ? total - level.min_xp : 1}
        max={next ? next.min_xp - level.min_xp : 1}
        label="Avance hacia el siguiente nivel"
      />
      <p className="cq-muted small mt-2 mb-0">
        {next ? `${next.min_xp - total} XP para llegar a ${next.name} (nivel ${next.number}).` : 'Alcanzaste el nivel máximo. ¡Eres un Maestro del código!'}
      </p>
    </div>
  );
}
