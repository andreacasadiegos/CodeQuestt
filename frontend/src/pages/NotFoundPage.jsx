import { Link } from 'react-router-dom';

/** Página para rutas que no existen. */
export default function NotFoundPage() {
  return (
    <main className="container py-5 text-center">
      <h1 className="display-4 fw-bold">404</h1>
      <p className="cq-muted">Esta página no existe.</p>
      <Link to="/">Volver al inicio</Link>
    </main>
  );
}
