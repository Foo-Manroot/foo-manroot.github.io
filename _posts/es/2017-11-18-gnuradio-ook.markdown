---
layout: post
title:  "Estudiando comunicaciones por radio con GNURadio y SDR"
date:	2017-11-18 16:51:19 +0100
author: foo
categories: es gnuradio sdr
lang: es
ref: gnuradio-ook
---


Este es mi último año en la universidad, y para mi trabajo de fin de grado estoy
investigando el uso de SDR
[(_Software Defined Radio_)](https://en.wikipedia.org/wiki/Software-defined_radio) para
interceptar y atacar comunicaciones por radio inseguras.


Las aplicaciones iniciales que tenía en mente eran sólo para interceptar teclados y
ratones inalámbricos; pero resulta que eso [ya se ha hecho](https://www.mousejack.com/),
así que decidí darle un enfoque más amplio y estudiar todas las comunicaciones por radio,
incluyendo mandos de garajes, llaves de algunos coches...

Por ahora, estoy sólo jugando y aprendiendo a usar [GNURadio](http://gnuradio.org/) e
intentando decodificar las señales simples de los mandos de domótica que se usan para
cosas como encender o apagar luces en una casa.


## Hardware

Antes que nada, necesitamos los dispositivos necesarios para interceptar y transmitir
señales a las frecuencias deseadas.

### Receptores

Hay múltiples opciones baratas para recibir señales. Sólo hay que buscar "RTL2832U"
(yo compré el mío por unos 5$, pero la antena no es muy buena).

Hay que tener en cuenta que estos aparatos **_no pueden transmitir_**. Sin embargo, son
buenos receptores y deberían bastar para empezar a jugar con SDR.

Se puede encontrar más información sobre el RTL-SDR en
[rtl-sdr.com](https://www.rtl-sdr.com), incluyendo una tienda donde comprar el _hardware_
y múltiples tutoriales, como instrucciones para construir una antena adecuada, o
decodificar las señales de la NOAA para obtener
[imágenes meteorológicas muy buenas](https://www.reddit.com/r/RTLSDR/search?q=noaa&restrict_sr=on)...


### Transceptores

Si te resulta cómodo trabajar con señales de radio, o crees que puedes usarlo para otros
proyectos, puedes comprar un transceptor por unos cientos de dólares, como el
[HackRF One](https://greatscottgadgets.com/hackrf/).


```
Voy a aportar algunas muestras para poder trabajar sin necesidad de un dispositivo
hardware; pero, si quieres jugar con tus propios mandos, deberías conseguir uno de los
dispositivos mencionados arriba.
```


## Software

El único _software_ que se necesita es GNURadio, pero se puede usar cualquier otro
programa para localizar y echar un vistazo a las señales recibidas. Dos opciones
populares son [GQRX](http://gqrx.dk/) y [SDR#](https://airspy.com/download/), pero hay
cientos de otros programas muy útiles.


## El mando

Yo voy a trabajar con el mando que tengo en casa: [EM_MAN-001,
hecho por Dinuy](http://dinuy.com/es/rss/86-productos/domotica/229-em-man-001)[^1]. En
la página enlazada hay un par de características de este mando; pero las más interesantes
son:

	- Comunicación:	Por Radio-Frecuencia (433,92MHz)
	- Modulación:	ASK

{% include image.html
	src="/assets/posts/2017-11-18-gnuradio-ook/EM_MAN-001.jpg"
	title="Mando a estudiar"
	alt="El mando Dinuy EM_MAN-001 que va a ser estudiado"
	style="max-height: 300px"
%}

Así que, simplemente mirando a la tabla proporcionada por el fabricante, sabemos dos
cosas esenciales: la __frecuencia__ y la __modulación__. Podríamos deducirlas buscando en
el espectro (normalmente, estos mandos usan la
[banda ISM](https://en.wikipedia.org/wiki/ISM_band) de 433 MHz) y examinando la onda (de
nuevo, estos mandos suelen modular usando
[On-Off Keying - OOK](https://en.wikipedia.org/wiki/On-off_keying)).

-----------------------------------------------------------------------------------------

## Interceptando y analizando la señal


Una vez hemos sintonizado el receptor a 433'92 MHz, podemos ver algo similar a esto en
GQRX:

{% include video.html
	src="/assets/posts/2017-11-18-gnuradio-ook/Screencast-GQRX.webm"
%}


Y viendo en Audacity el archivo WAV grabado, podemos ver esta señal tan bonita:

{% include image.html
	src="/assets/posts/2017-11-18-gnuradio-ook/gqrx_capture-audacity.jpg"
	title="Captura de la señal"
	alt="Señal vista en Audacity, mostrando la señal digital cuadrada"
%}


El archivo WAV con la señal grabada puede ser descargado
[aquí](/assets/posts/2017-11-18-gnuradio-ook/gqrx_capture.wav).


## Obteniendo los datos a mano

La codificación mostrada en la imagen de arriba es bastante sencilla, y puede ser
decodificada a mano. Básicamente, las ráfagas largas se interpretan como un bit (por
ejemplo, un _1_), y las cortas se interpretan como el otro bit (por ejemplo, un _0_).
Para diferenciar las ráfagas largas de las cortas podemos mirar en el medio de un periodo
(si está en alto, significa que es un 1 y si está en bajo un 0, por ejemplo).

{% include image.html
	src="/assets/posts/2017-11-18-gnuradio-ook/signal-hand-decode.jpg"
	title="Datos decodificados de la señal"
	alt="Señal vista en Audacity, mostrando la señal digital cuadrada y los bits decodificados"
%}


Así, los datos que corresponden con el primer botón pulsado en la captura son:
`0100 0001 0101 0100 0001 0101 0`


En la captura hay tres pulsaciones diferentes de botones:
  - Canal II, botón 4 (ON):	`0100000101010100000101010`
  - Canal II, botón 4 (OFF):	`0100000101010100000000000`
  - Canal II, botón 4 (ON):	`0100000101010100000101010`


Este tipo de dispositivos usan esta codificación tan simple para evitar perder
información (puesto que esas bandas tienen muchas interferencias), y es bastante común
que la información se repita varias veces; como en este mando, donde los paquetes se
repiten tras una espera de uno o dos periodos.

Yo usé Python para automatizar este proceso de decodificar las señales grabadas (aunque
luego descubrí que GNURadio era mejor para esta tarea), extrayendo los siguientes datos
para estudiar el protocolo:

{% include image.html
	src="/assets/posts/2017-11-18-gnuradio-ook/protocol-study.jpg"
	title="Estudio del protocolo"
	alt="Bits recibidos, dependiendo del botón pulsado"
%}


Como nota aparte, hice un pequeño archivo de sintaxis para vim (como se puede ver en la
imagen anterior), que puede ser descargado
[de aquí](/assets/posts/2017-11-18-gnuradio-ook/signal.vim). Para usarlo, hay que crear
un archivo `.vim.custom` en el directorio del proyecto con el siguiente contenido (o
añadirlo directamente al `.vimrc`, o como se prefiera hacer...):
```vim
autocmd BufRead,BufNewFile *.signal set filetype=signal
autocmd Syntax signal so **/syntax/signal.vim
```

Por otro lado, aunque el propósito principal es usar GNURadio, dejo
[por aquí](/assets/posts/2017-11-18-gnuradio-ook/wav_data_extract.tar.gz) el código
(Python2) usado para extraer los bits de las grabaciones en WAV, que usé antes de
conocer GNURadio. Para saber más sobre su uso, hay que ejecutar `./decode.py --help`.


-----------------------------------------------------------------------------------------

## Usando GNURadio

Ahora que sabemos todo lo que hay que saber sobre la señal, podemos empezar a usar
GNURadio para analizarla o decodificarla en tiempo real. Daré por hecho que se tienen
algunos conocimientos básicos de GNURadio o de tratamiento digital de señales (yo tampoco
soy un experto... sólo hacen falta algunos conceptos básicos para seguir esta parte).

Para aprender más sobre cualquiera de estas materias, hay muchos tutoriales y recursos en
internet, como [esta serie](https://greatscottgadgets.com/sdr/) sobre tratamiento digital
de señales, hecha por el creador del HackRF, o
[esta otra serie](https://wiki.gnuradio.org/index.php/Guided_Tutorial_Introduction),
sacada de la wiki de GNURadio.


A partir de ahora trabajaré con
[este archivo IQ](/assets/posts/2017-11-18-gnuradio-ook/cap.iq.tar.bz2), capturado
usando GNURadio, porque es más simple trabajar con él que enchufar el receptor.


### Obteniendo la señal digital

La señal capturada está
[modulada](https://es.wikipedia.org/wiki/Modulaci%C3%B3n_(telecomunicaci%C3%B3n)) en AM.
Eso significa que tenemos la señal portadora (a 433 MHz), pero tenemos que recuperar la
señal original para empezar a decodificarla. Como el método usado es muy sencillo,
podemos simplemente usar el bloque `Complex to Mag^2`. Además, un `Threshold` puede
usarse para reducir la señal a una onda perfectamente cuadrada.

Este primer diagrama (con un pequeño control para ajustar la frecuencia) puede ser
descargado desde [aquí](/assets/posts/2017-11-18-gnuradio-ook/flowgraphs/analyze.grc):

{% include image.html
	src="/assets/posts/2017-11-18-gnuradio-ook/flowgraph_receiver.jpg"
	title="Diagrama para extraer la señal digital"
	alt="Diagrama con los bloques mencionados para demodular la señal"
%}

De momento, sólo podemos ver la señal digital (junto con los diferentes estadios
mientras se procesa la señal capturada). También podemos añadir un filtro de paso de
banda (_band-pass filter_) para reducir el ruido.

### Analizando la señal

Para recuperar los datos de manera precisa mientras está siendo capturada la señal,
debemos obtener algunas estadísticas, como la frecuencia base (para saber el número de
muestras por periodo, para poder distinguir entre ráfagas cortas y largas). Para ello,
podemos usar el diagrama anterior junto a un bloque propio cuyo código se puede descargar
[aquí](/assets/posts/2017-11-18-gnuradio-ook/flowgraphs/stats_collector.py), y añadirlo
a la salida del bloque `Threshold`, como se muestra en la imagen:

{% include image.html
	src="/assets/posts/2017-11-18-gnuradio-ook/flowgraph_get_stats.jpg"
	title="Diagrama para analizar la señal digital"
	alt="Diagrama con el nuevo bloque propio para obtener estadísticas de la señal"
%}

Este nuevo diagrama puede ser descargado
[aquí](/assets/posts/2017-11-18-gnuradio-ook/flowgraphs/get_stats.grc).


Un ejemplo de la salida puede ser como el siguiente:
```
(...)
******************************
=> General stats:
	 -> Min burst: 688
	 -> Max burst: 2319
	 -> Mean: 1206.8630303
=> Short bursts:
	 -> Median: 716
	 -> Longer burst: 748
=> Long bursts:
	 -> Median: 2243
	 -> Shorter burst: 2223
=> Signal period (median): 2959 samples (675.904021629 Hz)
(...)
```

Ahora ya sabemos la frecuencia base, 675'9 Hz, y podemos empezar a decodificar los datos
en vivo, a medida que capturamos la señal.

### Decodificando en tiempo real

Para decodificar los datos, voy a sustituir el bloque `statistics sink` por
[otro bloque propio](/assets/posts/2017-11-18-gnuradio-ook/flowgraphs/ook2bin.py) para
mostrar los bits por STDOUT. Supongo que habrá otros métodos más simples para mostrar los
datos, pero elegí este porque Python es un lenguaje en el que el desarrollo es muy
rápido, y no sabía cómo hacerlo con los bloques disponibles.

Este diagrama puede descargarse
[aquí](/assets/posts/2017-11-18-gnuradio-ook/flowgraphs/decode.grc). Este es un ejemplo
de decodificación de paquetes en tiempo real:

{% include video.html
	src="/assets/posts/2017-11-18-gnuradio-ook/Screencast-flowgraph_decoding.webm"
%}


### Transmitiendo la señal

¡Al fin hemos llegado a la parte más chula!, donde podemos jugar con las luces / el
timbre / _para-lo-que-sirva-tu-mando_ ...

Si tienes uno de los dispositivos RTL-SDR, no podrás transmitir; pero hay muchas
alternativas baratas al HackRF (el que voy a usar para transmitir) por ahí. El HackRF y
transceptores similares son caros debido al amplio rango de frecuencias en el que pueden
operar; pero _chips_ pequeños que transmitan en 433 MHz deberían costar unos 5-10$. No
lo he probado; pero supongo que será fácil usar un Arduino o una Raspberry y, junto a
uno de esos _chips_, sintetizar la señal deseada.

De cualquier manera, hay dos métodos para suplantar al mando: repetir las señales
capturadas, o crear nuestra propia señal y emitirla para que el dispositivo final (la
luz, el timbre, etc.) lo reciba.

Repetir la señal es un método muy sencillo. Sólo tenemos que guardar la señal en un
fichero y luego usar este mismo fichero como fuente para transmitir.

No es el mejor método, puesto que hay que capturar todos los valores posibles, por cada
uno de los diferentes botones, y este método no escala. En cuanto se tienen más de tres
o cuatro botones, empieza a resultar bastante aburrido. Además, debemos tener cuidado
con los parámetros (frecuencia y velocidad de muestreo), para repetir exactamente la
misma señal que se recibió.

Los diagramas son bastante simples.

Recibir:
{% include image.html
	src="/assets/posts/2017-11-18-gnuradio-ook/flowgraph_capture.jpg"
	title="Diagrama para capturar la señal que va a ser repetida"
	alt="Diagrama con los bloques necesarios para guardar la señal en un archivo"
%}

Repetir:
{% include image.html
	src="/assets/posts/2017-11-18-gnuradio-ook/flowgraph_replay.jpg"
	title="Diagrama para repetir la señal"
	alt="Diagrama con los bloques necesarios para repetir la señal"
%}


Para el otro método, sintetizar la señal, crearé otro post nuevo; puesto que requiere
más explicación y este post es ya demasiado largo.


--------------

# Actualización 2018-06-10: la siguiente parte está [disponible aquí](/post/es/gnuradio/sdr/2018/01/15/gnuradio-ook-transmit.html).

--------------

[^1]: La página ya no está disponible. Tendréis que creerme cuando digo que esa es la
	información que venía ahí...
