# Guion de demostración de CodeQuest

Duración aproximada: 15 minutos. Todo lo que se muestra se guarda y se lee
de MySQL; no hay datos simulados.

## Antes de empezar (10 minutos antes)

1. Enciende **Apache** y **MySQL** en XAMPP.
2. En phpMyAdmin → pestaña SQL, ejecuta en orden `01_schema.sql` a
   `06_seed_retos.sql` para partir de una base limpia.
3. En la terminal de VS Code: `cd C:\xampp\htdocs\codequest\frontend` y `npm run dev`.
4. Abre <http://localhost:5173> en el navegador y deja una segunda pestaña con
   phpMyAdmin en `codequest_db`.
5. Opcional, para mostrar el avance de ruta sin esperar: registra antes un
   estudiante «Prueba Avance» en ruta básica, lee las lecciones de los
   3 módulos y aprueba las 3 evaluaciones con las respuestas del anexo.

## 1. Presentación (1 min)

- Página de inicio: propósito, los tres módulos y cómo funciona.
- Mensaje clave: React en el navegador, API en PHP y datos en MySQL.

## 2. Registro y seguridad de la cuenta (2 min)

1. **Registrarse** con datos inválidos: se ven los errores por campo (validación en React).
2. Regístrate bien (por ejemplo `ana@colegio.edu.co` / `codigo123`).
3. En phpMyAdmin → `users`: la contraseña está guardada como hash `$2y$…`.
4. Intenta abrir <http://localhost:5173/panel> en una ventana privada: te
   envía a iniciar sesión (ruta protegida).

## 3. Diagnóstico y ruta (2 min)

1. Elige «No tengo conocimientos» y responde las 5 preguntas.
2. Muestra el resultado: aciertos, ruta asignada y explicación de cada pregunta.
3. En phpMyAdmin → `diagnostics`: autoevaluación, aciertos y ruta.

## 4. Aprender: módulos y lecciones (2 min)

1. Panel: nivel, XP, actividades, insignias, retos y los 3 módulos.
2. Abre **Abstracción**: lecciones en orden, la segunda está bloqueada.
3. Lee la primera lección y pulsa «Entendido, a practicar».

## 5. Practicar: actividades y XP (3 min)

1. Resuelve la práctica (selección y relacionar conceptos) con todo correcto.
2. Resultado: puntaje, **+10 XP** e insignias **Primer paso** y **Sin errores**.
3. Pulsa **Reintentar** y repite: ya no suma XP (solo se paga la mejora).
4. Muestra en otra práctica los tipos **ordenar pasos** (arrastrar o con
   las flechas), **completar código** e **identificar patrones**.
5. En phpMyAdmin → `attempts` y `xp_transactions`: cada intento y cada punto
   quedan registrados.

## 6. Gamificación y seguimiento (2 min)

1. **Insignias**: obtenidas en color y las demás con su avance (ej. 1/10).
2. **Progreso**: mejor resultado e intentos por actividad, últimos intentos e historial de XP.
3. Si está preparado el estudiante del paso 5 de la preparación, entra con él:
   - El panel muestra «¡Puedes avanzar a la ruta intermedia!» con su promedio.
   - Pulsa avanzar: conserva XP e insignias y ahora ve las lecciones intermedias.
   - Los retos de módulo ya están disponibles.

## 7. Seguridad de los puntajes (2 min, Thunder Client)

| Prueba | Qué se demuestra |
| --- | --- |
| `GET /api/activities/2` | Las preguntas llegan sin respuestas correctas |
| `POST /api/activities/2/submit` con `{"answers": [], "xp": 999}` | 422: el XP nunca viene del navegador |
| `POST /api/path/advance` con un estudiante que no cumple | 409: el servidor revisa la regla del 80 % |
| `GET /api/dashboard` sin sesión | 401: ruta privada |

## 8. Métricas (1 min)

Ejecuta `database/07_consultas_metricas.sql` en phpMyAdmin: estudiantes
registrados, rutas, niveles, actividades más difíciles, preguntas con más
errores, retos superados e insignias otorgadas. La consulta 12 comprueba que
el XP de cada estudiante coincide con su historial.

## Anexo: respuestas de las evaluaciones de la ruta básica

**Evaluación: Abstracción**
1. Estaciones, líneas y conexiones
2. Transporte escolar = Dirección de la casa · Biblioteca = Libros prestados · Enfermería = Alergias
3. Elimina los detalles que no ayudan al objetivo
4. Qué botones usar para sumar

**Evaluación: Patrones**
1. 50
2. 162
3. `3`
4. Un triángulo

**Evaluación: Algoritmos**
1. Desbloquear el celular → Abrir el chat → Escribir el mensaje → Enviar
2. 7
3. `sino`
4. leer = Recibe un dato · mostrar = Presenta un resultado · ← = Guarda un valor en una variable

> Este anexo es solo para quien presenta: no lo compartas con los estudiantes.
