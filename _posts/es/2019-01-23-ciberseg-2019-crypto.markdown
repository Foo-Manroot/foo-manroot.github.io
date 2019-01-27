---
layout: post
title:  "Ciberseg 2019: criptología"
date:	2019-01-23 15:38:22 +0100
author: foo
categories: es ctf ciberseg write-up crypto
lang: es
ref: ciberseg-2019-crypto
---


¡Buenas! En este primer post del año os traigo los write-ups del Ciberseg de 2019. En
concreto, este post se corresponde con los de la categoría de **criptología**.

El [Ciberseg](https://ciberseg.uah.es/) es un congreso que tiene lugar todos los años por
estas fechas en la Universidad de Alcalá de Henares. La verdad es que los años anteriores
siempre ha sido divertido, y este año no ha sido menos :) Además, el podio ha estado muy
reñido y hubo sorpresas de última hora :D (al final gané en la última hora,
literalmente, por apenas unos pocos puntitos).


En fin, estos son los retos y sus soluciones. Para los que haga falta, dejaré también los
recursos necesarios que nos aportaron para intentar el reto por vuestra cuenta.

-----------------------------------------------------------------------------------------

# 1.- Complutum message (15 puntos)

La descripción de este reto solamente tenía el siguiente texto:
`PbzcyhgvHeovfHavirefvgnf`.

Entre que valía tan poquito y el nombre del reto, está bastante claro que es cifrado
César. Para quien no conozca _Complutum_ era el nombre de la ciudad romana que había
donde ahora está Alcalá de Henares, que es donde se celebra el congreso.

Si se descifra (ya sea por fuerza bruta, analizando a mano las frecuencias o usando
cualquier página en internet), el texto en claro nos sale que es
`COMPLUTIURBISUNIVERSITAS`, usando la clave **n**.

Sencillo, ¿verdad? No está mal para ir calentando y subir la moral :D

La _flag_ es `flag{COMPLUTIURBISUNIVERSITAS}`.

-----------------------------------------------------------------------------------------

# 2.- Alien message from XXXI century (50 puntos)

La descripción de este reto dice así:
```
Hemos recibido un mensaje alienígena!! ¿Nos puedes ayudar a entenderlo?
```

Y además se adjunta una imagen:
{% include image.html
	src="/assets/posts/2019-01-23-ciberseg-2019-crypto/alienMessage.jpg"
	title="Archivo adjunto en el reto"
	alt="Una imagen con fondo blanco y una serie de extraños símbolos al frente, en negro, que no parecen ningún alfabeto estándar (latín, cirílico...)"
%}


