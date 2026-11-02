/** Aviso de insignias nuevas al terminar una actividad. */
export default function BadgeUnlocked({ badges }) {
  return (
    <div className="cq-badge-unlocked mt-3 cq-fade-up" role="status">
      <p className="fw-bold mb-2">
        <i className="bi bi-stars me-1" aria-hidden="true" />
        {badges.length === 1 ? '¡Nueva insignia!' : `¡${badges.length} insignias nuevas!`}
      </p>
      <div className="d-grid gap-2">
        {badges.map((badge) => (
          <div key={badge.id} className="d-flex align-items-center gap-3">
            <span className="cq-badge-medal is-small" aria-hidden="true"><i className={`bi ${badge.icon}`} /></span>
            <span className="flex-grow-1">
              <span className="fw-semibold d-block">{badge.name}</span>
              <span className="cq-muted small">{badge.description}</span>
            </span>
            {badge.xp_reward > 0 && <span className="cq-xp-text fw-semibold small">+{badge.xp_reward} XP</span>}
          </div>
        ))}
      </div>
    </div>
  );
}
