# CodeQuest — plan técnico de evolución

## Decisiones confirmadas

- Renovación integral de la experiencia con una identidad visual inspirada en plataformas de aprendizaje gamificadas: amable, colorida, clara y responsive. No se copiará la identidad de Duolingo.
- Mejoras para todo el producto, con prioridad en el dashboard del estudiante.
- Tutor educativo CodeBot impulsado por IA.
- Historial persistente de conversaciones por estudiante.
- Se conserva la arquitectura existente: React + Vite, API REST PHP y MySQL/Supabase.
- La autenticación existente basada en cookie de sesión seguirá siendo la fuente de identidad.

## Estado de partida verificado

- Frontend: React 18 + Vite + React Router + Bootstrap.
- Backend: API REST en PHP.
- Persistencia: MySQL local y Supabase en producción.
- El dashboard ya consume `GET /api/dashboard` y muestra XP, estadísticas, módulos, retos e insignias.
- Las rutas privadas están protegidas con `ProtectedRoute`; administración usa `AdminRoute`.
- Los estilos globales actuales usan una paleta oscura morada. La nueva identidad se implementará mediante tokens CSS para evitar cambios aislados de color.
- La API usa `credentials: 'include'`; las nuevas peticiones del tutor deben reutilizar el cliente `apiRequest`.

## Arquitectura objetivo

```
React (Dashboard / CodeBot)
        |
        | HTTPS + cookie de sesión
        v
API REST PHP
  |-- verifica sesión y usuario
  |-- valida y limita solicitudes
  |-- carga contexto educativo permitido
  |-- guarda mensajes e historial
  |-- invoca proveedor de IA desde servidor
        |
        +---- MySQL / Supabase
        |
        +---- Adaptador de proveedor IA
```

### CodeBot: comportamiento

- Explica abstracción, patrones y algoritmos con lenguaje apropiado para grado 11.
- Adapta ejemplos y dificultad a la ruta básica o intermedia del estudiante.
- Ofrece pistas graduales antes de revelar una solución.
- Explica errores y propone ejercicios pequeños.
- Usa el contexto de la conversación actual y un resumen acotado de conversaciones anteriores cuando sea útil.
- No inventa notas, XP, insignias ni estados de progreso: esos datos se consultan a los endpoints oficiales.
- Debe reconocer cuando una pregunta está fuera del alcance educativo de CodeQuest y redirigirla con amabilidad.

### Persistencia propuesta

Tablas nuevas, sujetas a validar el motor y convenciones del esquema real antes de migrar:

- `tutor_conversations`: id, user_id, title, created_at, updated_at, archived_at.
- `tutor_messages`: id, conversation_id, user_id, role, content, created_at, token_count opcional.
- Índices por `user_id, updated_at` y `conversation_id, created_at`.
- Claves foráneas y borrado en cascada desde la conversación; el acceso siempre se filtra por el usuario autenticado.
- No guardar claves API ni datos secretos en estas tablas.

Se debe definir una política de retención y un límite de tamaño por mensaje/conversación antes de producción. No se guardarán datos sensibles innecesarios.

### Seguridad y confiabilidad

- La clave del proveedor IA vive en variables de entorno del servidor/Vercel; nunca en variables `VITE_*`, código cliente o Git.
- El servidor determina el `user_id` desde la sesión. Nunca acepta el identificador del estudiante como autoridad desde el body.
- Consultas SQL parametrizadas y autorización por propietario para leer, renombrar o archivar conversaciones.
- Límites de frecuencia, longitud de mensaje, tokens y presupuesto; errores controlados y timeout.
- No enviar contraseñas, correo, ni información personal innecesaria al proveedor IA.
- El historial enviado al modelo se limita a la conversación activa y a un resumen educativo pertinente.
- Registrar errores técnicos sin almacenar el contenido privado completo del chat en logs.

## Implementación por fases

### Fase 0 — Preparación (iniciada)
- Crear rama de trabajo independiente.
- Documentar arquitectura, riesgos y criterios de aceptación.
- No modificar `main` ni ejecutar scripts SQL destructivos.

### Fase 1 — Sistema visual y navegación
- Definir tokens claros: verde de marca, fondos suaves, tarjetas blancas, acentos cálidos para XP/recompensas y colores accesibles para estados.
- Renovar navbar, footer, botones, tarjetas, formularios, estados de carga/error y navegación móvil.
- Adaptar todas las páginas existentes sin cambiar sus contratos de API.
- Respetar contraste, foco visible, teclado y preferencia de movimiento reducido.

Criterio de aceptación: todas las rutas actuales se ven coherentes en móvil y escritorio; registro, login, diagnóstico y navegación siguen funcionando.

### Fase 2 — Dashboard del estudiante
- Mejorar jerarquía visual de bienvenida, nivel, XP y racha si el backend ya dispone de ese dato.
- Mostrar progreso por módulo, siguiente paso recomendado y accesos directos.
- Añadir tarjeta de entrada a CodeBot.
- No inventar métricas: reutilizar la respuesta real de `GET /api/dashboard`; cualquier dato nuevo requiere endpoint y prueba.

Criterio de aceptación: los datos y enlaces reflejan el estado real del estudiante y se conservan las funciones existentes.

### Fase 3 — CodeBot e historial persistente
- Acordar proveedor/modelo IA y configuración de presupuesto.
- Crear migración aditiva para conversaciones y mensajes, compatible con MySQL/Supabase.
- Implementar servicios y controladores PHP, rutas privadas y autorización por propietario.
- Añadir adaptador de proveedor IA en backend, con timeout, límites y manejo de errores.
- Crear interfaz de chat, lista de conversaciones, crear conversación y reabrir historial.
- Añadir pruebas de aislamiento entre usuarios y validación de entradas.

Criterio de aceptación: un estudiante puede conversar, cerrar sesión, volver a entrar y recuperar únicamente sus conversaciones; otro estudiante no puede acceder a ellas.

### Fase 4 — Administración y seguimiento
- Mejorar panel de administración y detalle de estudiante.
- Añadir indicadores solo cuando existan datos confiables y consultas eficientes.
- No exponer mensajes privados de CodeBot al administrador por defecto; cualquier función de revisión debe tener finalidad educativa, aviso y permisos explícitos.

### Fase 5 — Calidad y despliegue
- Ejecutar build del frontend, pruebas disponibles y revisión de endpoints.
- Probar responsive, teclado, accesibilidad básica, autenticación, permisos, persistencia y errores de IA.
- Revisar variables de entorno y despliegue Vercel/Supabase.
- Abrir Pull Request para revisión antes de integrar a `main`.

## Criterios globales de no regresión

- No alterar el flujo de registro, login, diagnóstico ni cookies de sesión.
- No cambiar la lógica de XP, calificaciones, desbloqueos o insignias sin requisito y pruebas.
- No ejecutar `database/01_schema.sql` sobre una base existente: el README indica que elimina y recrea la base.
- Las migraciones nuevas serán aditivas y tendrán instrucciones de reversión.
- Cada fase se valida antes de iniciar la siguiente.

## Pendientes antes de conectar la IA

1. Confirmar proveedor de IA (por ejemplo, OpenAI u otro compatible).
2. Configurar la clave como secreto de entorno en el backend/Vercel.
3. Definir límite inicial de uso por estudiante y presupuesto mensual.
4. Revisar el esquema real de usuarios y convenciones SQL para preparar la migración correcta.