Estos símbolos son un poco extraños, pero seguro que a algunas personas les resultan algo
familiares. Si no es así, basta con buscar un poco en las internetes con **DuckDuckGo**,
por ejemplo, por _alien language_ o cosas así y rápidamente se llega al
[lenguaje alien de Futurama](https://theinfosphere.org/Alien_languages), que tiene justo
los mismos símbolos que estamos buscando.

Una vez tenemos el alfabeto, se puede ir letra a letra comparando con la tabla y sacamos
el siguiente texto: `PLANETEXPRESSUAH`. Y ya está, ya tenemos 50 puntos más sin siquiera
despeinarnos :D

La _flag_ es `flag{PLANETEXPRESSUAH}`

-----------------------------------------------------------------------------------------

# 3.- Clásica (75 puntos)

La descripción de este reto dice así:
```
En la criptografía, como en la cerveza. Siempre viene bien alguna clásica:

sa okhbx dpejaja gc uad ei wlk tau becufwielhtkfaf effi uw sa okhbx pvmxauan ne zlm
sgygjigxtbv oszvfaa fo chdohs jw btkvimdce xrhvn fo cbudls p ubyc loghmpe jw llcloedce
eillscxaypfrxv hhsq k drqpqmesysg waurv gprkpcc on zlm rsmwjigxtbv oszvfaa a drrv ei
gfdvr fyrngp ewgwjtq lrvomerkw f cworcr nshvjhdq nefwbge ggy sw caors wyrnl y deea
hrymcairky ea epge jm hrqwa rv mmkvjv ahbugdes gff aopys sopvecwz dg vúphop psj
hyipmicdmiw zfnrgnirquiw jgu lgfaqxse plhblq kghd z qeclh sqwof pvc gcszieys rq ushf
hhrc va phsziqs f pcba yd dvmglvgtkfvd qsv vkv hgwof gfgmuako ootru fwxv tvnkdo ilhirvjl
lc plnj fw lrurapnbrhsw ulw zop nof fpwej ibe uo lyhwer dmf bkon crs iwf vllgqaplpr
siyhnkjaod fp zzsqe c va sdcvmts ke nk cruwidr
```

Como ya ha aparecido el cifrado César, lo más probable es que se trate de algo como
Vigenère, otro de los que siempre salen en los CTFs. Para estos casos no me suelo
complicar y voy directamente a páginas como [guballa.de](https://guballa.de/vigenere-solver)
o [dcode.fr](https://www.dcode.fr/vigenere-cipher), que suelen funcionar bastante bien.

En este caso, guballa saca la clave enseguida: _hackandbeers_. El texto descifrado es:
```
la mahou clasica es una de sus mas representativas bebe de la mahou original de mil
ochocientos noventa de cuando se utilizaba tapon de corcho y cuya botella se elaboraba
artesanalmente paso a denominarse mahou clasica en mil novecientos noventa y tres de
color dorado aspecto brillante y cuerpo moderado destaca por su sabor suave y buen
equilibrio en boca su aroma es ligero afrutado con tonos florales de lúpulo los
principales ingredientes son levadura lupulo agua y malta somos muy clasicos en todo para
la cerveza y para la criptografia por eso hemos decidido meter este bonito vigenere la
flag es hackandbeers que son dos cosas que se llevan muy bien por eso delegacion
organizaba el viaje a la fabrica de la cerveza
```

Y ya está.
Como dice en el texto, en la penúltima línea, la _flag_ es `flag{hackandbeers}`.


-----------------------------------------------------------------------------------------

# 4.- Cryptography is not steganography (150 puntos)

La descripción del reto dice así:
```
¡Que quede claro! ¡Ocultar no es cifrar!
```

También se adjunta el siguiente vídeo:

{% include video.html
	src="/assets/posts/2019-01-23-ciberseg-2019-crypto/harder.webm"
%}


Aquí se empieza a poner la cosa más interesante. A primera vista, el vídeo es bastante
normal; salvo por el final, donde se pone en negro pero sigue habiendo sonido. Esto me
hizo sospechar que hay algo escondido ahí en el final. Como el título habla de
esteganografía, pasé varias horas intentando buscar algo ahí.

Hasta que, después de verme el vídeo 876512348756123478 millones de veces, nos acabamos
dando cuenta de un pequeño detalle: hay un pixel bailón en la esquina superior izquierda
del vídeo. ¿Lo ves?

Pues a mí me costó mucho; pero al final lo vi. Hay quien se haría un _script_ para
extraer los valores del pixel; pero yo decidí extraer los 181 fotogramas del vídeo
(`ffmpeg -i ../harder.mp4 fotogramas/output%05d.png`) e ir uno a uno apuntando en una
hojita su valor. No es precisamente eficiente, pero por lo menos es eficaz...
¯\\\_(ツ)\_/¯


Al principio pensé que era morse; pero, al ver que era un patrón tan irregular y que no
había manera de pasar eso a puntos y rayas, decidí pasar a mi segunda opción: binario.

Si lo interpretamos como si el pixel en negro fuera un uno y el pixel en blanco, un cero,
sacamos lo siguiente:
```
01100110	f
01101100	l
01100001	a
01100111	g
01111011	{
01100100	d
01100001	a
01101110	n
01100011	c
01101001	i
01101110	n
01100111	g
01011111	_
01110000	p
01101001	i
01111000	x
01100101	e
01101100	l
```

Pues ahí está la _flag_. Al final sólo había que darse cuenta del pixel bailarín :)

Supongo que me faltó apuntar el último Byte y por eso falta la llave de cierre, _}_.

La _flag_ es `flag{dancing_pixel}`.


-----------------------------------------------------------------------------------------

# 5.- To be XOR not to be (200 puntos)

La descripción de este reto dice:
```
Han censurado la emisión de video, pero a ver si conseguimos el nombre del personaje que
aperece en él.
```
Y además se adjunta [este vídeo](/assets/posts/2019-01-23-ciberseg-2019-crypto/result.mp4).


Para solucionar este reto hay que darse cuenta de que el primer fotograma es diferente al
resto. Si se une eso con el título, _to be **XOR** not to be_, se concluye que hay el
vídeo está cifrado haciendo una XOR entre cada fotograma y el primero.

Para realizar la XOR, primero se extraen todos los fotogramas con
`ffmpeg -i result.mp4 fotogramas/output%05d.png`. Esto nos devuelve 3045 archivos con los
que debemos hacer la XOR. Para realizar la conversión, yo usé un programa llamado _gmic_,
de uso muy sencillo:
```sh
mkdir descifrados
cd fotogramas

for f in *
do
	printf "%s\n" "$f"
	gmic ../clave.png "$f" -blend xor -o ../descifrados/"$f" 2>/dev/null
done
```

Luego, se pueden recomponer en un vídeo de nuevo usando
`ffmpeg -i descifrados/%05d.png recompuesto.mp4`, lo que nos devuelve este vídeo:

{% include video.html
	src="/assets/posts/2019-01-23-ciberseg-2019-crypto/recompuesto.webm"
%}

Esto no deja muy claro cuál es el vídeo original. Tras un par de días sin ser resuelto,
los organizadores dejaron un par de pistas:
```
Hint! En este CTF no llegamos a crear la categoría de OSINT, pero... ¿Te has planteado
buscar los fotogramas descifrados en internet? Recuerda: ¡Buscamos el nombre del
personaje!

Hint! Hemos dejado una pista en nuestra cuenta de Twitter:
https://twitter.com/ciberseguah/status/1086750900167819265
```

Si desciframos la imagen de la pista que pusieron en Twitter, igual que hemos hecho con
los fotogramas, sacamos esto:

{% include image.html
	src="/assets/posts/2019-01-23-ciberseg-2019-crypto/pista_descifrada.jpg"
	title="Pista descifrada"
	alt="Se trata de una cara en primer plano con el texto 'si nos pinchan, ¿acaso no sangramos?"
%}

Después de buscar en internet, finalmente llegamos a la escena del
[monólogo de Shylock](https://www.youtube.com/watch?v=VydfEXZYmyU), el personaje de la
obra de Shakespeare _El mercader de Venecia_.

Como nos pedían el nombre del personaje que salía en esta escena, la _flag_ es
`flag{shylock}`.

-----------------------------------------------------------------------------------------

# 6.- YUVEYUVEYU (350 puntos)

La descripción del reto dice así:
```
Desde las llanuras de Ulan Bator nos llega una extraña señal...
```
Además, se nos proporciona el archivo **20190116_120900Z_106520122Hz_IQ.wav** que, al ser
muy grande para Github Pages, he tenido que comprimir en 8 partes:
  - [Parte 1](/assets/posts/2019-01-23-ciberseg-2019-crypto/20190116_120900Z_106520122Hz_IQ.wav.7z.001)
  - [Parte 2](/assets/posts/2019-01-23-ciberseg-2019-crypto/20190116_120900Z_106520122Hz_IQ.wav.7z.002)
  - [Parte 3](/assets/posts/2019-01-23-ciberseg-2019-crypto/20190116_120900Z_106520122Hz_IQ.wav.7z.003)
  - [Parte 4](/assets/posts/2019-01-23-ciberseg-2019-crypto/20190116_120900Z_106520122Hz_IQ.wav.7z.004)
  - [Parte 5](/assets/posts/2019-01-23-ciberseg-2019-crypto/20190116_120900Z_106520122Hz_IQ.wav.7z.005)
  - [Parte 6](/assets/posts/2019-01-23-ciberseg-2019-crypto/20190116_120900Z_106520122Hz_IQ.wav.7z.006)
  - [Parte 7](/assets/posts/2019-01-23-ciberseg-2019-crypto/20190116_120900Z_106520122Hz_IQ.wav.7z.007)
  - [Parte 8](/assets/posts/2019-01-23-ciberseg-2019-crypto/20190116_120900Z_106520122Hz_IQ.wav.7z.008)


Como yo [he hecho](/post/es/gnuradio/sdr/2017/11/18/gnuradio-ook.html) ya
[un par de cosas](post/es/gnuradio/sdr/2018/01/15/gnuradio-ook-transmit.html) con SDR, el
nombre del archivo me da una pista muy grande. De hecho, en cuanto lo vi fui directamente
a intentarlo :D

Normalmente cuando se guarda una captura de radio se suele poner en el nombre del archivo
la velocidad de muestreo usada, la frecuencia, la fecha... En este caso, tenemos:

  - `20190116_120900Z`. La fecha: 16 de Enero de 2019, con su zona horaria

  - `106520122Hz`. La **frecuencia central**: 106.520 MHz

  - `IQ`. El tipo de grabación: muestras en formato [I/Q](http://www.ni.com/tutorial/4805/en/)


Como la frecuencia de la captura se encuentra en la banda de la radio FM comercial,
esperamos escuchar voces o música. Esto nos ayudará a saber si vamos por buen camino en
la demodulación.


Aunque podríamos usar GNURadio para demodular la señal, suele ser más sencillo utilizar
uno de los muchos analizadores de espectro populares, como GQRX o SDR#, que ya tienen
implementados algunos demoduladores comunes como el de FM en banda ancha.

Por alguna razón GQRX se vuelve loco al intentar leer el archivo y SDR# va fatal en mi
Arch Linux; así que decidí hacerme una máquina virtual para abrir el archivo con SDR#.
Una vez abierto, navegamos entre las distintas emisoras de radio hasta acabar en una
señal que no parece de una emisora comercial y es más potente que el resto. Si nos
centramos en ella, descubrimos esto:

{% include video.html
	src="/assets/posts/2019-01-23-ciberseg-2019-crypto/sdr-sharp.webm"
%}

Hmmm... ¿No hay como unos chirridos raros en medio de la canción?

Casi pierdo la cabeza de locura, porque me encanta complicarme la vida innecesariamente y
me dediqué a buscar cosas como NRSC5 (radio HD), RDS... Pero al final me pregunté ¿y si
esos chirridos no son porque hay otra señal junto a la música, sino que hay algo _en_ la
música?

Al final resulta que es tan sencillo como extraer el audio (con SDR# basta con pulsar el
botón de _grabar_) y mirar el espectrograma:

{% include image.html
	src="/assets/posts/2019-01-23-ciberseg-2019-crypto/lord_chinggis.jpg"
	title="Espectrograma de la grabación"
	alt="Visualización del espectrograma de la pista de audio extraida, donde se lee 'flag{lord_chinggis}'"
%}

Y ahí está la _flag_: `flag{lord_chinggis}`.

-----------------------------------------------------------------------------------------

Y con esto y un bizcocho... Estos eran todos los retos de la categoría de criptología.
Siempre me lo paso bien con los retos del Ciberseg, y este año no ha sido menos. Espero
poder competir el año que viene, que seguro que se superan otra vez.

También quiero dar mi enhorabuena a los organizadores por todo su esfuerzo y su
creatividad para crear retos fuera de lo común :D
