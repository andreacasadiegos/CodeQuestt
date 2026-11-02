# CodeQuest: Aprende a programar

Plataforma web educativa y gamificada para que estudiantes de grado 11.º del
Colegio Fernández aprendan fundamentos de programación: **abstracción**,
**patrones** y **algoritmos**.

Arquitectura: **React (Vite) → API REST en PHP → MySQL**.
Node.js se usa solo como herramienta de desarrollo del frontend.

## Requisitos

| Herramienta | Versión | Para qué |
| --- | --- | --- |
| XAMPP | 8.2 o superior (PHP 8.2+) | Apache, PHP y MySQL/MariaDB |
| Node.js | 20 LTS o superior | Instalar y ejecutar el frontend |
| Git | Cualquiera reciente | Control de versiones |
| Visual Studio Code | Cualquiera reciente | Editor |

## Estructura

```text
codequest/
├── database/   Scripts SQL: esquema, datos iniciales y métricas
├── docs/       Guion de demostración
├── backend/    API REST en PHP
│   └── api/    Punto de entrada: index.php + .htaccess
└── frontend/   Aplicación React (Vite)
```

## Instalación en Windows

1. Copia o clona el proyecto en `C:\xampp\htdocs\codequest`.
   La ruta importa: Vite reenvía `/api` a `http://localhost/codequest/backend/api`.
2. Abre el **XAMPP Control Panel** y pulsa **Start** en **Apache**.
3. Comprueba el backend en el navegador:
   <http://localhost/codequest/backend/api/health>
   Debe mostrar un JSON con `"status": "ok"`.
4. En una terminal de VS Code:

   ```bash
   cd C:\xampp\htdocs\codequest\frontend
   npm install
   npm run dev
   ```

5. Abre <http://localhost:5173>. Debe aparecer el mensaje
   «La API de CodeQuest está funcionando».

## Base de datos

1. En el XAMPP Control Panel, pulsa **Start** en **MySQL**.
2. Abre <http://localhost/phpmyadmin> y entra en la pestaña **SQL** (sin
   seleccionar ninguna base).
3. Ejecuta, en este orden, el contenido de:
   1. `database/01_schema.sql` (crea `codequest_db` con 16 tablas; **borra la base si ya existía**).
   2. `database/02_seed_catalogos.sql` (rutas, niveles, módulos e insignias).
   3. `database/03_seed_diagnostico.sql` (prueba diagnóstica de 5 preguntas).
   4. `database/04_seed_contenido.sql` (15 lecciones de los 3 módulos).
   5. `database/05_seed_actividades.sql` (15 prácticas y 6 evaluaciones con 54 preguntas).
   6. `database/06_seed_retos.sql` (6 retos de módulo con 30 preguntas).
4. Ejecuta `database/verificacion.sql`. Debe mostrar 16 tablas, 26 claves
   foráneas y 2 rutas, 5 niveles, 3 módulos y 8 insignias.
5. Opcional: en `codequest_db` → **Más** → **Diseñador** puedes ver el
   diagrama de relaciones.

## Configuración del backend

Copia `backend/config/config.example.php` como `backend/config/config.php`.
Con XAMPP recién instalado no hay que cambiar nada (usuario `root` sin
contraseña). `config.php` no se sube a Git.

## Probar la API (Thunder Client)

Instala la extensión **Thunder Client** en VS Code. Con Apache y MySQL
encendidos, usa la URL base `http://localhost/codequest/backend/api` y en
las peticiones POST elige **Body → JSON**. Thunder Client guarda la cookie
de sesión automáticamente.

| # | Petición | Cuerpo JSON | Resultado esperado |
| --- | --- | --- | --- |
| 1 | `GET /health` | — | 200, `"database": "conectada"` |
| 2 | `GET /auth/me` | — | 200 con `"user": null` (no hay sesión) |
| 3 | `POST /auth/register` | `{"full_name":"A","email":"malo","password":"abc","password_confirmation":"x"}` | 422 con un error por campo |
| 4 | `POST /auth/register` | `{"full_name":"Ana María Pérez","email":"ana@colegio.edu.co","password":"codigo123","password_confirmation":"codigo123"}` | 201 con el usuario, `"needs_diagnostic": true` |
| 5 | Repetir la 4 | igual | 409, correo ya registrado |
| 6 | `GET /auth/me` | — | 200 con el usuario (la sesión quedó iniciada) |
| 7 | `POST /auth/logout` | — | 200, «Sesión cerrada correctamente.» |
| 8 | `GET /auth/me` | — | 200 con `"user": null` |
| 9 | `POST /auth/login` | `{"email":"ana@colegio.edu.co","password":"otra1234"}` | 401, «Correo o contraseña incorrectos.» |
| 10 | `POST /auth/login` | `{"email":"ana@colegio.edu.co","password":"codigo123"}` | 200 con el usuario |

