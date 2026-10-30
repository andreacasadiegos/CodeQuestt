import { BrowserRouter, Route, Routes } from 'react-router-dom';

import HomePage from './pages/HomePage.jsx';
import NotFoundPage from './pages/NotFoundPage.jsx';

/**
 * Definición de rutas de la aplicación.
 * En las siguientes etapas se agregan registro, login, panel y módulos.
 */
export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </BrowserRouter>
  );
}
