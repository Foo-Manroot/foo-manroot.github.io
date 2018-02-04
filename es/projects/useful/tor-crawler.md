---
layout: project
title: "Tor crawler"
tags: [python3]
lang: es
ref: projects-tor-crawler
---

## Tor crawler

Pequeño programa para mapear páginas de ToR y demostrar el uso de la API Stem para
conectarse a ToR usando Python3

Hecho por [ **Foo-Manroot** ](https://foo-manroot.github.io/)

Última modificación el **Feb 04, 2018**

La API usada para interactuar con el _proxy_ de ToR es
[stem](https://stem.torproject.org/). Para comprobar la IP externa se usó
[ipify](https://www.ipify.org/) was used (aunque debería cambiarse tras conectarse a ToR,
para evitar que se filtre la IP original).


## Motivación

Esta es una prueba de concepto rápida (tiene capacidades muy básicas) para demostrar el
uso de ToR desde Python, usando la [API de Stem](https://stem.torproject.org/), para la
asignatura _Seguridad en Sistemas Distribuidos_, donde el profesor nos invitó a hacer
algo con lo que aprendimos en la clase anterior ( _introducción a ToR_ ).


## Ejemplos

Para hacer pruebas he usado el foro de [Intel Exchange](http://rrcc5uuudhh4oz3c.onion/),
dado que ahí no debería haber ningún contenido ilegal (drogas, armas...).

Además, la salida se redirigirá a un fichero llamado `output.log`. Este fichero será
distribuido (con las IPs cambiadas, por privacidad) para ser usado como ejemplo.


### Mapeando la red descubierta a través de ToR

Este es un ejemplo de uso, mapeando la página por defecto (una página normal en la
_clearnet_) usando ToR para anonimizar el tráfico:
```sh
$ time ./main.py
 => The original IP address is: <ORIGINAL IP>
 => Starting ToR
[12:32:13] DEBUG - System call: tor --version (runtime: 0.02)
 => ToR started
 => New IP: <A DIFFERENT IP, PROVIDED BY TOR>
 => "https://foo-manroot.github.io/","Foo-ManBlog","Personal web page of Foo-Manroot, with articles, write-ups, useful tools, personal projects and more information; mainly about cybersecurity."
 => "https://foo-manroot.github.io/index.html","Foo-ManBlog","Personal web page of Foo-Manroot, with articles, write-ups, useful tools, personal projects and more information; mainly about cybersecurity."
 => "https://foo-manroot.github.io/about","About","Personal web page of Foo-Manroot, with articles, write-ups, useful tools, personal projects and more information; mainly about cybersecurity."
 => "https://foo-manroot.github.io/es","Foo-ManBlog","Página web personal de Foo-Manroot, con artículos, write-ups, herramientas útiles , proyectos y más información útil; sobre todo sobre ciberseguridad."
 => "https://foo-manroot.github.io/post/gnuradio/sdr/2018/01/15/gnuradio-ook-transmit.html","Impersonating a remote using SDR and GNURadio","A couple of months ago I wrote a post talkingabout the capabilities of SDR, allowing us to sniff radio communications with very cheaphardware; and now I’m go..."
 => "https://foo-manroot.github.io/post/side-channel/2018/01/09/side-channel-attacks-cso.html","Side-channel attacks","I haven’t post anything in a while, and the recent disclosure of theMeltdown and Spectre attacks reminded me of a littlepresentation a friend of mine, Albert..."
 => "https://foo-manroot.github.io/post/privacy/anonimity/security/conference/2017/12/17/privacy-conference-A.L.html","Privacy conference","Yesterday I gave a little talk about anonimity, privacy and security, and I said thatI’d upload the slideshow, so here it is.The topic was so broad that I le..."
 => "https://foo-manroot.github.io/post/keybase/pgp/crypto/privacy/2017/10/06/keybase.html","Keybase and the rebirth of PGP","A bit of historyBack in late 80s / early 90s, internet usage was on the rise, with more and more peopleconnected and using these new technologies to communic..."
 => "https://foo-manroot.github.io/post/ctf/meepwn/write-up/2017/09/28/meepwn-web.html","Meepwn Tsulott","It’s been a while since I last wrote something here, so maybe it’s time to fix that…NOTE: If you want to try this challenge first by yourself,here are all th..."
 => "https://foo-manroot.github.io/post/write-up/challenge/elttam/2017/09/09/elttam-challenge.html","Elttam challenge","Some time ago I read an interesting post on the Elttam(an infosec company) blog, and I decided to take a look on the rest of the webpage.I don’t know how, bu..."
 => "https://foo-manroot.github.io/post/scraping/twitter/2017/09/05/scraping-twitter.html","Scraping Twitter for fun... but no profit","A week ago, after reading aReddit post with some Twitter accounts to followto be updated with the latest news on netsec field, and I decided to follow them.H..."
 => "https://foo-manroot.github.io/post/ctf/ciberseg/write-up/reversing/2017/08/15/ciberseg-reversing.html","Ciberseg '17 write-ups: reversing","These are the reverse engineering challenges that formed part of theCTF organized at theCiberseg 2017, a conference about cibersecurity that takesplace every..."
 => "https://foo-manroot.github.io/post/ctf/ciberseg/write-up/forensics/2017/08/13/ciberseg-forensics.html","Ciberseg '17 write-ups: forensics","These are the forensics challenges that formed part of theCTF organized at theCiberseg 2017, a conference about cibersecurity that takesplace every year in o..."
 => "https://foo-manroot.github.io/post/ctf/ciberseg/write-up/exploiting/2017/08/12/ciberseg-exploiting.html","Ciberseg '17 write-ups: exploiting ","These are the exploiting challenges that formed part of theCTF organized at theCiberseg 2017, a conference about cibersecurity that takesplace every year in ..."
 => "https://foo-manroot.github.io/post/ctf/ciberseg/write-up/crypto/2017/08/11/ciberseg-crypto.html","Ciberseg '17 write-ups: crypto","These are the cryptography challenges that formed part of theCTF organized at theCiberseg 2017, a conference about cibersecurity that takesplace every year i..."
 => "https://foo-manroot.github.io/post/site-info/2017/08/11/intro-cont.html","How this page is done - part 2","Continuing with the previous article,I’m going to describe how did I built this website, for anybody curious about it orwilling to make another similar one.F..."
 => "https://foo-manroot.github.io/feed.xml","Foo-ManBlog","-"

real	0m51.879s
user	0m2.968s
sys	0m0.076s
```

### Mapendo la red oculta

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
