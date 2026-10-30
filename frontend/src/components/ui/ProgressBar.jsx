/** Barra de progreso de marca. value y max son números. */
export default function ProgressBar({ value, max = 100, label }) {
  const percent = max > 0 ? Math.min(100, Math.round((value * 100) / max)) : 0;

  return (
    <div
      className="cq-progress"
      role="progressbar"
      aria-valuenow={value}
      aria-valuemin={0}
      aria-valuemax={max}
      aria-label={label}
    >
      <span style={{ width: `${percent}%` }} />
    </div>
  );
}
