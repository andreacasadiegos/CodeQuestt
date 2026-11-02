import { Link } from 'react-router-dom';

import BadgeCard from '../components/gamification/BadgeCard.jsx';
import LevelCard from '../components/gamification/LevelCard.jsx';
import PathAdvanceCard from '../components/gamification/PathAdvanceCard.jsx';
import ModuleCard from '../components/learning/ModuleCard.jsx';
import ErrorState from '../components/ui/ErrorState.jsx';
import LoadingScreen from '../components/ui/LoadingScreen.jsx';
import { useApi } from '../hooks/useApi.js';
import { getDashboard } from '../services/gamificationService.js';

/**
 * Panel del estudiante (RF-11, RF-12, RF-13): nivel y XP, actividades
 * completadas, insignias, retos disponibles, módulos y avance de ruta.
 * Todos los datos salen de MySQL a través de GET /api/dashboard.
 */
export default function DashboardPage() {
  const { data, loading, error, reload } = useApi(getDashboard);

  if (loading && !data) return <LoadingScreen message="Cargando tu panel…" />;
  if (error) return <ErrorState error={error} onRetry={reload} backTo="/" backLabel="Ir al inicio" />;

  const { user, xp, stats, modules, retos, recent_badges: recentBadges, path_advance: advance } = data;
  const firstName = user.full_name.split(' ')[0];

  return (
    <section className="container py-4 py-lg-5">
      <div className="cq-fade-up mb-4">
        <span className="cq-eyebrow">panel del estudiante</span>
        <h1 className="h2 fw-bold mt-3 mb-1">¡Bienvenido de nuevo, {firstName}!</h1>
        <p className="cq-muted mb-0">
          <i className="bi bi-signpost-split me-1" aria-hidden="true" /> {user.path.name}
        </p>
      </div>

      <div className="row g-4">
        <div className="col-lg-5 cq-fade-up">
          <LevelCard xp={xp} />
        </div>
        <div className="col-lg-7">
          <div className="row g-3 h-100">
            <StatCard icon="bi-check2-square" label="Actividades completadas" value={`${stats.activities_completed} / ${stats.activities_total}`} delay={1} />
            <StatCard icon="bi-award" label="Insignias" value={`${stats.badges_earned} / ${stats.badges_total}`} delay={2} to="/insignias" />
            <StatCard icon="bi-trophy" label="Retos superados" value={`${stats.retos_completed} / ${retos.length}`} delay={3} />
          </div>
        </div>
      </div>

      {advance.available && (
        <div className="mt-4 cq-fade-up">
          <PathAdvanceCard status={advance} onAdvanced={reload} />
        </div>
      )}

      <SectionTitle title="Tus módulos" aside={`Contenido de la ${user.path.name.toLowerCase()}`} />
      <div className="row g-4">
        {modules.map((module) => (
          <div key={module.id} className="col-md-6 col-lg-4">
            <ModuleCard module={module} />
          </div>
        ))}
      </div>

      <div className="row g-4 mt-1">
        <div className="col-lg-7">
          <SectionTitle title="Retos de módulo" aside="Se desbloquean al aprobar la evaluación" />
          <div className="d-grid gap-2">
            {retos.map((reto) => <RetoRow key={reto.id} reto={reto} />)}
          </div>
        </div>
        <div className="col-lg-5">
          <SectionTitle title="Últimas insignias" aside={<Link to="/insignias">Ver todas</Link>} />
          {recentBadges.length === 0 ? (
            <div className="cq-card p-4 text-center cq-muted">
              <i className="bi bi-award fs-2 d-block mb-2" aria-hidden="true" />
              Completa tu primera actividad para ganar la insignia «Primer paso».
            </div>
          ) : (
            <div className="d-grid gap-2">
              {recentBadges.map((badge) => <BadgeCard key={badge.id} badge={badge} compact />)}
            </div>
          )}
        </div>
      </div>
    </section>
  );
}

function SectionTitle({ title, aside }) {
  return (
    <div className="d-flex flex-wrap align-items-end justify-content-between gap-2 mt-5 mb-3">
      <h2 className="h4 fw-bold mb-0">{title}</h2>
      <span className="cq-muted small">{aside}</span>
    </div>
  );
}

function StatCard({ icon, label, value, delay, to }) {
  const body = (
    <>
      <span className="cq-icon-soft mb-3"><i className={`bi ${icon}`} aria-hidden="true" /></span>
      <p className="cq-muted small mb-1">{label}</p>
      <p className="cq-stat-value mb-0">{value}</p>
    </>
  );

  return (
    <div className={`col-sm-4 ${delay === 3 ? 'col-12' : 'col-6'}`}>
      {to ? (
        <Link to={to} className={`cq-card cq-stat-card cq-stat-link d-block text-reset cq-fade-up cq-delay-${delay}`}>{body}</Link>
      ) : (
        <div className={`cq-card cq-stat-card cq-fade-up cq-delay-${delay}`}>{body}</div>
      )}
    </div>
  );
}

function RetoRow({ reto }) {
  const state = reto.passed ? 'done' : reto.locked ? 'locked' : 'open';
  const content = (
    <>
      <span className={`cq-lesson-dot is-${state}`}>
        <i className={`bi ${reto.passed ? 'bi-trophy-fill' : reto.locked ? 'bi-lock-fill' : 'bi-controller'}`} aria-hidden="true" />
      </span>
      <span className="flex-grow-1">
        <span className="fw-semibold d-block">{reto.title}</span>
        <span className="cq-muted small">
          {reto.passed ? `Superado · mejor ${reto.best_score}%` : reto.locked ? 'Aprueba la evaluación del módulo' : '¡Disponible!'}
        </span>
      </span>
      <span className="cq-chip cq-chip-xp small">
        <i className="bi bi-lightning-charge-fill" aria-hidden="true" /> {reto.base_xp} XP
      </span>
    </>
  );

  return reto.locked ? (
    <div className="cq-lesson-row is-locked" aria-disabled="true">{content}</div>
  ) : (
    <Link to={`/actividades/${reto.id}`} className="cq-lesson-row text-reset">{content}</Link>
  );
}
