import { BrowserRouter, Route, Routes } from 'react-router-dom';

import MainLayout from './components/layout/MainLayout.jsx';
import { AuthProvider } from './context/AuthContext.jsx';
import ActivityPage from './pages/ActivityPage.jsx';
import AdminPage from './pages/AdminPage.jsx';
import AdminStudentPage from './pages/AdminStudentPage.jsx';
import BadgesPage from './pages/BadgesPage.jsx';
import DashboardPage from './pages/DashboardPage.jsx';
import DiagnosticPage from './pages/DiagnosticPage.jsx';
import HomePage from './pages/HomePage.jsx';
import LessonPage from './pages/LessonPage.jsx';
import LoginPage from './pages/LoginPage.jsx';
import ModulePage from './pages/ModulePage.jsx';
import NotFoundPage from './pages/NotFoundPage.jsx';
import ProgressPage from './pages/ProgressPage.jsx';
import RegisterPage from './pages/RegisterPage.jsx';
import AdminRoute from './routes/AdminRoute.jsx';
import ProtectedRoute from './routes/ProtectedRoute.jsx';
import PublicOnlyRoute from './routes/PublicOnlyRoute.jsx';

/**
 * Definición de rutas de la aplicación.
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

            <Route element={<ProtectedRoute requireDiagnostic />}>
              <Route path="/panel" element={<DashboardPage />} />
              <Route path="/modulos/:slug" element={<ModulePage />} />
              <Route path="/lecciones/:id" element={<LessonPage />} />
              <Route path="/actividades/:id" element={<ActivityPage />} />
              <Route path="/insignias" element={<BadgesPage />} />
              <Route path="/progreso" element={<ProgressPage />} />
            </Route>

            <Route element={<AdminRoute />}>
              <Route path="/admin" element={<AdminPage />} />
              <Route path="/admin/estudiantes/:id" element={<AdminStudentPage />} />
            </Route>

            <Route path="*" element={<NotFoundPage />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}
