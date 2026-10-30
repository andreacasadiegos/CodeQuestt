import { useEffect, useState } from 'react';

import { apiRequest } from '../services/api.js';

/**
 * Página de inicio (versión de la Etapa 1).
 * Por ahora solo comprueba la conexión React -> PHP.
 * En la Etapa 4 se reemplaza por la página de inicio definitiva.
 */
export default function HomePage() {
  const [health, setHealth] = useState(null);
  const [error, setError] = useState('');

  useEffect(() => {
    apiRequest('/health')
      .then(setHealth)
      .catch((err) => setError(err.message));
  }, []);

  return (
    <main className="container py-5">
      <div className="cq-card p-4 p-md-5 mx-auto" style={{ maxWidth: 640 }}>
        <h1 className="h2 fw-bold mb-1">
          <i className="bi bi-code-slash me-2" style={{ color: 'var(--cq-accent)' }} aria-hidden="true" />
          CodeQuest
        </h1>
        <p className="cq-muted mb-4">Aprende a programar · Etapa 1: entorno de desarrollo</p>

        {!health && !error && <p className="mb-0">Conectando con la API…</p>}

        {health && (
          <div className="alert alert-success mb-0" role="status">
            <i className="bi bi-check-circle-fill me-2" aria-hidden="true" />
            {health.mensaje} (PHP {health.php})
          </div>
        )}

        {error && (
          <div className="alert alert-danger mb-0" role="alert">
            <i className="bi bi-exclamation-triangle-fill me-2" aria-hidden="true" />
            {error}. Revisa que Apache esté encendido en XAMPP.
          </div>
        )}
      </div>
    </main>
  );
}
