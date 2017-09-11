---
layout: post
title:  "Write-ups del Ciberseg '17: cripto"
date:	2017-08-11 21:10:15 +0200
author: foo
categories: es ctf ciberseg write-up crypto
lang: es
ref: ciberseg-crypto
---


Estos son los retos de criptografía que formaron parte del
[CTF](https://ciberseg.uah.es/ctf.html) organizado en el
[Ciberseg 2017](https://ciberseg.uah.es), un congreso sobre ciberseguridad que tiene
lugar cada año en nuestra universidad.

El año pasado fue la primera edición (y espero que haya más, pues fue bastante divertido)
del CTF (y yo gané el primer premio :D).

## Primer reto

Este era un reto sencillo de resolver, si averiguamos cuál es el método usado; pero era
bastante complicado darse cuenta del método de cifrado.

El criptograma es `MzkuM3gyLKA5K2AlrKO0ZS99`.

A pesar de que puede resultar difícil verlo, ya que no hay relleno (el símbolo '=' del
final), porque los bytes del mensaje original están alineados, el alfabeto usado hace
pensar que es base 64. Al decodificar la cadena, sin embargo, sólo sale basura:
```sh
$ echo "MzkuM3gyLKA5K2AlrKO0ZS99" | base64 -d | xxd
00000000: 3339 2e33 7832 2ca0 392b 6025 aca3 b465  39.3x2,.9+`%...e
00000010: 2f7d                                     /}
```

Para el segundo intento, se puede pensar que puede estar cifrado con algún método simple,
como alguna transposición o una substitución monoalfabética, como el cifrado César. De
hecho, ROT13 (un caso especial del César, con un desplazamiento de 13), parece un buen
candidato.

Para descifrarlo usando ROT13, se puede usar cualquier servicio en internet (incluso con
[duckduckgo](https://duckduckgo.com/html?q=rot13%20MzkuM3gyLKA5K2AlrKO0ZS99), que
responde directamente a la búsqueda 'rot13 MzkuM3gyLKA5K2AlrKO0ZS99') o implementarlo
por cuenta propia.

La cadena descifrada es `ZmxhZ3tlYXN5X2NyeXB0MF99`.

Ahora, decodificando la cadena obtenemos la bandera:
```sh
$ echo "ZmxhZ3tlYXN5X2NyeXB0MF99" | base64 -d | xxd
00000000: 666c 6167 7b65 6173 795f 6372 7970 7430  flag{easy_crypt0
00000010: 5f7d                                     _}
```

Finalmente, la bandera es `flag{easy_crypt0_}`.


-----------------------------------------------------------------------------------------


## Segundo reto

El segundo reto es el siguiente texto cifrado:
```
Pivfwrrk hl tairrvr cvkdr vk xnr lhceafa uw fiwjddf ernfsofrthtzud, ec ulfisgo uw
yixwqeiw hs ggoirdiaswwitg. Hs dmb ielhrvkdnkw dpiwqdvj hskg soiixe, rmqqlw hn cs
dckmdlzvdd eg ve lkh, nfk puvkwrr vh dffge mwqidgv. Lr xoax wv: fcsj{mvyxsksqlfkftw}
H.G. Sv vlcv ulfisu, nf wqciastrj.
```

Claramente, el trozo con la cadena 'fcsj{mvyxsksglfkftw}' se corresponde con el texto
plano 'flag{...}'. Además, parece que está cifrado con algún cifrado de sustitución
polialfabético (esto lo sabemos porque las frecuencias de las letras difieren de las
esperadas en un texto plano). Otra información importante es que el texto puede estar en
castellano.


Con todo esto, podemos intentar ver si el método de cifrado es la muy popular cifra
de Vigenère. Con esto en mente, podemos intentar sacar la clave (o, al menos, revelar
una porción de ésta) con el cacho de texto plano conocido.

<pre>
texto plano   =>  f l a g
texto cifrado =>  f c s j
----------------------
clave         =>  a r s d
</pre>

La parte filtrada de la clave parece ser "ARSD"

Una cosa importante a tener en cuenta es que el nombre de una de las entidades
organizadoras es "DARS", así que puede ser posible que la clave sea "DARS". En efecto,
descifrando con esta clave obtenemos el siguiente mensaje:
```
Mientras el cifrado cesar es una tecnica de cifrado monoalfabetica, el cifrado de
vigenere es polialfabetico. Es muy interesante aprender esto porque, aunque en la
actualidad no se use, nos muestra de donde venimos. La flag es: flag{megustanlosctf}
P.D. se dice cifrar, no encriptar.
```

La bandera es `flag{megustanlosctf}`


-----------------------------------------------------------------------------------------


## Tercer reto

En este último reto se nos dan tres cadenas:
```
a522c8bf85a95c066bb2a8a85309c5c431652342
1e230c2310c38677c2d1f9bf358539616f2fd89a
c2b7df6201fdd3362399091f0a29550df3505b6a
```

Puesto que las tres tienen la misma longitud y están en forma headecimal, parece que
pueden ser hashes; y, conforme a la longitud (20 Bytes), el algoritmo usado puede ser
SHA-1.

Usando cualquier base de datos online, como [crackstation](https://crackstation.net/),
podemos encontrar la partes primera y última de la bandera:

{% include image.html
	src="/assets/posts/2017-08-11-ciberseg-crypto/crackstation.png"
	title="Resultado obtenido con CrackStation"
	alt="Resultado de CrackStation"
%}

Desafortunadamente, la parte del medio de la bandera no ha sido encontrada. Sin embargo,
podemos usar la pista que nos dan, diciendo que es como una contraseña de la
[UAH](https://www.uah.es) (para quienes no lo sepan, el formato es
`[a-z]{3}[[:punct:]][0-9]{4}`). Eso hace la tarea más sencilla. Después de un par de
minutos tenemos la respuesta:

{% include image.html
	src="/assets/posts/2017-08-11-ciberseg-crypto/cracked-hash.png"
	title="Resultado obtenido con HashCat"
	alt="Resultado de HashCat"
%}

La bandera es `flag{uah#5674}`
