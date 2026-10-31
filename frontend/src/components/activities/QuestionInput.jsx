import CodeBlock from '../ui/CodeBlock.jsx';
import CodeCompletion from './CodeCompletion.jsx';
import MatchConcepts from './MatchConcepts.jsx';
import MultipleChoice from './MultipleChoice.jsx';
import OrderSteps from './OrderSteps.jsx';
import PatternSequence from './PatternSequence.jsx';

/** Elige el componente de respuesta según el tipo de pregunta. */
export default function QuestionInput({ question, value, onChange }) {
  switch (question.type) {
    case 'seleccion':
      return <MultipleChoice question={question} value={value} onChange={onChange} />;
    case 'patron':
      return <PatternSequence question={question} value={value} onChange={onChange} />;
    case 'completar_codigo':
      return <CodeCompletion question={question} value={value} onChange={onChange} />;
    case 'ordenar':
      return (
        <>
          <CodeBlock code={question.code_snippet} />
          <OrderSteps question={question} value={value} onChange={onChange} />
        </>
      );
    case 'relacionar':
      return (
        <>
          <CodeBlock code={question.code_snippet} />
          <MatchConcepts question={question} value={value} onChange={onChange} />
        </>
      );
    default:
      return null;
  }
}

/** Respuesta inicial: en ordenar, el orden en que llegaron los pasos. */
export function initialAnswer(question) {
  return question.type === 'ordenar' ? { order: question.items.map((item) => item.id) } : null;
}

/** ¿La pregunta ya tiene una respuesta completa para enviar? */
export function isAnswered(question, value) {
  if (!value) return false;
  switch (question.type) {
    case 'seleccion':
    case 'patron':
      return Number.isInteger(value.option_id);
    case 'completar_codigo':
      return (value.text ?? '').trim() !== '';
    case 'ordenar':
      return Array.isArray(value.order) && value.order.length === question.items.length;
    case 'relacionar':
      return question.items.every((item) => value.pairs?.[item.id]);
    default:
      return false;
  }
}
