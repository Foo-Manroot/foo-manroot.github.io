---
layout: post
title:  Cómo está hecha esta página - parte 2
date:	2017-08-11 12:35:58 +0200
author: foo
categories: es site-info
lang: es
ref: intro-cont
---

Continuando con el [artículo anterior]({% include post_link ref="intro-post" %}),
voy a describir cómo hice esta página, para cualquier persona que tenga curiosidad o
que quiera hacer una similar.

## Front-end

Este tema está basado en el [que viene por defecto](https://github.com/jekyll/minima) con
algunas modificaciones importantes.

En esta página no se usa nada de JavaScript, así que sólo voy a hablar sobre HTML y CSS.

### HTML y CSS

Lo primero que he cambiado es el modo en que todo está dispuesto. A pesar de que todo
se ve bastante parecido al tema por defecto (excepto los colores, obviamente), esta
página web está hecha usando las propiedades de CSS [grid](https://developer.mozilla.org
/en/docs/Web/CSS/grid) y [flex](https://developer.mozilla.org/en/docs/Web/CSS/flex),
evitando así los incontables `div` innecesarios (la llamada 'divitis').

Además, las propiedades de _grid_ han sido bastante útiles al intentar alinear elementos
como las etiquetas que hay al principio del post, donde se pueden tener múltiples
elementos y el objetivo es que permanezcan alineados y visibles, sin importar la cantidad
de filas o columnas.

Cuando se le da a un elemento el siguiente estilo, tiene este comportamiento flexible que
se necesita:

```css
#elem {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
}
```

Este código permite que todos los elementos dentro del que tiene `id="elem"` fluir,
llenando todo el espacio disponible, pero nunca teniendo estos elementos menos de 100px
de ancho. Para comprobar esto, se puede ir a la página [de mi proyecto 'Collatz'](
/es/projects/toy/collatz), redimensionar la ventanta y ver cómo las etiquetas se
reorganizan solas.


Por otro lado, el pie de página está diseñado usando una rejilla (_grid_), de modo que
es más fácil reordenarlo a voluntad. De hecho, se usan dos plantillas diferentes en esta
página (una para dispositivos móviles y otra para los demás). Estas dos plantillas se
cambian simplemente modificando el valor de `grid-template`.

Estos son los dos modelos, mostrados usando las herramientas de desarrollo de Mozilla
Firefox (el color de fondo se ha quitado para ver la rejilla más fácilmente):

{% include image.html
	src="/assets/posts/2017-08-11-intro-cont/footer-grid.png"
	title="Rejilla vista con las herramientas de desarrollo"
	alt="Rejilla en dispositivos con pantallas grandes"
%}

y para móviles:

{% include image.html
	src="/assets/posts/2017-08-11-intro-cont/footer-grid-mobile.png"
	title="Rejilla en móviles vista con las herramientas de desarrollo"
	alt="Rejilla en dispositivos móviles"
%}


Más ejemplos de esto están en [esta página](https://gridbyexample.com/learn/), donde yo
aprendí todo lo que sé sobre CSS grid.


Aparte de estos cambios técnicos, he hecho otros para reorganizar la página a mi gusto
(aparte de cambiar los colores, por supuesto), siendo los más notables el uso del
[truco del _checkbox_](https://stackoverflow.com/a/32721572) para simular el evento
`onClick`de JavaScript para mostrar la barra lateral (excepto en móviles, donde hay otra
plantilla). Esa es la razón por la que hay un _div_ alrededor de casi todo el
contenido de la página llamado "page-wrap", para poder moverlo a un lado cuando la
barra de navegación está visible.


## Back-end

Aunque es una página estática, cuando digo aquí "back-end" me estoy refiriendo a cómo
se han usado Jekyll y Liquid para generar las páginas.

### Internacionalización

La única cosa resaltable que hice en este apartado es la internacionalización (debería
haber un par de botones encima de este artículo, donde se puede cambiar el idioma del
artículo).

Para hacerlo sin _plugins_ (dado que esta página depende de los plugins aceptados en
Github Pages), basé mi enfoque en
[este artículo](https://www.sylvaindurand.org/making-jekyll-multilingual/), donde el
autor propone añadir dos atributos, `lang` y `ref`, a todos los posts para que puedan ser
referenciados dependiendo del idioma actual de la página.

También añadí un fichero en el directorio *_data/* llamado *i18n.yml* para almacenar las
traducciones de algunas cadenas comunes, como los meses o el nombre del idioma.


Además, extendí la internacionalización a las colecciones _proyectos_ y _herramientas_,
creando un directorio especial para cada uno de los idiomas disponibles, con un
subdirectorio para cada colección (también hay traducciones de los archivos principales
index.html y about.md). El contenido de estos directorios es el siguiente:
<pre>
cod-idioma (es, fr...)/
├── index.html
├── about.md
├── categories
│   └── index.html
├── projects
│   ├── index.md
 ...
└── tools
    ├── index.md
    ...
</pre>
