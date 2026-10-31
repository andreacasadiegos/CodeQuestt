import { useCallback, useEffect, useState } from 'react';

/**
 * Ejecuta una llamada a la API al montar el componente (y cuando cambian
 * las dependencias) y expone { data, loading, error, reload }.
 *
 * @param {() => Promise<any>} request Función que hace la petición.
 * @param {Array} deps Dependencias que obligan a repetir la petición.
 */
export function useApi(request, deps = []) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const run = useCallback(request, deps);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      setData(await run());
    } catch (err) {
      setError(err);
    } finally {
      setLoading(false);
    }
  }, [run]);

  useEffect(() => {
    load();
  }, [load]);

  return { data, loading, error, reload: load };
}
