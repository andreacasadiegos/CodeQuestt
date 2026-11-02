import { apiRequest } from './api.js';

/** Resumen del panel: XP, nivel, actividades, insignias, retos, módulos y avance de ruta. */
export function getDashboard() {
  return apiRequest('/dashboard');
}

/** Todas las insignias con lo que lleva el estudiante hacia cada una. */
export function getBadges() {
  return apiRequest('/badges');
}

/** Progreso detallado: módulos, actividades, historial de intentos y de XP. */
export function getProgress() {
  return apiRequest('/progress');
}

/** Pide pasar a la ruta intermedia. El servidor comprueba la regla del 80 %. */
export function advancePath() {
  return apiRequest('/path/advance', { method: 'POST' });
}
