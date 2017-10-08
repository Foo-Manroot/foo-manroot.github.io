---
layout: post
title:  "Write-ups del Ciberseg '17: forense"
date:	2017-08-13 10:32:29 +0200
author: foo
lang: es
categories: es ctf ciberseg write-up forensics
ref: ciberseg-forensics
---


Estos son los retos de análisis forense que formaron parte del
[CTF](https://ciberseg.uah.es/ctf.html) organizado en el
[Ciberseg 2017](https://ciberseg.uah.es), un congreso sobre ciberseguridad que tiene
lugar cada año en nuestra universidad.

El año pasado fue la primera edición (y espero que haya más, pues fue bastante divertido)
del CTF (y yo gané el primer premio :D).

## Primer reto: Living in the fast lane

### Materiales
Para este reto, nos dieron un juego que puede ser descargado en las siguientes versiones:
  - [GNU/Linux](/assets/posts/2017-08-13-ciberseg-forensics/Living-in-the-fast-Lain-1.0-dists/Living-in-the-fast-Lain-1.0-linux.tar.bz2)
  - [Windows](/assets/posts/2017-08-13-ciberseg-forensics/Living-in-the-fast-Lain-1.0-dists/Living-in-the-fast-Lain-1.0-mac.zip)
  - [MAC](/assets/posts/2017-08-13-ciberseg-forensics/Living-in-the-fast-Lain-1.0-dists/Living-in-the-fast-Lain-1.0-win.zip)

### El reto

Tras examinar todos los ficheros y buscar cadenas en ellos, sin ningún resultado, podemos
empezar a intentar mirar en los archivos del juegos.

Este juego fue escrito con el [motor renpy](https://www.renpy.org/). Este motor usa
un archivo especial para almacenar todos los datos usados en el juego. En este fichero,
`archive.rpa`, la información se guarda comprimida. Para descomprimirla, podemos usar
una de las herramientas disponibles, como
[rpatool](https://raw.githubusercontent.com/Shizmob/rpatool/master/rpatool).

Descomprimiendo este fichero, podemos ver la siguiente lista de archivos:
{% highlight sh linenos %}
$ ./rpatool -l archive.rpa
icon.png
resources/backgrounds/bedroom.jpg
resources/backgrounds/bedroom_dark.jpg
resources/backgrounds/dorm_hallway.jpg
resources/backgrounds/lecture_front.png
resources/backgrounds/lecture_hall.jpg
resources/backgrounds/menu.png
resources/backgrounds/uni.jpg
resources/characters/jobs/jobs.png
resources/characters/jobs/jobs_gun.png
resources/characters/jobs/jobs_gun_fire.png
resources/characters/jobs/jobs_side.jpg
resources/characters/lain/lain_relaxed_side.png
resources/characters/stallman/stallman.png
resources/characters/stallman/stallman_angry - Copy.png
resources/characters/stallman/stallman_angry.png
resources/characters/stallman/stallman_embarrassed.png
resources/characters/stallman/stallman_embarrassed_side.png
resources/characters/stallman/stallman_shocked.png
resources/characters/stallman/stallman_shocked_side.png
resources/characters/stallman/stallman_sicp.png
resources/characters/stallman/stallman_side.png
resources/characters/stallman/stallman_side_angry.png
resources/characters/torvalds/torvalds.png
resources/characters/torvalds/torvalds_angry.png
resources/characters/torvalds/torvalds_card.png
resources/characters/torvalds/torvalds_side.png
resources/flag.png
resources/music/main_menu.ogg
resources/sounds/breathing.ogg
resources/sounds/door-open.wav
resources/sounds/reee.ogg
$
{% endhighlight %}

Y ahí está, en la línea 29: `resources/flag.png`. Y es una imagen. Por eso no podíamos
obtener la respuesta buscando _strings_.

Al extraer los ficheros obtenemos la siguiente imagen con la respuesta:

{% include image.html
	src="/assets/posts/2017-08-13-ciberseg-forensics/flag.jpg"
	title="Imagen con la bandera"
	alt="Bandera"
%}

La bandera es: `flag{4077fb6a74ea5a5b6ac7d0b74e5a379d}`


-----------------------------------------------------------------------------------------


## Segundo reto: Mimikatz

### Materiales

Para este segundo reto, tenemos que descargar una
[imagen de una RAM (159.5 MB)](https://drive.google.com/drive/folders
/0BzLA9WAiAXudNEZRYTgxZkxjWWM?usp=sharing), donde se nos dice que quizá podamos
'recuperar algunas contraseñas'. Parece que la bandera es una de las contraseñas.

### El reto

En este reto usaremos [volatility](http://www.volatilityfoundation.org/), un
framework para herramientas de análisis forense de memoria. Antes que nada, vamos a
determinar el perfile de la imagen de memoria para poder realizar el resto de las pruebas
con precisión. Para ello, podemos usar el _plugin_ 'imageinfo':
```sh
$ volatility -f ram1.mem imageinfo
Volatility Foundation Volatility Framework 2.5
INFO    : volatility.debug    : Determining profile based on KDBG search...
          Suggested Profile(s) : Win7SP0x86, Win7SP1x86
                     AS Layer1 : IA32PagedMemoryPae (Kernel AS)
                     AS Layer2 : FileAddressSpace (./ram1.mem)
                      PAE type : PAE
                           DTB : 0x185000L
                          KDBG : 0x82961c30L
          Number of Processors : 1
     Image Type (Service Pack) : 1
                KPCR for CPU 0 : 0x82962c00L
             KUSER_SHARED_DATA : 0xffdf0000L
           Image date and time : 2017-01-09 13:03:38 UTC+0000
     Image local date and time : 2017-01-09 05:03:38 -0800

```

Aunque puede ser incorrecto (en cuyo caso deberíamos intentar otro perfil), empezaremos
a trabajar bajo el supuesto de que es una imagen de Windows 7, ServicePack 0, x86.

En este punto hay dos aproximaciones diferentes que podemos tomar.


#### Primera aproximación

El método más directo (pero no el mejor) es volcar todas las contraseñas e intentar
crackearlas, esperando que una de ellas tenga el formato 'flag{...}'. Con este objetivo
en mente, volcamos primero las contraseñas en el sistema:
```sh
$ volatility -f ram1.mem --profile Win7SP0x86 hashdump
Volatility Foundation Volatility Framework 2.5
Administrator:500:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
IEUser:1000:aad3b435b51404eeaad3b435b51404ee:ea0026d2bc07d7f56ea8e3599cabed43:::
```

Ahora sólo tenemos que crackear los hashes usando la herramienta que queramos, como
hashcat, usando el filtro incremental `flag{?a?a?a?a?a?a?a?a?a?a}`, que buscará todas
las posibilidades desde `flag{a}` hasta `flag{~~~~~~~~~~~}`. Con esta regla, la
contraseña se saca en un par de horas. Sin embargo, este incremento se puede (y debería)
hacerse de manera manual, para evitar que hashcat pruebe contraseñas que no acaben en
'}'. Esto no es un problema hasta que alcanza una máscara con 6 elementos '?a', donde
tarda horas en realizar la búsqueda. Afortunadamente, encontramos la bandera en el primer
intento usando `hashcat -m 1000 -a 3 -o cracked ctf.hashes flag{?a?a?a?a?a}`, tardando
sólo un par de minutos:

{% include image.html
	src="/assets/posts/2017-08-13-ciberseg-forensics/hashcat-crack.jpg"
	title="Contraseña sacada con HashCat"
	alt="Resultado de hashcat"
%}

#### Segunda aproximación

Tal y como sugiere el nombre del reto, también podemos usar [mimikatz](https://github.com
/gentilkiwi/mimikatz), una herramienta para sacar las contraseñas de los usuarios con
una sesión iniciada (explotando vlnerabilidades de Windows, por supuesto). Hay un
[plugin para volatility](https://github.com/RealityNet/hotoloti/blob/master
/volatility/mimikatz.py) que podemos usar; y podemos obtener la respuesta en segundos:
```sh
$ volatility --plugins=/usr/share/volatility/contrib/plugins/ -f ram1.mem --profile=Win7SP0x86 mimikatz
Volatility Foundation Volatility Framework 2.5
Module   User             Domain           Password
-------- ---------------- ---------------- ----------------------------------------
wdigest  IEUser           IE8Win7          flag{cadia}
wdigest  IE8WIN7$         WORKGROUP
```

En cualquier caso, la bandera es: `flag{cadia}`.


-----------------------------------------------------------------------------------------


## Tercer reto: TrueCrypt

### Materiales

De nuevo, debemos [descargar (55 MB + 1.2 GB)](https://drive.google.com/drive/folders
/0BzLA9WAiAXudZ0RFTzN0MnB4bG8?usp=sharing) una imagen de una RAM y un directorio
cifrado, "MyDocuments"; y debemos recuperar la contraseña de la memoria para poder
descifrar estos archivos.


### El reto

Para este reto vakos a usar de nuevo el
[framework volatility](http://www.volatilityfoundation.org/), ya que el título de este
reto sugiere que tiene algo que ver con TrueCrypt (quizá tenemos que encontrar las
claves de cifrado...), y volatility tiene un par de plugins para obtener las contraseñas,
que son almacenadas en claro en la memoria.


La imagen parece estar corrupta, porque no puedo leer los datos de ella. En cualquier
caso, la solución es bastante simple: usando el plugin `truecryptpassphrase` se obtienen
las contraseñas para descifrar el archivo. La clave debería ser `GetRektTrueCrypt7.0`.
Después sólo tenemos que usar TrueCrypt para descifrar `MyDocuments` y encontrar el .txt
con la bandera:
 `flag{useVeracrypt}`.


-----------------------------------------------------------------------------------------


## Cuarto reto: MrRobot

### Materiales

Para este reto sólo necesitamos [este archivo zip](/assets/posts
/2017-08-13-ciberseg-forensics/Light_of_the_Seven.zip), con un archivo de audio dentro.

### El reto

Después de trastear un rato, no podemos encontrar nada interesante (ni en los metadatos,
ni buscando _strings_, ni en el espectrograma).

El nombre de este reto nos da una pista, puesto que el personaje principal de la serie
_Mr. Robot_ usa un programa llamado [DeepSound](http://www.jpinsoft.net/DeepSound/) para
ocultar información en archivos de música.

Como los datos están sin cifrar, podemos simplemente extraerlos y obtener la bandera:

{% include image.html
	src="/assets/posts/2017-08-13-ciberseg-forensics/deepsound.jpg"
	title="Datos extraídos usando DeepSound"
	alt="Fichero extraído"
%}

Y tenemos la última bandera de este conjunto de retos:
`flag{thelannistersendtheirregards}`.
