---
layout: post
title:  "Tor crawler"
date:	2018-02-04 12:58:48 +0100
author: foo
categories: es tor crawler side-project
lang: es
ref: tor-crawler
---

La semana pasada en la clase _Seguridad en Sistemas Distribuidos_ el profesor nos dio
una presentación sobre ToR, y nos invitó a hacer algo relacionado; así que aproveché que
tenía libre la mañana del sábado para hacer un pequeño
[ _crawler_ ](https://es.wikipedia.org/wiki/Ara%C3%B1a_web) usando ToR y Python3.


Es muy simple, porque estuve unas pocas horas (básicamente, sólo adaptar los ejemplos del
[tutorial de stem](https://stem.torproject.org/tutorials/to_russia_with_love.html)), pero
cumple su propósito.


Este proyecto está [en Github](https://github.com/Foo-Manroot/ToR_crawler), y más
información se puede obtener en la
[página del proyecto](/es/projects/useful/tor-crawler.html).


### Mapendo la red oculta

Con este _script_ se puede mapear la _darknet_ (red oculta).

Para esta prueba, el punto inicial será la categoría
["Wheelwork of Nature"](http://rrcc5uuudhh4oz3c.onion/?cmd=category&id=15) de Intel
Exchange, usando un puerto diferente, cambiando la profundidad de recursión a 1 (para
mostrar sólo los posts en esa categoría) y redirigiendo la salida a `output.log`:
```sh
$ time ./main.py -d 1 -p 5678 -u "http://rrcc5uuudhh4oz3c.onion/?cmd=category&id=15" | tee output.log
 => The original IP address is: <ORIGINAL IP>
 => Starting ToR
[12:21:38] DEBUG - System call: tor --version (runtime: 0.02)
 => ToR started
 => New IP: <A DIFFERENT IP, PROVIDED BY TOR>
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=category&id=15","Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/","Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=16516","Nitrous Oxide Synthesis - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=10276","The power of 3, 6, and 9 - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=7767","Blackholes - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=12519","The pill that makes you jedi. - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=939","Magic - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=15543","a little help please - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=14046","Help with Sulfuric Acid - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=15142","Reed root bark for DMT?  - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=14860","Science and crystal healing? - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=12943","The Cerebral Network - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=13362","Quantum Computer?? - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=13153","Things that naturally hypnotize the brain - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=12538","Category Description Issue - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=12566","The Dream of Life - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=10345","not 'free' energy but low cost?  - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=410","The fourth dimension. - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=11312","A indefinite cycle - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=991","I know how to make zombies! - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=10715","Relativity and Higgs - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=1690","Black Raven  - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=7092","Which explosive to start with? - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=7544","Parallel Universe  - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=1977","Dimensions of the Universe - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=7131","We Are Missing Something - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=1903","Quantum Soul Theory(Opinion) - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=2019","Mathematical genetics - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=869","Genetic Mutation - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=523","Will Traffic jams cause Traffic jams? - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=574","A small correction - Wheelwork of Nature - Intel Exchange","-"
 => "http://rrcc5uuudhh4oz3c.onion/?cmd=topic&id=569","Dehydrating Butter - Wheelwork of Nature - Intel Exchange","-"

real	2m15.140s
user	0m1.348s
sys	0m0.064s
```

----

Este proyecto [está en Github](https://github.com/Foo-Manroot/ToR_crawler). Ahí debería
haber más información sobre el proyecto y su estructura para poder contribuir.
