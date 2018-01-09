---
layout: post
title:  "Side-channel attacks"
date:	2018-01-09 11:03:27 +0100
author: foo
categories: es side-channel
lang: es
ref: side-channel-attacks-cso
---

No he subido nada aquí en mucho tiempo, y la reciente revelación de los ataques
[Meltdown y Spectre](https://meltdownattack.com/) me recordaron una pequeña presentación
que un amigo, Alberto Serrano, y yo hicimos como tarea para la asignatura
_Computer Structure & Organization_, del año pasado en la universidad.

Spectre y Meltdown se basan en
[canales laterales](https://es.wikipedia.org/wiki/Ataque_de_canal_lateral), midiendo el
tiempo tardado en acceder a la memoria para determinar si un valor se encuentra en caché
o no, permitiendo a cualquier proceso leer cualquier posición de memoria que quiera. Por
supuesto, es más complicado que eso; pero la cuestión es que los _side-channel attacks_
siguen siendo un vector de ataque muy peligroso. Uno que debería ser tenido en cuenta al
diseñar (o atacar) cualquier sistema.

En esta asignatura, _CS & O_, se nos dijo que hiciéramos una pequeña presentación de
unos 10 minutos, así que es muy corto; pero quizá siga teniendo alguna cosa interesante.
Además, la asignatura se daba en inglés, por lo que las diapositivas están en ese idioma,
y tampoco cuento ya con las diapositivas originales para poder traducirlas al castellano.

{% include embed_pdf.html
	path="/assets/posts/2018-01-09-side-channel-attacks-cso/cso_slides.pdf"
%}
