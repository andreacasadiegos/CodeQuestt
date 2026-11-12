/**
 * Logotipo de CodeQuest: el robot de la marca sobre fondo azul noche,
 * más el nombre. size controla la altura del símbolo en píxeles.
 */
export default function Logo({ size = 36, showName = true, className = '' }) {
  return (
    <span className={`d-inline-flex align-items-center gap-2 ${className}`}>
      <svg width={size} height={size} viewBox="0 0 48 48" aria-hidden="true">
        <rect width="48" height="48" rx="12" fill="#131a39" />
        <g fill="none" stroke="#fff" strokeLinecap="round" strokeLinejoin="round">
          <circle cx="24" cy="6" r="2.4" strokeWidth="2.2" />
          <path d="M24 8.4v3.6" strokeWidth="2.6" />
          <rect x="9.5" y="12" width="29" height="26" rx="10" strokeWidth="3" />
          <path d="M7 21v8M41 21v8" strokeWidth="3" />
          <rect x="14.5" y="18" width="19" height="13" rx="6.5" strokeWidth="2.4" />
          <path d="M17.6 26q2.2-3 4.4 0M26 26q2.2-3 4.4 0" strokeWidth="2.2" />
        </g>
      </svg>
      {showName && (
        <span className="fw-bold" style={{ fontSize: size * 0.6, letterSpacing: '-0.02em' }}>
          Code<span className="cq-gradient-text">Quest</span>
        </span>
      )}
    </span>
  );
}
