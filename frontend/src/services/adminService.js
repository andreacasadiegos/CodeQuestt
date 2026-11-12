import { apiRequest } from './api.js';

/** Resumen general y una fila por estudiante (solo administradores). */
export function getStudents() {
  return apiRequest('/admin/students');
}

/** Detalle de un estudiante: diagnóstico, módulos, insignias e intentos. */
export function getStudent(id) {
  return apiRequest(`/admin/students/${id}`);
}
