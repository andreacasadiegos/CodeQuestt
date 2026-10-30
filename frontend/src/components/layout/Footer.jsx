import Logo from '../ui/Logo.jsx';

/** Pie de página común. */
export default function Footer() {
  return (
    <footer className="cq-footer mt-5">
      <div className="container py-4 d-flex flex-column flex-md-row align-items-center justify-content-between gap-3">
        <Logo size={28} />
        <p className="cq-muted small mb-0 text-center">
          Plataforma educativa para estudiantes de grado 11.º · Colegio Fernández
        </p>
        <p className="cq-muted small mb-0 cq-code">&copy; {new Date().getFullYear()} CodeQuest</p>
      </div>
    </footer>
  );
}
