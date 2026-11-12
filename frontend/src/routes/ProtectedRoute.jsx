import { Navigate, Outlet, useLocation } from 'react-router-dom';

import LoadingScreen from '../components/ui/LoadingScreen.jsx';
import { useAuth } from '../hooks/useAuth.js';

/**
 * Protege las páginas privadas.
 *
 * - Sin sesión: envía a /iniciar-sesion y recuerda a dónde quería ir.
 * - requireDiagnostic: si el estudiante aún no hizo el diagnóstico, lo envía a /diagnostico.
 * - onlyBeforeDiagnostic: si ya lo hizo, lo envía a /panel.
 *
 * Es solo una ayuda de navegación: la protección real está en el backend
 * (AuthMiddleware), que rechaza con 401 cualquier petición sin sesión.
 */
export default function ProtectedRoute({ requireDiagnostic = false, onlyBeforeDiagnostic = false }) {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) return <LoadingScreen />;

  if (!user) {
    return <Navigate to="/iniciar-sesion" replace state={{ from: location.pathname }} />;
  }

  // El administrador no hace el recorrido de estudiante: va a su panel.
  if (user.role === 'admin') {
    return <Navigate to="/admin" replace />;
  }

  if (requireDiagnostic && user.needs_diagnostic) {
    return <Navigate to="/diagnostico" replace />;
  }

  if (onlyBeforeDiagnostic && !user.needs_diagnostic) {
    return <Navigate to="/panel" replace />;
  }

  return <Outlet />;
}
