import { Navigate, Outlet, useLocation } from 'react-router-dom';

import LoadingScreen from '../components/ui/LoadingScreen.jsx';
import { useAuth } from '../hooks/useAuth.js';
import { homeFor } from '../utils/home.js';

/**
 * Páginas de administración. Solo ayuda a navegar: el backend
 * (AdminMiddleware) responde 403 a quien no sea administrador.
 */
export default function AdminRoute() {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) return <LoadingScreen />;
  if (!user) return <Navigate to="/iniciar-sesion" replace state={{ from: location.pathname }} />;
  if (user.role !== 'admin') return <Navigate to={homeFor(user)} replace />;

  return <Outlet />;
}
