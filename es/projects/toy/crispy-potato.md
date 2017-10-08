---
layout: project
title: "Crispy potato"
tags: [php, html5, css3, javascript]
lang: es
ref: projects-crispy-potato
---

## Crispy potato

Este es un proyecto que hice (en realidad la iniciativa fue mía y de unos amigos de la
universidad, pero sólo {% include icon-github.html username="sergio-sanchezl" %} hizo
algo) para aprender HTML5, CSS3, Javascript y PHP, creando mientras tanto una página
web personal (todo ello sin usar ningún _framework_, ya que la intención era _aprender_).
De hecho, gracias al conocimiento adquirido en este desarrollo _front-end_, pude hacer
esta página (en la que estás ahora mismo).


La página tiene un código horroroso, pero _funciona_. Tengo un servidor (bueno, más bien
mi ordenador con Apache instalado) en casa con crispy-potato corriendo, esperando a que
yo haga algo útil con ella.


Por el momento, sólo tiene datos de pega y las siguientes funcionalidades:

### Manejo de cuentas

Basado en el control de accesos de Unix (con usuarios y grupos, cada uno con su uid y
guid, respectivamente), se puede crear una cuenta y acceder/salir para realizar todas
las acciones que requieren identificación (como escribir artículos).

### Subida y bajada de archivos

Con un control de accesos también basado en el del sistema de archivos de Unix, se pueden
ver los archivos disponibles (a los que se tiene permiso para acceder) y administrar los
propios.

{% include image.html
	src="/assets/projects/images/crispy-potato_Files-download.jpg"
	title="Página de descarga de archivos"
	alt="Descarga de archivos"
%}

También se pueden subir archivos nuevos:

{% include image.html
	src="/assets/projects/images/crispy-potato_Files-upload.jpg"
	title="Página para la subida de archivos"
	alt="Subida de archivos"
%}

### Artículos

Usando [TinyMCE](https://www.tinymce.com/) me las arreglé para crear artículos básicos.
Sólo he intentado crear artículos con multimedia, enlaces y texto; así que puede que
un uso y formato más avanzados podrían romperlo todo...

Un tema importante que no he implementado es actualizar el contenido multimedia (como
borrar una imagen de un artículo, que también debería borrarse en la base de datos del
servidor).

Aparte de eso, hay otras cosa que no están hechas (como manejar posts con etiquetas y
todas las demás cosas que ya está implementadas en esta página web).

----

Este proyecto [está en Github](https://github.com/Foo-Manroot/Crispy-potato).
