---
layout: post
title:  "Write-ups del Cybercamp 2018: Medium (parte 2)"
date:	2018-12-26 20:32:53 +0100
author: foo
categories: es ctf cybercamp write-up
lang: es
ref: cybercamp-medium-2
---

En el [post anterior](/post/es/ctf/cybercamp/write-up/2018/10/14/cybercamp-medium.html)
sólo incluí los retos 5 y 6. Como ya ha pasado mucho tiempo, he decidido escribir una
segunda parte con el resto de los retos _medium_

-----------------------------------------------------------------------------------------

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


## 7.- Vacaciones

La descripción de este reto dice así:
```
Por orden de un juez, se ha intervenido un equipo en casa de un sospechoso
ciberdelincuente, por suerte su portátil aún se encontraba encendido cuando se produjo la
detención. Se sabe que ha intentado eliminar pruebas, pero creemos que aún es posible
obtener alguna. ¿Cuál era su nick en la red? (Respuesta: flag{NICK}).
```

Se nos dan dos archivos:
	- `dump.elf`: un ejecutable (ELF) de 64-bit
	- `volume.bin`: una imagen de un disco


Vamos a empezar montando la imagen del disco para ver si podemos encontrar algo. Lo
primero que debemos hacer al montar una imagen es buscar el desplazamiento necesario
de la partición que queremos explorar. Para esto, `fdisk -l` viene muy útil:
```sh
$ fdisk -l volume.bin
Disk volume.bin: 64 MiB, 67108864 bytes, 131072 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x00000000

Device      Boot Start   End Sectors  Size Id Type
volume.bin1         63 16064   16002  7.8M 83 Linux
```


Hay que tener en cuenta el valor de _start_ y **multiplicarlo por 512**, porque ese es el
tamaño de un sector y `mount` espera _Bytes_, no _sectores_; así que para montar la
imagen habrá que usar la siguiente orden:
```sh
$ sudo mount -o offset=32256 volume.bin mnt/
mount: ./mnt: unknown filesystem type 'crypto_LUKS'.
```

