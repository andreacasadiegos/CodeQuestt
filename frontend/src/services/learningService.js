/**
 * Llamadas a la API del recorrido de aprendizaje.
 * En las siguientes etapas se agregan módulos, lecciones y actividades.
 */
import { apiRequest } from './api.js';

/** Autoevaluación y preguntas del diagnóstico (sin respuestas correctas). */
export function getDiagnostic() {
  return apiRequest('/diagnostic');
}

/**
 * Envía el diagnóstico. El servidor califica y asigna la ruta.
 * @param {number} experienceOption 1, 2 o 3
 * @param {Array<{question_id: number, option_id: number}>} answers
 */
export function submitDiagnostic(experienceOption, answers) {
  return apiRequest('/diagnostic', {
    method: 'POST',
    body: { experience_option: experienceOption, answers },
  });
}
