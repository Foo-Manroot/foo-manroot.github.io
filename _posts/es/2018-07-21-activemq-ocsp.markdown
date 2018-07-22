---
layout: post
title:  "Creando un OCSP responder con ActiveMQ"
date:   2018-07-21 14:01:40 +0200
author: foo
categories: es ocsp activemq programming
lang: es
ref: activemq-ocsp
---

Hace un tiempo me encontré un problema en el trabajo en el que tuve que aprender un par
de cosas interesantes. Se trataba de controlar el acceso de los productores y
consumidores en una cola de AtiveMQ, pudiéndose controlar qué sondas (consumidores o
productores) podían acceder.

Para quienes no sepan lo que es ActiveMQ, se trata básicamente de un servidor, el
_broker_, que administra una cola. Ciertos clientes, los _productores_, generan datos y
los suben a esta cola. Luego, los datos son leídos **de manera asíncrona** por otro
cliente, el _consumidor_. Una vez se han leído, los datos son borrados o simplemente
marcados como "leídos", dependiendo del tipo de cola usada. Este proceso se muestra, más
o menos, en el siguiente diagrama:
```
              ________
             |        |  2) Encolar
             | Broker | <---> Base de Datos (colas)
             |________|  4) Desencolar

              ^       ^
1) Escribir  /         \  3) Leer
            /           \
    __________      __________
   |          |    |          |
   | Producer |    | Consumer |
   |__________|    |__________|
```

Aunque ActiveMQ tiene una opción para establecer una contraseña, esto sólo funciona de
manera global para todas las sondas del sistema. Esta es una medida para denegar el
acceso a sondas no autentificadas; pero, ¿qué pasa si sólo queremos revocar los permisos
de un productor concreto? ¿Hay que cambiar la contraseña e informar sólo a las sondas
permitidas[^1]?¿O quizá haya que escribir una extensión propia para el control de acceso?

Esta segunda opción parece ser la mejor, pero aún es demasiado complicada. Antes de
empezar a implementar un _plug-in_ propio, deberíamos intentar explorar más en la
configuración y en la documentación de ActiveMQ. En un rato encontramos una opción
posible mediante el uso de certificados. El problema es que necesitamos una manera de
revocar y añadir certificados en vivo, sin reiniciar el _broker_. Sin embargo, cambiar el
estado de un certificado significa cambiar la lista de revocación de certificados
(Certificate Revocation List, CRL), y esto no se puede hacer en Java sin reiniciar la
JVM. Pero aún hay esperanzas, porque podemos intentar ver si podemos usar un _OCSP
responder_. Esta no es una funcionalidad muy bien documentada en Java ni ActiveMQ (al
menos yo no pude encontrar nada útil), de ahí este artículo.

## ¿Qué es un OCSP responder?