En phpMyAdmin, la tabla `users` debe mostrar la contraseña como un hash que
empieza por `$2y$10$`, nunca el texto original.

## Probar el diagnóstico (Etapa 5)

Regístrate en <http://localhost:5173>: entrarás directo al diagnóstico.
Las respuestas correctas de la prueba son **A, B, B, C, C**. Así se asigna la ruta:

| Autoevaluación | Aciertos | Ruta |
| --- | --- | --- |
| No tengo conocimientos | cualquiera | Básica |
| Tengo conocimientos básicos | 4 o 5 | Intermedia |
| Tengo conocimientos básicos | 0 a 3 | Básica (con posibilidad de avanzar) |
| Ya he estudiado programación | 3 a 5 | Intermedia |
| Ya he estudiado programación | 0 a 2 | Básica (con posibilidad de avanzar) |

En phpMyAdmin verás el resultado en `diagnostics`, `attempts`, `attempt_answers`
y en `users.path_id`. El diagnóstico solo se puede hacer una vez: un segundo
envío responde 409.

## Probar módulos y lecciones (Etapa 6)

Cada módulo tiene una lección común y dos propias de cada ruta (3 lecciones
por módulo para cada estudiante):

| Módulo | Común | Ruta básica | Ruta intermedia |
| --- | --- | --- | --- |
| Abstracción | ¿Qué es la abstracción? | Lo esencial y los detalles · Usar sin conocer todos los detalles | Modelar datos · Funciones |
| Patrones | ¿Qué es un patrón? | Secuencias de números y figuras · Repetir sin repetirse | La regla del término n · Patrones con ciclos y condiciones |
| Algoritmos | ¿Qué es un algoritmo? | Paso a paso: secuencias · Tomar decisiones | Variables, condiciones y ciclos · Encontrar el mayor |

1. Entra con un estudiante de ruta básica y otro de ruta intermedia: cada uno ve sus propias lecciones.
2. Las lecciones se desbloquean en orden; abrir una bloqueada por URL responde «Completa la lección anterior».
3. Al pulsar «Entendido, continuar» se guarda en `lesson_progress` y el avance del módulo en `module_progress`.
4. Cierra sesión y vuelve a entrar: el avance se conserva.

## Probar actividades y calificación (Etapa 7)

Cada lección tiene una práctica de 2 preguntas y cada módulo una evaluación
de 4 preguntas por ruta. Hay cinco tipos de pregunta: selección múltiple,
identificar patrones, completar código, ordenar pasos y relacionar conceptos.

| Actividad | Dificultad | XP máximo | Se aprueba con |
| --- | --- | --- | --- |
| Práctica de la lección 1, 2 y 3 | 1, 2 y 3 estrellas | 10, 20 y 30 | 60 % |
| Evaluación del módulo | 3 estrellas | 40 | 60 % |

1. En una lección pulsa «Entendido, a practicar»: abre su práctica.
2. Responde y envía. El resultado muestra el puntaje, el XP ganado, el nivel y la explicación de cada pregunta.
3. XP = XP máximo × porcentaje de aciertos. Al reintentar solo se suma la mejora: repetir con el mismo puntaje da 0 XP.
4. La evaluación del módulo se desbloquea al leer todas sus lecciones.
5. En phpMyAdmin revisa `attempts`, `attempt_answers`, `xp_transactions` y `users.xp_total` / `users.level_id`.

Seguridad que se puede comprobar en Thunder Client:

| Prueba | Resultado esperado |
| --- | --- |
| `GET /activities/2` | Las preguntas llegan sin `is_correct` ni orden o parejas correctas |
| `POST /activities/2/submit` con `{"answers":[], "xp": 999}` | 422; el XP nunca se acepta del navegador |
| Abrir la práctica de una lección no leída | 403, «Lee primero la lección de esta práctica.» |
| Abrir una evaluación de la otra ruta | 404 |

