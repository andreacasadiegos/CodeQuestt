import { formatDate } from '../../utils/format.js';
import ProgressBar from '../ui/ProgressBar.jsx';

/**
 * Tarjeta de una insignia. Si aún no se obtiene, se ve apagada y muestra
 * cuánto falta (current / target).
 */
export default function BadgeCard({ badge, compact = false }) {
  const { earned } = badge;

  return (
    <div className={`cq-card cq-badge-card ${earned ? 'is-earned' : 'is-locked'} ${compact ? 'is-compact' : ''}`}>
      <span className="cq-badge-medal" aria-hidden="true">
        <i className={`bi ${earned ? badge.icon : 'bi-lock-fill'}`} />
      </span>
      <div className="flex-grow-1 min-w-0">
        <p className="fw-bold mb-1">{badge.name}</p>
        <p className="cq-muted small mb-2">{badge.description}</p>
        {earned ? (
          <p className="small mb-0 cq-badge-earned">
            <i className="bi bi-patch-check-fill" aria-hidden="true" /> Obtenida
            {badge.earned_at && ` el ${formatDate(badge.earned_at)}`}
            {badge.xp_reward > 0 && ` · +${badge.xp_reward} XP`}
          </p>
        ) : (
          !compact && (
            <>
              <ProgressBar value={badge.current} max={badge.target} label={`Avance hacia ${badge.name}`} />
              <p className="cq-muted small mt-2 mb-0">
                {badge.current} / {badge.target}
                {badge.xp_reward > 0 && ` · premio ${badge.xp_reward} XP`}
              </p>
            </>
          )
        )}
      </div>
    </div>
  );
}