El [Online Certificate Status Protocol](https://es.wikipedia.org/wiki/Online_Certificate_Status_Protocol)
es un método usado en una [Infraestructura de Clave Pública](https://es.wikipedia.org/wiki/Infraestructura_de_clave_p%C3%BAblica)
para que los clientes comprueben el estado de un certificado ("revocado", "válido" o
"desconocido"). Esto se hace preguntando a un servidor en el que confía el cliente, que
responde con el estado. De este modo, si un certificado es revocado, sólo tendremos que
informar al servidor central, en lugar de tener que actualizar cada CRL en cada agente
del sistema.

Volviendo a nuestro problema original, queríamos controlar el acceso al _broker_ por
parte de las sondas sin necesidad de reiniciar el servidor. Podemos hacer esto con un
proceso adicional en el servidor que responderá cualquier pregunta del _broker_ sobre el
estado de cualquier certificado. Cada nueva conexión, el _broker_ permitirá o denegará la
petición basándose en la respuesta devuelta por este nuevo proceso. El diagrama es ahora
un poco diferente al de antes:
```
 ___________  2,6) Petición OCSP   ________
|           |   <---------------  |        |  4) Encolar
| Responder |   --------------->  | Broker | <---> Base de Datos (colas)
|___________| 3,7) Respuesta OCSP |________|  8) Desencolar

                                  ^       ^
                    1) Escribir  /         \  5) Leer
                                /           \
                          __________      __________
                         |          |    |          |
                         | Producer |    | Consumer |
                         |__________|    |__________|
```

Esta sería la solución perfecta, que nos permitiría cambiar el estado de cualquier
certificado en cualquier momento sin necesidad de reiniciar ningún servicio. Ahora el
reto está en implementar esta solución en ActiveMQ. Si resulta que es más fácil crear un
_plug-in_ propio, habrá que hacer esto último.

Tras investigar un par de horas, encontramos que debería ser posible hacerlo, puesto que
existe una opción en el archivo de configuración [`java.security`](http://activemq.apache.org/how-do-i-use-ssl.html#HowdoIuseSSL-Certificaterevocation).
En la página de documentación enlazada hay también
[una demo](https://github.com/dejanb/sslib) que, con algunos arreglillos, nos da la
respuesta a nuestro problema. Las opciones clave a especificar en el archivo mencionado
son:
```conf
ocsp.enable=true
ocsp.responderURL=http://ocsp.responder.example
```
Obviamente, la URL del _responder_ debe ser cambiada por la del nuestro.

Como la demo referida en la documentación, hecha por
[dejanb](https://github.com/dejanb/sslib), no funciona y las instrucciones están un poco
mal (pero no demasiado), este artículo pretende llenar los espacios en esa explicación.
Los certificados y la documentación actualizados están en
[mi fork en Github](https://github.com/Foo-Manroot/sslib).


## Responder con OpenSSL

Para esta serie de pruebas vamos a usar un _responder_ muy simple que proporciona
OpenSSL, ya que sólo no interesa en la parte del _broker_ (por ahora). Más adelante en el
proyecto lo que hicimos fue implementar nuestro propio _responder_, que se encargaba de
buscar en la base de datos la respuesta que debía darle a ActiveMQ. Esta tarea es (casi)
trivial y se deja como ejercicio[^2].

Para iniciar el _responder_ de OpenSSL hay que ejecutar la siguiente orden:
```sh
openssl ocsp -port 2560 -text \
        -index demoCA/index.txt \
        -CA demoCA/cacert.pem \
        -rkey demoCA/private/cakey.pem \
        -rsigner demoCA/cacert.pem
```

Hace falta una [autoridad de certificación (CA)](https://es.wikipedia.org/wiki/Autoridad_de_certificaci%C3%B3n)
propia para emitir todos los certificados de nuestras sondas y firmar las respuestas (al
fin y al cabo, estamos preguntándole el estado de los certificados a la entidad que los
emitió) enviadas al _broker_[^3]. Usamos el certificado de la CA, `demoCA/cacert.pem`, y
la clave privada, `demoCA/private/cakey.pem`, para firmar las respuestas. También hay un
archivo con el estado de cada uno de los certificados emitidos por esta CA (en otras
palabras, una CRL):
```sh
$ cat index.txt
V   21171114205545Z     D7455D88CE0EBB0D    unknown /C=AA/ST=Example State/O=CA Company/CN=example.com/emailAddress=CA@example.com
V   271206210849Z       D7455D88CE0EBB0F    unknown /C=AA/O=Broker Company/CN=broker.example/emailAddress=broker@broker.example
V   271206211359Z       D7455D88CE0EBB10    unknown /C=AA/O=Client - 1 Company/CN=client-1.company/emailAddress=client-1@client-1.company
```

## Creación de los certificados necesarios

Vamos a necesitar dos tipos diferentes de certificados: los del _broker_ y los de las
sondas. Ambos tipos van a ser emitidos por nuestra propia CA: `demoCA`.

El _broker_ necesita un certificado para que las sondas puedan verificar su identidad.
Esto sólo es necesario al usar los _jar_ compilados que vienen con ActiveMQ, que nos
permite probar la configuración sin necesidad de escribir nada de código. Cuando todo
esté completo, podemos implementar nuestro propio productor o consumidor ignorando
cualquier error de certificados (si se quiere).

Para crear los certificados usaré la utilidad [CA.pl](https://github.com/openssl/openssl/blob/master/apps/CA.pl.in).
Ten cuidado al usar el archivo enlazado, pues se trata de una plantilla a rellenar con
la configuración al compilar OpenSSL. En la mayoría de sistemas tipo Unix está disponible
en la instalación por defecto de la biblioteca OpenSSL (en mi caso, en
`/usr/lib/ssl/misc/CA.pl`).

### Crear la CA

Lo primero de todo es crear la Autoridad que emitirá el resto de certificados. Para hacer
esto, podemos usar el _script_ auxiliar; o puedes hacerlo por tu cuenta simplemente
mirando al código fuente de `CA.pl` o buscando uno de los muchos tutoriales disponibles
en internet:
```sh
$ /usr/lib/ssl/misc/CA.pl -newca
```

Tan simple como eso. Tras responder a un par de preguntas necesarias para el certificado
(país, nombre del dominio, etc.), tendrás un nuevo directorio llamado `demoCA` con la
clave privada de la nueva CA, su certificado y el índice con la CRL de los certificados
emitidos. Ahora mismo, debería tener sólo el certificado de la CA.

No hace falta ninguna otra configuración para la CA. Ya podemos crear una nueva petición
de firma de certificado (Certificate Signing Request, CSR) desde la sonda con
`CA.pl -newreq`, firmarla desde la CA con `CA.pl -sign` y crear un
[PKCS#12](https://en.wikipedia.org/wiki/PKCS_12) para importar la cadena de certificados
en el almacén de claves de la sonda.

### Certificado del _broker_

El broker no es más que un servidor ejecutándose en la JVM, así que tenemos que añadir
nuestro nuevo certificado (el PKCS#12) a su almacén de claves, y el certificado de la CA
en el almacén de confianza (_trust-store_) del _broker_. Este último paso es el que
dejanb hizo mal, puesto que en su repositorio el _broker_ no confiaba en la CA y cada
petición era, por tanto, rechazada.

Para crear los certificados del _broker_ sólo tenemos que crear la CSR, firmarla con la
CA y crear la cadena de certificados para importarla:
```sh
$ /usr/lib/ssl/misc/CA.pl -newreq
$ /usr/lib/ssl/misc/CA.pl -sign
$ /usr/lib/ssl/misc/CA.pl -pkcs12

$ mv newcert.pem broker/broker.cert.pem
$ mv newcert.p12 broker/broker.p12
$ mv newkey.pem broker/broker.key.pem
$ rm newreq.pem
```

Ahora podemos crear el almacén de claves del _broker_ añadiendo su certificado y el de la
CA. El certificado de la CA tiene el nombre por defecto "my certificate", dado por el
_script_ auxiliar `CA.pl`. Si no queremos un almacén de tipo PKCS#12 sino uno de tipo
JKS, simplemente hay que cambiar un par de opciones (ver `man keytool(1)`):
```sh
$ keytool -importkeystore \
        -srckeystore broker/broker.p12 \
        -destkeystore broker/broker-keys.ks \
        -srcstoretype pkcs12 \
        -deststoretype pkcs12 \
        -alias "my certificate" \
        -destalias broker

$ keytool -import \
        -file demoCA/cacert.pem \
        -alias "ca" -trustcacerts \
        -keystore broker/broker-keys.ks
```

Tras este paso, sólo tenemos que añadir la CA en el almacén de confianza del _broker_:
```sh
$ keytool -import \
        -file demoCA/cacert.pem \
        -alias "ca" -trustcacerts \
        -keystore broker/broker-trust.ts
```

El _broker_ está ya preparado y puede ser ejecutado. Además, sólo vamos a necesitar el
certificado del _broker_. Salvo este archivo (`broker/broker.cert.pem`), podemos borrar
el resto del directorio. Aunque tampoco hace falta borrarlo, así que convendría
mantenerlo, por si acaso.

### Certificados de los clientes

El proceso para crear los almacenes de claves y de confianza es muy parecido al de [la
sección anterior](#certificado-del-broker), y es idéntico en cada sonda nueva que
queramos añadir.

Igual que antes, creamos la CSR, la firmamos y almacenamos la cadena del nuevo
certificado en formato PKCS#12:
```sh
$ /usr/lib/ssl/misc/CA.pl -newreq
$ /usr/lib/ssl/misc/CA.pl -sign
$ /usr/lib/ssl/misc/CA.pl -pkcs12

$ mv newcert.pem client-1/client-1.cert.pem
$ mv newcert.p12 client-1/client-1.p12
$ mv newkey.pem client-1/client-1.key.pem
$ rm newreq.pem
```

Y el almacén de claves para el cliente:
```sh
$ keytool -importkeystore \
        -srckeystore client-1/client-1.p12 \
        -destkeystore client-1/client-1-keys.ks \
        -srcstoretype pkcs12 \
        -deststoretype pkcs12 \
        -alias "my certificate" \
        -destalias client-1

$ keytool -import \
        -file demoCA/cacert.pem \
        -alias "ca" -trustcacerts \
        -keystore client-1/client-1.ks
```

Para acabar, tenemos que añadir no sólo el certificado de la CA en el almacén de claves
del cliente; sino también el certificado del _broker_. Esto es necesario porque los
clientes no van a preguntar al _OCSP responder_, sino que siempre confiarán en el
_broker_. Para añadir los certificados usamos una orden similar a la anterior (ten en
cuenta que `broker.cert.pem` ya tiene la cadena completa incluida; así que no es
necesario importar también la CA):
```sh
$ keytool -import \
    -file broker/broker.cert.pem \
    -alias "broker" -trustcacerts \
    -keystore client-1/client-1.ts
```

### Pruebas del _OCSP responder_

Para iniciar el _OCSP responder_, ejecuta:
```sh
openssl ocsp -port 2560 -text \
        -index demoCA/index.txt  -CA demoCA/cacert.pem \
        -rkey demoCA/private/cakey.pem \
        -rsigner demoCA/cacert.pem
```

Se puede realizar una petición de prueba también con OpenSSL:
```sh
openssl ocsp -CAfile demoCA/cacert.pem \
        -url http://127.0.0.1:2560 -resp_text \
        -issuer demoCA/cacert.pem \
        -cert client-1.cert.pem
```

## Configuración en ActiveMQ

Antes de probar la conexión, tenemos que decirle a ActiveMQ que use el _OCSP responder_ y
los almacenes de claves y confianza apropiados. Los archivos a editar son `java.security`
y `activemq.xml`.

En el primero de ellos deben estar las siguientes opciones (con la URL apropiada):
```conf
ocsp.enable=true
ocsp.responderURL=http://localhost:2560
```

En el segundo, la configuración del _broker_, añadiremos esto dentro del elemento
`<broker>` (cambiando las contraseñas por las que le hayamos dado a nuestros almacenes):
```xml
<sslContext>
    <sslContext
        keyStore="file:${activemq.conf}/broker.ks"
        keyStorePassword="activemq"
        trustStore="file:${activemq.conf}/broker.ts"
        trustStorePassword="activemq"
    />
</sslContext>

<!-- Puede que el conector SSL ya estuviera presente -->
<transportConnectors>
    <transportConnector name="ssl" uri="ssl://0.0.0.0:61617?transport.closeAsync=false&amp;wantClientAuth=true&amp;needClientAuth=true"/>
</transportConnectors>
```

Ya estamos listo para probarlo.

## Demostración

En el siguiente vídeo se muestra todo el sistema funcionando. Cualquier conexión
realizada por el cliente es validada mediante el _OCSP responder_. También puedes
intentar conectar con un cliente sin un certificado válido (o revocado) y ver cómo el
_responder_ devuelve un estado "unknown" o "revoked", tras lo cual el _broker_ denegará
la conexión.

{% include video.html
    src="/assets/posts/2018-07-21-activemq-ocsp/demo.webm"
%}

Espero haber ayudado a alguien con el mismo problema que tenía yo, preguntándome por qué
la configuración indicada en la documentación oficial no funcionaba.

Saludos :)

-----------------------------------------------------------------------------------------

[^1]: Lo sé, lo sé: es un sistema horrible.

[^2]: He he... Seguro que ya has escuchado estas palabras más de una vez en los libros de
    matemáticas :D

[^3]: Aunque se podría usar un juego completamente diferente de claves para firmar la
    respuesta, lo normal es usar el _responder_ ejecutándose en los servidores de la CA.
    Hacerlo de otro modo no sería demasiado útil. De hecho, diría que en este caso sería
    peor para el propósito del artículo (comprender el proceso).
