-- =====================================================================
-- CodeQuest: Aprende a programar
-- 04_seed_contenido.sql - Lecciones de los módulos
--
-- Ejecutar DESPUÉS de 03_seed_diagnostico.sql.
-- Cada módulo tiene una lección común (path_id NULL) y dos lecciones
-- propias de cada ruta (1 = básica, 2 = intermedia).
-- Formato del contenido: párrafos separados por una línea en blanco,
-- viñetas con "- " y negrita con **texto**.
-- Las actividades de cada lección se agregan en la Etapa 7.
-- =====================================================================

USE codequest_db;
SET NAMES utf8mb4;

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (1, 1, NULL, '¿Qué es la abstracción?',
   'La **abstracción** consiste en quedarse con lo importante de un problema y dejar de lado los detalles que no ayudan a resolverlo.\n\nPiensa en el mapa del sistema de transporte de una ciudad: no muestra calles, edificios ni árboles. Solo muestra estaciones, líneas y conexiones. Ese mapa es una abstracción: elimina detalles para que puedas responder una pregunta concreta, «¿cómo llego de una estación a otra?».\n\nEn programación hacemos lo mismo todo el tiempo:\n- Antes de escribir código, decidimos qué información necesita el programa y cuál sobra.\n- Damos nombres a las ideas (por ejemplo, **precio** o **nombreEstudiante**) en lugar de pensar en cómo se guardan los ceros y unos.\n- Usamos instrucciones como **mostrar** sin preocuparnos por cómo la pantalla dibuja cada letra.\n\nLa pregunta clave de la abstracción es: **¿qué necesito saber para lograr mi objetivo?**',
   'Objetivo: explicarle a un amigo cómo llegar al colegio.\n\nLo importante:   calles principales, giros, puntos de referencia\nLo que sobra:    color de las casas, número de árboles, nombres de vecinos',
   1);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (2, 1, 1, 'Lo esencial y los detalles',
   'Lo que es «importante» depende del **objetivo**. La misma realidad se puede resumir de formas distintas según para qué la necesitemos.\n\nImagina la información de un estudiante. Si la usa la **biblioteca**, le interesan el nombre, el curso y los libros prestados. Si la usa la **enfermería**, le interesan el nombre, el grupo sanguíneo y las alergias. El estudiante es el mismo, pero cada abstracción guarda datos diferentes.\n\nPara abstraer bien, sigue tres pasos:\n- Escribe con claridad cuál es el objetivo.\n- Haz una lista de toda la información disponible.\n- Tacha lo que no ayuda a cumplir el objetivo.\n\nLo que queda en la lista es tu abstracción. Un buen programa empieza con una buena abstracción: si guardamos datos de más, el programa se vuelve confuso; si nos faltan datos, no podrá resolver el problema.',
   'Ficha para la biblioteca      Ficha para la enfermería\n- nombre                      - nombre\n- curso                       - grupo sanguíneo\n- libros prestados            - alergias',
   2);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (3, 1, 1, 'Usar sin conocer todos los detalles',
   'Otra cara de la abstracción es poder **usar algo sin saber cómo funciona por dentro**.\n\nCuando usas el control remoto del televisor, solo ves botones: subir volumen, cambiar canal, apagar. No necesitas entender las señales infrarrojas ni los circuitos. El control **oculta los detalles** y te muestra solo lo que necesitas.\n\nEn programación pasa lo mismo. Cuando escribes la instrucción **mostrar "Hola"**, el computador hace muchísimas operaciones para dibujar cada letra en la pantalla, pero tú solo necesitas saber qué hace la instrucción, no cómo lo hace.\n\nGracias a esto podemos construir programas grandes a partir de piezas sencillas: cada pieza se usa por **lo que hace**, sin tener que recordar **cómo lo hace**.',
   '// Tú escribes una sola línea...\nmostrar "Hola, CodeQuest"\n\n// ...y el computador se encarga de todos los detalles:\n// elegir la fuente, calcular píxeles, encender la pantalla...',
   3);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (4, 1, 2, 'Modelar datos: atributos relevantes',
   'Cuando un programa trabaja con cosas del mundo real (estudiantes, productos, canciones), necesitamos **modelarlas**: describirlas con un conjunto de **atributos**.\n\nModelar es abstraer. Una canción tiene millones de características (cada nota, cada instrumento), pero una aplicación de música solo guarda algunas: título, artista, duración y género. Elegimos los atributos según lo que el programa debe hacer.\n\nBuenas preguntas para elegir atributos:\n- ¿Qué operaciones hará el programa? (buscar, ordenar, calcular)\n- ¿Qué dato necesita cada operación?\n- ¿Hay atributos que se pueden calcular a partir de otros? (por ejemplo, la edad a partir de la fecha de nacimiento)\n\nUn atributo que no se usa en ninguna operación es un detalle que sobra.',
   'registro Cancion\n    titulo     : texto\n    artista    : texto\n    duracion   : entero   // en segundos\n    genero     : texto\nfin registro\n\n// Operación que usa los atributos:\nsi cancion.duracion > 300 entonces\n    mostrar "Canción larga"\nfin si',
   2);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (5, 1, 2, 'Funciones: esconder el cómo, mostrar el qué',
   'Una **función** es un bloque de instrucciones con nombre que resuelve una tarea concreta. Es una de las herramientas de abstracción más poderosas: quien usa la función solo necesita saber **qué recibe** y **qué devuelve**.\n\nPor ejemplo, una función **calcularPromedio** recibe una lista de notas y devuelve su promedio. Quien la usa no tiene que repetir los pasos de sumar y dividir cada vez: simplemente la llama.\n\nVentajas de usar funciones:\n- **Reutilización:** se escribe una vez y se usa muchas veces.\n- **Claridad:** el programa principal se lee como una lista de ideas.\n- **Mantenimiento:** si hay un error, se corrige en un solo lugar.\n\nUn buen nombre de función describe el **qué** (calcularPromedio), no el **cómo** (sumarYDividir).',
   'funcion calcularPromedio(notas)\n    suma ← 0\n    para cada nota en notas\n        suma ← suma + nota\n    fin para\n    devolver suma / cantidad(notas)\nfin funcion\n\n// Uso: no hace falta saber cómo se calcula\npromedio ← calcularPromedio([4.0, 3.5, 4.5])\nmostrar promedio   // 4.0',
   3);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (6, 2, NULL, '¿Qué es un patrón?',
   'Un **patrón** es una regularidad: algo que se repite o que sigue una regla. Reconocer patrones nos permite predecir qué viene después y resolver problemas parecidos de la misma manera.\n\nEncontramos patrones en todas partes:\n- En los números: 2, 4, 6, 8… (de dos en dos).\n- En las figuras: ● ■ ● ■ ● ■… (se alternan).\n- En la vida diaria: el horario de clases se repite cada semana.\n- En la naturaleza: los pétalos de muchas flores siguen secuencias numéricas.\n\nEn programación, detectar un patrón es muy valioso: si una tarea se repite, no necesitamos escribir las instrucciones muchas veces. Podemos describir la regla una sola vez y dejar que el computador la repita.',
   'Secuencia:  5, 10, 15, 20, ?\nRegla:      sumar 5 al número anterior\nSiguiente:  25',
   1);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (7, 2, 1, 'Secuencias de números y figuras',
   'Para descubrir el patrón de una secuencia, compara cada elemento con el anterior y pregúntate **qué cambió**.\n\nLas reglas más comunes son:\n- **Sumar o restar** siempre lo mismo: 3, 7, 11, 15 (suma 4).\n- **Multiplicar o dividir** siempre por lo mismo: 2, 6, 18, 54 (multiplica por 3).\n- **Alternar** elementos: rojo, azul, rojo, azul.\n- **Crecer de forma ordenada:** ■, ■■, ■■■ (cada vez uno más).\n\nUn consejo: si sumar no funciona, prueba multiplicar. Si ninguna operación funciona, mira si hay dos secuencias intercaladas (por ejemplo, 1, 10, 2, 20, 3, 30).\n\nCuando encuentres la regla, compruébala con **todos** los elementos, no solo con los dos primeros.',
   '1, 3, 9, 27, ?\n\n3 ÷ 1 = 3    9 ÷ 3 = 3    27 ÷ 9 = 3\nRegla: multiplicar por 3   →   siguiente: 81',
   2);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (8, 2, 1, 'Repetir sin repetirse',
   'Imagina que debes darle instrucciones a un robot para dibujar un cuadrado:\n\navanzar, girar, avanzar, girar, avanzar, girar, avanzar, girar.\n\n¿Notas el patrón? El par «avanzar, girar» se repite **4 veces**. En lugar de escribir ocho instrucciones, podemos decir: **repetir 4 veces: avanzar y girar**.\n\nEsa es la idea de un **ciclo** (o bucle): una instrucción que repite un bloque de pasos varias veces. Los ciclos existen gracias a los patrones: primero reconocemos qué se repite y luego lo escribimos una sola vez.\n\nVentajas:\n- El programa es más corto y fácil de leer.\n- Si queremos un hexágono, solo cambiamos el 4 por un 6 (y el ángulo).\n- Hay menos posibilidades de equivocarse al copiar.',
   '// Sin ciclo                 // Con ciclo\navanzar 10                  repetir 4 veces\ngirar 90                        avanzar 10\navanzar 10                      girar 90\ngirar 90                    fin repetir\navanzar 10\ngirar 90\navanzar 10\ngirar 90',
   3);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (9, 2, 2, 'Generalizar: la regla del término n',
   'Reconocer un patrón es el primer paso; **generalizarlo** es escribir una regla que sirva para cualquier posición.\n\nEn la secuencia 4, 7, 10, 13… cada término suma 3. Pero si queremos el término número 100, no es práctico sumar 3 noventa y nueve veces. Mejor buscamos una fórmula en función de la posición **n**:\n\n- Posición 1 → 4 = 3·1 + 1\n- Posición 2 → 7 = 3·2 + 1\n- Posición 3 → 10 = 3·3 + 1\n\nLa regla general es **término(n) = 3n + 1**, y el término 100 es 301.\n\nGeneralizar es pasar de «veo que se repite» a «puedo calcular cualquier caso». Es exactamente lo que hace un programa: una regla general que funciona para todas las entradas posibles.',
   'funcion termino(n)\n    devolver 3 * n + 1\nfin funcion\n\npara n desde 1 hasta 5\n    mostrar termino(n)     // 4, 7, 10, 13, 16\nfin para',
   2);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (10, 2, 2, 'Patrones con ciclos y condiciones',
   'Muchos patrones combinan **repetición** con **decisiones**: algo se repite, pero no siempre de la misma forma.\n\nPor ejemplo, en un juego un enemigo aparece cada 3 turnos y un premio cada 5. Para saber si en un turno ocurre algo, usamos el **residuo** de la división (la operación **mod**): si turno mod 3 = 0, el turno es múltiplo de 3.\n\nEste tipo de patrón aparece en:\n- Calendarios (cada 7 días se repite el día de la semana).\n- Semáforos (ciclos de verde, amarillo y rojo).\n- Diseños (cada tercera baldosa es de otro color).\n\nPara programarlos: identifica qué se repite (el ciclo) y qué condición cambia el resultado (el si).',
   'para turno desde 1 hasta 15\n    si turno mod 15 = 0 entonces\n        mostrar "¡Enemigo y premio!"\n    sino si turno mod 3 = 0 entonces\n        mostrar "Enemigo"\n    sino si turno mod 5 = 0 entonces\n        mostrar "Premio"\n    fin si\nfin para',
   3);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (11, 3, NULL, '¿Qué es un algoritmo?',
   'Un **algoritmo** es una secuencia ordenada de pasos precisos que resuelve un problema. Una receta de cocina, las instrucciones para armar un mueble o la ruta para llegar al colegio son algoritmos.\n\nUn buen algoritmo cumple tres condiciones:\n- **Preciso:** cada paso dice exactamente qué hacer, sin ambigüedad.\n- **Ordenado:** los pasos tienen un orden y cambiarlo puede cambiar el resultado.\n- **Finito:** termina después de un número determinado de pasos.\n\nCasi todos los algoritmos siguen el esquema **entrada → proceso → salida**: reciben datos, los transforman y entregan un resultado.\n\nLos computadores no improvisan: solo siguen algoritmos. Por eso programar es, en gran parte, diseñar algoritmos claros.',
   'Algoritmo: calcular el área de un rectángulo\n\nEntrada:  base y altura\nProceso:  área ← base × altura\nSalida:   mostrar el área',
   1);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (12, 3, 1, 'Paso a paso: secuencias',
   'La forma más sencilla de algoritmo es una **secuencia**: pasos que se ejecutan uno después de otro, de arriba hacia abajo.\n\nPara escribir algoritmos usamos **pseudocódigo**: una forma de escribir instrucciones parecida al español, pero ordenada como un programa. No depende de ningún lenguaje de programación.\n\nReglas básicas del pseudocódigo de CodeQuest:\n- El algoritmo empieza con **inicio** y termina con **fin**.\n- **leer** recibe un dato y **mostrar** lo presenta en pantalla.\n- La flecha **←** guarda un valor en una variable: x ← 5 significa «x ahora vale 5».\n\nEl orden importa: si mostramos el resultado antes de calcularlo, el algoritmo falla.',
   'inicio\n    leer precio\n    leer cantidad\n    total ← precio * cantidad\n    mostrar total\nfin',
   2);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (13, 3, 1, 'Tomar decisiones: si… entonces',
   'No todos los algoritmos siguen siempre el mismo camino. A veces deben **decidir**: «si llueve, llevo paraguas; si no, llevo gorra».\n\nEn pseudocódigo usamos la estructura **si … entonces … sino … fin si**:\n- Después de **si** va una **condición**: una pregunta que se responde con verdadero o falso (por ejemplo, nota ≥ 3.0).\n- Si la condición es verdadera, se ejecutan los pasos de **entonces**.\n- Si es falsa, se ejecutan los pasos de **sino** (que es opcional).\n\nLas condiciones usan comparaciones: = (igual), ≠ (diferente), > (mayor), < (menor), ≥ (mayor o igual), ≤ (menor o igual).',
   'inicio\n    leer nota\n    si nota ≥ 3.0 entonces\n        mostrar "Aprobaste"\n    sino\n        mostrar "Debes reforzar"\n    fin si\nfin',
   3);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (14, 3, 2, 'Variables, condiciones y ciclos juntos',
   'Los algoritmos reales combinan las tres estructuras básicas:\n- **Secuencia:** pasos en orden.\n- **Decisión:** si … entonces.\n- **Repetición:** para … hasta o mientras.\n\nUn patrón muy común es el **acumulador**: una variable que empieza en 0 y en cada vuelta del ciclo suma un valor nuevo. Con un acumulador podemos calcular totales y promedios.\n\nOtro es el **contador**: una variable que suma 1 cada vez que se cumple una condición, por ejemplo, para contar cuántas notas son aprobatorias.\n\nAl diseñar un algoritmo así, define primero las variables, su valor inicial y en qué momento cambian.',
   'inicio\n    suma ← 0\n    aprobadas ← 0\n    para i desde 1 hasta 5\n        leer nota\n        suma ← suma + nota\n        si nota ≥ 3.0 entonces\n            aprobadas ← aprobadas + 1\n        fin si\n    fin para\n    mostrar "Promedio: ", suma / 5\n    mostrar "Aprobadas: ", aprobadas\nfin',
   2);

INSERT INTO lessons (id, module_id, path_id, title, content, example, sort_order) VALUES
  (15, 3, 2, 'Diseñar y probar: encontrar el mayor',
   'Diseñar un algoritmo no termina al escribirlo: hay que **probarlo**. Una técnica sencilla es la **prueba de escritorio**: seguir el algoritmo a mano con datos concretos y anotar cómo cambian las variables en cada paso.\n\nProblema: encontrar el número mayor de una lista. Idea: suponer que el primero es el mayor y recorrer el resto; cada vez que aparezca uno más grande, se reemplaza.\n\nPrueba con la lista [7, 3, 12, 5]:\n- mayor = 7\n- compara 3: no cambia\n- compara 12: mayor = 12\n- compara 5: no cambia → resultado 12\n\nPrueba también casos especiales: una lista con un solo número, números repetidos o negativos. Si el algoritmo funciona en todos, es confiable.',
   'funcion encontrarMayor(lista)\n    mayor ← lista[1]\n    para i desde 2 hasta cantidad(lista)\n        si lista[i] > mayor entonces\n            mayor ← lista[i]\n        fin si\n    fin para\n    devolver mayor\nfin funcion',
   3);
