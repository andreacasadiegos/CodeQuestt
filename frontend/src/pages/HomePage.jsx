import { Link } from 'react-router-dom';

import { useAuth } from '../hooks/useAuth.js';

const STEPS = [
  { icon: 'bi-person-plus', title: 'Crea tu cuenta', text: 'Regístrate con tu nombre y tu correo en menos de un minuto.' },
  { icon: 'bi-clipboard-check', title: 'Haz el diagnóstico', text: 'Cuéntanos tu experiencia y responde una prueba corta de 5 preguntas.' },
  { icon: 'bi-signpost-split', title: 'Recibe tu ruta', text: 'Te asignamos la ruta básica o la intermedia según lo que ya sabes.' },
  { icon: 'bi-trophy', title: 'Aprende y sube de nivel', text: 'Completa lecciones, actividades y retos para ganar XP e insignias.' },
];

const MODULES = [
  {
    icon: 'bi-layers',
    name: 'Abstracción',
    text: 'Aprende a quedarte con lo importante de un problema y dejar de lado los detalles.',
    example: 'Un mapa del metro no muestra calles: solo estaciones y líneas.',
  },
  {
    icon: 'bi-grid-3x3-gap',
    name: 'Patrones',
    text: 'Descubre regularidades y repeticiones para resolver problemas parecidos de la misma forma.',
    example: '2, 4, 8, 16, ? → cada número es el doble del anterior.',
  },
  {
    icon: 'bi-diagram-3',
    name: 'Algoritmos',
    text: 'Diseña secuencias de pasos ordenados y precisos para resolver un problema.',
    example: '1. Inicio  2. Leer dato  3. Procesar  4. Mostrar  5. Fin',
  },
];

const BENEFITS = [
  { icon: 'bi-graph-up-arrow', title: 'Aprendizaje progresivo', text: 'Las actividades aumentan de dificultad poco a poco.' },
  { icon: 'bi-hand-index-thumb', title: 'Actividades prácticas', text: 'Completas código, ordenas pasos, encuentras patrones y relacionas conceptos.' },
  { icon: 'bi-controller', title: 'Juegos y retos', text: 'Cada módulo termina con un reto que pone a prueba lo aprendido.' },
  { icon: 'bi-lightning-charge', title: 'Puntos y recompensas', text: 'Ganas XP según tu desempeño, subes de nivel y desbloqueas insignias.' },
  { icon: 'bi-bar-chart-line', title: 'Seguimiento del progreso', text: 'Tus resultados quedan guardados y los ves cada vez que entras.' },
  { icon: 'bi-signpost-2', title: 'Ruta a tu medida', text: 'Empiezas donde corresponde según tus conocimientos previos.' },
];

