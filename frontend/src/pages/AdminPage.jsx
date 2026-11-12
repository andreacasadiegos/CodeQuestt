import { useMemo, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';

import ErrorState from '../components/ui/ErrorState.jsx';
import LoadingScreen from '../components/ui/LoadingScreen.jsx';
import { useApi } from '../hooks/useApi.js';
import { getStudents } from '../services/adminService.js';
import { formatDate } from '../utils/format.js';

const SORTS = {
  name: { label: 'Nombre', fn: (a, b) => a.full_name.localeCompare(b.full_name, 'es') },
  xp: { label: 'Más XP', fn: (a, b) => b.xp_total - a.xp_total },
  score: { label: 'Mejor promedio', fn: (a, b) => (b.average_score ?? -1) - (a.average_score ?? -1) },
  recent: { label: 'Actividad reciente', fn: (a, b) => (b.last_activity ?? '').localeCompare(a.last_activity ?? '') },
};

/** Panel de administración: resultados de todos los estudiantes. */
export default function AdminPage() {
  const { data, loading, error, reload } = useApi(getStudents);
  const [query, setQuery] = useState('');
  const [sort, setSort] = useState('name');
  const navigate = useNavigate();

  const students = useMemo(() => {
    if (!data) return [];
    const q = query.trim().toLowerCase();
    return data.students
      .filter((s) => !q || s.full_name.toLowerCase().includes(q) || s.email.includes(q))
      .sort(SORTS[sort].fn);
  }, [data, query, sort]);

  if (loading) return <LoadingScreen message="Cargando estudiantes…" />;
  if (error) return <ErrorState error={error} onRetry={reload} backTo="/" backLabel="Ir al inicio" />;

  const { summary } = data;

  return (
    <section className="container py-4 py-lg-5">
      <header className="d-flex flex-wrap align-items-end justify-content-between gap-3 mb-4 cq-fade-up">
        <div>
          <span className="cq-eyebrow">administración</span>
          <h1 className="h2 fw-bold mt-3 mb-1">Resultados de los estudiantes</h1>
          <p className="cq-muted mb-0">Avance, puntajes e insignias de cada estudiante registrado.</p>
        </div>
        <button
          type="button"
          className="btn btn-cq btn-cq-outline"
          onClick={() => downloadCsv(students)}
          disabled={students.length === 0}
        >
          <i className="bi bi-download" aria-hidden="true" /> Descargar Excel (CSV)
        </button>
      </header>

      <div className="row g-3 mb-4">
        <Stat icon="bi-people" label="Estudiantes registrados" value={summary.students} />
        <Stat icon="bi-signpost-split" label="Con diagnóstico" value={summary.with_diagnostic} />
        <Stat icon="bi-lightning-charge" label="Han resuelto actividades" value={summary.active} />
        <Stat icon="bi-bar-chart" label="Puntaje promedio" value={summary.average_score === null ? '—' : `${summary.average_score}%`} />
      </div>

      <div className="cq-card p-3 p-md-4">
        <div className="d-flex flex-wrap gap-2 mb-3 cq-form">
          <div className="flex-grow-1" style={{ minWidth: 220 }}>
            <label htmlFor="admin-search" className="visually-hidden">Buscar estudiante</label>
            <input
              id="admin-search"
              type="search"
              className="form-control"
              placeholder="Buscar por nombre o correo…"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
            />
          </div>
          <label htmlFor="admin-sort" className="visually-hidden">Ordenar</label>
          <select id="admin-sort" className="form-control w-auto" value={sort} onChange={(e) => setSort(e.target.value)}>
            {Object.entries(SORTS).map(([key, { label }]) => (
              <option key={key} value={key}>{label}</option>
            ))}
          </select>
        </div>

        {students.length === 0 ? (
          <p className="cq-muted text-center my-4">
            {summary.students === 0 ? 'Todavía no hay estudiantes registrados.' : 'Ningún estudiante coincide con la búsqueda.'}
          </p>
        ) : (
          <div className="table-responsive">
            <table className="table cq-table cq-admin-table mb-0">
              <thead>
                <tr>
                  <th scope="col">Estudiante</th>
                  <th scope="col" className="d-none d-md-table-cell">Ruta</th>
                  <th scope="col" className="d-none d-lg-table-cell">Nivel</th>
                  <th scope="col" className="text-end">XP</th>
                  <th scope="col" className="text-end">Aprobadas</th>
                  <th scope="col" className="text-end">Promedio</th>
                  <th scope="col" className="text-end d-none d-md-table-cell">Insignias</th>
                  <th scope="col" className="text-end d-none d-lg-table-cell">Última actividad</th>
                </tr>
              </thead>
              <tbody>
                {students.map((s) => (
                  <tr key={s.id} onClick={() => navigate(`/admin/estudiantes/${s.id}`)} className="cq-admin-row">
                    <td>
                      <Link to={`/admin/estudiantes/${s.id}`} className="fw-semibold" onClick={(e) => e.stopPropagation()}>
                        {s.full_name}
                      </Link>
                      <span className="d-block cq-muted small">{s.email}</span>
                    </td>
                    <td className="d-none d-md-table-cell">{s.path?.name ?? <span className="cq-muted">Sin diagnóstico</span>}</td>
                    <td className="d-none d-lg-table-cell">{s.level.number} · {s.level.name}</td>
                    <td className="text-end cq-xp-text fw-semibold">{s.xp_total}</td>
                    <td className="text-end">{s.activities_passed}</td>
                    <td className="text-end"><Score value={s.average_score} /></td>
                    <td className="text-end d-none d-md-table-cell">{s.badges}</td>
                    <td className="text-end d-none d-lg-table-cell cq-muted small">
                      {s.last_activity ? formatDate(s.last_activity) : '—'}
                    </td>
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

function Stat({ icon, label, value }) {
  return (
    <div className="col-6 col-lg-3">
      <div className="cq-card cq-stat-card h-100">
        <span className="cq-icon-soft mb-3"><i className={`bi ${icon}`} aria-hidden="true" /></span>
        <p className="cq-muted small mb-1">{label}</p>
        <p className="cq-stat-value mb-0">{value}</p>
      </div>
    </div>
  );
}

export function Score({ value }) {
  if (value === null || value === undefined) return <span className="cq-muted">—</span>;
  const tone = value >= 80 ? 'text-success' : value >= 60 ? '' : 'cq-danger-text';
  return <span className={`fw-semibold ${tone}`}>{value}%</span>;
}

/** Descarga la tabla visible como CSV (se abre en Excel). */
function downloadCsv(students) {
  const header = ['Nombre', 'Correo', 'Ruta', 'Nivel', 'XP', 'Actividades aprobadas', 'Intentos',
    'Puntaje promedio', 'Insignias', 'Módulos completados', 'Última actividad', 'Registro'];
  const rows = students.map((s) => [
    s.full_name, s.email, s.path?.name ?? 'Sin diagnóstico', `${s.level.number} - ${s.level.name}`, s.xp_total,
    s.activities_passed, s.attempts, s.average_score ?? '', s.badges, s.modules_completed,
    s.last_activity ?? '', s.created_at,
  ]);
  const escape = (v) => `"${String(v).replace(/"/g, '""')}"`;
  const csv = [header, ...rows].map((r) => r.map(escape).join(';')).join('\r\n');
  const url = URL.createObjectURL(new Blob(['﻿' + csv], { type: 'text/csv;charset=utf-8' }));
  const link = document.createElement('a');
  link.href = url;
  link.download = `codequest-estudiantes-${new Date().toISOString().slice(0, 10)}.csv`;
  link.click();
  URL.revokeObjectURL(url);
}
