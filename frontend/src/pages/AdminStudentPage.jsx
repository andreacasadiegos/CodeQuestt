import { Link, useParams } from 'react-router-dom';

import ErrorState from '../components/ui/ErrorState.jsx';
import LoadingScreen from '../components/ui/LoadingScreen.jsx';
import ProgressBar from '../components/ui/ProgressBar.jsx';
import { useApi } from '../hooks/useApi.js';
import { getStudent } from '../services/adminService.js';
import { formatDate } from '../utils/format.js';
import { Score } from './AdminPage.jsx';

const KIND_LABELS = { practica: 'Práctica', evaluacion: 'Evaluación', reto: 'Reto' };
const STATUS_LABELS = { no_iniciado: 'Sin iniciar', en_curso: 'En curso', completado: 'Completado' };
const EXPERIENCE_LABELS = {
  1: 'No tengo conocimientos',
  2: 'Tengo conocimientos básicos',
  3: 'Ya he estudiado programación',
};

/** Detalle de un estudiante para el administrador. */
export default function AdminStudentPage() {
  const { id } = useParams();
  const { data, loading, error, reload } = useApi(() => getStudent(id), [id]);

  if (loading) return <LoadingScreen message="Cargando estudiante…" />;
  if (error) return <ErrorState error={error} onRetry={reload} backTo="/admin" backLabel="Volver a estudiantes" />;

  const { student, summary, diagnostic, modules, badges, attempts } = data;

  return (
    <section className="container py-4 py-lg-5">
      <Link to="/admin" className="cq-muted small d-inline-block mb-3">
        <i className="bi bi-arrow-left" aria-hidden="true" /> Todos los estudiantes
      </Link>

      <header className="mb-4 cq-fade-up">
        <h1 className="h2 fw-bold mb-1">{student.full_name}</h1>
        <p className="cq-muted mb-0">
          {student.email} · {student.path?.name ?? 'Sin diagnóstico'} · Nivel {student.level.number} ({student.level.name}) ·
          Registrado el {formatDate(student.created_at)}
        </p>
      </header>

      <div className="row g-3 mb-4">
        <Stat label="XP" value={<span className="cq-xp-text">{student.xp_total}</span>} />
        <Stat label="Actividades aprobadas" value={summary.activities_passed} />
        <Stat label="Puntaje promedio" value={<Score value={summary.average_score} />} />
        <Stat label="Intentos" value={summary.attempts} />
      </div>

      <div className="row g-4">
        <div className="col-lg-6">
          <h2 className="h5 fw-bold mb-3">Avance por módulo</h2>
          <div className="cq-card p-4 d-grid gap-3">
            {modules.map((m) => (
              <div key={m.id}>
                <div className="d-flex align-items-center gap-2 mb-1">
                  <i className={`bi ${m.icon}`} aria-hidden="true" />
                  <span className="fw-semibold flex-grow-1">{m.name}</span>
                  <span className="cq-muted small">{STATUS_LABELS[m.status]}</span>
                  <span className="fw-semibold">{m.percent}%</span>
                </div>
                <ProgressBar value={m.percent} label={`Avance en ${m.name}`} />
              </div>
            ))}
          </div>
        </div>

        <div className="col-lg-6">
          <h2 className="h5 fw-bold mb-3">Diagnóstico e insignias</h2>
          <div className="cq-card p-4">
            {diagnostic ? (
              <p className="mb-3">
                <span className="d-block">Autoevaluación: <strong>{EXPERIENCE_LABELS[diagnostic.experience_option]}</strong></span>
                <span className="d-block">Prueba: <strong>{diagnostic.test_score}/5</strong> aciertos</span>
                <span className="d-block">Ruta asignada: <strong>{diagnostic.assigned_path}</strong></span>
              </p>
            ) : (
              <p className="cq-muted mb-3">Aún no ha hecho la prueba diagnóstica.</p>
            )}
            {badges.length === 0 ? (
              <p className="cq-muted mb-0">Sin insignias todavía.</p>
            ) : (
              <div className="d-flex flex-wrap gap-2">
                {badges.map((b) => (
                  <span key={b.name} className="cq-admin-badge" title={`Obtenida el ${formatDate(b.earned_at)}`}>
                    <i className={`bi ${b.icon}`} aria-hidden="true" /> {b.name}
                  </span>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>

      <h2 className="h5 fw-bold mt-5 mb-3">Intentos ({attempts.length})</h2>
      <div className="cq-card p-3 p-md-4">
        {attempts.length === 0 ? (
          <p className="cq-muted text-center my-3">Todavía no ha resuelto actividades.</p>
        ) : (
          <div className="table-responsive">
            <table className="table cq-table mb-0">
              <thead>
                <tr>
                  <th scope="col">Actividad</th>
                  <th scope="col" className="d-none d-md-table-cell">Módulo</th>
                  <th scope="col" className="text-end">Aciertos</th>
                  <th scope="col" className="text-end">Puntaje</th>
                  <th scope="col" className="text-end d-none d-md-table-cell">XP</th>
                  <th scope="col" className="text-end">Fecha</th>
                </tr>
              </thead>
              <tbody>
                {attempts.map((a) => (
                  <tr key={a.id}>
                    <td>
                      <span className={`cq-kind cq-kind-${a.kind} me-2`}>{KIND_LABELS[a.kind]}</span>
                      {a.title}
                    </td>
                    <td className="d-none d-md-table-cell">{a.module_name}</td>
                    <td className="text-end">{a.correct}/{a.total}</td>
                    <td className="text-end">
                      <i className={`bi ${a.passed ? 'bi-check-circle-fill text-success' : 'bi-x-circle-fill cq-danger-text'} me-1`} aria-hidden="true" />
                      {a.score_pct}%
                    </td>
                    <td className="text-end d-none d-md-table-cell cq-xp-text">{a.xp_awarded > 0 ? `+${a.xp_awarded}` : ''}</td>
                    <td className="text-end cq-muted small">{formatDate(a.submitted_at)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </section>
  );
}

function Stat({ label, value }) {
  return (
    <div className="col-6 col-lg-3">
      <div className="cq-card cq-stat-card h-100">
        <p className="cq-muted small mb-1">{label}</p>
        <p className="cq-stat-value mb-0">{value}</p>
      </div>
    </div>
  );
}
