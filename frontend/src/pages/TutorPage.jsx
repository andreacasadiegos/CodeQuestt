import { useCallback, useEffect, useRef, useState } from 'react';
import { Link } from 'react-router-dom';

import ErrorState from '../components/ui/ErrorState.jsx';
import LoadingScreen from '../components/ui/LoadingScreen.jsx';
import { useAuth } from '../hooks/useAuth.js';
import {
  archiveConversation,
  createConversation,
  getConversation,
  getConversations,
  sendTutorMessage,
} from '../services/tutorService.js';

/** Chat educativo con historial persistente en el servidor. */
export default function TutorPage() {
  const { user } = useAuth();
  const [conversations, setConversations] = useState([]);
  const [activeId, setActiveId] = useState(null);
  const [messages, setMessages] = useState([]);
  const [draft, setDraft] = useState('');
  const [loading, setLoading] = useState(true);
  const [sending, setSending] = useState(false);
  const [error, setError] = useState('');
  const endRef = useRef(null);

  const refreshConversations = useCallback(async () => {
    const result = await getConversations();
    setConversations(result.conversations ?? []);
    return result.conversations ?? [];
  }, []);

  const openConversation = useCallback(async (id) => {
    setError('');
    setLoading(true);
    try {
      const result = await getConversation(id);
      setActiveId(result.conversation.id);
      setMessages(result.messages ?? []);
    } catch (e) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    let alive = true;
    (async () => {
      try {
        const result = await getConversations();
        if (!alive) return;
        const items = result.conversations ?? [];
        setConversations(items);
        if (items.length) {
          const first = await getConversation(items[0].id);
          if (!alive) return;
          setActiveId(first.conversation.id);
          setMessages(first.messages ?? []);
        }
      } catch (e) {
        if (alive) setError(e.message);
      } finally {
        if (alive) setLoading(false);
      }
    })();
    return () => { alive = false; };
  }, []);

  useEffect(() => {
    endRef.current?.scrollIntoView({ behavior: 'smooth', block: 'end' });
  }, [messages, sending]);

  const startConversation = async () => {
    setError('');
    setLoading(true);
    try {
      const result = await createConversation();
      await refreshConversations();
      setActiveId(result.conversation.id);
      setMessages([]);
    } catch (e) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  };

  const submit = async (event) => {
    event.preventDefault();
    const message = draft.trim();
    if (!message || !activeId || sending) return;
    setDraft('');
    setSending(true);
    setError('');
    setMessages((current) => [...current, { role: 'user', content: message }]);
    try {
      const result = await sendTutorMessage(activeId, message);
      setMessages((current) => [...current, result.assistant_message]);
      await refreshConversations();
    } catch (e) {
      setError(e.message);
      setMessages((current) => current.filter((item, index) => !(index === current.length - 1 && item.role === 'user' && item.content === message)));
      setDraft(message);
    } finally {
      setSending(false);
    }
  };

  const archiveActive = async () => {
    if (!activeId || !window.confirm('¿Archivar esta conversación? Ya no aparecerá en tu historial.')) return;
    try {
      await archiveConversation(activeId);
      const items = await refreshConversations();
      setActiveId(null);
      setMessages([]);
      if (items.length) await openConversation(items[0].id);
    } catch (e) {
      setError(e.message);
    }
  };

  if (loading && conversations.length === 0 && !activeId) {
    return <LoadingScreen message="Preparando tu espacio con CodeBot…" />;
  }

  return (
    <section className="container py-4 py-lg-5 cq-tutor-page">
      <div className="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
        <div>
          <span className="cq-eyebrow"><i className="bi bi-stars" aria-hidden="true" /> tutor inteligente</span>
          <h1 className="h2 fw-bold mt-3 mb-1">CodeBot</h1>
          <p className="cq-muted mb-0">Tu compañero para aprender programación paso a paso.</p>
        </div>
        <Link className="btn btn-cq btn-cq-outline" to="/panel">
          <i className="bi bi-arrow-left" aria-hidden="true" /> Volver al panel
        </Link>
      </div>

      {error && <div className="cq-alert cq-alert-danger mb-3" role="alert"><i className="bi bi-exclamation-circle" />{error}</div>}

      <div className="row g-3 cq-tutor-shell">
        <aside className="col-lg-4">
          <div className="cq-card cq-tutor-sidebar p-3 h-100">
            <button type="button" className="btn btn-cq btn-cq-primary w-100 mb-3" onClick={startConversation} disabled={loading || sending}>
              <i className="bi bi-plus-lg" /> Nueva conversación
            </button>
            <div className="d-flex justify-content-between align-items-center mb-2">
              <h2 className="h6 fw-bold mb-0">Tu historial</h2>
              <span className="cq-muted small">{conversations.length}/50</span>
            </div>
            <div className="cq-tutor-history" aria-label="Conversaciones anteriores">
              {conversations.length === 0 ? (
                <p className="cq-muted small py-3">Todavía no tienes conversaciones. ¡Empieza una!</p>
              ) : conversations.map((item) => (
                <button
                  type="button"
                  key={item.id}
                  onClick={() => openConversation(item.id)}
                  className={`cq-tutor-history-item ${activeId === item.id ? 'is-active' : ''}`}
                >
                  <i className="bi bi-chat-left-text" aria-hidden="true" />
                  <span className="text-truncate">{item.title}</span>
                </button>
              ))}
            </div>
          </div>
        </aside>

        <div className="col-lg-8">
          <div className="cq-card cq-tutor-chat">
            <div className="cq-tutor-chat-head">
              <div className="cq-tutor-avatar"><i className="bi bi-robot" aria-hidden="true" /></div>
              <div className="flex-grow-1">
                <strong>CodeBot</strong>
                <div className="cq-muted small">Gemini · Tutor de programación</div>
              </div>
              {activeId && <button type="button" className="btn btn-sm btn-cq-outline" onClick={archiveActive} disabled={sending} title="Archivar conversación"><i className="bi bi-archive" /> <span className="d-none d-sm-inline">Archivar</span></button>}
            </div>

            <div className="cq-tutor-messages" aria-live="polite">
              {loading ? <p className="cq-muted text-center my-5">Cargando conversación…</p> : messages.length === 0 ? (
                <div className="cq-tutor-welcome text-center">
                  <div className="cq-tutor-welcome-icon"><i className="bi bi-stars" /></div>
                  <h2 className="h4 fw-bold">¡Hola, {user?.full_name?.split(' ')[0] || 'explorador'}!</h2>
                  <p className="cq-muted">Soy CodeBot. Puedo ayudarte con abstracción, patrones y algoritmos. ¿Qué te gustaría aprender hoy?</p>
                  <div className="d-flex flex-wrap justify-content-center gap-2">
                    {['Explícame qué es la abstracción', 'Ayúdame con los algoritmos', 'Quiero practicar patrones'].map((hint) => (
                      <button type="button" className="cq-tutor-suggestion" key={hint} onClick={() => setDraft(hint)}>{hint}</button>
                    ))}
                  </div>
                </div>
              ) : messages.map((message, index) => (
                <article key={message.id ?? `${message.role}-${index}`} className={`cq-tutor-message is-${message.role === 'user' ? 'user' : 'bot'}`}>
                  <div className="cq-tutor-bubble">{message.content}</div>
                </article>
              ))}
              {sending && <div className="cq-tutor-typing"><span /> <span /> <span /> CodeBot está pensando…</div>}
              <div ref={endRef} />
            </div>

            <form className="cq-tutor-composer" onSubmit={submit}>
              <label className="visually-hidden" htmlFor="cq-tutor-input">Escribe tu pregunta</label>
              <textarea
                id="cq-tutor-input"
                className="form-control"
                rows="2"
                maxLength="2000"
                placeholder="Escribe tu pregunta sobre programación…"
                value={draft}
                onChange={(event) => setDraft(event.target.value)}
                disabled={!activeId || sending || loading}
              />
              <div className="d-flex justify-content-between align-items-center mt-2 gap-2">
                <small className="cq-muted">Máximo 20 preguntas al día · {draft.length}/2000</small>
                <button type="submit" className="btn btn-cq btn-cq-primary" disabled={!activeId || !draft.trim() || sending || loading}>
                  Enviar <i className="bi bi-send-fill" aria-hidden="true" />
                </button>
              </div>
            </form>
          </div>
          <p className="cq-muted small mt-2 mb-0"><i className="bi bi-shield-check me-1" />Tus conversaciones son privadas y solo tú puedes acceder a tu historial.</p>
        </div>
      </div>
    </section>
  );
}
