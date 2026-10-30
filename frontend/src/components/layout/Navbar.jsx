import { useState } from 'react';
import { Link, NavLink, useNavigate } from 'react-router-dom';

import { useAuth } from '../../hooks/useAuth.js';
import Logo from '../ui/Logo.jsx';

/** Barra de navegación superior, adaptable a celular. */
export default function Navbar() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [open, setOpen] = useState(false);

  const close = () => setOpen(false);

  const handleLogout = async () => {
    close();
    await logout();
    navigate('/');
  };

  return (
    <header className="cq-navbar sticky-top">
      <nav className="container d-flex align-items-center justify-content-between py-3" aria-label="Principal">
        <Link to="/" onClick={close} className="text-reset" aria-label="CodeQuest, inicio">
          <Logo size={34} />
        </Link>

        <button
          type="button"
          className="btn btn-cq-outline btn-cq d-lg-none px-3"
          onClick={() => setOpen((v) => !v)}
          aria-expanded={open}
          aria-controls="cq-nav-menu"
          aria-label="Abrir menú"
        >
          <i className={`bi ${open ? 'bi-x-lg' : 'bi-list'}`} aria-hidden="true" />
        </button>

        <div id="cq-nav-menu" className={`cq-nav-menu ${open ? 'is-open' : ''}`}>
          <a href="/#como-funciona" onClick={close} className="cq-nav-link">Cómo funciona</a>
          <a href="/#modulos" onClick={close} className="cq-nav-link">Módulos</a>
          <a href="/#beneficios" onClick={close} className="cq-nav-link">Beneficios</a>

          {user ? (
            <>
              <NavLink
                to={user.needs_diagnostic ? '/diagnostico' : '/panel'}
                onClick={close}
                className="btn btn-cq btn-cq-outline"
              >
                <i className="bi bi-person-circle" aria-hidden="true" />
                {user.full_name.split(' ')[0]}
              </NavLink>
              <button type="button" onClick={handleLogout} className="btn btn-cq btn-cq-outline">
                <i className="bi bi-box-arrow-right" aria-hidden="true" />
                Salir
              </button>
            </>
          ) : (
            <>
              <NavLink to="/iniciar-sesion" onClick={close} className="btn btn-cq btn-cq-outline">
                Iniciar sesión
              </NavLink>
              <NavLink to="/registro" onClick={close} className="btn btn-cq btn-cq-primary">
                Registrarse
              </NavLink>
            </>
          )}
        </div>
      </nav>
    </header>
  );
}
