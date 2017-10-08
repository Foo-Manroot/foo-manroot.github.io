---
layout: project
title: "Time Wanderer"
tags: [java]
lang: es
ref: projects-time-wanderer
---

## Time Wanderer

{% include image.html
	src="/assets/projects/images/time-wanderer.jpg"
	title="Cover"
	alt="Cover de Time-Wanderer"
%}

Este es un videojuego que hicimos (unos compañeros, mencionados más abajo, y yo) para
la clase '_Tecnología de Videojuegos_', de la universidad, como proyecto final.


Está escrito en Java, usando [Slick2D](http://slick.ninjacave.com/), un motor gráfico
de bajo nivel (de hecho, sólo es un envoltorio alrededor de OpenGL).

Es un juego Rogue-like, donde el objetivo principal del jugador es limpiar el nivel
matando al jefe final, mientras abre las diferentes cámaras para que los dos personajes
puedan matar a sus respectivos jefes.


En este juego, el/la jugador/a controla dos personajes (no a la vez, sino cambiando entre
ellos) que están aislados entre ellos, con cada uno de ellos en su línea temporal (el
primero es como un arqueólogo Indiana Jones en el presente, y el otro es una especie de
guerrero de tiempos pasados) mientras colaboran, puesto que el arqueólogo está en un
templo en ruinas con cámaras bloqueadas. Por lo tanto, el guerrero del pasado debe
activar algunas palancas para eliminar esos bloqueos.


Como se ha dicho antes, Slick2D es solamente un envoltorio alrededor de OpenGL; así que
este juego está hecho casi desde cero (incluyendo las físicas y la IA).


### Créditos

Como he puesto antes, este juego ha sido realizado con un equipo de 5 personas:

  - **Alberto Serrano Ibaibarriaga**: Todas las pistas de audio han sido compuestas por
	él. Además, el inventario y el motor de sonido son obra suya.

  - **Miguel García Martín** (yo): Jefe de proyecto. La IA de los enemigos y las armas
	(salvo el diseño de los gráficos); además de diversos arreglos generales.

	  - Github: {% include icon-github.html username="Foo-Manroot" %}
	  - Contacto: [miguel.garciamartin@hotmail.com](mailto:miguel.garciamartin@hotmail.com)

  - **Pablo Peña Romero**: Autor de los objetos especiales (como pociones y runas) y
	algunos arreglos globales por diversas partes del juego.

  - **Sergio Sánchez López**: Autor único del motor de físicas (un trabajo muy duro que
	le fue recompensado con mayor nota), y las _tilesets_ de las habitaciones.

	  - Github: {% include icon-github.html username="sergio-sanchezl" %}

  - **Zamar-Elahi Fazal Roura**: Diseñador de los personajes y los objetos. Además, como
	a Pablo, se le asignaron algunos arreglos globales en diversas partes.


----

Este proyecto [está en Github](https://github.com/Foo-Manroot/Time-Wanderer). Ahí
debería haber más información sobre el proyecto y su estructura para poder contribuir.

Además, la última versión puede ser decargada [aquí (82 MB)](/assets/projects/
Time-Wanderer-dist1.0.tar.gz). Está lista para ser jugada. Simplemente hay que pinchar
dos veces sobre el _.jar_; o ejecutar `java -jar Time-Wanderer.jar` desde la consola.
