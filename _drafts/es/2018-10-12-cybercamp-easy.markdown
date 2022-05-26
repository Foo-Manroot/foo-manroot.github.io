---
layout: post
title:  "Write-ups del Cybercamp 2018: easy"
date:	2018-10-12 13:22:04 +0200
author: foo
categories: es ctf cybercamp write-up
lang: es
ref: cybercamp-easy
---

Cada año, el [INCIBE](https://www.incibe.es/) (una agencia española que se encarga de
concienciar sobre temas de ciberseguridad) organiza la [CyberCamp](cybercamp.es).

Estos son los _write-ups_ de los clasificatorios del CTF, que fueron hace ya un par de
semanas. Como los resultados ya se han anunciado[^1] y [han dicho que podemos subir
nuestros _write-ups_](https://twitter.com/CybercampEs/status/1048129712491569152), estoy
escribiendo aquí mis soluciones para los retos que resolví. Los materiales para los de
este _post_ se pueden descargar aquí:

  - [Reto 1](/assets/posts/2018-10-12-cybercamp-easy/1_Easy.7z)
  - [Reto 2](/assets/posts/2018-10-12-cybercamp-easy/2_Easy.7z)
  - [Reto 3](/assets/posts/2018-10-12-cybercamp-easy/3_Easy.7z)
  - [Reto 4](/assets/posts/2018-10-12-cybercamp-easy/4_Easy.7z)


En este artículo explicaré mis respuestas para los retos etiquetados como _easy_.

-----------------------------------------------------------------------------------------

## 1.- Toxinas aéreas

La descripción de este reto dice así:
```
Desde hace un tiempo la red Wifi de nuestro cliente no va bien. Se quejan de que a veces
no se conectan los equipos y sospechamos que existe algún atacante malicioso en la zona.
Hemos enviado a nuestro auditor junior a realizar una captura en el sitio, pero no ha
podido determinar lo que pasa y nos ha enviado la captura en formato pcap. ¿Podrías
echarle una mano? (Respuesta: flag{dirección MAC en formato XX:XX:XX:XX:XX:XX del host
atacado} – ejemplo: flag{xx:xx:xx:xx:xx:xx})
```

Se nos da una captura de tráfico de todas las redes _Wifi_ en la zona. Podemos ver los
diferentes puntos de acceso (**AP**, _Access Points_) en el área, como
_MiFibra_A3E0_ o _MOVISTAR-F43B_. Uno de los primeros ataques que debemos buscar es el de
[_fake deauthentication_](https://en.wikipedia.org/wiki/Wi-Fi_deauthentication_attack),
porque si la red "no va bien" es posible que se deba a un atacante intentando echar a los
clientes para que se conecten a su AP malicioso.

Para buscar estas tramas, debemos aplicar el filtro `wlan.fc.type_subtype eq 12` al
archivo capturado:
{% include image.html
	src="/assets/posts/2018-10-12-cybercamp-easy/01.- Filter.jpg"
	title="Filtro aplicado a la captura"
	alt="Captura de pantalla de Wireshark con el resultado de aplicar el filtro. El resultado es una larga lista de paquetes de deauth enviados por el atacante."
%}

Es bastante obvio que el atacante es el que no para de _spamear_ las tramas de _deauth_:
`08:6a:0a:3b:b0:08`.

Al final, tenemos que la _flag_ es `flag{08:6a:0a:3b:b0:08}`.

-----------------------------------------------------------------------------------------

## 2.- Vivan Las Vegas

La descripción de este reto dice así:
```
Se ha incautado el equipo personal de un presunto pedófilo, pero en dicha computadora no
se ha podido obtener ninguna evidencia de la fuente de los ficheros ilegales que se
descargó, sin embargo, en la carpeta de las evidencias se ha encontrado un fichero de
video que parece sospechoso.
```

En nuestro primer intento[^2], encontramos un texto empotrado que obviamente son datos
codificados en base64:
```
$ strings elvis.avi
(...)
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
DX0scQqRx3FFgGoUjJfQRA==
-------------------------------------------------
hQGMAxcYmah/ykbaAQv/YF+v5ElbV8cCtYTmB5yJ4AI2v5+3OUzQaOhC1W1OWn5JqkbPxkQqbfC6
81OKFjSA9L7BWWn2qNnYlmT8Hxu+Ux4CsO1YZHZ1MNJSZHdDIpire9Tplr0fkGO/GLKuSUxq20/7
gJ3AdnqABuEOZzEpXmtgUy1PCVeJjXy4RG8hGsq0/lOf6ry+zeGBMQPDldPVRoEEJIOkvbOSKMfh
VoOZMe1LpRbMt1Q14TD6HTghAN+HmEzfZ/sdggFftRev1f9nC6Y6TgCIBTx0y4X/yhvZWc+HKC0s
Rc5yBhWtaM66PSfnN3sZKnK4z5fWMMIlvyOUTa1JGNc37ZNqQMB9Sb5HIVrmFJ4Oq5x9OdIY/Gk9
aRVguU3Z79vrPm55gulzX8Mp27DncSQLINmp/zBV8NjC09ip7l3lHcLB32ks+POild/5kGRIcvmn
/Z50xcCgOK+orpkPodNOTTVRosTwdBifFPd9PN9cW1vki4WGO+5rZSM5KfC0jGo74Nf1ss1+Bwoo
0k4B1YvEv8aWpZZtdzUqIg5HH2uAHfv480KiOUdHoq7YcGV2N1Q4kcryh26tAmrVu4628qPgG0vO
9rc8/WTNYfRPB2U8c0FYdYDOATvzYaY=
```

De hecho, son dos los archivos que hay, separados por una línea de guiones. Una vez
extraídos y decodificados, tenemos lo siguiente:
```
$ file extract_{1,2}
extract_1: PGP\011Secret Key - 3072b created on Thu Jun 14 15:51:44 2018 - RSA (Encrypt or Sign) e=65537 hashed AES with 128-bit key Salted&Iterated S2K SHA-1
extract_2: PGP RSA encrypted session key - keyid: A8991817 DA46CA7F RSA (Encrypt or Sign) 3072b .
$ gpg --list-packets extract_1
:secret key packet:
	version 4, algo 1, created 1528984304, expires 0
	skey[0]: [3072 bits]
	skey[1]: [17 bits]
	(...)
	keyid: E1D24027D28DA6DB
:user ID packet: "Elvis <elvis@esreal.com>"
(...)
$ gpg --list-packets extract_2
:pubkey enc packet: version 3, algo 1, keyid 171899A87FCA46DA
	data: [3071 bits]
:encrypted data packet:
	length: 78
	mdc_method: 2
gpg: encrypted with RSA key, ID 7FCA46DA
gpg: decryption failed: secret key not available
```

Así que tenemos un archivo cifrado (`extract_2`) y la clave privada para descifrarlo
(`extract_2`)... Esto está chupado :D
Vamos a intentar descifrarlo[^3]:
```
$ gpg --import extract_1
gpg: key D28DA6DB: secret key imported
gpg: key D28DA6DB: public key "Elvis <elvis@esreal.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1  (RSA: 1)
gpg:       secret keys read: 1
gpg:   secret keys imported: 1
$ gpg --decrypt extract_2

You need a passphrase to unlock the secret key for
user: "Elvis <elvis@esreal.com>"
3072-bit RSA key, ID 7FCA46DA, created 2018-06-14 (main key ID D28DA6DB)

Enter passphrase:
```

Hmm... ¿Cuál será la contraseña? Vamos a preguntarle a nuestro amigo
[John](https://www.openwall.com/john/)!

John The Ripper es una potente herramienta para _crackear_ contraseñas; pero, en mi
opinión, su mayor ventaja es que se puede usar de manera sencilla para una prueba rápida
(sólo hay que ejecutar `john [hash_file]` y listo), y cuenta con muchísimas utilidades
para convertir archivos cifrados a formato JTR (como `7z2john`, `keepass2john` o
`luks2john`). En este caso, usaremos `gpg2john` y un sencillo diccionario para comprobar
si la contraseña es una de las facilitas (al fin y al cabo, estamos en la categoría
facilita...):
```
$ gpg2john extract_1 > hash
$ cat hash
Elvis:$gpg$*1*988*3072*8f3cbe32e7a1d077144030ba6a5b8ffc619e9c032667c65856d85907324b332c60771623e7de7ea80683171c89a6fd742fd40c08b767195647cca3b88d6291d258e995a9b4ba5aec34c24b5b29866c10d51ca2adc4a0ee15f8669a5d389b61e0314c48e1ede48e5a73efa2ea1d177f488fb41ec69242afd46b44be92c3f8cc69b99edb7d05e808998c0839adef4affe6b6a1afa26f8a408f59f31794864f52d43273c5f94f015a7c89f596b33f1d6f4b4dff42a5d21abb41212b60841060a1411dd30871b5031baddd1043a6358fb982a3917c73e44f74dd10e233e1d11eff6c5046bf10e146b5808e6e192b82daba9ef0c73b3cb72ee40fc58c13946ac4af5148874bb67037b5abac407597d6f3499895811fb44275e14e1eb71355a6c167c7c42e30f14f9ecb9b6135bceafd38c5ef2d557374fd750c9059e5ff0097bec2e33e9f89daf84a3e3215c48db46f39e771e66de7dbb980826e916d47860e0b51003378b7e1c2414a2c6bb627659be341d7f4dad20ca9111844ac74ea044f926e03905a724c170825b974540ca7decca360dedb8012142544edefd8554f5b9dbdd26f6da855f87d2b444277df2da58a760b5b4aaf7cae2b9bf1d3e18d4479c27a53cc090548ef4ed23ac1a7859f9708cdec9f00f86f1507abd95e153726ea5111dfebb561761467f40458953b7d75bde101577db364189c1a5481f1d422a6a830d9cd199cb2a86f5763ab6bfd54b3466adb6c4754a2ca58a30ffd44818669bdb1635d9a9b907eebd8e0b7b81ea7b62d3c62203babf82b1b7a67ff97f7b4228d2e8437e29d53c0d0c41f88fd7dd490bd0a0b1478eeb81cef4c50e1f532f5960c710f687048fb9cbfe6cbc90d887f2ca56c42b11637b540e5065533e10b0b95bbd4dccb7fd0f656c80f17c6adbe72cb1397b5f566243a2232c7014fd19712add1deab84e6323412d0dffcb66cdbe70fa229e2f6e8487e847789e671ff65234d63b3a0cfd6fa3acc79a718eadebb0f3d11f5dff233398717e805da419850ea070dc40d22405a990eeea644406722639896a105d834fe19aa3c3ecfa21461a3b939eb69986f20cda56342a7881308e572dfd05d44e882b259a0a2565fa8fdfcc3115727c877717dc593ebfe7605c50cd1219b47ae6d95875618ea67708122f8dcc2ae449300d86270bc6d8e6937069ec070ec8b09eb02c4cec6e73a19de58123e374e538bb9cbfb044a22be7565a321a368208b77f1f1d1c369cdecffc461dac5a37a78d39fe6c69e9bd350d6a999b0b4da084e76089c5e03dbb42369743548e6ca4031311b5365ebcaf9b458031f88b6b5240f4878c40629c79aa893ba6e7103f7b0ce653bcda4861dc24303692e134ab6358dd62e4e600717aa123c0ef462*3*254*2*7*16*21e9da9491def965a53ef71d7ea84b6f*65011712*a7ee1ca3267fa71e:::Elvis <elvis@esreal.com>::extract_1
$ john "$(readlink -f hash)"
Warning: detected hash type "gpg", but the string is also recognized as "gpg-opencl"
Use the "--format=gpg-opencl" option to force loading these as that type instead
Using default input encoding: UTF-8
Loaded 1 password hash (gpg, OpenPGP / GnuPG Secret Key [32/64])
Cost 1 (s2k-count) is 65011712 for all loaded hashes
Cost 2 (hash algorithm [1:MD5 2:SHA1 3:RIPEMD160 8:SHA256 9:SHA384 10:SHA512 11:SHA224]) is 2 for all loaded hashes
Cost 3 (cipher algorithm [1:IDEA 2:3DES 3:CAST5 4:Blowfish 7:AES128 8:AES192 9:AES256 10:Twofish 11:Camellia128 12:Camellia192 13:Camellia256]) is 7 for all loaded hashes
Will run 8 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
elviselvis       (Elvis)
1g 0:00:00:01 DONE 1/3 (2018-10-12 15:57) 0.8474g/s 40.67p/s 40.67c/s 40.67C/s Cesreal..ecom
Use the "--show" option to display all of the cracked passwords reliably
Session completed
```

Tras un par de segundos, tenemos nuestra contraseña: `elviselvis`. Ahora podemos
descifrar el archivo y obtener la bandera:
```
$ gpg --decrypt extract_2

You need a passphrase to unlock the secret key for
user: "Elvis <elvis@esreal.com>"
3072-bit RSA key, ID 7FCA46DA, created 2018-06-14 (main key ID D28DA6DB)

gpg: encrypted with 3072-bit RSA key, ID 7FCA46DA, created 2018-06-14
      "Elvis <elvis@esreal.com>"
elvissiguevivo
```

Finalmente, la _flag_ es: `elvissiguevivo`.

-----------------------------------------------------------------------------------------

## 3.- Amigo, ¿dónde está mi contraseña?


La descripción de este reto dice así:
```
Un compañero te proporciona un volcado de memoria y te dice que ha perdido la contraseña,
tendrás que apañártelas para encontrarla, la contraseña será la FLAG buscada. El nombre
de usuario de tu compañero es ThatDude.
```

No fui capaz de acabar este reto por mi cuenta, así que tuve que tirar de las pistas
que daban, y la verdad es que me da rabia; porque las dos primeras pistas eran
increíblemente inútiles y las solución sólo me vino cuando leí la tercera. Para entonces
ya había perdido unos 200 puntos de los 300 del reto (cada pista cuesta más que las
anteriores), y creo que me podría haber clasificado a la final su no hubiera leído las
dos primeras pistas... :(

En fin, vayamos al reto. Tenemos un `MDMP crash report data`, según `file`. Tras un
tiempo buscando en internet cómo abrirlo o convertirlo a un _core dump_ de Unix o
algo[^4], me rendí y leí la primera pista:
```
El sistema operativo es un Windows 7 Home Basic x86
```
...

Ya, eso no ayuda para nada. Vamos a ver qué dice la siguiente pista (adiós, mis queridos
puntos...):
```
Se trata de un volcado de un proceso indispensable en la seguridad del sistema.
```

Hmm...
Nope, sigo sin saber qué es este archivo. Esperemos que la tercera pista aporte algo más
de información:
```
Se trata de un minidump del proceso lsass.exe
```

Oooooooooohhhh, rayos.

De repente, se hizo la luz: `mimikatz`. Mimikatz es una herramienta muy versátil para
saltarse la seguridad de Windows, extraer información de la memoria y mil cosas más.

Sí, debería haber pensado eso desde el principio...
{% include image.html
	src="/assets/posts/2018-10-12-cybercamp-easy/facepalm.jpg"
	title="Sin palabras..."
	alt="Facepalm (de https://upload.wikimedia.org/wikipedia/commons/3/3b/Paris_Tuileries_Garden_Facepalm_statue.jpg )"
	style="max-height: 200px"
%}

Para esta tarea es más sencillo usar Windows (mi sistema principal es GNU/Linux), así que
usaré una máquina virtual para esto. Tras obtener los [binarios de
mimikatz](https://github.com/gentilkiwi/mimikatz/releases), sólo tenemos que obtener las
credenciales de `ThatDude`:
{% include image.html
	src="/assets/posts/2018-10-12-cybercamp-easy/03.- Mimikatz.jpg"
	title="Resultado de la ejecución de mimikatz"
	alt="Tras cargar mi_memoria, se busca la información de seguridad de los usuarios. Entre los resultados, hay una entrada para el usuario TheDude, junto a su contraseña."
%}

La _flag_ es: `ImFreeWhyNot98`

-----------------------------------------------------------------------------------------

## 4.- La memoria no puede ser leída

Desgraciadamente, perdí la descripción para este reto; pero decía algo sobre que había
un virus en el host cuya imagen de memoria se nos ha dado, y que tenemos que descubrir
quién infectó la máquina (la _flag_ es la IP del atacante).

Así que tenemos un volcado de memoria y tenemos que descubrir quién la ha infectado, Como
vamos a trabajar con [volatility](https://github.com/volatilityfoundation/volatility),
primero vamos a obtener el perfil de la imagen (el sistema del que se hizo el volcado):
```
$ volatility -f memdump imageinfo
Volatility Foundation Volatility Framework 2.5
INFO    : volatility.debug    : Determining profile based on KDBG search...
          Suggested Profile(s) : WinXPSP2x86, WinXPSP3x86 (Instantiated with WinXPSP2x86)
                     AS Layer1 : IA32PagedMemoryPae (Kernel AS)
                     AS Layer2 : FileAddressSpace (/tmp/tmp.MLZQCZb8xV/___ASDF/04_Easy__RESUELTO - La memoria no puede ser leída/memdump)
                      PAE type : PAE
                           DTB : 0xb2a000L
                          KDBG : 0x80544ce0L
          Number of Processors : 1
     Image Type (Service Pack) : 2
                KPCR for CPU 0 : 0xffdff000L
             KUSER_SHARED_DATA : 0xffdf0000L
           Image date and time : 2018-06-14 10:56:44 UTC+0000
     Image local date and time : 2018-06-14 05:56:44 -0500
```

Ahora sabemos que estamos tratando con una imagen de un Windows XP. El siguiente paso es
revisar los procesos en ejecución, para identificar cualquier actividad que pueda estar
relacionada con el virus:
```
$ volatility --profile WinXPSP2x86 -f memdump pstree
Volatility Foundation Volatility Framework 2.5
Name                                                  Pid   PPid   Thds   Hnds Time
-------------------------------------------------- ------ ------ ------ ------ ----
 0x817cc830:System                                      4      0     54    822 1970-01-01 00:00:00 UTC+0000
. 0x812e69e0:smss.exe                                 548      4      3     21 2018-06-14 10:38:40 UTC+0000
.. 0x813618d8:winlogon.exe                            620    548     18    440 2018-06-14 10:38:40 UTC+0000
... 0x8118b020:services.exe                           664    620     16    353 2018-06-14 10:38:40 UTC+0000
.... 0x815a6da0:svchost.exe                          1024    664     70   1388 2018-06-14 10:38:41 UTC+0000
..... 0x8143c6f8:wscntfy.exe                         1332   1024      1     36 2018-06-14 10:40:09 UTC+0000
..... 0x81714980:wuauclt.exe                         1788   1024      3    141 2018-06-14 10:40:08 UTC+0000
.... 0x8147ada0:SolarWinds TFTP                      1776    664      9    211 2018-06-14 10:46:13 UTC+0000
.... 0x813c6980:tlntsvr.exe                          1960    664      3    103 2018-06-14 10:39:01 UTC+0000
.... 0x813289a0:svchost.exe                          1072    664      6     93 2018-06-14 10:38:41 UTC+0000
.... 0x81331ae8:spoolsv.exe                          1352    664     10    120 2018-06-14 10:38:42 UTC+0000
.... 0x8144c610:vmacthlp.exe                          832    664      1     24 2018-06-14 10:38:40 UTC+0000
.... 0x811903c8:VMUpgradeHelper                       288    664      3     96 2018-06-14 10:39:08 UTC+0000
.... 0x816df800:svchost.exe                          1224    664     13    201 2018-06-14 10:38:42 UTC+0000
.... 0x8162b980:vmtoolsd.exe                          204    664      4    229 2018-06-14 10:39:08 UTC+0000
.... 0x8166c8f0:svchost.exe                           848    664     19    207 2018-06-14 10:38:40 UTC+0000
.... 0x8166c460:svchost.exe                           932    664     10    280 2018-06-14 10:38:41 UTC+0000
.... 0x81547870:alg.exe                              1184    664      6    104 2018-06-14 10:39:09 UTC+0000
... 0x8118f020:lsass.exe                              676    620     21    349 2018-06-14 10:38:40 UTC+0000
.. 0x81356550:csrss.exe                               596    548     11    463 2018-06-14 10:38:40 UTC+0000
 0x81570810:explorer.exe                             1620   1580     13    372 2018-06-14 10:38:47 UTC+0000
. 0x812adb30:VMwareTray.exe                          1696   1620      1     55 2018-06-14 10:38:47 UTC+0000
. 0x8144d500:VMwareUser.exe                          1708   1620      8    218 2018-06-14 10:38:47 UTC+0000
. 0x812aa7f8:ctfmon.exe                              1720   1620      1     67 2018-06-14 10:38:47 UTC+0000
. 0x81478da0:hot_pictures.ex                          324   1620      0 ------ 2018-06-14 10:39:57 UTC+0000
.. 0x8147c650:cmd.exe                                 640    324      1     35 2018-06-14 10:40:14 UTC+0000
... 0x813ec418:ping.exe                              1688    640      1     51 2018-06-14 10:45:05 UTC+0000
. 0x816f0da0:firefox.exe                             1116   1620     30    406 2018-06-14 10:45:47 UTC+0000
. 0x81397da0:TFTPServer.exe                          1572   1620     12    254 2018-06-14 10:45:56 UTC+0000
. 0x8154c020:cmd.exe                                 1392   1620      1     31 2018-06-14 10:39:41 UTC+0000
.. 0x81739020:mdd.exe                                1264   1392      1     23 2018-06-14 10:56:44 UTC+0000
. 0x812ddda0:samba_service.e                         1176   1620      2    101 2018-06-14 10:53:40 UTC+0000
.. 0x812bb8d0:cmd.exe                                1940   1176      1     35 2018-06-14 10:54:19 UTC+0000
... 0x813cb658:ping.exe                              1944   1940      1     51 2018-06-14 10:54:31 UTC+0000
. 0x8159ada0:IEXPLORE.EXE                            1956   1620     14    356 2018-06-14 10:46:31 UTC+0000
```

Claramente, `hot_pictures.exe` tiene una gran posibilidad de ser el virus, y vemos que
su hijo es una ventana de comandos ejecutando `ping`. ¿Quizá podamos comprobar si hay una
conexión abierta con el atacante? Desafortunadamente, no:
```
$ volatility --profile WinXPSP2x86 -f memdump connections | grep -P "324|640|1688"
$ volatility --profile WinXPSP2x86 -f memdump connections
Volatility Foundation Volatility Framework 2.5
Offset(V)  Local Address             Remote Address            Pid
---------- ------------------------- ------------------------- ---
0x812b3a68 192.168.21.140:1164       216.58.211.35:443         1116
0x8172fbd0 192.168.21.140:1172       216.58.211.45:443         1116
0x81399008 192.168.21.140:1177       216.58.211.35:443         1116
0x813a9b48 192.168.21.140:1160       216.58.211.46:80          1116
0x813de288 192.168.21.140:1173       216.58.211.33:443         1116
0x8147f5f0 192.168.21.140:1153       216.58.211.40:443         1116
0x8158e4e8 192.168.21.140:1169       216.58.211.34:443         1116
0x8172b8a8 192.168.21.140:1149       216.58.211.46:443         1116
0x81435008 192.168.21.140:1166       185.103.39.27:443         1116
0x812ae088 127.0.0.1:8099            127.0.0.1:1073            1776
0x813d1bf8 127.0.0.1:1073            127.0.0.1:8099            1572
0x815993a8 192.168.21.140:1146       2.17.152.162:443          1116
0x813ca888 192.168.21.140:1147       172.217.16.228:443        1116
0x812a1008 192.168.21.140:1139       192.168.21.161:445        1176
0x812c24f8 127.0.0.1:1051            127.0.0.1:1050            1116
0x812dace0 127.0.0.1:1054            127.0.0.1:1055            1116
0x812db440 192.168.21.140:1165       216.58.211.35:80          1116
0x8139a4a0 192.168.21.140:1174       216.58.211.33:443         1116
0x813d1630 192.168.21.140:1178       216.58.211.35:443         1116
0x8168a460 192.168.21.140:1170       216.58.211.46:443         1116
0x8168dc78 127.0.0.1:1055            127.0.0.1:1054            1116
0x816f2008 127.0.0.1:1050            127.0.0.1:1051            1116
0x813a5840 192.168.21.140:1154       104.19.199.151:443        1116
0x813cf228 192.168.21.140:1167       216.58.210.130:443        1116
0x816fed28 192.168.21.140:1162       216.58.210.131:80         1956
0x812df220 192.168.21.140:1171       216.58.211.46:443         1116
0x8159e8f0 192.168.21.140:1179       216.58.211.35:443         1116
0x81399c58 192.168.21.140:1161       104.83.54.35:443          1116
0x81647008 192.168.21.140:1142       13.33.237.52:80           1116
0x8119ed40 192.168.21.140:1159       216.58.210.131:80         1116
0x81297610 192.168.21.140:1148       216.58.210.130:443        1116
0x814284b0 192.168.21.140:1163       216.58.210.131:80         1956
0x81599210 192.168.21.140:1168       216.58.210.130:443        1116
```

No hay una conexión abierta por ninguno de los procesos sospechosos (324, 640 y 1688).

Sin embargo, nuestras esperanzas no están perdidas del todo. ¡Hay un segundo archivo
sospechoso! Si examinamos de nuevo los procesos en ejecución, podemos ver que hay un
servicio samba. ¿Quizá el atacante haya usado alguna vulnerabilidad de samba para entrar?
Podemos buscar conexiones a uno de los puertos usados por el protocolo SMB, como el 445
(comunicación directa por TCP), o el 137, 138 y 139 (mediante la API NetBIOS):
```
$ volatility --profile WinXPSP2x86 -f memdump connections | grep -P ":(445|137|138|139)"
Volatility Foundation Volatility Framework 2.5
0x812a1008 192.168.21.140:1139       192.168.21.161:445        1176
```

Y _voilà_, nuestro ataque vino de **192.168.32.161**.

La _flag_ es: `192.168.21.161`



<br/>

<br/>

-----------------------------------------------------------------------------------------

[^1]: Desgraciadamente, sólo saqué unos 2900-3000 puntos; mientras que el corte se hizo
    alrededor de los 3100 puntos... :(

[^2]: Recordad, niños: empezad siempre comprobando las cosas más obvias. Confiad en mí
    cuando digo que no queréis pasar cantidades ridículas de tiempo pensando en cosas
    complicadas cuando las solución es tan simple como mirar `strings`...

[^3]: Para que GPG funcione, primero tenemos que importar la clave. Podríamos crear otro
    _keyring_ o hacer alguno de los truquillos que vienen en internet; pero de este modo
    es más sencillo. Podemos borrar la clave luego usando
    `gpg --delete-secret-keys D28DA6DB`.

[^4]: Esto sencillamente es una tontería, porque de todas formas no sería capaz de
    recuperar ninguna información sin los símbolos... Simplemente es que no sabía por
    dónde tirar, así que intenté lo mejor que se me vino a la mente...
