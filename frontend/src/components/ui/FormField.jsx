import { useId, useState } from 'react';

/**
 * Campo de formulario con etiqueta, ícono, mensaje de error y,
 * para contraseñas, botón para mostrar u ocultar el texto.
 */
export default function FormField({
  label,
  name,
  type = 'text',
  value,
  onChange,
  error,
  icon,
  autoComplete,
  placeholder,
  children,
}) {
  const id = useId();
  const [visible, setVisible] = useState(false);
  const isPassword = type === 'password';
  const inputType = isPassword && visible ? 'text' : type;
  const errorId = `${id}-error`;

  return (
    <div className="mb-3">
      <label htmlFor={id} className="form-label">
        {icon && <i className={`bi ${icon} me-2`} style={{ color: 'var(--cq-accent)' }} aria-hidden="true" />}
        {label}
      </label>
      <div className={isPassword ? 'input-group has-validation' : ''}>
        <input
          id={id}
          name={name}
          type={inputType}
          value={value}
          onChange={onChange}
          autoComplete={autoComplete}
          placeholder={placeholder}
          className={`form-control ${error ? 'is-invalid' : ''}`}
          aria-invalid={Boolean(error)}
          aria-describedby={error ? errorId : undefined}
        />
        {isPassword && (
          <button
            type="button"
            className="btn"
            onClick={() => setVisible((v) => !v)}
            aria-label={visible ? 'Ocultar contraseña' : 'Mostrar contraseña'}
          >
            <i className={`bi ${visible ? 'bi-eye-slash' : 'bi-eye'}`} aria-hidden="true" />
          </button>
        )}
        {error && (
          <div id={errorId} className="invalid-feedback d-block">
            {error}
          </div>
        )}
      </div>
      {children}
    </div>
  );
}