## Probar gamificación, panel y avance de ruta (Etapa 8)

**Retos.** Cada módulo tiene un reto de 5 preguntas que mezcla los tipos de
pregunta (60 XP, se aprueba con 70 %). Se desbloquea al aprobar la evaluación
del módulo.

**Insignias.** Se otorgan solas, en el servidor, justo después de calificar:

| Insignia | Meta | Premio |
| --- | --- | --- |
| Primer paso | Aprobar 1 actividad | 10 XP |
| Constancia | Aprobar 10 actividades | 30 XP |
| Sin errores | Sacar 100 % en una actividad | 20 XP |
| Retador | Superar un reto | 25 XP |
| Maestro de… (×3) | Completar el módulo al 100 % | 40 XP |
| Leyenda en ascenso | Llegar a 500 XP | — |

**Avance de ruta (RF-31).** Un estudiante de ruta básica que aprueba las 3
evaluaciones con un promedio de 80 % o más ve en el panel el botón «Avanzar a
la ruta intermedia». El servidor vuelve a comprobar la regla; conserva XP,
insignias e intentos, y en `diagnostics` queda la ruta inicial.

Páginas nuevas: **Panel** (nivel, XP, actividades, insignias, retos y
avance de ruta), **Progreso** (mejor resultado e intentos por actividad,
historial de intentos y de XP) e **Insignias**.

| Petición (Thunder Client) | Resultado esperado |
| --- | --- |
| `GET /dashboard` | Resumen del panel |
| `GET /badges` | 8 insignias con `earned`, `current` y `target` |
| `GET /progress` | Módulos, actividades, intentos y movimientos de XP |
| `POST /path/advance` sin cumplir la regla | 409, «Aún no cumples la regla para avanzar de ruta.» |
| `GET /activities/{reto}` sin aprobar la evaluación | 403, «Aprueba la evaluación del módulo para desbloquear el reto.» |

## Métricas y demostración

- `database/07_consultas_metricas.sql`: consultas de solo lectura con
  estudiantes registrados, rutas, avances de ruta, niveles, ranking de XP,
  avance por módulo, actividades y preguntas más difíciles, retos e
  insignias, y una comprobación de integridad del XP.
- `docs/guion-demostracion.md`: guion paso a paso para presentar el proyecto.

## Problemas frecuentes

| Síntoma | Causa probable | Solución |
| --- | --- | --- |
| `/health` responde 404 de Apache | `mod_rewrite` desactivado o `.htaccess` ignorado | En `C:\xampp\apache\conf\httpd.conf`, verifica que `LoadModule rewrite_module` no tenga `#` y que `<Directory "C:/xampp/htdocs">` tenga `AllowOverride All`. Reinicia Apache |
| React dice «No se pudo conectar con la API» | Apache apagado o proyecto en otra carpeta | Enciende Apache y confirma la ruta del paso 1 |
| Apache no arranca | Puerto 80 ocupado (Skype, IIS) | Cierra el programa o cambia el puerto en XAMPP y en `vite.config.js` |
| MySQL no arranca en XAMPP | Puerto 3306 ocupado por otro MySQL instalado | Detén el otro servicio de MySQL en Servicios de Windows |
| La API responde 500 «Falta backend/config/config.php» | No se creó el archivo de configuración | Copia `config.example.php` como `config.php` |
| `#1046 No database selected` | Se ejecutó el seed sin el schema | Ejecuta primero `01_schema.sql` |
| Aparecen tildes rotas (`Ã³`) | Los scripts se ejecutaron con otra codificación | Vuelve a ejecutarlos: cada uno empieza con `SET NAMES utf8mb4` |
| `npm` no se reconoce | Node.js no instalado o terminal abierta antes de instalarlo | Instala Node.js LTS y abre una terminal nueva |

## Etapas

| Etapa | Contenido | Estado |
| --- | --- | --- |
| 0 | Análisis y planificación | Completada |
| 1 | Entorno de desarrollo | Completada |
| 2 | Base de datos | Completada |
| 3 | API base y autenticación | Completada |
| 4 | Identidad visual, inicio y acceso | Completada |
| 5 | Diagnóstico | Completada |
| 6 | Módulos y lecciones | Completada |
| 7 | Actividades y calificación | Completada |
| 8 | Gamificación, panel y cierre | Completada |
