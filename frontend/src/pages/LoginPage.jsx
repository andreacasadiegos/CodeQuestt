import { useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';

import AuthLayout from '../components/layout/AuthLayout.jsx';
import Alert from '../components/ui/Alert.jsx';
import FormField from '../components/ui/FormField.jsx';
import { useAuth } from '../hooks/useAuth.js';
import { validateLogin } from '../utils/validators.js';
import { homeFor } from '../utils/home.js';

/** Inicio de sesión. Vuelve a la página que el estudiante quería abrir. */
export default function LoginPage() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [form, setForm] = useState({ email: '', password: '' });
  const [errors, setErrors] = useState({});
  const [serverError, setServerError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const handleChange = (event) => {
    const { name, value } = event.target;
    setForm((current) => ({ ...current, [name]: value }));
    setErrors((current) => ({ ...current, [name]: undefined }));
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setServerError('');

    const clientErrors = validateLogin(form);
    if (Object.keys(clientErrors).length > 0) {
      setErrors(clientErrors);
      return;
    }

    setSubmitting(true);
    try {
      const user = await login(form);
      navigate(location.state?.from ?? homeFor(user), { replace: true });
    } catch (error) {
      setErrors(error.fields ?? {});
      setServerError(error.message);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <AuthLayout
      title="¡Hola de nuevo!"
      subtitle="Inicia sesión para continuar tu progreso."
      footer={<>¿Aún no tienes cuenta? <Link to="/registro">Regístrate</Link></>}
    >
      <form className="cq-form" onSubmit={handleSubmit} noValidate>
        <Alert>{serverError}</Alert>

        <FormField
          label="Correo electrónico"
          name="email"
          type="email"
          icon="bi-envelope"
          value={form.email}
          onChange={handleChange}
          error={errors.email}
          autoComplete="email"
          placeholder="tucorreo@ejemplo.com"
        />
        <FormField
          label="Contraseña"
          name="password"
          type="password"
          icon="bi-lock"
          value={form.password}
          onChange={handleChange}
          error={errors.password}
          autoComplete="current-password"
        />

        <button type="submit" className="btn btn-cq btn-cq-primary w-100 mt-2" disabled={submitting}>
          {submitting ? 'Entrando…' : <>Iniciar sesión <i className="bi bi-box-arrow-in-right" aria-hidden="true" /></>}
        </button>
      </form>
    </AuthLayout>
  );
}
