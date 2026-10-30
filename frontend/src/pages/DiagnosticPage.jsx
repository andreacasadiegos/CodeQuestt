import { useAuth } from '../hooks/useAuth.js';

/**
 * Diagnóstico inicial (versión de la Etapa 4).
 * Por ahora solo confirma que la sesión y la protección de rutas funcionan.
 * En la Etapa 5 se reemplaza por la autoevaluación y la prueba de 5 preguntas.
 */
export default function DiagnosticPage() {
  const { user } = useAuth();

  return (
    <section className="container py-5">
      <div className="cq-card p-4 p-md-5 mx-auto text-center cq-fade-up" style={{ maxWidth: 640 }}>
        <span className="cq-icon-tile mb-3"><i className="bi bi-clipboard-check" aria-hidden="true" /></span>
        <h1 className="h3 fw-bold">¡Bienvenido, {user.full_name.split(' ')[0]}!</h1>
        <p className="cq-muted mb-0">
          Tu cuenta está lista y tu sesión está activa. Aquí irá el diagnóstico inicial, que construiremos en la
          Etapa 5.
        </p>
      </div>
    </section>
  );
}
