/**
 * Logotipo de CodeQuest: símbolo </> dentro de un escudo de misión
 * más el nombre. size controla la altura del símbolo en píxeles.
 */
export default function Logo({ size = 36, showName = true, className = '' }) {
  return (
    <span className={`d-inline-flex align-items-center gap-2 ${className}`}>
      <svg width={size} height={size} viewBox="0 0 48 48" aria-hidden="true">
        <defs>
          <linearGradient id="cq-logo-gradient" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0" stopColor="#8b5cf6" />
            <stop offset="0.6" stopColor="#6366f1" />
            <stop offset="1" stopColor="#3b82f6" />
          </linearGradient>
        </defs>
        <path
          d="M24 2 42 9v14c0 11-7.6 19.6-18 23C13.6 42.6 6 34 6 23V9z"
          fill="url(#cq-logo-gradient)"
        />
        <path
          d="m18 17-6 7 6 7M30 17l6 7-6 7"
          fill="none"
          stroke="#fff"
          strokeWidth="3.2"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
        <path d="m26.5 14-5 20" stroke="#ddd6fe" strokeWidth="3.2" strokeLinecap="round" />
      </svg>
      {showName && (
        <span className="fw-bold" style={{ fontSize: size * 0.6, letterSpacing: '-0.02em' }}>
          Code<span className="cq-gradient-text">Quest</span>
        </span>
      )}
    </span>
  );
}
