import BadgeCard from '../components/gamification/BadgeCard.jsx';
import ErrorState from '../components/ui/ErrorState.jsx';
import LoadingScreen from '../components/ui/LoadingScreen.jsx';
import ProgressBar from '../components/ui/ProgressBar.jsx';
import { useApi } from '../hooks/useApi.js';
import { getBadges } from '../services/gamificationService.js';

/** Colección de insignias: las obtenidas y el avance hacia las demás (RF-27). */
export default function BadgesPage() {
  const { data, loading, error, reload } = useApi(getBadges);

  if (loading) return <LoadingScreen message="Cargando tus insignias…" />;
  if (error) return <ErrorState error={error} onRetry={reload} />;

  const { badges } = data;
  const earned = badges.filter((badge) => badge.earned).length;
  const sorted = [...badges].sort((a, b) => Number(b.earned) - Number(a.earned));

  return (
    <section className="container py-4 py-lg-5">
      <header className="d-flex flex-column flex-md-row gap-3 align-items-md-end justify-content-between mb-4 cq-fade-up">
        <div>
          <span className="cq-eyebrow">logros</span>
          <h1 className="h2 fw-bold mt-3 mb-1">Tus insignias</h1>
          <p className="cq-muted mb-0">Se otorgan solas cuando cumples cada meta.</p>
        </div>
        <div style={{ minWidth: 220 }}>
          <div className="d-flex justify-content-between small mb-2">
            <span className="cq-muted">Colección</span>
            <span className="fw-semibold">{earned} / {badges.length}</span>
          </div>
          <ProgressBar value={earned} max={badges.length} label="Insignias obtenidas" />
        </div>
      </header>

      <div className="row g-3">
        {sorted.map((badge) => (
          <div key={badge.id} className="col-md-6 col-xl-4">
            <BadgeCard badge={badge} />
          </div>
        ))}
      </div>
    </section>
  );
}
