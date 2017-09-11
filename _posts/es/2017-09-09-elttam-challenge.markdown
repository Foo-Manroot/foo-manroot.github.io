---
layout: post
title:  "Reto de Elttam"
date:	2017-09-09 16:41:04 +0200
author: foo
categories: es write-up challenge elttam
lang: es
ref: elttam-challenge
---

Hace un tiempo leí un post interesante en el blog de
[Elttam](https://www.elttam.com.au/blog) (una empresa de seguridad), y decidí echar un
vistazo al resto de la página. No sé cómo, pero acabé en la
[sección de ofertas de trabajo](https://www.elttam.com.au/careers/),
donde se debe completar un pequeño reto antes de solicitar un puesto.

No tenía ninguna intención de solicitar nada, porque no creo que tenga las capacidades
que estén buscando (básicamente, porque aún ni siquiera he acabado el Grado...); pero
el reto parecía divertido, así que decidí intentarlo.

---

**NOTA: He cambiado algunos datos para no revelar la solución real del reto, aunque la
metodología para resolverlo es exactamente la misma.**

---

## El reto

{% include image.html
	src="/assets/posts/2017-09-09-elttam-challenge/challenge-screenshot.png"
	title="Captura de pantalla del reto"
	alt="Captura de pantalla de la página del reto"
%}


La primera cosa que hay que hacer es obtener el volcado hexadecimal y sacar el binario,
para ver qué datos se están representando. Quizá podamos encontrar algún formato
reconocible. Aquí hago todo en un sólo paso, así que hay un `0d 0a 00` de más al final
(eso no nos afecta para nada):
```
$ cat - | tr -d "\n" | sed -e "s/ //g" | xxd -r -ps > dump.bin
2c 54 2d f0 0d 2a 08 00 27 c3 59 62 08 00 45 00
01 a1 f3 33 40 00 40 06 bd 8d c0 a8 7b 2d 68 69
6a 6b 88 90 00 50 c9 c9 77 90 1f e5 d2 bd 50 18
00 e5 8a 29 00 00 50 4f 53 54 20 2f 63 61 72 65
65 72 20 48 54 54 50 2f 31 2e 31 0d 0a 48 6f 73
74 3a 20 77 77 77 2e 65 6c 74 74 61 6d 2e 63 6f
6d 2e 61 75 0d 0a 55 73 65 72 2d 41 67 65 6e 74
3a 20 65 6c 74 74 61 6d 20 72 6f 63 6b 73 21 0d
0a 41 63 63 65 70 74 2d 4c 61 6e 67 75 61 67 65
3a 20 65 6e 2d 55 53 2c 65 6e 3b 71 3d 30 2e 35
0d 0a 41 63 63 65 70 74 2d 45 6e 63 6f 64 69 6e
67 3a 20 67 7a 69 70 2c 20 64 65 66 6c 61 74 65
0d 0a 43 6f 6f 6b 69 65 3a 20 5a 57 31 68 61 57
77 39 4d 57 4d 77 4d 44 41 30 4d 47 51 79 4e 54
41 77 4d 44 6b 78 4d 54 45 78 4d 44 51 77 4f 44
52 69 4d 44 59 77 59 54 41 34 4e 47 49 77 4e 44
45 77 0d 0a 43 6f 6e 74 65 6e 74 2d 54 79 70 65
3a 20 61 70 70 6c 69 63 61 74 69 6f 6e 2f 78 2d
77 77 77 2d 66 6f 72 6d 2d 75 72 6c 65 6e 63 6f
64 65 64 0d 0a 43 6f 6e 74 65 6e 74 2d 4c 65 6e
67 74 68 3a 20 38 31 0d 0a 43 6f 6e 6e 65 63 74
69 6f 6e 3a 20 63 6c 6f 73 65 0d 0a 0d 0a 71 3d
54 68 65 2b 65 6d 61 69 6c 2b 61 64 64 72 65 73
73 2b 69 73 2b 68 69 64 64 65 6e 2b 69 6e 2b 74
68 69 73 2b 72 65 71 75 65 73 74 26 62 6f 6e 75
73 3d 57 68 61 74 2b 69 73 2b 73 6f 75 72 63 65
2b 49 50 2b 61 64 64 72 65 73 73 0d 0a 0d 0a 00
$ xxd dump.bin
00000000: 2c54 2df0 0d2a 0800 27c3 5962 0800 4500  ,T-..*..'.Yb..E.
00000010: 01a1 f333 4000 4006 bd8d c0a8 7b2d 6869  ...3@.@.....{-hi
00000020: 6a6b 8890 0050 c9c9 7790 1fe5 d2bd 5018  jk...P..w.....P.
00000030: 00e5 8a29 0000 504f 5354 202f 6361 7265  ...)..POST /care
00000040: 6572 2048 5454 502f 312e 310d 0a48 6f73  er HTTP/1.1..Hos
00000050: 743a 2077 7777 2e65 6c74 7461 6d2e 636f  t: www.elttam.co
00000060: 6d2e 6175 0d0a 5573 6572 2d41 6765 6e74  m.au..User-Agent
00000070: 3a20 656c 7474 616d 2072 6f63 6b73 210d  : elttam rocks!.
00000080: 0a41 6363 6570 742d 4c61 6e67 7561 6765  .Accept-Language
00000090: 3a20 656e 2d55 532c 656e 3b71 3d30 2e35  : en-US,en;q=0.5
000000a0: 0d0a 4163 6365 7074 2d45 6e63 6f64 696e  ..Accept-Encodin
000000b0: 673a 2067 7a69 702c 2064 6566 6c61 7465  g: gzip, deflate
000000c0: 0d0a 436f 6f6b 6965 3a20 5a57 3168 6157  ..Cookie: ZW1haW
000000d0: 7739 4d57 4d77 4d44 4130 4d47 5179 4e54  w9MWMwMDA0MGQyNT
000000e0: 4177 4d44 6b78 4d54 4578 4d44 5177 4f44  AwMDkxMTExMDQwOD
000000f0: 5269 4d44 5977 5954 4134 4e47 4977 4e44  RiMDYwYTA4NGIwND
00000100: 4577 0d0a 436f 6e74 656e 742d 5479 7065  Ew..Content-Type
00000110: 3a20 6170 706c 6963 6174 696f 6e2f 782d  : application/x-
00000120: 7777 772d 666f 726d 2d75 726c 656e 636f  www-form-urlenco
00000130: 6465 640d 0a43 6f6e 7465 6e74 2d4c 656e  ded..Content-Len
00000140: 6774 683a 2038 310d 0a43 6f6e 6e65 6374  gth: 81..Connect
00000150: 696f 6e3a 2063 6c6f 7365 0d0a 0d0a 713d  ion: close....q=
00000160: 5468 652b 656d 6169 6c2b 6164 6472 6573  The+email+addres
00000170: 732b 6973 2b68 6964 6465 6e2b 696e 2b74  s+is+hidden+in+t
00000180: 6869 732b 7265 7175 6573 7426 626f 6e75  his+request&bonu
00000190: 733d 5768 6174 2b69 732b 736f 7572 6365  s=What+is+source
000001a0: 2b49 502b 6164 6472 6573 730d 0a0d 0a00  +IP+address.....
```

Resulta que es una petición POST, y hay un par de pistas en los parámetros:
  - **q**: El email está escondido en esta petición
  - **bonus**: Cuál es la dirección IP fuente

Ahora debemos encontrar esas dos cosas.

### Dirección de email

Como dice la primera pista, la dirección de email tiene que estar escondida en algún
lugar de la petición,, así que podemos intentar encontrar primero en los otros parámetros
de la petición... como la *cookie*. Vamos a ver qué se decodifica en esa cadena
codificada en base64:
```sh
$ cat - | base64 -d
ZW1haWw9MWMwMDA0MGQyNTAwMDkxMTExMDQwODRiMDYwYTA4NGIwNDEw
email=1c00040d250009111104084b060a084b0410
```

¡Genial! Tenemos una dirección de email que no parece para nada una dirección...
Las direcciones de correo [**DEBEN**](https://tools.ietf.org/html/rfc5322#section-3.4.1)
tener una parte local (una cadena, usando un subconjunto del ASCII, para identificar la
cuenta de correo), un símbolo '@', y luego una cadena para el dominio (usando otro
subconjunto, más restrictivo, del ASCII). Por lo tanto, la cadena hexadecimal que se nos
ha dado tiene que estar codificada o cifrada.

Los intentos de decodificar la cadena no da frutos, así que vamos a la cadena, dando
por hecho que es un cirado, y empezar asumiendo que es una simple sustitución. Como con
cualquier otro cifrado, la primera cosa que hacer es contar los diferentes símbolos
usados:
```
Cadena: 1c 00 04 0d 25 00 09 11 11 04 08 4b 06 0a 08 4b 04 10

Conteo:
   Símbolo   Cuenta
      1c       1
      00       2
      04       3
      0d       1
      25       1
      00       1
      09       1
      11       2
      04       2
      0a       1
      08       2
      4b       2
      06       1
      10       1
```

No hay mucha información ahí... Quizá 0x04 sea una 'e', pero no hay suficiente texto para
concluir nada.

De cualquier modo, podemos intentar extraer alguna información de ahí; porque, como
dije antes, las direcciones de email tienen un formato claramente definido
(`<local>@<domain>`), y el dominio será seguramente `elttam.au`, or `elttam.com.au`; o
algo así.

Si se trata de una sustitución monoalfabética simple (significando que cada carácter
se cifra siempre con el mismo carácter) y el dominio es `elttam.<algo>`, ese patrón
debería ser visible al final de la cadena (la parte del dominio).

Sólo hay una posición en la que un símbolo es repetido dos veces, uno después del otro
(que sería la parte 'tt' de 'elttam'), así que sólo hay un candidato:
```
1c 00 04 0d 25 00 09 11 11 04 08 4b 06 0a 08 4b 04 10
                e  l  t  t  a  m
```

Con esa información, podemos intentar recuperar algunas partes del texto (de nuevo,
sólo si nuestra suposición inicial es correcta):
```
1c 00 04 0d 25 00 09 11 11 04 08 4b 06 0a 08 4b 04 10
    e  a        e  l  t  t  a  m           m     a
```

No es mucho texto; pero suficiente para hacernos pensar en uno de los posibles dominios:
```
1c 00 04 0d 25 00 09 11 11 04 08 4b 06 0a 08 4b 04 10
    e  a        e  l  t  t  a  m  .  c  o  m  .  a  u
```

Ahora ya podemos decir con cierta confianza que vamos por buen camino. Luego deberíamos
recuperar el método de cifrado. Una cosa que nos puede ayudar es notar que el cifrado
genera datos binarios (caracteres no imprimibles), así que es casi seguro que no se trata
de métodos clásicos (Vigenère, César...), sino de uno relativamente moderno, quizá
operando a nivel de bit. La primera cosa que nos viene a la cabeza es
[Vernam](https://en.wikipedia.org/wiki/Gilbert_Vernam#The_Vernam_cipher). Ahora es el
momento de probar esta hipótesis:
```sh
$ cat - > /dev/null
# Valores hexadecimales de los caracteres (pueden consultarse con `man ascii`):
e -> 0x65
l -> 0x6c
t -> 0x74
a -> 0x61
m -> 0x6d
$ # Primera prueba para recuperar la clave: 'e' xor 0x00 (obviamente, será 'e')
$ printf "%#x\n" "$((0x65 ^ 0x00))"
0x65
$ # Segunda prueba: 'l' xor 0x09
$ printf "%#x\n" "$((0x6c ^ 0x09))"
0x65
$ # Vale, voy a decir que la clave es 0x65 ('e')
$ printf "%#x\n" "$((0x74 ^ 0x11))"
0x65
$ # ¡Wow! ¡Menuda sorpresa! No esperaba que fuera 0x65 para nada...
$ printf "%#x\n" "$((0x61 ^ 0x04))"
0x65
```

Bueno, ya es suficiente. Definitivamente, el algoritmo es hacer la xor de cada carácter
con 'e'.

Ahora sólo tenemos que recuperar la dirección completa. Yo usé este simple *script*
de Python:
```sh
#!/usr/bin/env python
# -*- coding: utf-8 -*-

import binascii

mail = "1c00040d250009111104084b060a084b0410"
key = ord ("e")

arr = [ mail [i:(i + 2)] for i in xrange (0, len (mail), 2) ]

xored = [ key ^ int (elem, 16) for elem in arr ]

print "Mail address: " \
    + "".join ( [ binascii.unhexlify (hex (x).lstrip ("0x")) for x in xored ] )
```

Y ya tenemos la dirección de email (como ya dije antes, esta no es la dirección real):
```sh
$ ./decrypt_mail.py
Mail address: yeah@elttam.com.au
```

### La dirección IP

Esta es una tarea más simple, pues sólo tenemos que leer los Bytes del paquete y, como
tiene un formato estandarizado, obtener la IP fuente. Para hacer esto, podemos usar una
herramienta como [scapy](http://www.secdev.org/projects/scapy/) y simplemente construir
el paquete con la petición y leer los datos:
```python
>>> data = open ("dump.bin").read ()
>>> Ether (data)
<Ether  dst=2c:54:2d:f0:0d:2a src=08:00:27:c3:59:62 type=0x800 |<IP  version=4L ihl=5L tos=0x0 len=417 id=62259 flags=DF frag=0L ttl=64 proto=tcp chksum=0xbd8d src=192.168.123.45 dst=104.105.106.107 options=[] |<TCP  sport=34960 dport=http seq=3385423760 ack=535155389 dataofs=5L reserved=0L flags=PA window=229 chksum=0x8a29 urgptr=0 options=[] |<Raw  load='POST /career HTTP/1.1\r\nHost: www.elttam.com.au\r\nUser-Agent: elttam rocks!\r\nAccept-Language: en-US,en;q=0.5\r\nAccept-Encoding: gzip, deflate\r\nCookie: ZW1haWw9MWMwMDA0MGQyNTAwMDkxMTExMDQwODRiMDYwYTA4NGIwNDEw\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: 81\r\nConnection: close\r\n\r\nq=The+email+address+is+hidden+in+this+request&bonus=What+is+source+IP+address\r\n\r\n' |<Padding  load='\x00' |>>>>>
```

Y ya está, ya tenemos las direcciones IP fuente y destino (igual que el email, han sido
cambiadas):
  - **Fuente**: 192.168.123.45
  - **Destino**: 104.105.106.107


¡Y eso es todo!


Creo que es bueno cuando a veces las compañías hacen este tipo de retos para filtrar las
posibles solicitudes y evitar el *spam* (por si acaso hay algún *bot* sacando
direcciones de email por ahí). Además es bastante divertido y he disfrutado el tiempo que
me llevó el completarlo.
