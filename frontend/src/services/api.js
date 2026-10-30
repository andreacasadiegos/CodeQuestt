/**
 * Cliente base de la API de CodeQuest.
 *
 * Todas las llamadas al backend pasan por aquí, para que el manejo de
 * errores y el envío de la cookie de sesión estén en un solo lugar.
 */
const BASE_URL = '/api';

/**
 * Hace una petición a la API y devuelve el JSON de respuesta.
 * Si el servidor responde con error, lanza un Error con el mensaje recibido.
 *
 * @param {string} path   Ruta del endpoint, por ejemplo '/health'.
 * @param {object} options { method, body }
 */
export async function apiRequest(path, { method = 'GET', body } = {}) {
  const response = await fetch(`${BASE_URL}${path}`, {
    method,
    credentials: 'include',
    headers: body ? { 'Content-Type': 'application/json' } : {},
    body: body ? JSON.stringify(body) : undefined,
  });

  let data = null;
  try {
    data = await response.json();
  } catch {
    // La respuesta no era JSON (por ejemplo, Apache apagado).
  }

  if (!response.ok || data === null) {
    const error = new Error(data?.error ?? `No se pudo conectar con la API (código ${response.status})`);
    error.status = response.status;
    throw error;
  }

  return data;
}
