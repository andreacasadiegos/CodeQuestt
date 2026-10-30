import { Outlet } from 'react-router-dom';

import Footer from './Footer.jsx';
import Navbar from './Navbar.jsx';

/** Estructura común: barra superior, contenido de la página y pie. */
export default function MainLayout() {
  return (
    <>
      <Navbar />
      <main>
        <Outlet />
      </main>
      <Footer />
    </>
  );
}
