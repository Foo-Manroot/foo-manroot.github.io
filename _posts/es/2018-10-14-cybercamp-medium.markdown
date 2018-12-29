---
layout: post
title:  "Write-ups del Cybercamp 2018: medium"
date:	2018-10-14 16:21:34 +0200
author: foo
categories: es ctf cybercamp write-up
lang: es
ref: cybercamp-medium
---

Cada año, el [INCIBE](https://www.incibe.es/) (una agencia española que se encarga de
concienciar sobre temas de ciberseguridad) organiza la [CyberCamp](cybercamp.es).

Estos son los _write-ups_ de los clasificatorios del CTF, que fueron hace ya un par de
semanas. Como los resultados ya se han anunciado[^1] y [han dicho que podemos subir
nuestros _write-ups_](https://twitter.com/CybercampEs/status/1048129712491569152), estoy
escribiendo aquí mis soluciones para los retos que resolví. Los materiales para los de
este _post_ se pueden descargar aquí:

  - [Reto 5](/assets/posts/2018-10-14-cybercamp-medium/5_Medium.7z)
  - [Reto 6](/assets/posts/2018-10-14-cybercamp-medium/6_Medium.7z)
  - [Reto 7](/assets/posts/2018-10-14-cybercamp-medium/7_Medium.7z)
  - [Reto 8](/assets/posts/2018-10-14-cybercamp-medium/8_Medium.7z)
  - [Reto 9](/assets/posts/2018-10-14-cybercamp-medium/9_Medium.7z)
  - El reto 10 era demasiado grande, así que está dividido:
	- [Parte 1](/assets/posts/2018-10-14-cybercamp-medium/10_Medium.7z.001)
	- [Parte 2](/assets/posts/2018-10-14-cybercamp-medium/10_Medium.7z.002)
	- [Parte 3](/assets/posts/2018-10-14-cybercamp-medium/10_Medium.7z.003)
	- [Parte 4](/assets/posts/2018-10-14-cybercamp-medium/10_Medium.7z.004)
  - [Reto 11](/assets/posts/2018-10-14-cybercamp-medium/11_Medium.7z)


En este artículo explicaré mis respuestas para los retos etiquetados como _medium_.

-----------------------------------------------------------------------------------------


## 5.- Cosas del Wi-Fi

La descripción de este reto dice así:
```
Se ha realizado la monitorización de tráfico wireless de una de las redes de tu
organización. Se tiene la sospecha de que uno de los usuarios se está logueando contra
una web que está realizando phishing y suplantando la legítima. Tu objetivo es recuperar
las credenciales, la FLAG será la contraseña que utiliza el usuario para loguear.
```

Bien, abramos con Wireshark el `.pcap` que nos dan y veamos lo que hay dentro...
{% include image.html
	src="/assets/posts/2018-10-14-cybercamp-medium/01.- Wireshark first recon.jpg"
	title="Primera vez que abrimos el archivo"
	alt="Al abrir el archivo por primera vez, vemos muchos paquetes 802.11 (Wi-Fi) sin descifrar."
%}

Perfecto, no hay problema. Estamos en la categoría _medium_. ¿Pensabas que que iba a ser
tan sencillo como abrir el archivo y buscar _HTTP_? Ya, yo también pensaba eso :( Pero no
hay que preocuparse, que somos l33t hax0rs y sabemos crackear el Wi-Fi, ¿verdad?

Hay muchas herramientas diferentes para sacar la contraseña de un punto de acceso (AP,
_Access Point_); pero ahora vamos a usar una de las más populares: `aircrack-ng`.
Normalmente tenemos que descubrir el BSSID del AP para calcular las claves; pero
_aircrack-ng_ ya nos muestra un mensaje al abrir el archivo que nos permite seleccionar
el AP que queremos usar y realiza todos los cálculos necesarios.

Para una primera prueba, podemos usar alguno de los diccionarios que vienen por defecto
en la mayoría de sistemas de tipo Unix, `/usr/share/dict/words`, que contiene una pequeña
lista de palabras en inglés que se comprueba de manera muy rápida:
```sh
$ aircrack-ng medium_5.cap -w /usr/share/dict/words

(...)

Passphrase not in dictionary

Quitting aircrack-ng...
```

Rayos... Vamos a usar un diccionario más potente y grande (pero más lento, también):
el archifamoso _rockyou_. En lugar de pasar un buen rato intentando buscarlo por
Internet, yo suelo usar el
[repositorio en Github de SecLists](https://github.com/danielmiessler/SecLists), que
contiene una cantidad enorme de diccionarios, reglas para _fuzzing_, nombres de usuario
comunes... Tengo el repositorio clonado en mi ordenador[^2] poder actualizarlo cuando lo
necesite.



Probemos ahora con este nuevo diccionario:
```sh
$ aircrack-ng medium_5.cap -w /usr/share/dict/seclists/Passwords/rockyou.txt
Opening medium_5.cap
Read 3166 packets.

   #  BSSID              ESSID                     Encryption

   1  D4:63:FE:C1:09:91  ECORP                     WPA (1 handshake)

Choosing first network as target.

Opening medium_5.cap
Reading packets, please wait...

                                 Aircrack-ng 1.2 beta3


                   [00:03:34] 870344 keys tested (3616.36 k/s)


                           KEY FOUND! [ iw4108604 ]
(...)
```

¡Genial! Tras unos 10 minutos obtenemos la clave: `iw4108604`. Ahora toca descifrar el
archivo con la captura. De nuevo, podemos hacerlo de varias formas (por ejemplo, es muy
fácil hacerlo en Wireshark). En este caso, voy a usar otra de las herramientas de la
suite _aircrack-ng_:  `airdecap-ng`.
```sh
$ airdecap-ng -p "iw4108604" -b "D4:63:FE:C1:09:91" -e "ECORP" medium_5.cap
Total number of packets read          3166
Total number of WEP data packets         0
Total number of WPA data packets      1466
Number of plaintext data packets         0
Number of decrypted WEP  packets         0
Number of corrupted WEP  packets         0
Number of decrypted WPA  packets       328
```

Ahora es tan fácil como abrir el archivo `medi_5-dec.pcap` y buscar el tráfico HTTP
sospechoso... o quizá no. Si usamos el filtro de visualización `HTTP` en Wireshark, sólo
vemos un mensaje que parece ser una prueba de conexión, pero no parece que haya nada
raro. Tendremos que seguir buscando.

Por suerte este archivo es pequeño, pero con otras capturas más grandes no sería posible
buscar entre _todos_ los paquetes. Así que necesitamos usar filtros y otras herramientas
que nos permite usar Wireshark. Una cosa que se puede buscar, por ejemplo, son paquetes
anormalmente grandes, basándose en el protocolo que usan. Por ejemplo, si ordenamos los
paquetes de más a menos pesado, vemos un paquete de _ping_ ICMP con 605 Bytes y
_ninguna respuesta_:

{% include image.html
	src="/assets/posts/2018-10-14-cybercamp-medium/01.2- Wireshark large ICMP.jpg"
	title="Inspeccionando el paquete ICMP anormalmente grande"
	alt="Mientras inspeccionamos la captura descifrada, podemos ver un paquete ICMP inusualmente grande. Al inspeccionarlo, se ve que dentro hay HTML."
%}

Los datos de este paquete sospechoso parecen ser una petición HTTP. Al copiar los valores
nos devuelve los datos capturados por el atacante (recordad que nuestro objetivo es
recuperar las credenciales robadas):
```http
POST /login.a4p HTTP/1.1

Host: 10.0.1.1
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Referer: http://10.0.1.1/
Connection: close
Upgrade-Insecure-Requests: 1
Content-Type: application/x-www-form-urlencoded
Pragma: no-cache
Cache-Control: no-cache
Content-Length: 100



f_Login_Name=john&f_Login_Password=qwertyFpass1234&bt_Login=Submit&Login_Page=%2FLogin_Santander.a4d
```

Parece que la página de _phishing_ se estaba intentando hacer pasar por el
_Banco Santander_, y el usuario _john_ cayó en la trapa y puso su contraseña (la _flag_):
_qwertyFpass1234_.


Como nota aparte, podríamos haber completado este reto de una forma un poco más rápida
(una vez tenemos los paquetes descifrados):
```sh
$ strings ../medium_5-dec.cap | grep -i pass
              <label class="lb02" for="password">Password
                <input class="it02" id="password" type="password" name="f_Login_Password" value="">
f_Login_Name=john&f_Login_Password=qwertyFpass1234&bt_Login=Submit&Login_Page=%2FLogin_Santander.a4dmc3[</label>
```
Y a otra cosa XD

La _flag_ es `qwertyFpass1234`.


-----------------------------------------------------------------------------------------


## 6.- Redundancia innecesaria


La descripción de este reto dice así:
```
Nuestros expertos han capturado un pendrive que contenía estos dos ficheros, pero parece
que uno de ellos ha sufrido daños... (Respuesta: flag{X})
```

Los dos archivos que se nos dan son `secret.txt`, que sólo contiene datos binarios, y
`key.pem`. Parece que este segundo archivo es la clave privada que hace falta para
descifrar el otro. Sin embargo, la clave privada no está completa :(
```sh
$ cat key.pem
-----BEGIN RSA PRIVATE KEY-----
MIIBOwIBAAJBAMSwf+/I42wFwNpDQiGuv0fb9w5Ria2JJAjzrYEYKp4HAKB8nXxm
yGx6OWAhI+4PYFYT3pf95J/mg5buCvP19fMCAwEAAQJAKuxRnyR57PL8eSVAY1Vd
TPNF4QwOPZ62DHYRISEC++UtRemqE1eBPkRgswiJ91+r9y8EnVw/SvL4GYQmeovS
sQIhAOq8Heinxe4udriNOd35SgJV9e87YglCCIfCoAirR0qtAiEA1oIMcKaiRiUj
2S/Q4YFTNySdT+fH16huoSQrEapD9x8*********************************
****************************************************************
********************************************
-----END RSA PRIVATE KEY-----
```

Antes de continuar con el reto, tenemos que aprender un par de cosas sobre el formato
usado para almacenar la información de la clave privada, porque esta es la clave (he he)
para solucionar el problema.

Hay dos formatos para almacenar claves privadas: **PEM** y **DER**. De hecho, sólo es un
formato; porque el _PEM_ es sólo los codificar los datos del _DER_ un base64 y añadirle
una cabecera y un pie.
Así pues, sólo tenemos que entender cómo funciona la codificación _DER_[^3]


Como ya sabemos, una clave privada de RSA se compone (en teoría) de un **módulo** y de un
**exponente privado**. Sin embargo, en la práctica, la clave privada tiene otros
parámetros que se usan para agilizar las operaciones. En el
[RFC 3447](https://tools.ietf.org/html/rfc3447#appendix-A.1.2) se especifica que una
clave privada debería tener los siguientes campos (codificados en ASN.1):
```asn1
RSAPrivateKey ::= SEQUENCE {
  version           Version,
  modulus           INTEGER,  -- n
  publicExponent    INTEGER,  -- e
  privateExponent   INTEGER,  -- d
  prime1            INTEGER,  -- p
  prime2            INTEGER,  -- q
  exponent1         INTEGER,  -- d mod (p-1)
  exponent2         INTEGER,  -- d mod (q-1)
  coefficient       INTEGER,  -- (inverse of q) mod p
  otherPrimeInfos   OtherPrimeInfos OPTIONAL
}
```

Como se ve, hay algunos parámetros redundantes (en realidad sólo necesitamos `n` y `e`).
De esta forma, puede que en nuestra clave privada corrupta haya suficiente información
como para descifrar el archivo.

Empecemos por crear un archivo, `partial_key.der`, con lo que conocemos de nuestra clave:
```sh
$ base64 -d > partial_key.der
MIIBOwIBAAJBAMSwf+/I42wFwNpDQiGuv0fb9w5Ria2JJAjzrYEYKp4HAKB8nXxm
yGx6OWAhI+4PYFYT3pf95J/mg5buCvP19fMCAwEAAQJAKuxRnyR57PL8eSVAY1Vd
TPNF4QwOPZ62DHYRISEC++UtRemqE1eBPkRgswiJ91+r9y8EnVw/SvL4GYQmeovS
sQIhAOq8Heinxe4udriNOd35SgJV9e87YglCCIfCoAirR0qtAiEA1oIMcKaiRiUj
2S/Q4YFTNySdT+fH16huoSQrEapD9x8
base64: invalid input
```

El decodificador se queja de `invalid input` porque el último bloque de base64 no está
completo y no puede usarse para recuperar el último Byte de información. Sin embargo, eso
nos da igual ahora mismo.

El siguiente paso es interpretar los Bytes con el formato ASN.1 descrito. Para ello,
podemos hacerlo a mano (para ser sinceros, preferiría no hacerlo), o usando alguna de las
bibliotecas que tenemos disponibles. Por ejemplo, yo he elegido la biblioteca de Python
[pyasn1](http://snmplabs.com/pyasn1/). La herramienta
[pyasn1gen](https://github.com/kimgr/asn1ate) también es bastante útil para automatizar
el proceso lo más posible.

Estos son los pasos para obtener la información:

### Crear la definición de la clave en ASN.1 y guardarla en el archivo `pkcs1.asn`

Partimos de la definición original, la del RFC:
```sh
$ cat -> pkcs1.asn
PKCS-1 {iso(1) member(2) us(840) rsadsi(113549) pkcs(1) pkcs-1(1) modules(0) pkcs-1(1)}

DEFINITIONS EXPLICIT TAGS ::= BEGIN
    RSAPrivateKey ::= SEQUENCE {
         version Version,
         modulus INTEGER,
         publicExponent INTEGER,
         privateExponent INTEGER,
         prime1 INTEGER,
         prime2 INTEGER,
         exponent1 INTEGER,
         exponent2 INTEGER,
         coefficient INTEGER
    }
    Version ::= INTEGER
END
```

### Traducirlo a Python

```python
$ ./asn1ate-master/asn1ate/pyasn1gen.py pkcs1.asn
# Auto-generated by asn1ate v.0.6.1.dev0 from pkcs-1.asn
# (last modified on 2018-10-21 16:00:07.678764)

from pyasn1.type import univ, char, namedtype, namedval, tag, constraint, useful


class Version(univ.Integer):
    pass


class RSAPrivateKey(univ.Sequence):
    pass


RSAPrivateKey.componentType = namedtype.NamedTypes(
    namedtype.NamedType('version', Version()),
    namedtype.NamedType('modulus', univ.Integer()),
    namedtype.NamedType('publicExponent', univ.Integer()),
    namedtype.NamedType('privateExponent', univ.Integer()),
    namedtype.NamedType('prime1', univ.Integer()),
    namedtype.NamedType('prime2', univ.Integer()),
    namedtype.NamedType('exponent1', univ.Integer()),
    namedtype.NamedType('exponent2', univ.Integer()),
    namedtype.NamedType('coefficient', univ.Integer())
)
```

### Cargar la clase `RSAPrivateKey` en el intérprete e intentar decodificarlo

Primero necesitamos un par de _imports_ y leer algunos datos antes de intentar
decodificar el archivo:
```python
>>> data = open ("partial_key.der", "rb").read ()
>>> from pyasn1.codec.der.decoder import decode as der_decoder
>>> from pkcs1 import RSAPrivateKey
```

Ahora podemos intentar decodificar:
```
>>> pk, rest = der_decoder (data, asn1spec = RSAPrivateKey ())
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/usr/local/lib/python3.5/dist-packages/pyasn1/codec/ber/decoder.py", line 1182, in __call__
    raise error.SubstrateUnderrunError('%d-octet short' % (length - len(substrate)))
pyasn1.error.SubstrateUnderrunError: 104-octet short
```

No esperaba este error (`104-octet short`); pero supuse que tiene algo que ver con la
manera de funcionar de ASN.1: al principio de cada campo indicamos su tipo (INTEGER,
SEQ...). Luego ponemos su longitud ( **en octetos** ), y luego empezamos con el valor del
objeto codificado. El mensaje `104-octet short` nos dice que el objeto necesita tener 104
octetos más de los que le estamos pasando. Para resolver esto podríamos analizar
cuidadosamente `partial_key.der` para modificar la longitud y decodificarlo con éxito (en
cuyo caso casi mejor nos hubiera valido decodificar a mano desde el principio)... O
podríamos añadir 104 octetos más de basura. Por supuesto, decidí hacerlo por este segundo
método :D
```sh
$ cp partial_key.der partial_key_append.der
$ cat /dev/zero | fold -w 140 | head -n 1 | tr -d '\n' >> partial_key_append.der
```

Podemos continuar con nuestros esfuerzos.

Tras intentarlo sin suerte durante bastante tiempo (la biblioteca seguía lanzando
errores), casi doy mi brazo a torcer... Hasta que me di cuenta de que aún no había
intentado usar `asn1parse` de OpenSSL. Con la clave original devolvía el mismo error que
_pyasn1_ (`ASN1_get_object:too long`). Sin embargo, con la nueva clave con los ceros
añadidos al final, podemos decodificar sin problema:
```sh
$ openssl asn1parse -inform der -in partial_key_append.der
    0:d=0  hl=4 l= 315 cons: SEQUENCE
    4:d=1  hl=2 l=   1 prim: INTEGER           :00
    7:d=1  hl=2 l=  65 prim: INTEGER           :C4B07FEFC8E36C05C0DA434221AEBF47DBF70E5189AD892408F3AD81182A9E0700A07C9D7C66C86C7A39602123EE0F605613DE97FDE49FE68396EE0AF3F5F5F3
   74:d=1  hl=2 l=   3 prim: INTEGER           :010001
   79:d=1  hl=2 l=  64 prim: INTEGER           :2AEC519F2479ECF2FC79254063555D4CF345E10C0E3D9EB60C7611212102FBE52D45E9AA1357813E4460B30889F75FABF72F049D5C3F4AF2F81984267A8BD2B1
  145:d=1  hl=2 l=  33 prim: INTEGER           :EABC1DE8A7C5EE2E76B88D39DDF94A0255F5EF3B6209420887C2A008AB474AAD
  180:d=1  hl=2 l=  33 prim: INTEGER           :D6820C70A6A2462523D92FD0E1815337249D4FE7C7D7A86EA1242B11AA43F71F
  215:d=1  hl=2 l=   0 prim: EOC
  217:d=1  hl=2 l=   0 prim: EOC
(...)
  317:d=1  hl=2 l=   0 prim: EOC
  319:d=0  hl=2 l=   0 prim: EOC
```

Obviamente, el intérprete sólo nos va mostrando los objetos que se va encontrando; pero
sabemos qué registros se están leyendo:
  - Primero va la **SEQUENCE** _RSAPrivateKey_
  - Luego, viene un _INTEGER_: **version** (`0x00`)
  - El primer dato dentro de la _SEQUENCE_ es un _INTEGER_: **modulus** (`0xC4B0...F5F3`)
  - El segundo dato es otro _INTEGER_: **publicExponent** (`0x010001`)
  - Por último, viene **privateExponent** (`0x2AEC...D2B1`).

Con esta información ya podemos descifrar el mensaje; pero vamos a ver qué mas datos hay
en la clave:
  - **prime1** (_p_): `0xEABC...4AAD`
  - **prime2** (_q_): `0xD682...F71F`


Podemos comprobar que <img src="https://latex.codecogs.com/svg.latex?\fn_cm p * q %3D n"
class="inline-math" alt="p * q = n"> y verificar que tenemos los datos correctos.

Para descifrar el mensaje original, podemos usar Python de nuevo y crear una clave
privada para descifrar usando OpenSSL[^4]. Para ello, vamos a usar la clase
`Crypto.PublicKey.RSA`, disponible en la biblioteca estándar:
```python
>>> # First, we load the data
>>> mod = 0xC4B07FEFC8E36C05C0DA434221AEBF47DBF70E5189AD892408F3AD81182A9E0700A07C9D7C66C86C7A39602123EE0F605613DE97FDE49FE68396EE0AF3F5F5F3
>>> pub_exp = 0x65537
>>> pub_exp = 0x010001
>>> priv_exp = 0x2AEC519F2479ECF2FC79254063555D4CF345E10C0E3D9EB60C7611212102FBE52D45E9AA1357813E4460B30889F75FABF72F049D5C3F4AF2F81984267A8BD2B1
>>> prime_1 = 0xEABC1DE8A7C5EE2E76B88D39DDF94A0255F5EF3B6209420887C2A008AB474AAD
>>> prime_2 = 0xD6820C70A6A2462523D92FD0E1815337249D4FE7C7D7A86EA1242B11AA43F71F
>>>
>>>
>>> # Then, we create the private key with the previous data
>>> from Crypto.PublicKey import RSA
>>> rsa_private = RSA.construct ((mod, pub_exp, priv_exp, prime_1, prime_2))
>>>
>>> # Finnally, we store the private key to decrypt with OpenSSL
>>> open ("key_NEW.pem", "wb").write (rsa_private.exportKey (format = "PEM", pkcs = 8))
521
```

Para descifrar el archivo, podemos usar nuestra nueva clave privada con OpenSSL:
```sh
$ openssl rsautl -inkey key_NEW.pem -in secret.txt -decrypt
flag{gk83h280fwlo2}
```

Resulta que perdí mucho tiempo intentando usar _pyasn1_ cuando en realidad podría haber
usado _openssl_ sin problema...

Después de todos esos callejones sin salida y pensar demasiado, obtenemos nuestra _flag_:
`flag{gk83h280fwlo2}`


-----------------------------------------------------------------------------------------

**ACTUALIZACIÓN**: Ya está disponible la
[segunda parte](/post/es/ctf/cybercamp/write-up/2018/12/26/cybercamp-medium-2.html) con
el resto de los retos.

-----------------------------------------------------------------------------------------

[^1]: Desgraciadamente, sólo saqué unos 2900-3000 puntos; mientras que el corte se hizo
    alrededor de los 3100 puntos... :(

[^2]: Es muy útil [clonar parcialmente un repo](https://stackoverflow.com/a/28039894),
     en lugar de descargarse cientos de archivos que puede que nunca vayas a usar.

[^3]: Esta es sólo una explicación rápida. Si quieres más información, puedes visitar
    [esta página](https://tls.mbed.org/kb/cryptography/asn1-key-structures-in-der-and-pem),
    (en inglés) o simplemente leer la entrada de la Wikipedia y tirar del hilo.

[^4]: Técnicamente podríamos usar Python, usando `pow (msg, priv_exp, mod)` o
        `RSA.decrypt ()`; pero, por alguna razón, no para de sacar basura. Supongo que
	OpenSSL añade algo al archivo y por eso no podemos descifrarlo...
