---
layout: project
title: "Super duper umbrella"
tags: [c, cuda, c++, makefile]
lang: es
ref: projects-super-duper-umbrella
---

## Super duper umbrella

Este proyecto fue hecho para crear el programa necesario en nuestra clase de
'_Ampliación de Programación Avanzada_', donde se nos pidió hacer un juego similar al
Candy Crush, usando las GPU de NVidia (y, por tanto, usando CUDA para programarlas).

El archivo `README.md` documenta de manera extensa el proyecto, porque hicimos el
proyecto 'open-source' un par de días antes de la fecha límite, porque no mucha gente
lo tenía terminado (de hecho, creo que sólo dos grupos hicimos todas las partes que
pidieron, incluyendo la interfaz gráficac con OpenGL), y queríamos ayudarles.


Para ejecutar cualquiera de las múltiples versiones que se pidieron (sólo con CPU,
con GPU, GPU con optimizaciones y GPU con optimizaciones e interfaz gráfica con OpenGL),
sólo hay que compilar todo (con `make`) y ejecutar el binario resultante.

Para compilarlo todo de golpe, hay un `Makefile` principal que puede ser usado para
compilar los directorios de manera recursiva (o, por ejemplo, sólo `make openGL` para
compilar, ejecutar y limpiar sólo la parte con interfaz gráfica).


Por supuesto, una tarjeta gráfica de NVidia es necesaria para ejecutar el código (excepto
para la implementación sólo con CPU).


No tuvimos tiempo ni ganas para darle nombre, así que cogimos el nombre sugerido
automáticamente por Github.


{% include image.html
	src="/assets/projects/images/super-duper-umbrella.jpg"
	title="Juego con la opción de detalle extra activada"
	alt="Captura de pantalla del juego con detalle extra"
%}

----

Este proyecto [está en Github](https://github.com/Foo-Manroot/super-duper-umbrella).
