import { BrowserRouter, Route, Routes } from 'react-router-dom';

import MainLayout from './components/layout/MainLayout.jsx';
import { AuthProvider } from './context/AuthContext.jsx';
import DiagnosticPage from './pages/DiagnosticPage.jsx';
import HomePage from './pages/HomePage.jsx';
import LoginPage from './pages/LoginPage.jsx';
import NotFoundPage from './pages/NotFoundPage.jsx';
import RegisterPage from './pages/RegisterPage.jsx';
import ProtectedRoute from './routes/ProtectedRoute.jsx';
import PublicOnlyRoute from './routes/PublicOnlyRoute.jsx';

/**
 * Definición de rutas de la aplicación.
 * El panel (/panel) y los módulos se agregan en las siguientes etapas.
 */
export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route element={<MainLayout />}>
            <Route path="/" element={<HomePage />} />

            <Route element={<PublicOnlyRoute />}>
              <Route path="/registro" element={<RegisterPage />} />
              <Route path="/iniciar-sesion" element={<LoginPage />} />
            </Route>

            <Route element={<ProtectedRoute onlyBeforeDiagnostic />}>
              <Route path="/diagnostico" element={<DiagnosticPage />} />
            </Route>

            <Route path="*" element={<NotFoundPage />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}