/** Página de inicio pública de CodeQuest. */
export default function HomePage() {
  const { user } = useAuth();
  const continueTo = user?.needs_diagnostic ? '/diagnostico' : '/panel';

  return (
    <>
      {/* ---------- Presentación ---------- */}
      <section className="cq-hero">
        <div className="container">
          <div className="row align-items-center g-5">
            <div className="col-lg-6 cq-fade-up">
              <span className="cq-eyebrow mb-3">// grado 11.º · Colegio Fernández</span>
              <h1 className="mt-3 mb-4">
                Aprende a programar <span className="cq-gradient-text">superando misiones</span>
              </h1>
              <p className="cq-hero-lead cq-muted mb-4">
                CodeQuest es una plataforma interactiva y gamificada para aprender los fundamentos de la
                programación: abstracción, patrones y algoritmos, a tu ritmo y según lo que ya sabes.
              </p>

              <div className="d-flex flex-wrap gap-3 mb-5">
                {user ? (
                  <Link to={continueTo} className="btn btn-cq btn-cq-primary btn-lg">
                    Continuar mi aventura <i className="bi bi-arrow-right" aria-hidden="true" />
                  </Link>
                ) : (
                  <>
                    <Link to="/registro" className="btn btn-cq btn-cq-primary btn-lg">
                      Comenzar mi aventura <i className="bi bi-arrow-right" aria-hidden="true" />
                    </Link>
                    <Link to="/iniciar-sesion" className="btn btn-cq btn-cq-outline btn-lg">
                      Ya tengo cuenta
                    </Link>
                  </>
                )}
              </div>

              <div className="d-flex gap-4">
                <div className="cq-stat"><strong>3</strong><span className="cq-muted small">módulos</span></div>
                <div className="cq-stat"><strong>2</strong><span className="cq-muted small">rutas</span></div>
                <div className="cq-stat"><strong>5</strong><span className="cq-muted small">niveles</span></div>
              </div>
            </div>

            <div className="col-lg-6 cq-fade-up cq-delay-2">
              <div className="cq-terminal">
                <div className="cq-card">
                  <div className="cq-terminal-bar">
                    <span /><span /><span />
                    <small className="cq-muted cq-code ms-2">mision_1.cq</small>
                  </div>
                  <pre aria-label="Ejemplo de algoritmo en pseudocódigo">
<span className="cq-tok-com">{'// Algoritmo: preparar una arepa'}</span>{'\n'}
<span className="cq-tok-key">inicio</span>{'\n'}
{'  '}<span className="cq-tok-num">1.</span> tomar <span className="cq-tok-str">"masa"</span>{'\n'}
{'  '}<span className="cq-tok-num">2.</span> formar la arepa{'\n'}
{'  '}<span className="cq-tok-num">3.</span> <span className="cq-tok-key">mientras</span> no esté dorada{'\n'}
{'       '}asar <span className="cq-tok-num">1</span> minuto{'\n'}
{'  '}<span className="cq-tok-num">4.</span> servir{'\n'}
<span className="cq-tok-key">fin</span><span className="cq-caret">▍</span>
                  </pre>
                  <div className="cq-level">
                    <div className="d-flex justify-content-between small mb-2">
                      <span><i className="bi bi-shield-fill-check me-1" style={{ color: 'var(--cq-accent)' }} aria-hidden="true" /> Nivel 2 · Aprendiz</span>
                      <span className="cq-muted cq-code">180 / 250 XP</span>
                    </div>
                    <div className="cq-progress"><span style={{ width: '72%' }} /></div>
                  </div>
                </div>

                <span className="cq-floating cq-floating-xp cq-float">
                  <i className="bi bi-lightning-charge-fill" aria-hidden="true" /> +20 XP
                </span>
                <span className="cq-floating cq-floating-badge cq-float">
                  <i className="bi bi-rocket-takeoff-fill" style={{ color: 'var(--cq-accent)' }} aria-hidden="true" />
                  Insignia: Primer paso
                </span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ---------- Cómo funciona ---------- */}
      <section id="como-funciona" className="cq-section">
        <div className="container">
          <div className="text-center mb-5">
            <span className="cq-eyebrow">cómo funciona</span>
            <h2 className="cq-section-title mt-3">Tu aventura en cuatro pasos</h2>
          </div>
          <div className="row g-4">
            {STEPS.map((step, index) => (
              <div key={step.title} className="col-sm-6 col-lg-3">
                <article className="cq-card cq-step">
                  <div className="d-flex justify-content-between align-items-start mb-3">
                    <span className="cq-icon-tile"><i className={`bi ${step.icon}`} aria-hidden="true" /></span>
                    <span className="cq-step-number">0{index + 1}</span>
                  </div>
                  <h3 className="h5 fw-bold">{step.title}</h3>
                  <p className="cq-muted mb-0">{step.text}</p>
                </article>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ---------- Módulos ---------- */}
      <section id="modulos" className="cq-section">
        <div className="container">
          <div className="text-center mb-5">
            <span className="cq-eyebrow">módulos</span>
            <h2 className="cq-section-title mt-3">Tres pilares del pensamiento computacional</h2>
          </div>
          <div className="row g-4">
            {MODULES.map((module) => (
              <div key={module.name} className="col-md-4">
                <article className="cq-card cq-module">
                  <span className="cq-icon-tile mb-3"><i className={`bi ${module.icon}`} aria-hidden="true" /></span>
                  <h3 className="h4 fw-bold">{module.name}</h3>
                  <p className="cq-muted mb-0">{module.text}</p>
                  <div className="cq-module-example">
                    <i className="bi bi-lightbulb me-2" style={{ color: 'var(--cq-xp)' }} aria-hidden="true" />
                    {module.example}
                  </div>
                </article>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ---------- Rutas ---------- */}
      <section id="rutas" className="cq-section">
        <div className="container">
          <div className="text-center mb-5">
            <span className="cq-eyebrow">rutas de aprendizaje</span>
            <h2 className="cq-section-title mt-3">Empiezas donde te corresponde</h2>
          </div>
          <div className="row g-4 justify-content-center">
            <div className="col-md-6 col-lg-5">
              <article className="cq-card cq-route">
                <span className="cq-route-tag mb-3">Ruta básica</span>
                <h3 className="h5 fw-bold">Si estás empezando</h3>
                <p className="cq-muted">
                  Para quienes no tienen conocimientos previos o tienen conocimientos mínimos de programación.
                </p>
                <p className="small mb-0">
                  <i className="bi bi-arrow-up-right-circle me-2" style={{ color: 'var(--cq-success)' }} aria-hidden="true" />
                  Si demuestras dominio en las evaluaciones, puedes avanzar a la ruta intermedia.
                </p>
              </article>
            </div>
            <div className="col-md-6 col-lg-5">
              <article className="cq-card cq-route">
                <span className="cq-route-tag mb-3">Ruta intermedia</span>
                <h3 className="h5 fw-bold">Si ya sabes lo básico</h3>
                <p className="cq-muted">
                  Para quienes ya poseen conocimientos básicos de programación y quieren retos más exigentes.
                </p>
                <p className="small mb-0">
                  <i className="bi bi-speedometer2 me-2" style={{ color: 'var(--cq-warning)' }} aria-hidden="true" />
                  Actividades de mayor dificultad desde el inicio.
                </p>
              </article>
            </div>
          </div>
        </div>
      </section>

      {/* ---------- Beneficios ---------- */}
      <section id="beneficios" className="cq-section">
        <div className="container">
          <div className="text-center mb-5">
            <span className="cq-eyebrow">beneficios</span>
            <h2 className="cq-section-title mt-3">¿Por qué aprender programación con CodeQuest?</h2>
            <p className="cq-muted mx-auto" style={{ maxWidth: 640 }}>
              Programar entrena tu forma de pensar: aprendes a dividir problemas, encontrar regularidades y
              diseñar soluciones paso a paso, algo útil en cualquier carrera.
            </p>
          </div>
          <div className="row g-4">
            {BENEFITS.map((benefit) => (
              <div key={benefit.title} className="col-md-6 col-lg-4">
                <article className="d-flex gap-3 cq-benefit">
                  <span className="cq-icon-soft"><i className={`bi ${benefit.icon}`} aria-hidden="true" /></span>
                  <div>
                    <h3 className="h6 fw-bold mb-1">{benefit.title}</h3>
                    <p className="cq-muted small mb-0">{benefit.text}</p>
                  </div>
                </article>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ---------- Llamado final ---------- */}
      {!user && (
        <section className="container pb-4">
          <div className="cq-card cq-cta text-center">
            <h2 className="cq-section-title mb-3">¿Listo para tu primera misión?</h2>
            <p className="cq-muted mb-4">Crea tu cuenta, haz el diagnóstico y empieza a ganar XP hoy mismo.</p>
            <Link to="/registro" className="btn btn-cq btn-cq-primary btn-lg">
              Registrarme gratis <i className="bi bi-rocket-takeoff" aria-hidden="true" />
            </Link>
          </div>
        </section>
      )}
    </>
  );
}
