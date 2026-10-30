import Logo from './Logo.jsx';

/** Pantalla de carga mientras se consulta la sesión. */
export default function LoadingScreen({ message = 'Cargando…' }) {
  return (
    <div className="d-flex flex-column align-items-center justify-content-center gap-3 py-5 my-5" role="status">
      <span className="cq-float">
        <Logo size={56} showName={false} />
      </span>
      <span className="cq-muted cq-code small">{message}</span>
    </div>
  );
}
