/**
 * Llamadas a la API relacionadas con la autenticación.
 */
import { apiRequest } from './api.js';

/** Devuelve el usuario con sesión activa o null si no hay sesión. */
export async function getCurrentUser() {
  const data = await apiRequest('/auth/me');
  return data.user;
}

export async function register(form) {
  const data = await apiRequest('/auth/register', { method: 'POST', body: form });
  return data.user;
}

export async function login(credentials) {
  const data = await apiRequest('/auth/login', { method: 'POST', body: credentials });
  return data.user;
}

export async function logout() {
  await apiRequest('/auth/logout', { method: 'POST' });
}
