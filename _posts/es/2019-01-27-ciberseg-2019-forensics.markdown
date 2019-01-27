---
layout: post
title:  "Ciberseg 2019: forense"
date:	2019-01-27 15:54:54 +0100
author: foo
categories: es ctf ciberseg write-up forensics
lang: es
ref: ciberseg-2019-forensics
---

En este post voy a explicar mis soluciones a los retos del Ciberseg de 2019. En concreto,
este artículo se corresponde con los de la categoría de **forense**.

El [Ciberseg](https://ciberseg.uah.es/) es un congreso que tiene lugar todos los años por
estas fechas en la Universidad de Alcalá de Henares. La verdad es que los años anteriores
siempre ha sido divertido, y este año no ha sido menos :) Además, el podio ha estado muy
reñido y hubo sorpresas de última hora :D (al final gané en la última hora,
literalmente, por apenas unos pocos puntitos).

En fin, estos son los retos y sus soluciones. Para los que haga falta, dejaré también los
recursos necesarios que nos aportaron para intentar el reto por vuestra cuenta.

-----------------------------------------------------------------------------------------

# 1.- Exfiltration files (25pts)

La descripción de este primer reto dice:
> Hemos interceptado esta foto parece que oculta algún mensaje.


Esta es la imagen que nos dan:
{% include image.html
	src="/assets/posts/2019-01-23-ciberseg-2019-forensics/imagen.jpg"
	title="Imagen inicial del reto"
	alt="Dos coches de carreras vistos de frente"
%}

Si buscamos con `binwalk`, nos dice que hay una imagen dentro:
```sh
$ binwalk imagen.jpg

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             JPEG image data, JFIF standard 1.01
51961         0xCAF9          JPEG image data, EXIF standard
51973         0xCB05          TIFF image data, big-endian, offset of first image directory: 8
71107         0x115C3         Unix path: /www.w3.org/1999/02/22-rdf-syntax-ns#"> <rdf:Description rdf:about="" xmlns:xmp="http://ns.adobe.com/xap/1.0/" xmlns:xmpMM="http
74915         0x124A3         Copyright string: "Copyright 1999 Adobe Systems Incorporated"
```

Sin embargo, no puede extraer la información. No sé qué criterio sigue _binwalk_ para
extraer a veces sí y a veces no los datos. Pero bueno, podemos usar
`dd id=imagen.jpg of=imagen_extracted.jpg bs=51961 skip=1` para extraer los datos. Luego,
simplemente abrimos la nueva imagen y obtenemos la solución:
{% include image.html
	src="/assets/posts/2019-01-23-ciberseg-2019-forensics/imagen_extracted.jpg"
	title="Imagen extraída"
	alt="Imagen con el texto de la bandera: 'flag{RapidoYFurioso}'"
%}

Otra forma de resolverlo es mirando las cadenas de texto:
```sh
$ strings imagen.jpg | grep -Poi 'flag{[^}]*}'
flag{RapidoYFurioso}
flag{RapidoYFurioso}
```

De cualquier forma, la _flag_ es: `flag{RapidoYFurioso}`.

-----------------------------------------------------------------------------------------

# 2.- Break the gesture (50pts)

Este reto no tenía descripción. Simplemente hay un archivo:
[gesture.key](/assets/posts/2019-01-23-ciberseg-2019-forensics/gesture.key).

Aunque me costó un rato darme cuenta, este archivo es el que se usa en Android para
guardar el patrón de desbloqueo del terminal.

