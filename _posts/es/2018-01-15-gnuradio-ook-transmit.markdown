---
layout: post
title:  "Suplantando un mando a distancia usando SDR y GNURadio"
date:	2018-01-15 19:31:24 +0100
author: foo
categories: es gnuradio sdr
lang: es
ref: gnuradio-ook-transmit
---


Hace unos meses [escribí un artículo](/post/es/gnuradio/sdr/2017/11/18/gnuradio-ook.html)
sobre las capacidades del SDR, permitiéndonos escuchar comunicaciones por radio con
un _hardware_ muy barato; y ahora voy a hablar sobre el siguiente paso: usar ese mismo
_hardware_ para suplantar cualquier dispositivo que queramos.


Ya tenía todo preparado desde hace un tiempo, pero no pude encontrar tiempo para
escribir este artículo y grabar los vídeos con las demostraciones; así que no hay que
pensar que esto me ha llevado tres meses para tenerlo listo. De hecho, es muy fácil.
Usé un objetivo ridículamente sencillo; pero el mismo ciclo de trabajo puede aplicarse
a cualquier objetivo que se quiera y debería llevar poco tiempo empezar a juguetear.

## Aviso legal

**Nota importante**:
```
No soy abogado, y todo lo que diga en esta sección se aplica sólo a las leyes españolas.
Pueden ser similares en otros países, o pueden no serlo. En cualquier caso, es
recomendable tomarse un tiempo para consultar a alguien que pueda saber la legalidad de
estos experimentos; o, al menos, echar un vistazo a las regulaciones locales.
```

Antes de entrar con los detalles técnicos, es importante saber la legalidad de transmitir
en ciertos rangos de frecuencia. No había que preocuparse de esto en la parte anterior,
escuchar señales, porque es legal hacerlo (al menos aquí en España) excepto algunas
frecuencias especiales como las de comunicaciones militares y cosas similares.


