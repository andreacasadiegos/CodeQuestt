import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// Dirección de la API en Apache (XAMPP).
// El repositorio debe estar en C:\xampp\htdocs\codequest
const API_TARGET = 'http://localhost';
const API_PATH = '/codequest/backend/api';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    // Las peticiones a /api se reenvían a Apache. Así frontend y backend
    // comparten origen y la cookie de sesión de PHP funciona sin CORS.
    proxy: {
      '/api': {
        target: API_TARGET,
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, API_PATH),
      },
    },
  },
});
