---
layout: post
title:  "Write-ups del Ciberseg '17: ingeniería inversa"
date:	2017-08-15 20:23:20 +0200
author: foo
categories: es ctf ciberseg write-up reversing
lang: es
ref: ciberseg-reversing
---


Estos son los retos de ingeniería inversa que formaron parte del
[CTF](https://ciberseg.uah.es/ctf.html) organizado en el
[Ciberseg 2017](https://ciberseg.uah.es), un congreso sobre ciberseguridad que tiene
lugar cada año en nuestra universidad.

El año pasado fue la primera edición (y espero que haya más, pues fue bastante divertido)
del CTF (y yo gané el primer premio :D).


## Primer reto: Reversing facilito

Para este reto asumo que se tiene un conocimiento básico de ensamblador x8086
(específicamente, la
[syntaxis AT&T](http://csiflabs.cs.ucdavis.edu/~ssdavis/50/att-syntax.htm)).

### Materiales

La única cosa necesaria para este primer reto es [este archivo](/assets/posts
/2017-08-15-ciberseg-reversing/b8c7903110ebdf9fa487e899b3bdefe4).

### El reto

Este es bastante sencillo de resolver. La primera cosa que notamos es un conjunto extraño
de instrucciones `mov`. Podemos observarlas usando `objdump -d
b8c7903110ebdf9fa487e899b3bdefe4`:
```
  40055c:    00 00
  40055e:    48 89 45 f8          mov    %rax,-0x8(%rbp)
  400562:    31 c0                xor    %eax,%eax
  400564:    c6 45 c0 66          movb   $0x66,-0x40(%rbp)
  400568:    c6 45 c1 6c          movb   $0x6c,-0x3f(%rbp)
  40056c:    c6 45 c2 61          movb   $0x61,-0x3e(%rbp)
  400570:    c6 45 c3 67          movb   $0x67,-0x3d(%rbp)
  400574:    c6 45 c4 7b          movb   $0x7b,-0x3c(%rbp)
  400578:    c6 45 c5 73          movb   $0x73,-0x3b(%rbp)
  40057c:    c6 45 c6 31          movb   $0x31,-0x3a(%rbp)
  400580:    c6 45 c7 5f          movb   $0x5f,-0x39(%rbp)
  400584:    c6 45 c8 6c          movb   $0x6c,-0x38(%rbp)
  400588:    c6 45 c9 30          movb   $0x30,-0x37(%rbp)
  40058c:    c6 45 ca 5f          movb   $0x5f,-0x36(%rbp)
  400590:    c6 45 cb 68          movb   $0x68,-0x35(%rbp)
  400594:    c6 45 cc 34          movb   $0x34,-0x34(%rbp)
  400598:    c6 45 cd 35          movb   $0x35,-0x33(%rbp)
  40059c:    c6 45 ce 5f          movb   $0x5f,-0x32(%rbp)
  4005a0:    c6 45 cf 68          movb   $0x68,-0x31(%rbp)
  4005a4:    c6 45 d0 33          movb   $0x33,-0x30(%rbp)
  4005a8:    c6 45 d1 63          movb   $0x63,-0x2f(%rbp)
  4005ac:    c6 45 d2 68          movb   $0x68,-0x2e(%rbp)
  4005b0:    c6 45 d3 30          movb   $0x30,-0x2d(%rbp)
  4005b4:    c6 45 d4 5f          movb   $0x5f,-0x2c(%rbp)
  4005b8:    c6 45 d5 63          movb   $0x63,-0x2b(%rbp)
  4005bc:    c6 45 d6 30          movb   $0x30,-0x2a(%rbp)
  4005c0:    c6 45 d7 6e          movb   $0x6e,-0x29(%rbp)
  4005c4:    c6 45 d8 5f          movb   $0x5f,-0x28(%rbp)
  4005c8:    c6 45 d9 72          movb   $0x72,-0x27(%rbp)
  4005cc:    c6 45 da 34          movb   $0x34,-0x26(%rbp)
  4005d0:    c6 45 db 64          movb   $0x64,-0x25(%rbp)
  4005d4:    c6 45 dc 34          movb   $0x34,-0x24(%rbp)
  4005d8:    c6 45 dd 72          movb   $0x72,-0x23(%rbp)
  4005dc:    c6 45 de 33          movb   $0x33,-0x22(%rbp)
  4005e0:    c6 45 df 5f          movb   $0x5f,-0x21(%rbp)
  4005e4:    c6 45 e0 68          movb   $0x68,-0x20(%rbp)
  4005e8:    c6 45 e1 31          movb   $0x31,-0x1f(%rbp)
  4005ec:    c6 45 e2 67          movb   $0x67,-0x1e(%rbp)
  4005f0:    c6 45 e3 68          movb   $0x68,-0x1d(%rbp)
  4005f4:    c6 45 e4 5f          movb   $0x5f,-0x1c(%rbp)
  4005f8:    c6 45 e5 66          movb   $0x66,-0x1b(%rbp)
  4005fc:    c6 45 e6 31          movb   $0x31,-0x1a(%rbp)
  400600:    c6 45 e7 76          movb   $0x76,-0x19(%rbp)
  400604:    c6 45 e8 33          movb   $0x33,-0x18(%rbp)
  400608:    c6 45 e9 7d          movb   $0x7d,-0x17(%rbp)
  40060c:    c6 45 ea 00          movb   $0x0,-0x16(%rbp)
  400610:    b8 00 00 00 00       mov    $0x0,%eax
```

Para ver qué valores están siendo empujados a la pila, podemos usar gdb y añadir un
punto de ruptura justo después del último _mov_ extraño:
```sh
$ gdb b8c7903110ebdf9fa487e899b3bdefe4
GNU gdb (Ubuntu 7.11.1-0ubuntu1~16.5) 7.11.1
Copyright (C) 2016 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
<http://www.gnu.org/software/gdb/documentation/>.
For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from b8c7903110ebdf9fa487e899b3bdefe4...(no debugging symbols found)...done.
(gdb) break *0x400610
Breakpoint 1 at 0x400610
(gdb) r
Starting program: b8c7903110ebdf9fa487e899b3bdefe4

Breakpoint 1, 0x0000000000400610 in main ()
(gdb) x/10s $rsp
0x7fffffffd8e0:layout"\030\332\377\377\377\177"
0x7fffffffd8e7:layout""
0x7fffffffd8e8:layout""
0x7fffffffd8e9:layout""
0x7fffffffd8ea:layout""
0x7fffffffd8eb:layout"\377\001"
0x7fffffffd8ee:layout""
0x7fffffffd8ef:layout""
0x7fffffffd8f0:layout"flag{s1_l0_h45_h3ch0_c0n_r4d4r3_h1gh_f1v3}"
0x7fffffffd91b:layout""
(gdb)
```

Y podemos ver que todos esos _mov_ sólo estaban metiendo la bandera en la pila:
`flag{s1_l0_h45_h3ch0_c0n_r4d4r3_h1gh_f1v3}`.


-----------------------------------------------------------------------------------------


## Segundo reto: Reversing CPP

### Materiales

El único archivo necesario para este retor puede [descargarse here](/assets/posts
/2017-08-15-ciberseg-reversing/82dba1aba3278a9a617ed4635cce47fe).

### El reto

Esta vez el reto no trata sobre leer ensamblador, sino sobre realizar la ingeniería
inversa sobre la salida del programa; pues se nos dijo que la bandera es el SHA-1 del
número que generó la secuencia:
```sh
$ ./82dba1aba3278a9a617ed4635cce47fe
[15745687,47237062,23618531,70855594,35427797,106283392,53141696,26570848,13285424,6642712,3321356,1660678,830339,2491018,1245509,3736528,1868264,934132,467066,233533,700600,350300,175150,87575,262726,131363,394090,197045,591136,295568,147784,73892,36946,18473,55420,27710,13855,41566,20783,62350,31175,93526,46763,140290,70145,210436,105218,52609,157828,78914,39457,118372,59186,29593,88780,44390,22195,66586,33293,99880,49940,24970,12485,37456,18728,9364,4682,2341,7024,3512,1756,878,439,1318,659,1978,989,2968,1484,742,371,1114,557,1672,836,418,209,628,314,157,472,236,118,59,178,89,268,134,67,202,101,304,152,76,38,19,58,29,88,44,22,11,34,17,52,26,13,40,20,10,5,16,8,4,2,1]
```

Para obtener el generador, primero debemos averiguar la regla que sigue esta serie. Para
ello, podemos restar cada número a su predecesor, y ver si podemos concluir algo:
```
Número         Diferencia             Commentarios
             (n_i - n_(i-1)
15745687          -             Número inicial, así que no hay diferencia
47237062       -31491375          -
23618531        23618531        47237062 / 2 = 23618531
70855594       −47237063        47237063 = (23618531 * 2) + 1
35427797        35427797        70855594 / 2 = 35427797
106283392      −70855595        70855595 = (35427797 * 2) + 1
53141696        53141696        106283392 / 2 = 53141696
26570848       −26570848        53141696 / 2 = 26570848
13285424       −13285424        26570848 / 2 = 13285424
6642712         −6642712        13285424 / 2 = 6642712
...
```

Parece que algunos números se dividen entre 2, mientras que a otros se les suma
<img src="https://latex.codecogs.com/svg.latex?%5Cinline%20%5Cbg_white%20%5C
%20%282%20*%20n%29%20&plus;%201" class="inline-math" alt="2n + 1">, resultando en la
siguiente regla:

<img src="https://latex.codecogs.com/svg.latex?%5Cbg_white%20f%28n%29%3D%7B%20%5Cbegin%7Bcases%7D%20n/2%20%26%7B%20%5Ctext%7Bif%20%7D%20%7D%20%3F%20%5C%5C%203n&plus;1%20%26%7B%20%5Ctext%7Bif%20%7D%20%7D%20%3F%20%5Cend%7Bcases%7D%20%7://latex.codecogs.com/svg.latex?%5Cbg_white%20f%28n%29%3D%7B%20%5Cbegin%7Bcases%7D%20n/2%20%26%7B%20%5Ctext%7Bif%20%7D%20%7D%20%3F%20%5C%5C%20n&plus;2n&plus;1%20%26%7B%20%5Ctext%7Bif%20%7D%20%7D%20%3F%20%5Cend%7Bcases%7D%20%7D"
title="Deduced formula"
alt="f(n)={
    \begin{cases}
        n/2     %26{ \text{if } } ? \\
        n+2n+1  %26{ \text{if } } ?
    \end{cases}
}"
class="math">

Luego tenemos que determinar cuándo se usa cada una de las fórmulas. Podemos observar que
todos los número impares se multiplican; mientras que los pares se dividen entre dos:

<img src="https://latex.codecogs.com/svg.latex?%5Cbg_white%20f%28n%29%3D%7B%20%5Cbegin%7Bcases%7D%20n/2%20%26%7B%20%5Ctext%7Bif%20%7D%20%7D%20n%20%5Cequiv%200%20%7B%5Cpmod%20%7B2%7D%7D%20%5C%5C%203n&plus;1%20%26%7B%20%5Ctext%7Bif%20%7D%20%7D%20n%20%5Cequiv%201%20%7B%5Cpmod%20%7B2%7D%7D%20%5Cend%7Bcases%7D%20%7D"
alt="f(n)={
    \begin{cases}
        n/2   %26{ \text{if } } n \equiv 0 {\pmod {2}} \\
        3n+1  %26{ \text{if } } n \equiv 1 {\pmod {2}}
    \end{cases}
}"
class="math">

Y esta es exactamente la [conjetura de Collatz](https://es.wikipedia.org/wiki
/Conjetura_de_Collatz). Ahora podemos recuperar el generador de la serie.


Como sabemos que el último dígito del primer número es __7__, el número anterior debe
acabar en __4__ (sabemos eso porque la serie tiene un
[patrón conocido](https://www.reddit.com/r/math/comments/5n1m5h
/i_created_an_arrow_diagram_to_show_how_the_ones/) en las unidades). Por lo tanto,
15745687 es el resultado de dividir este primer un número (que acaba en 4, así que es
par) entre 2, así que podemos calcular el generador:
<img src="https://latex.codecogs.com/svg.latex?%5Cbg_white%2015745687%20%3D%20x%20/%202%20%5Crightarrow%20x%20%3D%2015745687%20*%202%20%5Crightarrow%20x%20%3D%2031491374"
alt="15745687 = x / 2 \rightarrow x = 15745687 * 2 \rightarrow x = 31491374"
class="math">

Para obtener la bandera, sólo tenemos que calcular el sha1sum de este número:
```sh
$ printf "31491374" | sha1sum
1693083796038695739252687f70ddf09991181b  -
```

Nuestra bandera es: `flag{1693083796038695739252687f70ddf09991181b}`.


-----------------------------------------------------------------------------------------


## Tercer reto: Crackme

### Materiales

El binario para ser analizado puede [descargarse aquí](/assets/posts
/2017-08-15-ciberseg-reversing/26890d22b8e912c822df40c825de96c7).

### El reto

Como en el primer reto, empezamos desensamblando el ejecutable con `objdump -d
26890d22b8e912c822df40c825de96c7`. Vemos que hay cuatro funciones importantes:
  - `main ()`: comprueba que todos los argumentos son correctos, luego llama a
	*check_pass()* (en 0x804850f: `test   %eax,%eax`), llama a *one()*.

  - `one ()`: recorre una cadena, haciendo algunos cálculos en cada carácter (le hace
	una xor con algo) e imprime su contenido.

  - `two ()`: hace lo mismo que la función anterior, pero con otros datos.

  - `chek_pass ()`: comprueba la contraseña, que debe tener una longitud mayor que 6
	(en 0x8048611: `cmp    $0x5,%eax`), y parece que devuelve la suma de todos los
	caracteres de la contraseña.

Lo más curioso de todo esto es que la función _two()_ nunca es usada...

No merece la pena intentar sacar la contraseña (incluso aunque lo probáramos... ¿cómo
podemos obtener una cadena de longitud 6 o más cuya suma de sus caracteres sea 0,
teniendo en cuenta que no existen caracteres con valor numérico negativo y 0x00 indica un
fin de cadena?), así que podemos simplemente cambiar el valor de __%eip__ (el _Index
Pointer_, el registro que nos dice qué instrucción viene después) e ir a ejecutar la
función _one()_ para ver qué imprime:
```sh
$ gdb 26890d22b8e912c822df40c825de96c7
GNU gdb (Ubuntu 7.11.1-0ubuntu1~16.5) 7.11.1
Copyright (C) 2016 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
<http://www.gnu.org/software/gdb/documentation/>.
For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from 26890d22b8e912c822df40c825de96c7...(no debugging symbols found)...done.
(gdb) break *0x80484e1
Breakpoint 1 at 0x80484e1
(gdb) r
Starting program: ./26890d22b8e912c822df40c825de96c7

Breakpoint 1, 0x080484e1 in main ()
(gdb) info registers $eip
eip            0x80484e10x80484e1 <main+22>
(gdb) p one
$1 = {<text variable, no debug info>} 0x804859a <one>
(gdb) set $eip=0x804859a
(gdb) info registers $eip
eip            0x804859a0x804859a <one>
(gdb) continue
Continuing.
https://www.youtube.com/watch?v=dQw4w9WgXcQb

Program received signal SIGSEGV, Segmentation fault.
0xf7f9d3dc in ?? () from /lib/i386-linux-gnu/libc.so.6
(gdb)
```

El programa acaba con una violación del segmento (_segfault_); pero no nos importa,
porque tenemos un enlace a Youtube que puede ser la respuesta. Bien, vamos a ver dónde
apunta [https://www.youtube.com/watch?v=dQw4w9WgXcQ](https://www.youtube.com
/watch?v=dQw4w9WgXcQ)...

Oh.

Vaya.

Bien...

Depsués de haber sido rickrolleados, podemos continuar buscando la respuesta.

La otra función interesante (incluso más que la anterior, puesto que nunca es ejecutada)
es _two()_. Vamos a hacer lo mismo que antes y a modificar __%eip__:
```sh
$ gdb 26890d22b8e912c822df40c825de96c7
GNU gdb (Ubuntu 7.11.1-0ubuntu1~16.5) 7.11.1
Copyright (C) 2016 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
<http://www.gnu.org/software/gdb/documentation/>.
For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from 26890d22b8e912c822df40c825de96c7...(no debugging symbols found)...done.
(gdb) break *0x080484e1
Breakpoint 1 at 0x80484e1
(gdb) r
Starting program: ./26890d22b8e912c822df40c825de96c7

Breakpoint 1, 0x080484e1 in main ()
(gdb) info registers $eip
eip            0x80484e10x80484e1 <main+22>
(gdb) p two
$1 = {<text variable, no debug info>} 0x8048537 <two>
(gdb) set $eip=0x8048537
(gdb) info registers $eip
eip            0x80485370x8048537 <two>
(gdb) continue
Continuing.
https://www.youtube.com/watch?v=PmHyI5vFlGob

Program received signal SIGSEGV, Segmentation fault.
0xf7f9d3dc in ?? () from /lib/i386-linux-gnu/libc.so.6
(gdb)
```

De nuevo, el programa acaba con una violación del segmento (_segfault_), pero no nos
importa. Con suerte, el nuevo enlace,
[https://www.youtube.com/watch?v=PmHyI5vFlGob](https://www.youtube.com
/watch?v=PmHyI5vFlGob), no nos llevará a otro meme...

Bien, no lo hizo. El título de este vídeo es la bandera:
`flag{ee1784da5ebc7941f9478e21d36a3e1b}`.


-----------------------------------------------------------------------------------------

## Cuarto reto: Reversing Android

### Materiales

Para este último reto sólo vamos a necesitar [esta apk](/assets/posts
/2017-08-15-ciberseg-reversing/reto.tar.gz).

### El reto

Tras descargar la aplicación de Android, podemos usar un emulador para instalar y
explorarla un poco. Sólo tiene un botón con el texto "calcular flag"; y, una vez
accionado, muestra ek texto "flag calculada".

![Exploración de la app](/assets/posts/2017-08-15-ciberseg-reversing/apk-first-run.png
"Primera ejecución de la app")

Parece que algo pasa por debajo, en el _back-end_, pero no se nos muestra. Ahora es
momento para examinar el código fuente. Podemos usar cualquier servicio online para
decompilar un archivo apk; pero también poemos hacerlo localmente con algunas
herramientas.

Primero, usamos [dex2jar](https://github.com/pxb1988/dex2jar) para convertir el apk, con
sus _.dex_, en un jar, con archivos _.class_. Luego, decompilamos el bytecode usando un
[decompilador de Java](http://jd.benow.ca/), y podemos obtener una clase llamada
__CalculateFlagAction__, donde podemos ver:

![App decompilada](/assets/posts/2017-08-15-ciberseg-reversing/apk-decompiled.png
"CalculateFlagAction vista en el decompilador")

Se ve aquí que la bandera es calculada añadiendo los códigos de los caracteres uno a uno
en un array que luego se formatea como un cadena con la bandera ("flag{...}")

En este punto tenemos dos opciones: podemos cambiar el código para mostrar la bandera en
la app y luego compilarlo de nuevo; o coger sólo la función en la que se calcula la
bandera y compilarla como una aplicación Java que imprima la bandera. Yo usé esta última
que pensé que era más rápida y sencilla.

Hay un par de caracteres extraños, así que es mejor guardar el archivo decompilado
(desde el menú del decompilador) y luego modificarlo que copiarlo a mano. Después de
todos los cambios apropiados, podemos imprimir la bandera:

__NOTA: como los caracteres extraños dan problemas a la hora de interpretar el XML (para
el feed RSS), han sido eliminados del texto (en particular, el carácter `0x1f`)__ 

```sh
$ javac Flag.java
$ java Flag
flag{693f'$da %d""d"ac#"#'a"ce333 3##$}
$ java Flag | xxd
00000000: 666c 6167 7b36 3933 6627 2464 6120 2564  flag{693f'$da %d
00000010: 2222 6422 6163 2322 2327 6122 6365 3333  ""d"ac#"#'a"ce33
00000020: 3320 3323 1f23 247d 0a                   3 3#.#$}.
```

Por lo tanto, la bandera es `flag{693f'$da %d""d"ac#"#'a"ce333 3##$}` (se ha eliminado
el carácter problemático, `0x1f`).