En cuanto a la transmisión, esto es todo lo que he podido encontrar:
  - Según las regulaciones de la [regulaciones de la U.E. (p. 11)](https://www.boe.es/doue/2017/214/L00003-00027.pdf),
	los " _dispositivos de corto alcance no específicos_ " (telemetría, mandos a
	distancia, alarmas...) en la banda de 433'92 MHz pueden emitir libremente con
	hasta 10 mW de potencia radiada en antena (p.r.a.).
  - En la última [tabla de asignación de frecuencias (p.12)](http://www.minetad.gob.es/telecomunicaciones/espectro/CNAF/notas-UN-2017.pdf),
	del Ministerio de Energía, Turismo y Agenda Digital, parece corroborar este
	límite de 10 mW p.r.a., añadiendo además que los dispositivos que trabajen en
	esta banda " _deben aceptar la interferencia perjudicial que pudiera resultar de
	aplicaciones ICM u otros usos de radiocomunicaciones en estas frecuencias o en
	bandas adyacentes_ ".


Si te encuentras en la Unión Europea, puede que estas regulaciones se apliquen a tu caso;
pero sería mejor si lo comprobaras, por si acaso...



## Preparación


Igual que en el artículo anterior, voy a trabajar con el transceptor
[HackrfOne](https://greatscottgadgets.com/hackrf/) (el RTL, más barato, no sirve aquí,
dado que no puede transmitir). Además, el mando a distancia que intentaré suplantar es
el mismo (un [EM_MAN-001](http://dinuy.com/es/rss/86-productos/domotica/229-em-man-001)).


Para comprobar si la señal se transmite correctamente, usaré dos luces enchufadas con un
par de receptores que tenía rodando por casa.


Ese era el _hardware_. En la parte del _software_, esta vez usaré solamente
[GNURadio](https://www.gnuradio.org/), con algunos bloques propios escritos en Python.



Como apunte final, el mando estudiado funciona con
[OOK](https://es.wikipedia.org/wiki/Modulaci%C3%B3n_Digital_de_Amplitud), modulada en
ASK, así que los diagramas de GNURadio están diseñados para modular en AM. Esta
información fue obtenida en el artículo anterior, junto con la banda base (necesaria
para sintetizar la señal).


## Repitiendo la señal

Este es el primer y más sencillo de los métodos a probar. Consiste en capturar la señal
objetivo y guardarla para simplemente repetirla cuando se quiera.


El método para hacerlo (junto con los diagramas) se explica más detalladamente en el
[artículo anterior](/post/es/gnuradio/sdr/2017/11/18/gnuradio-ook.html#transmitting-the-signal).


Aunque algo rudimentario, es un primer paso muy sencillo que permite obtener bastante
información sobre la señal, tanto si funciona como si no:
  - Si **cada vez** que se repite la señal se genera una respuesta en el receptor, se
	puede concluir que los paquetes son siempre los mismos, sin
	[ _rolling codes_ ](https://en.wikipedia.org/wiki/Rolling_code), contadores ni
	ninguna otra variable.
  - Si, por el contrario, sólo **funciona a veces** (o nunca), se puede deducir que hay
	alguna parte del paquete cambiando (como un contador o un _rolling code_). Esto
	nos dice que el protocolo es más coplejo y que simplemente repetir la señal
	grabada no es suficiente. Sin embargo, si funciona sólo a veces, se puede
	transmitir lo mismo durante un buen rato hasta que el receptor acepte el mensaje.
	Esto puede no resultar muy útil si se quiere encender una luz; pero puede
	resultar peligroso si un nuestro coche puede ser abierto " _sólo a veces_ " (esto
	puede ser causado por un _rolling code_ con un ciclo corto)


Incluso cuando no se tiene éxito repitiendo la señal, se puede extraer información sobre
el objetivo.


Si este método ha funcionado (debería hacerlo si el objetivo es un mando como el mío, o
algún juguete), entonces enhorabuena :)

Si no lo ha hecho, no hay que rendirse, porque aún hay otras técnicas que se pueden
usar. También se debería comprobar que todos los parámetros están correctos (velocidad
de muestreo, frecuencia...). Si nada de esto funciona, entonces habría que cambiar de
objetivo por uno más sencillo.


## Sintetizando la señal


El siguiente paso es crear la señal deseada sobre la marcha, directamente desde GNURadio,
sin necesidad de almacenar ningún fichero con una señal capturada, porque estos archivos
tienden a ser muy grandes y es muy molesto capturar _todos los posibles paquetes_ a mano.

Así que, ¿cómo se sintetiza la señal?

Lo primero que hay que hacer es crear la onda cuadrada con la señal que queremos. En este
caso, la codificación usada por el mando es _On-Off Keying_ (OOK), y la onda generada
debe ser algo como esto:
```
Para representar un '1': 3/4 del periodo en alto, 1/4 en bajo
Para representar un '0': 1/4 del periodo en alto, 3/4 en bajo


Periodo:     |0       |1       |2       |3       |
Bit:         |  '1'   |   '1'  |   '0'  |   '0'  |

Alto ->       _____    _____    __      __
             |     |  |     |  |  |    |  |
             |     |  |     |  |  |    |  |
Bajo ->  ----+     +--+     +--+  +-----  +------
```

Para generar esta onda se pueden simplemente generar _nibbles_ (números de 4 bits) y
serializarlos para obtener las muestras consecutivas que se necesitan: suponiendo que
se quiere producir un '1', representado por una ráfaga larga. Si establecemos que 4 bits
son un periodo, entonces el '1' sería `1110` (0xE), mientras que un '0' sería
`1000` (0x8).

Sabiendo esto, se puede generar una serie infinita de 0 y 1 con el bloque `Vector Source`
y convertirlos a 0x8 o 0xE respectivamente con el bloque `Map`. Finalmente, el bloque
`Unpack K bits` se puede usar para serializar esos números de 4 bits. Además, se pueden
añadir algunos '2' que, mapeados con 0x00, permiten añadir espacios entre los paquetes.
El resultado es el siguiente:

{% include image.html
	src="/assets/posts/2018-01-15-gnuradio-ook-transmit/square_wave.jpg"
	title="Diagrama de puntos de la señal generada"
	alt="Diagrama de puntos mostrando las señales correspondientes a la serie 011"
%}


Para facilitar el trabajo, he añadido una variable con el paquete en una cadena de
caracteres y el vector de números se genera añadiendo el siguiente código en
`Vector Source`:
```python
[ int (x) for x in packet ] + [ 2 ] * spacing
```

Ahora que tenemos la señal cuadrada, toca remuestrearla para que coincida con la
velocidad de muestreo del diagrama. Para ello, se puede usar el bloque
`Rational Resampler` y establecer el interpolado a `samples_per_symbol / 4` (ese '4'
viene de las 4 muestras por cada bit que se están generando), usando la información
obtenida sobre la señal cuando se estudió. La variables _samples_per_symbol_ se calcula
usando la frecuencia de banda base y la velocidad de muestreo del siguiente modo:
`int (samp_rate / baseband_freq)`. Después del remuestreo, se puede añadir un filtro
`Moving Average` (con el parámetro _length_ igual a `samples_per_symbol / 4`) para crear
una señal tan bonita como la que se ve en la siguiente imagen:

{% include image.html
	src="/assets/posts/2018-01-15-gnuradio-ook-transmit/squared_upsampled.jpg"
	title="Señal cuadrada remuestreadad"
	alt="Diagrama mostrando la señal cuadrada tras el remuestreo"
%}

Ahora ya simplemente es una cuestión de modular la señal cuadrada en AM para mandarla.
De hecho... ni siquiera es necesario hacerlo (supongo que el HackRF se encarga de ello).
Este es el diagrama final, que puede ser descargado
[aquí](/assets/posts/2018-01-15-gnuradio-ook-transmit/transmit.grc):

{% include image.html
	src="/assets/posts/2018-01-15-gnuradio-ook-transmit/transmit_flowgraph.jpg"
	title="Diagrama completo para sintetizar y enviar la señal"
	alt="Diagrama finalizado para sintetizar y enviar una señal modulada en ASK"
%}

## Fuerza bruta

Una vez que se pueden transmitir datos, el siguiente paso es traer el caos al mundo,
mandando todas las combinaciones de paquetes posibles y encender y apagarlo todo a la
vez sin parar. Aún no lo he probado, pero supongo que esta misma técnica puede ser usada
también para vencer los _rolling codes_ probando todas las combinaciones hasta que el
coche se abra...

Para este ataque, el diagrama se deja como estaba, salvo el generador de números, donde
se sustituye el bloque `Vector Source` por uno propio cuyo código se puede descargar
[aquí](/assets/posts/2018-01-15-gnuradio-ook-transmit/gen_packets.py). El nuevo diagrama
puede descargarse también
[por aquí](/assets/posts/2018-01-15-gnuradio-ook-transmit/bruteforce.grc).

{% include image.html
	src="/assets/posts/2018-01-15-gnuradio-ook-transmit/bruteforcer_flowgraph.jpg"
	title="Diagrama modificado para generar diferentes paquetes"
	alt="Modificación del diagrama anterior, mostrando el bloque cambiado"
%}


Este bloque propio toma un patrón (una expresión regular) como argumento y, usando
[exrex](https://github.com/asciimoo/exrex) o fuerza bruta (dependiendo del método que sea
más rápido en cada situación), genera todas las posibles cadenas de 0 y 1 que se le deben
pasar al serializador.

El código de este bloque es bastante simple, dado que sólo usa un generador que `yield`s
cada paquete (cadenas de 0, 1, y 2) y los agrupa en un array que se le puede pasa al
siguiente bloque.


Como siempre, cualquiera es libre de modificar estos _scripts_ y diagramas, y usarlos
para lo que quiera. Lo único que pido es que no se me culpe cuando algo vaya mal :D
(aunque agradecería algunas sugerencias para mejorarlos).


Para mostrar el generador en acción, usé un par de receptores para encender y apagar unas
luces. En el siguiente vídeo muestro primero el mando siendo usado, y luego inicio
el _bruteforcer_, que genera todas las combinaciones (sólo de un canal), encendiendo y
apagando las dos luces:

{% include video.html
	src="/assets/posts/2018-01-15-gnuradio-ook-transmit/demo.webm"
%}

