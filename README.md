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
├── database/   Scripts SQL (Etapa 2)
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

## Problemas frecuentes

| Síntoma | Causa probable | Solución |
| --- | --- | --- |
| `/health` responde 404 de Apache | `mod_rewrite` desactivado o `.htaccess` ignorado | En `C:\xampp\apache\conf\httpd.conf`, verifica que `LoadModule rewrite_module` no tenga `#` y que `<Directory "C:/xampp/htdocs">` tenga `AllowOverride All`. Reinicia Apache |
| React dice «No se pudo conectar con la API» | Apache apagado o proyecto en otra carpeta | Enciende Apache y confirma la ruta del paso 1 |
| Apache no arranca | Puerto 80 ocupado (Skype, IIS) | Cierra el programa o cambia el puerto en XAMPP y en `vite.config.js` |
| `npm` no se reconoce | Node.js no instalado o terminal abierta antes de instalarlo | Instala Node.js LTS y abre una terminal nueva |

## Etapas

| Etapa | Contenido | Estado |
| --- | --- | --- |
| 0 | Análisis y planificación | Completada |
| 1 | Entorno de desarrollo | Completada |
| 2 | Base de datos | Pendiente |
| 3 | API base y autenticación | Pendiente |
| 4 | Identidad visual, inicio y acceso | Pendiente |
| 5 | Diagnóstico | Pendiente |
| 6 | Módulos y lecciones | Pendiente |
| 7 | Actividades y calificación | Pendiente |
| 8 | Gamificación, panel y cierre | Pendiente |
