/** Fragmento de código o pseudocódigo con estilo de editor. */
export default function CodeBlock({ code }) {
  if (!code) return null;

  return (
    <pre className="cq-codeblock" aria-label="Fragmento de código">
      <code>{code}</code>
    </pre>
  );
}
