import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';

import AuthLayout from '../components/layout/AuthLayout.jsx';
import Alert from '../components/ui/Alert.jsx';
import FormField from '../components/ui/FormField.jsx';
import { useAuth } from '../hooks/useAuth.js';
import { passwordChecks, validateRegister } from '../utils/validators.js';

const EMPTY_FORM = { full_name: '', email: '', password: '', password_confirmation: '' };

/** Registro de estudiantes. Al terminar, pasa directo al diagnóstico. */
export default function RegisterPage() {
  const { register } = useAuth();
  const navigate = useNavigate();
  const [form, setForm] = useState(EMPTY_FORM);
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

    const clientErrors = validateRegister(form);
    if (Object.keys(clientErrors).length > 0) {
      setErrors(clientErrors);
      return;
    }

    setSubmitting(true);
    try {
      await register(form);
      navigate('/diagnostico', { replace: true });
    } catch (error) {
      setErrors(error.fields ?? {});
      setServerError(error.message);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <AuthLayout
      title="Crea tu cuenta"
      subtitle="Empieza tu aventura para aprender a programar."
      footer={<>¿Ya tienes cuenta? <Link to="/iniciar-sesion">Inicia sesión</Link></>}
    >
      <form className="cq-form" onSubmit={handleSubmit} noValidate>
        <Alert>{serverError}</Alert>

        <FormField
          label="Nombre completo"
          name="full_name"
          icon="bi-person"
          value={form.full_name}
          onChange={handleChange}
          error={errors.full_name}
          autoComplete="name"
          placeholder="Ej.: Laura Gómez Ruiz"
        />
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
        <div className="row">
          <div className="col-md-6">
            <FormField
              label="Contraseña"
              name="password"
              type="password"
              icon="bi-lock"
              value={form.password}
              onChange={handleChange}
              error={errors.password}
              autoComplete="new-password"
            >
              <ul className="cq-password-checks" aria-label="Requisitos de la contraseña">
                {passwordChecks(form.password).map((check) => (
                  <li key={check.label} className={check.ok ? 'ok' : ''}>
                    <i className={`bi ${check.ok ? 'bi-check-circle-fill' : 'bi-circle'} me-1`} aria-hidden="true" />
                    {check.label}
                  </li>
                ))}
              </ul>
            </FormField>
          </div>
          <div className="col-md-6">
            <FormField
              label="Confirmar contraseña"
              name="password_confirmation"
              type="password"
              icon="bi-shield-lock"
              value={form.password_confirmation}
              onChange={handleChange}
              error={errors.password_confirmation}
              autoComplete="new-password"
            />
          </div>
        </div>

        <button type="submit" className="btn btn-cq btn-cq-primary w-100 mt-2" disabled={submitting}>
          {submitting ? 'Creando tu cuenta…' : <>Crear cuenta <i className="bi bi-arrow-right" aria-hidden="true" /></>}
        </button>
      </form>
    </AuthLayout>
  );
}
