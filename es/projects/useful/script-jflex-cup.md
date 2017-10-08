---
layout: project
title: "Script JFlex/CUP"
tags: [sh, lex, cup, java]
lang: es
ref: projects-script-jflex-cup
---

## Script JFlex/CUP

Este proyecto empezó cuando, en el laboratorio de nuestra clase de '_Procesadores del
Lenguaje_', nos dijeron que usáramos [CUP](http://www.cs.princeton.edu/~appel/modern
/java/CUP/) y [JFLEX](http://jflex.de/) para generar un analizador semántico de un
lenguaje con las especificaciones que nos dieron.

El problema era que la única manera útil de rtabajar con esto (al menos, la única manera
que los profesores nos contaron) era usar un plugin para
[Eclipse](https://www.eclipse.org/), y yo no quería instalar todas esas cosas inútiles
(sí, lo has adivinado: soy un fan de [vim](http://www.vim.org/)) sólo por un semestre.


Con las cosas como estaban, mi reacción inicial fue usar todas las herramientas a mano
(has vuelto a acertar: me encanta usar la consola para casi todo), pero eso era
increíblemente repetitivo y aburrido; así que creé un pequeño script para generar y
compilar todo por mí.

Pero, como siempre intento hacer las cosas mejorar, empecé a añadir más opciones y
funcionalidades hasta que obtuve un script bastante completo.


Además, añadí ejemplo e incluso [el trabajo final](https://github.com/Foo-Manroot
/Script-JFlex-CUP/blob/master/test/sem/Memoria.pdf) resultante de ese semestre, con la
memoria y todo el código fuente.

{% include image.html
	src="/assets/projects/images/script-jflex-cup.jpg"
	title="Analizador semántico en acción"
	alt="Salida del analizador"
%}

----

Este proyecto [está en Github](https://github.com/Foo-Manroot/Script-JFlex-CUP). Ahí
debería haber más información sobre el proyecto y su estructura para poder contribuir.