Para sacar el patrón, se puede utilizar cualquier herramienta. Por ejemplo, yo utilicé
[androidpatternlock](https://github.com/sch3m4/androidpatternlock) y la saca en cuestión
de segundos:
```sh
$ time python2 aplc.py ../gesture.key

################################
# Android Pattern Lock Cracker #
#             v0.2             #
# ---------------------------- #
#  Written by Chema Garcia     #
#     http://safetybits.net    #
#     chema@safetybits.net     #
#          @sch3m4             #
################################

[i] Taken from: http://forensics.spreitzenbarth.de/2012/02/28/cracking-the-pattern-lock-on-android/

[:D] The pattern has been FOUND!!! => 210345876

[+] Gesture:

  -----  -----  -----
  | 3 |  | 2 |  | 1 |
  -----  -----  -----
  -----  -----  -----
  | 4 |  | 5 |  | 6 |
  -----  -----  -----
  -----  -----  -----
  | 9 |  | 8 |  | 7 |
  -----  -----  -----

It took: 1.1906 seconds

real	0m1.251s
user	0m3.894s
sys	0m0.084s
```

Y ya está. No tiene ninguna complicación más.

La _flag_ es: `flag{210345876}`.

-----------------------------------------------------------------------------------------

# 3.- Pcap (250pts)

La descripción del reto dice así:
>  Creo que se han llevado algo. ¿Me puedes decir el nombre del archivo?

También se adjunta
[esta captura de red](/assets/posts/2019-01-23-ciberseg-2019-forensics/captura.zip).

Al examinarla con _Wireshark_ vemos que hay muchos paquetes de TCP, HTTPS... Si los
ordenamos de mayor a menor tamaño, esperando que el archivo exfiltrado sea grande, vemos
un par de paquetes TCP con texto en claro que parece Base64:
{% include image.html
	src="/assets/posts/2019-01-23-ciberseg-2019-forensics/pcap-tcp.jpg"
	title="Paquetes vistos con Wireshark"
	alt="Paquete TCP con Base64 en el campo de datos"
%}

Si seguimos la traza de esa conversación, vemos que hay bastantes más datos. Cuando los
extraemos y decodificamos en Base64 obtenemos una cadena que tiene toda la pinta de ser
un volcado hexadecimal:
```
$ base64 -d b64
37 7A BC AF 27 1C 00 04 65 3D 77 8C 58 0F 00 00 00 00 00 00 6A 00 00 00 00 00 00 00 ...
```

Este volcado hexadecimal se corresponde con un archivo 7z que tenemos que examinar
para ver qué archivos fueron exfiltrados:
```sh
$ base64 -d b64 | tr -d '\r\n\t ' | xxd -r -ps > file.7z
$ file file.7z
file.7z: 7-zip archive data, version 0.4
$ 7z l file.7z

(...)
Scanning the drive for archives:
1 file, 4066 bytes (4 KiB)

Listing archive: file.7z

--
(...)
   Date      Time    Attr         Size   Compressed  Name
------------------- ----- ------------ ------------  ------------------------
2018-11-21 16:13:51 ....A        19385         3928  credit_cards.txt
------------------- ----- ------------ ------------  ------------------------
2018-11-21 16:13:51              19385         3928  1 files

```

Pues ya está. Sólo hay un archivo en el comprimido: `credit_cards.txt`.

La _flag_ es: `flag{credit_cards.txt}`

-----------------------------------------------------------------------------------------

# 4.- Pcap2 (300pts)

La descripción dice:
> No network traffic
Y se adjunta [esta](/assets/posts/2019-01-23-ciberseg-2019-forensics/captura2.zip)
captura.

Si la abrimos vemos que es una captura USB. Sé que habría que extraer el ID del USB que
nos interesa, estudiar los valores y blablabla; pero no tenía ganas de hacer eso y
preferí buscar en internet algún _script_ porque este es un reto muy común y normalmente
basta con extraer las pulsaciones del teclado. Si queréis una explicación más detallada,
[aquí](https://xbytemx.github.io/post/ciberseg19-writeups/#pcap2-300pts) los write-ups de
otra persona que participó en la competición. Está muy bien explicado y se sigue con
facilidad.

En fin, el caso es que yo utilicé este _script_, que lo saqué de [este artículo](https://medium.com/@ali.bawazeeer/kaizen-ctf-2018-reverse-engineer-usb-keystrok-from-pcap-file-2412351679f4):
```python
# Sacado de
# https://medium.com/@ali.bawazeeer/kaizen-ctf-2018-reverse-engineer-usb-keystrok-from-pcap-file-2412351679f4

newmap = {
  2: "PostFail",
  4: "a",  5: "b",  6: "c",  7: "d",  8: "e",  9: "f", 10: "g", 11: "h", 12: "i",
 13: "j", 14: "k", 15: "l", 16: "m", 17: "n", 18: "o", 19: "p", 20: "q", 21: "r",
 22: "s", 23: "t", 24: "u", 25: "v", 26: "w", 27: "x", 28: "y", 29: "z", 30: "1",
 31: "2", 32: "3", 33: "4", 34: "5", 35: "6", 36: "7", 37: "8", 38: "9", 39: "0",
 40: "Enter", 41: "esc", 42: "del", 43: "tab", 44: "space",
 45: "-", 47: "[", 48: "]", 56: "/",
 57: "CapsLock", 79: "RightArrow", 80: "LetfArrow"
}

myKeys = open('hexoutput.txt')
i = 1
for line in myKeys:
    bytesArray = bytearray.fromhex(line.strip())
#    print "Line Number: " + str (i)
    for byte in bytesArray:
        if byte != 0:
            keyVal = int(byte)

            if keyVal in newmap:
#                print "Value map: " + str (keyVal) + " --> " + newmap [keyVal]
                print newmap[keyVal]
            else:
#                print "No map found for this value: " + str(keyVal)
                print format(byte, '02X')
    i+=1
```

Exportando el CSV con Wireshark (como dice en ese artículo) y decodificando los valores,
nos sale la solución:
```sh
$ python2 decode.py
f
l
l
a
a
a
g
g
PostFail
PostFail
[
PostFail
u
u
s
s
b
m
o
n
i
t
t
o
o
r
PostFail
PostFail
]
PostFail
```

No sé por qué aparecen los valores repetidos, porque no he perdido ni un segundo en saber
cómo funcionan esto de las interrupciones del teclado capturadas en un pcap, aunque
quizá debería...

La _flag_ es: `flag{usbmonitor}`

-----------------------------------------------------------------------------------------

# 5.- Creo que me espían... (350pts)

La descripción dice así:
> Sospechamos que el dispositivo Android ha sido comprometido y queremos que lo
> investigues. Para ello te damos la partición data y necesitamos saber cual les la APK
> que lo ha comprometido.

Y se adjunta [la imagen](/assets/posts/2019-01-23-ciberseg-2019-forensics/imagen_data.E01.7z)
del dispositivo.

Se puede descomprimir la imagen con `ewfmount` y luego montarla como un dispositivo más.
Una vez se tiene montada, empezamos a navegar por el sistema de archivos. La primera
parada es el directorio `app`, que parece que tiene un par de aplicaciones candidatas,
pero sólo están ahí para despistar.

Lo que nos importa realmente es mirar las aplicaciones instaladas (es decir, las que
están bajo `/data/`. De todas estas, sólo unas pocas tienen datos y apenas un par son
instaladas por el usuario. El resto son las que vienen por defecto para usar el sistema
(teléfono, contactos, etc.); así que, en lugar de buscar la aplicación maliciosa, podemos
intentar buscar el **punto de entrada** de esta aplicación. Los candidatos más
prometedores son: `com.android.email` y `com.android.browser`.

Tras analizar la aplicación de correo vemos que está limpia, por lo que pasamos a nuestra
segunda opción: el navegador.

Al entrar en `/data/com.android.browser/` vemos un archivo llamado `wCLxU.dex`.
_Spoiler alert!_ Esta es la aplicación maliciosa.
Yo no me di cuenta en su momento, así que seguiré como si no lo hubiera visto...


Rebuscando entre las BDD que hay en el directorio `databases/` hay una que se llama
_browser2.db_ y donde podemos ver algo interesante:
```
sqlite> select * from history;
(...)
_id	title						url					     created	date		visits	user_entered
8	http://192.168.74.128/i6ADxOqMEyyI		http://192.168.74.128/i6ADxOqMEyyI		0	1516629327266	1	0
9	http://192.168.74.128/i6ADxOqMEyyI/EeMVfx/	http://192.168.74.128/i6ADxOqMEyyI/EeMVfx/	0	1516629327667	1	0
```

Esto tiene buena pinta. Por lo visto, alguien se descargó un archivo de un directorio con
un nombre raro en un servidor que no tiene ni nombre de dominio, accediendo directamente
por la IP (que, además, pertenece a una red privada). Esto tiene toda la pinta de ser lo
que buscamos.


Sabiendo que el usuario se descargó algo chungo, empezamos a indagar en
`cache/webviewCacheChromium/`, que es donde parece que se guarda la caché del navegador.
Sabiendo que buscamos un archivo `.apk`, podemos hacer un _grep_ rápido para ver si
suena la campana:
```sh
$ grep -PoR '[A-Za-z0-9]*[.]apk' .
./f_0000d6:wCLxU.apk
./f_0000d7:graphilos.apk
./f_0000d7:graphilos.apk
./f_0000d7:graphilos.apk
./f_0000d7:graphilos.apk
./f_0000d7:graphilos.apk
./f_0000d7:graphilos.apk
./f_0000d7:graphilos.apk
./f_0000d7:graphilos.apk
./f_0000d7:graphilos.apk
./f_0000d7:heagoo.apk
./f_0000d7:heagoo.apk
./f_0000d7:heagoo.apk
./f_0000d7:heagoo.apk
./f_0000d7:heagoo.apk
./f_0000d7:heagoo.apk
./f_0000d7:heagoo.apk
./f_0000d7:heagoo.apk
./f_0000d7:heagoo.apk
./f_0000d7:com.apk
./f_0000d7:com.apk
./f_0000d7:com.apk
./f_0000d7:com.apk
./f_0000d7:com.apk
./f_0000d7:com.apk
./f_0000d7:com.apk
./f_0000d7:com.apk
./f_0000d7:com.apk
./f_0000d7:www.apk
./f_0000d7:www.apk
./f_0000d7:www.apk
./f_0000d7:www.apk
./f_0000d7:www.apk
./f_0000d7:www.apk
./f_0000d7:www.apk
./f_0000d7:www.apk
./f_0000d7:www.apk
./f_0000d7:www.apk
./f_0000d7:www.apk
./f_0000d7:.apk
```

_Et voilà!_ De todos esos resultados, el más sospechoso es el primero, `wCLxU.apk`.
¿Recordáis el archivo ese que vimos antes que se llamaba `wCLxU.dex`? Pues ahora es
cuando algo hizo _click_ en mi cabeza y me di cuenta de que había perdido como una hora
rebuscando entre las tripas del historial de navegación, cuando tenía la solución delante
de mis narices...

En fin... La _flag_ es: `flag{wCLxU.apk}`

-----------------------------------------------------------------------------------------

Y sin habernos dado cuenta, ya hemos terminado todos los retos de forense :)

Siempre me lo paso bien con los retos del Ciberseg, y este año no ha sido menos. Espero
poder competir el año que viene, que seguro que se superan otra vez.

También quiero dar mi enhorabuena a los organizadores por todo su esfuerzo y su
creatividad para crear retos fuera de lo común :D
