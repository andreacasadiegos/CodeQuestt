import { Link } from 'react-router-dom';

/** Página para rutas que no existen. */
export default function NotFoundPage() {
  return (
    <section className="container py-5 text-center">
      <p className="cq-code cq-gradient-text display-1 fw-bold mb-2">404</p>
      <h1 className="h4 fw-bold">Esta misión no existe</h1>
      <p className="cq-muted mb-4">La página que buscas no está en el mapa.</p>
      <Link to="/" className="btn btn-cq btn-cq-primary">Volver al inicio</Link>
    </section>
  );
}
