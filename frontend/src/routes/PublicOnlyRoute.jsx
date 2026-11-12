import { Navigate, Outlet } from 'react-router-dom';

import LoadingScreen from '../components/ui/LoadingScreen.jsx';
import { useAuth } from '../hooks/useAuth.js';
import { homeFor } from '../utils/home.js';

/** Páginas solo para visitantes (registro e inicio de sesión). */
export default function PublicOnlyRoute() {
  const { user, loading } = useAuth();

  if (loading) return <LoadingScreen />;
  if (user) return <Navigate to={homeFor(user)} replace />;

  return <Outlet />;
}