Oh, vaya... Parece que no va a ser tan fácil :( El volumen está cifrado con LUKS. Para
montarlo vamos a tener que averiguar la contraseña o sacarla de algún lado.

Vamos a echarle un vistazo al otro archivo, `dump.elf`.


A primera vista, parece un ejecutable de 64-bit normal. Tiene las cabeceras correctas
para engañar a `file`. Sin embargo, si miramos más de cerca, podemos ver que contiene
muchas cosas, empezando por un ejecutable de 64-bit. Por ejemplo, con
[binwalk](https://github.com/ReFirmLabs/binwalk) extraemos _muchísimas_ cosas:
```
DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             ELF, 64-bit LSB core file AMD x86-64, version 1 (SYSV)
48047         0xBBAF          Copyright string: "Copyright (C) 1994-2015 H. Peter Anvin et al"
935207        0xE4527         Copyright string: "Copyright (C) 1997-2000 Intel Corporation"
935250        0xE4552         Copyright string: "Copyright (C) 2010-2017 Oracle Corporation"
1058104       0x102538        gzip compressed data, maximum compression, from Unix, NULL date (1970-01-01 00:00:00)
7094968       0x6C42B8        gzip compressed data, maximum compression, from Unix, NULL date (1970-01-01 00:00:00)
21275960      0x144A538       gzip compressed data, maximum compression, from Unix, NULL date (1970-01-01 00:00:00)
24771468      0x179FB8C       ELF, 32-bit LSB executable, Intel 80386, version 1 (SYSV)
87520568      0x5377538       Linux kernel version "4.14.52-0-virt (buildozer@build-3-8-x86) (gcc version 6.4.0 (Alpine 6.4.0)) #1-Alpine SMP Tue Jun 26 07:14:31 UTC 2018"
87654648      0x53980F8       CRC32 polynomial table, little endian
88712398      0x549A4CE       Unix path: /home/buildozer/aports/main/linux-vanilla/src/linux-4.14/init/main.c
(...)
```
Parece que es algún tipo de volcado. ¿Quizá sea de la memoria, donde pueden estar las
claves para descifrar el disco? Vamos a usar
[findaes](https://sourceforge.net/projects/findaes/) para buscar claves de AES (LUKS
normalmente usa AES):
```sh
$ ./findaes ../../dump.elf
Searching ../../dump.elf
Found AES-256 key schedule at offset 0xe414ce8:
0a b4 d6 ef 72 82 6b c6 03 a8 89 9f 32 5b b6 7e 9b 32 41 77 1c fd 03 30 56 9a ce ab 16 f2 51 bd
Found AES-128 key schedule at offset 0xe4158f8:
84 bc d9 8c fc f2 de db 26 06 35 bf ca a9 a4 7d
```

_Et voilà_, tenemos dos posibles candidatos. Tendremos que esperar un poco para saber
cuál tendremos que usar.

Como la herramienta para descifrar la partición espera que la imagen sea un dispositivo
(un archivo de tipo _device_) y en el reto nos han dado un archivo regular, tenemos que
realizar una conversión primero. En los sistemas de tipo Unix todo es un archivo, y los
dispositivos (discos, teclados, micrófonos...) no son una excepción. Sin embargo, hay
diferentes tipos de archivos (tuberías, archivos regulares, sockets...). Para convertir
un archivo _regular_ en un _dispositivo_ usamos el _dispositivo loop_, usando la
herramienta `losetup`. Tras ejecutar `sudo losetup /dev/loop0 volume.bin -o 32256` (hay
que recordar que queremos descifrar la partición que empieza en el sector 64) podemos
seguir trabajando con `/dev/loop0`.

Ahora que tenemos lista la partición, podemos usar la herramienta `cryptsetup` para
obtener más información sobre la clave que deberíamos usar:
```sh
$ sudo cryptsetup luksDump /dev/loop0
LUKS header information for /dev/loop0

Version:        1
Cipher name:    aes
Cipher mode:    cbc-essiv:sha256
Hash spec:      sha256
Payload offset: 2048
MK bits:        128
(...)
```

Así que es AES-128. Bien, usemos la clave que hemos sacado antes:
```sh
$ printf "84 bc d9 8c fc f2 de db 26 06 35 bf ca a9 a4 7d" | tr -d ' ' | xxd -r -ps > key_file
$ sudo cryptsetup open /dev/loop0 cybercamp-7-decrypted --master-key-file key_file
$ sudo mount /dev/mapper/cybercamp-7-decrypted mnt/
$ ls -a mnt/
.  ..
```

Rayos, esto es un poco incómodo... Estaba esperando sacar algo de aquí, pero está vacío.
¿O quizá no?

Hmmmm...

Sabemos que el criminal intentó borrar algunas pruebas, así que puede que borrara el
contenido del disco pero en realidad sigan ahí. Si los archivos no han sido sobrescritos,
puede que aún sean recuperables. Hay muchas herramientas para recuperar archivos
"borrados". Una de ellas es [scalpel](ihttps://github.com/sleuthkit/scalpel). Una vez
ha terminado su trabajo, nos deja con un _.zip_ que parece estar cifrado, porque `file`
devuelve `Zip archive data, at least v1.0 to extract`.

Como siempre, tenemos muchas formas de recuperar la contraseña; pero yo voy a usar John
The Ripper debido a la multitud de herramientas disponibles para convertir de cualquier
formato al que usa JTR. En este caso, usamos `zip2john` para obtener el _hash_ y luego
ejecutamos `john <archivo_hash>`. En un par de segundos extrae la contraseña: `iloveyou`.

Luego extraemos el archivo comprimido (con `7z`, ya que `unzip` no sabe manejar los
archivos con contraseña) y vemos el contenido del archivo que estaba comprimido:
```sh
$ cat secret.txt
_z3r0.c00l!_ was here! :)
```

Pues ya hemos recuperado el nick, buen trabajo.
La _flag_ es `flag{z3r0.c00l!}`

-----------------------------------------------------------------------------------------

## 8.- Oh, my GOd!


La descripción de este reto dice así:
```
Se ha interceptado un código en la conversación entre dos delincuentes cuyo
funcionamiento tendrás que averiguar para llegar a la FLAG.
```

Este reto es bastante más sencillo que el resto de los de este nivel, y sólo involucra
un archivo de bytecode de Python, `medium_8.pyc`.

Podemos intentar importarlo en el intérprete de Python; pero no es aconsejable ejecutar
sin más cualquier código sin antes inspeccionarlo, especialmente en un CTF donde lo más
probable es que haya que hacerlo igualmente...

Para decompilar el bytecode de Python[^2] usé [pycdc](https://github.com/zrax/pycdc), que
es sencillo de usar y funciona bastante bien:
```python
$ pycdc medium_8.pyc
# Source Generated with Decompyle++
# File: medium_8.pyc (Python 2.7)

print '$$$$$$$$$ ^-^ \xe2\x95\xa6 \xe2\x95\xa6\xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90\xe2\x94\xac  \xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90\xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90\xe2\x94\x8c\xe2\x94\xac\xe2\x94\x90\xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90  \xe2\x94\x8c\xe2\x94\xac\xe2\x94\x90\xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90  \xe2\x94\x8c\xe2\x94\xac\xe2\x94\x90\xe2\x94\xac \xe2\x94\xac\xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90  \xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90\xe2\x94\xac \xe2\x94\xac\xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90\xe2\x94\xac  \xe2\x94\xac  \xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90\xe2\x94\x8c\xe2\x94\x90\xe2\x94\x8c\xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90\xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90'
print '              \xe2\x95\x91\xe2\x95\x91\xe2\x95\x91\xe2\x94\x9c\xe2\x94\xa4 \xe2\x94\x82  \xe2\x94\x82  \xe2\x94\x82 \xe2\x94\x82\xe2\x94\x82\xe2\x94\x82\xe2\x94\x82\xe2\x94\x9c\xe2\x94\xa4    \xe2\x94\x82 \xe2\x94\x82 \xe2\x94\x82   \xe2\x94\x82 \xe2\x94\x9c\xe2\x94\x80\xe2\x94\xa4\xe2\x94\x9c\xe2\x94\xa4   \xe2\x94\x82  \xe2\x94\x9c\xe2\x94\x80\xe2\x94\xa4\xe2\x94\x9c\xe2\x94\x80\xe2\x94\xa4\xe2\x94\x82  \xe2\x94\x82  \xe2\x94\x9c\xe2\x94\xa4 \xe2\x94\x82\xe2\x94\x82\xe2\x94\x82\xe2\x94\x82 \xe2\x94\xac\xe2\x94\x9c\xe2\x94\xa4 '
print '              \xe2\x95\x9a\xe2\x95\xa9\xe2\x95\x9d\xe2\x94\x94\xe2\x94\x80\xe2\x94\x98\xe2\x94\xb4\xe2\x94\x80\xe2\x94\x98\xe2\x94\x94\xe2\x94\x80\xe2\x94\x98\xe2\x94\x94\xe2\x94\x80\xe2\x94\x98\xe2\x94\xb4 \xe2\x94\xb4\xe2\x94\x94\xe2\x94\x80\xe2\x94\x98   \xe2\x94\xb4 \xe2\x94\x94\xe2\x94\x80\xe2\x94\x98   \xe2\x94\xb4 \xe2\x94\xb4 \xe2\x94\xb4\xe2\x94\x94\xe2\x94\x80\xe2\x94\x98  \xe2\x94\x94\xe2\x94\x80\xe2\x94\x98\xe2\x94\xb4 \xe2\x94\xb4\xe2\x94\xb4 \xe2\x94\xb4\xe2\x94\xb4\xe2\x94\x80\xe2\x94\x98\xe2\x94\xb4\xe2\x94\x80\xe2\x94\x98\xe2\x94\x94\xe2\x94\x80\xe2\x94\x98\xe2\x94\x98\xe2\x94\x94\xe2\x94\x98\xe2\x94\x94\xe2\x94\x80\xe2\x94\x98\xe2\x94\x94\xe2\x94\x80\xe2\x94\x98'
print '                                                                                    ^-^ $$$$$$$$$$'
import md5
SHA1 = [
    0xBA4439EE9A46D9D9F14C60F88F45F87L,
    0xDB0F6F37EBEB6EA09489124345AF2A45L,
    0x52A8CBE3663CD6772338701016AFD2DFL,
    0x56AB24C15B72A457069C5EA42FCFC640L,
    0xB61A6D542F9036550BA9C401C80F00EFL]
print 'If you are a good programer you know what you need to do to read the script'
Flag = raw_input('Please enter the flags: ')
if len(Flag) > 25:
    print 'The flag is to long'
    exit()
if len(Flag) % 5 != 0:
    print 'The flag is to short'
    exit()
if len(Flag) == 0:
    print 'Please enter the Flags'
    exit()
for r00t in range(0, len(Flag), 5):
    z3r0 = Flag[r00t:r00t + 5]
    if int('0x' + md5.new(z3r0).hexdigest(), 16) != SHA1[r00t / 5]:
        print 'try harder the next time'
        exit()
        continue
if len(Flag) == 25:
    print 'The Flag Is : ', Flag
    exit()
exit()
if len(Flag) / 25 != '0b1'[2:]:
    print 'try with binary'
    exit()
```

Este código de **Python 2** es bastante sencillo de entender: pide al usuario que
introduzca algo por pantalla, `Flag`, que debe tener 25 caracteres y luego realiza alguna
comprobación en un bucle. En este bucle se extraen de `Flag` trozos de 5 caracteres.
Luego comprueba que el MD5 de este cacho es igual que un hash _hardcodeado_, los que se
almacenan en la variable `SHA1` (el nombre es obviamente una distracción, porque
claramente se está usando el módulo `md5`).

Al final, la respuesta es la concatenación de cinco palabras de cinco caracteres con
un _hash_ en particular.

Al final el reto consiste simplemente en _crackear_ estos _hashes_ para obtener la
_flag_. O, incluso mejor, usar alguna de las muchas bases de datos que hay disponibles
por Internet. Después de buscar en un par de ellas, llegamos rápidamente al resultado
(ordenado de la misma forma en la que se comprueban):
```
0ba4439ee9a46d9d9f14c60f88f45f87 MD5 : check
db0f6f37ebeb6ea09489124345af2a45 MD5 : group
52a8cbe3663cd6772338701016afd2df MD5 : zezex
56ab24c15b72a457069c5ea42fcfc640 MD5 : happy
b61a6d542f9036550ba9c401c80f00ef MD5 : tests
```

Fácil, ¿verdad? :)
La _flag_ es `checkgroupzezexhappytests`.

-----------------------------------------------------------------------------------------

## 9.- Monkey Island

La descripción de este reto dice así:
```
Se ha incautado un equipo perteneciente al miembro de una APT, tras un profundo análisis
forense no se han podido obtener evidencias que hayan sido eliminadas o cifradas, en el
contenido más significativo del delincuente se ha recuperado un video que sospechan que
 pueda contener algún tipo de prueba delictiva. (La flag es sensible a mayus/minus)
```

La primera cosa que suelo hacer con archivos de este tipo (películas, audio...) en los
CTFs, incluso antes de leer la descripción, es usar `binwalk`. Esconder un archivo dentro
de otro simplemente concatenándolos es una técnica tan usada (al menos en los CTFs) que
lo hago casi por instinto :D
No siempre encuentra algo; pero esta vez sí:
```
$ binwalk MonkeyIsland.avi

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
26013116      0x18CEDBC       Zip archive data, at least v2.0 to extract, compressed size: 613, uncompressed size: 811, name: bandera64.txt
26013883      0x18CF0BB       End of Zip archive
```

El _zip_ extraído contiene un archivo de texto con algunos datos codificados en base64:
```sh
$ cat bandera64.txt
UEsDBAoACQBjALpE5UyE1fPolAEAAHgBAAALAAsAYmFuZGVyYS5wbmcBmQcAAQBBRQMAAPKu8K6x
c7GJh/VmKva+f8JqD7Pe3X95ttenp+LwVVKiTrs1N450IIK7cjKsIYwqYBWiSwcClH2S51vh+L6/
xnICJFdIYuqD+sB282j0guUmoXbdIwU3dMtkYeUs/tOm7yd4TxHMfEQ2wM+i64R/iuhx9xvvh5PV
jnyPiKnjKPTQf9tH1XflKezQ8lHDAFPeEWZSMlRBaOwVWLywkiopyEYSuJGzJchCoRtiMX3fmfJX
8bD3SozBFIOPMjje/3/Xn6tVdmaaAVpAt8+iXu05VwXmmg8Ub7isi2KJBljiGMTQ+knFndW3gCEr
V3pk1OfNOGWAI09l5QXe6I+UKJZ5p9bpLi0fBbTHJCFcFu5y/IJHr9Vr5rzi6vpPU7p0ZtNJyYoK
EUB18DsmONtxc+xuqloJtzhRUQ5ZHRWumnfMk9Cw1tYT/KHa4gWh/GOVHLEAkizskRobAfanZ0OY
TfmYtjl/60UaL/sFkDYH4+uNt9MKLLiLR4WomoTq2Qi4o+EyzLDO0drgZXjsd1aN9s3EYkNY+Ug6
UEsHCITV8+iUAQAAeAEAAFBLAQIfAAoACQBjALpE5UyE1fPolAEAAHgBAAALAC8AAAAAAAAAIAAA
AAAAAABiYW5kZXJhLnBuZwoAIAAAAAAAAQAYAABwYYR+FNQBD0sSrJY51AHbTw9ChznUAQGZBwAB
AEFFAwAAUEsFBgAAAAABAAEAaAAAANgBAAAAAA==
```

Su nombre, _bandera64_, sugiere que si decodificamos en base64 obtendremos la bandera.
Vamos a ver si es verdad:
```sh
$ base64 -d bandera64.txt > decoded
$ file decoded
decoded: Zip archive data, at least v1.0 to extract
```

Rayos, es un Zip cifrado. Pero no es la primera vez que nos encontramos uno de estos.
¿Recuerdas el [7º reto](#7--holidays)?

Usemos otra vez las mismas herramientas (`zip2john` y `john`) para intentar sacar la
contraseña. No tenemos ninguna pista de cuál puede ser, así que empezaremos como siempre,
probando primero los diccionarios comunes (`/usr/share/dict/words`, `rockyou`...). Con
nuestro primer intento ya sacamos la contraseña: `grog`.

De este _zip_ extraemos un archivo llamado _bandera.png_. Pero soy incapaz de saber qué
significa esto:

{% include image.html
	src="/assets/posts/2018-12-26-cybercamp-medium-2/bandera.png"
	title="File extracted from the encrypted zip"
	alt="La imagen es una extraña secuencia de pixels (su tamaño es de 76 x 12 pixels) con diferentes colores, pero sin orden aparente"
%}

¿Es esta la _flag_? ¿Cómo meto la solución en la página del CTF?

Estaba bastante perdido con este paso final, así que decidí coger una pista de la página:
```
El segundo mensaje se ha ocultado con el lenguaje de programación PIET
https://gabriellesc.github.io/piet/
```

Vale, la verdad es que esta pista fue bastante útil. Ahora es simplemente hay que subir
esta imagen al intérprete que se da en la pista y ejecutarlo. El código imprime el
mensaje `THESevenSamurai`, que resulta que es la solución.

Finalmente, la _flag_ es `THESevenSamurai`.

-----------------------------------------------------------------------------------------

## 9.- Chicken Dinner

La descripción de este reto dice así:
```
Se sospecha que un compañero de tu oficina está vendiendo secretos de estado a través de
una aplicación de mensajería muy utilizada. Se te ha proporcionado la imagen de su
terminal Android a través del cual deberás recuperar y localizar estos mensajes. En ellos
se encontrará la FLAG que necesitas.
```

Para empezar este reto, vamos a montar la imagen y a empezar navegando en el sistema de
archivos un poco. Recuerda que hay que mirar el desplazamiento de la partición usando
`fdisk -l` y luego hay que multiplicar lo que salga por el tamaño de un sector (512
Bytes) para decirle a `mount` cuál es el desplazamiento correcto.

Como estamos intentando encontrar mensajes borrados, necesitamos localizar las
aplicaciones que se hayan podido utilizar. En este caso, encontramos cuatro:
	- WhatsApp
	- Telegram
	- Facebook Messenger
	- Instagram

De estas cuatro, sólo los directorios de Instagram y WhatsApp tienen algo. La de
Instagram, sin embargo, parece que sólo tiene algunas preferencias locales y la caché,
pero ninguna base de datos que parezca que pueda tener mensajes; así que vamos a echarle
un vistazo a WhatsApp.

Este es el contenido del directorio de WhatsApp:
```
android-6.0-rc1/data/data/com.whatsapp/
├── app_minidumps
├── cache
├── databases
│   ├── _jobqueue-WhatsAppJobManager
│   └── _jobqueue-WhatsAppJobManager-journal
├── files
│   ├── Avatars
│   ├── key
│   ├── Logs
│   │   └── whatsapp.log
│   ├── rc2
│   ├── statistics
│   ├── .trash
│   └── wam.wam
├── no_backup
│   └── com.google.android.gms.appid-no-backup
└── shared_prefs
    ├── com.google.android.gms.appid.xml
    ├── com.google.android.gms.measurement.prefs.xml
    ├── com.whatsapp_preferences.xml
    ├── _has_set_default_values.xml
    ├── keystore.xml
    └── qr_data.xml
```

Desafortunadamente, no hay nada por aquí. Las únicas bases de datos que hay parecen
tener cosas de la configuración, pero ningún mensaje. Pero parece que hay un archivo que
se llama _key_ que puede ser útil en el futuro...

Otro lugar en el que podemos mirar es en el directorio de datos del usuario, en
`/android-6.0-rc1/data/media`:
```
data/media
├── 0
├── DCIM
│   ├── Camera
│   ├── Screenshots
│   └── .thumbnails
├── obb
└── WhatsApp
    ├── Databases
    │   └── msgstore.db.crypt12
    ├── Media
    │   ├── WallPaper
    │   ├── WhatsApp Animated Gifs
    │   │   ├── Private
    │   │   │   └── .nomedia
    │   │   └── Sent
    │   │       └── .nomedia
    │   ├── WhatsApp Audio
    │   │   ├── Private
    │   │   │   └── .nomedia
    │   │   └── Sent
    │   │       └── .nomedia
    │   ├── WhatsApp Documents
    │   │   ├── Private
    │   │   │   └── .nomedia
    │   │   └── Sent
    │   │       └── .nomedia
    │   ├── WhatsApp Images
    │   │   ├── Private
    │   │   │   └── .nomedia
    │   │   └── Sent
    │   │       └── .nomedia
    │   ├── WhatsApp Profile Photos
    │   ├── WhatsApp Stickers
    │   │   └── .nomedia
    │   ├── WhatsApp Video
    │   │   ├── Private
    │   │   │   └── .nomedia
    │   │   └── Sent
    │   │       └── .nomedia
    │   └── WhatsApp Voice Notes
    │       ├── 201815
    │       │   └── .nomedia
    │       └── .nomedia
    ├── .Shared
    └── .trash
```

¡Bingo! Bueno, más o menos... Podemos ver que hay un archivo llamado _msgstore.db_...
Con una extensión _crypt12_ :(

Aunque una extensión por sí misma no significa nada, un vistazo rápido a las cabeceras
nos dicen que el archivo está cifrado. Pese a esto, hay muchas herramientas por ahí que
te permiten descifrarlo, suponiendo que tienes la clave. Yo decidí usar
[WhatsApp-Crypt12-Decrypter](https://github.com/EliteAndroidApps/WhatsApp-Crypt12-Decrypter/)
sin más razón que fue el primer resultado que apareció en DuckDuckGo cuando lo busqué.

Como nota aparte, encontré [este otro repo](https://github.com/mgp25/Crypt12-Decryptor)
donde se explica el modo de funcionamiento de Crypt12 (AES-GCM, básicamente), lo que me
parece bastante interesante.

Este usuario, @mgp25, tiene también otras cosas muy interesantes. Os recomiendo echarle
un vistazo a sus otros proyectos.

Volviendo al reto, ¿recordáis aquél archivo llamado _key_ que vimos antes? Quizá podamos
usarlo aquí:
```sh
$ java -jar decrypt12.jar ../key ../msgstore.db.crypt12 decrypted.db
Decryption of crypt12 file was successful.
$ file decrypted.db
decrypted.db: SQLite 3.x database, user version 1, last written using SQLite version 3011000
```

Genial, esto marcha bien. Ahora es el momento de examinar el contenido de la BDD. Hay
varias tablas; pero la que más nos llama la atención es la que se llama _messages_.
Efectivamente, ahí hay varios mensajes intercambiados. Esta es la transcripción, siendo
_A_ el propietario del dispositivo y _B_ el otro extremo de la conversación,
_+34 628 205 625_:

> A: Hey!! Are u online? I think they have discovered me...
>
> A: This is my last message...i want my money
>
> A: And the chicken dinner...u know what it is
>
> B: Ok no problem...
>
> B: Send me the chicken dinner now and delete this conversation
>
> A: Ok, 1min, need to encode it
>
> A: iVBORw0KGgoAAAANSUhEUgAAAyAAAAJYCAYAAACadoJwAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBI
>    WXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4gYZCggdk0GemwAAAAxpVFh0Q29tbWVudAAAAAAAvK6y
>    mQAAIABJREFUeNrt3XmYFOWB+PFihhkchmtAkGNUDkWBcHjhgRxmAwRJsoqKqNldo0TDk6BBIIJB
>    o+IK67UadReIiTGiuBFcg7qocQHlkM0DCowrXly6HAqogNzj8/7++D36JE4VzMB093TP5/M89QfD
>    AQAABAgAAIAAAQAABAgAACBAAAAABAgAACBAAAAABAgAACBAAAAAAQIAACBAAAAAAQIAACBAAAAA
>    (...)
>    AAAQIAAAgAABAAAQIAAAgAABAAAQIAAAgAABAAAECAAAgAABAAAECAAAgAABAAAECAAAIEAAAAAE
>    CAAAIEAAAAAECAAAIEAAAAABAgAAIEAAAAABAgAAIEAAAAABAgAACBAAAAABAgAACBAAAAABAgAA
>    CBAAAECAAAAACBAAAECAAAAACBAAAECAAAAACBAAAECAAAAAAgQAAECAAAAANd//AyfU84FIjoOV
>    AAAAAElFTkSuQmCC
>
> A: This is my last message, send me the money on the same account
>
> B: Ok...


Esa cadena tan larga es demasiado sospechosa y tiene pinta de ser base64. De hecho, si la
extraemos y decodificamos, acabamos con una imagen PNG que contiene la respuesta:

{% include image.html
	src="/assets/posts/2018-12-26-cybercamp-medium-2/decoded-flag-10.png"
	title="Result of decoding the base64 message"
	alt="Fondo totalmente negro con el texto TOO_MANY_SECRETS escrito al frente, en blanco."
%}

Y ya hemos acabado.
La _flag_ es `TOO_MANY_SECRETS`.



-----------------------------------------------------------------------------------------

## 10.- La Orden del Temple


La descripción de este reto dice así:
```
Se incauta a un sospechoso de terrorismo su equipo, dentro de éste se encuentran ficheros
que se podrían considerar de vital importancia para continuar con la investigación, pero
muchos de esos ficheros están cifrados y se sabe que mediante PGP simétrico.

Gracias a la investigación del sospechoso tus compañeros te han dado las siguientes
pautas que sigue el sospechoso a la hora de crear sus contraseñas:

    Son de longitud de 6 a 7 caracteres.
    Sólo contienen letras minúsculas
    Sólo se utilizan estas letras: eghotu
    No se repite ninguna de las letras de la contraseña
    Algunas de ellas contienen dos números entre estos: 0134

Tu trabajo será intentar descifrar el fichero gracias a la investigación realizada sobre
el sospechoso y a los datos proporcionados para determinar si el contenido es de vital
importancia para la investigación en curso.
```

Este es un ejercicio bastante sencillo y directo, ya que la descripción proporciona las
reglas para crear el diccionario correcto. Por extraño que parezca, estos son los tipos
de retos que más me cuestan :(

A pesar de ello, gracias al
[modo de máscara](https://github.com/magnumripper/JohnTheRipper/blob/bleeding-jumbo/doc/MASK)
de JTR, por fin he sido capaz de pasar la primera parte de este reto (dos meses después
del tiempo límite, me da que ya es un poco tarde) en una hora o dos, con esta orden
tan sencillita:
```
john -mask=[eghotu0134] -min-len=6 -max-len=7 medium_11.gpg_HASH --format=gpg-opencl
```

La explicación de los parámetros:

  - `-mask` le dice a JTR que use el modo de máscara, usando `eghotu0134` como alfabeto.
	Aunque no sigue exactamente las guías, en concreto lo de
	_no se repiten las letras_ y _contiene **dos** números_, creo que es más sencillo
	ir por _todas_ las combinaciones en vez de andar puliendo el diccionario.
	Obviamente, alguien con más conocimiento del uso de las reglas en JTR podrá
	llegar mucho más rápido a la solución.

  - `-min-len` y `-max-len` están ahí por las guías que dicen que la longitud de la
	contraseña es de 6 ó 7 caracteres.

  - `medium_11.gpg_HASH` es el _hash_ sacado por `gpg2john`, otra de esas herramientas
	increíblemente útiles para convertir cualquier formato en algo que JTR entienda.

  - Finalmente, `--format` está ahí para decirle a JTR que usa la GPU, en lugar de la CPU
	(que es mucho más lenta).


Después de una hora y media, JTR saca la contraseña: `eg1u03`. Es interesante el hecho de
que hay _tres_ números ahí, mientras que en las guías nos decían que podría haber _dos_
números. Me lo tomaré como una lección de que esas guías no son siempre 100% correctas.
Si no puedes sacar la contraseña y tienes la seguridad de que el diccionario está bien
hecho, intenta expandir la búsqueda a otros casos que no sigan todas las reglas, sólo
algunas (por ejemplo, permitir varios números en vez de sólo dos).

En fin, los datos cifrados son la siguiente imagen:

{% include image.html
	src="/assets/posts/2018-12-26-cybercamp-medium-2/ordendelos.png"
	title="Decrypted data"
	alt="Una gran cruz patada (un símbolo Templario) con algunos símbolos raros, como triángulos con puntos dentro, en las esquinas."
%}


Quizá algunas personas hayáis identificado los símbolos que aparecen en la imagen con el
[cifrado Pigpen](https://en.wikipedia.org/wiki/Pigpen_cipher#Variants). Los símbolos de
la parte de arriba de la imagen y la de abajo son los mismos; y, descifrados, dan el
siguiente texto plano (con los espacios añadidos por mí):
> ERES MUY GOLOSO

Así que la _flag_ es (o al menos eso creo, porque no pude completar este reto a tiempo)
`ERESMUYGOLOSO`

-----------------------------------------------------------------------------------------

[^1]: Desgraciadamente, sólo saqué unos 2900-3000 puntos; mientras que el corte se hizo
    alrededor de los 3100 puntos... :(


[^2]: A estas alturas seguro que estás hasta las narices de oírlo; pero sí, hay muchas
	maneras de hacerlo :D
