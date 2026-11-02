import ProgressBar from '../ui/ProgressBar.jsx';

/**
 * Tarjeta de experiencia ganada al terminar una actividad.
 * xp: respuesta del servidor { xp_awarded, xp_total, level, level_up, earned, next_level }
 */
export default function XpGain({ xp }) {
  const { xp_awarded: awarded, badge_xp: badgeXp, xp_total: total, level, level_up: levelUp, earned, next_level: next } = xp;
  const span = next ? next.min_xp - level.min_xp : 1;
  const inLevel = next ? total - level.min_xp : 1;

  return (
    <div className="cq-xp-card cq-fade-up">
      {levelUp && (
        <div className="cq-level-up" role="status">
          <i className="bi bi-stars" aria-hidden="true" /> ¡Subiste al nivel {level.number}: {level.name}!
        </div>
      )}

      <div className="d-flex align-items-center gap-3">
        <span className="cq-xp-badge"><i className="bi bi-lightning-charge-fill" aria-hidden="true" /></span>
        <div className="flex-grow-1">
          {awarded > 0 ? (
            <p className="h4 fw-bold mb-0 cq-xp-text">+{awarded} XP</p>
          ) : (
            <p className="fw-semibold mb-0">
              {earned > 0 ? 'Ya habías obtenido este XP antes.' : 'Esta vez no sumaste XP.'}
            </p>
          )}
          {badgeXp > 0 && <p className="small mb-0 cq-xp-text">+{badgeXp} XP por insignias nuevas</p>}
          <p className="cq-muted small mb-0">
            Total: {total} XP · Nivel {level.number}, {level.name}
          </p>
        </div>
      </div>

      <div className="mt-3">
        <ProgressBar value={inLevel} max={span} label="Avance hacia el siguiente nivel" />
        <p className="cq-muted small mt-2 mb-0">
          {next
            ? `Te faltan ${next.min_xp - total} XP para ${next.name}.`
            : 'Alcanzaste el nivel máximo.'}
        </p>
      </div>
    </div>
  );
}
