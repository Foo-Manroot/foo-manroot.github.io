---
layout: post
title:  "Pequeño servidor sencillo para transferir archivos"
date:	2024-03-05 22:44:19 +0100
author: foo
categories: es útiles
lang: es
ref: quick-transfer-server
---

Escribo este artículo simplemente para mi propia referencia y poder copiar+pegar los scripts que contiene.
Si estás leyendo esto y no tienes ni idea de cómo funcionan, no dudes en [contactarme](/es/about).

* Table of Contents
{:toc}

A veces me veo en la necesidad de transferir datos entre dos clientes en mi red local, o entre mi servidor y un cliente con el que tengo una conexión por RDP o Citrix, y el intercambio de archivos está deshabilitado.

Por supuesto, en esas situaciones podría usar cualquier solución existente como WeTransfer, OneDrive, etc.
Sin embargo, intento no subir archivos a cualquier sitio aleatorio en internet, ya que no sé realmente lo que pasa con esos datos (los cuales por supuesto cifro localmente antes de subirlos, por si acaso).

Otra alternativa sería alojar alguno de esos servicios, como [Lufi](https://framagit.org/fiat-tux/hat-softwares/lufi) en mi propio servidor.
Para ello, necesuto dos cosas que no tengo:
    - Capacidad de planificación
    - Un servidor

También está el problema de exponer a internet un servicio como este que puede ser abusado tan fácilmente, de modo que consideraciones adicionales (autentificación o límites de uso de recuros, por ejemplo) son necesarias.


Puesto que me da demasiada pereza y no necesito realmente que el servicio esté disponible 24/7, al final acabo recurriendo al viejo `netcat` (o `python -m http.server`, si el cliente no tiene netcat instalado).
Esto me sirve para la mayoría de casos excepto para uno: subir datos desde un cliente _sin_ netcat hacia mi servidor.

# Servidor con netcat

Una solución rápida y sencilla sería usar netcat como un servidor HTTP un poco chustero:
```
$ printf "HTTP/1.1 200 OK\r\n" ; ncat -nvlp 8080 > request
```

Y subir los datos con `curl`, que suele venir instalado por defecto en muchos equipos Windows o tipo-Unix:
```
$ echo "asdf" > qwer
$ curl -v 127.1:1234 -T qwer
*   Trying 127.0.0.1:1234...
* Connected to 127.0.0.1 (127.0.0.1) port 1234
> PUT /qwer HTTP/1.1
> Host: 127.0.0.1:1234
> User-Agent: curl/8.6.0
> Accept: */*
> Content-Length: 5
>
< HTTP/1.1 200 OK
* We are completely uploaded and fine
* Connection #0 to host 127.0.0.1 left intact
```
En Windows parace que cURL se queja de que la conexión se interrumpe al final o algo así; pero para entonces ya me han llegado los datos al servidor, así que bien está lo que bien acaba ¯\\\_(ツ)\_/¯

Y los datos están ahí:
```
$ cat data
PUT /qwer HTTP/1.1
Host: 127.0.0.1:1234
User-Agent: curl/8.6.0
Accept: */*
Content-Length: 5

asdf
```


# Servir datos vía HTTPS con Python

Otra situación que a veces me encuentro es la de tener que servir algunos archivos vía HTTPS, puesto que el objetivo está detrás de un _proxy_ que rechaza el HTTP en claro.
En esos casos, puedo envolver la conexión de SimpleHttpServer (es decir: Python2 - de momento) en un _socket_ TLS y ejecutarlo tal que así:
```py
#!/usr/bin/python
import BaseHTTPServer, SimpleHTTPServer
import ssl

port = 8443

httpd = BaseHTTPServer.HTTPServer(('0.0.0.0', port), SimpleHTTPServer.SimpleHTTPRequestHandler)
httpd.socket = ssl.wrap_socket(httpd.socket, certfile='../cert.pem', keyfile = '../key.pem', server_side=True)

print ("Starting server on 0.0.0.0:" + str(port))
httpd.serve_forever()
```

```sh
#!/bin/sh -x

SERVE_DIR="$PWD/serve_dir"

mkdir -p "$SERVE_DIR"
cd "$SERVE_DIR"

python ../python_get_https.py
```

El certificado (autofirmado) y la clave se pueden crear con el típico `openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 365 -nodes`

El modo de operación desde el lado del cliente es igual, salvo que se debe usar la URL con _https_.


# Subir archivos vía HTTPS

Para acabar, el equivalente cifrado del servidor chustero que hicimos antes con netcat podemos replicarlo usando el siguiente _script_, que tira de `openssl s_server`:
```sh
#!/bin/bash

PORT=8443
SLEEP_SECONDS=15
RAW_REQUEST=raw_request
REQUEST_FILE=http_request
DATA_FILE=data

printf "The server will listen on port %d\n" "$PORT"
printf "To upload a file, use \`curl -k https://0wn.at:%s -T <file-to-upload>\`\n" "$PORT"

#printf "200 OK\r\n\r\n" | nc -nvlp "$PORT"

printf "The server will wait %s seconds for the transfer to complete. If it takes longer (for bigger files or congested network), modify the SLEEP_SECONDS variable.\n" "$SLEEP_SECONDS"
(printf "HTTP/1.1 200 OK\r\n" ; sleep "$SLEEP_SECONDS" ) | openssl s_server -key key.pem -cert cert.pem -accept "$PORT" > "$RAW_REQUEST"

# We can avoid all this extra metadata by adding `-quiet` to openssl; but, for whatever reason, that makes the server hang forever (?)
awk '
/DONE$/ {
	d =  substr ($0, 1, length ($0) - length ("DONE"));
	printf "%s", d;
	data = 0;
}

data {
	print $0;
}

/ACCEPT/ {
	data = 1;
}' "$RAW_REQUEST" > "$REQUEST_FILE"
rm "$RAW_REQUEST"

# If the data doesn't end with a new line, the end of the data gets interleaved with the "DONE" message from OpenSSL

# Extract the data from the HTTP headers
#awk '
#BEGIN {
#	ORS = "";
#}
#
#end_headers {
#	print $0;
#}
#
#/^\r$/ {
#	end_headers = 1;
#}' "$REQUEST_FILE" > "$DATA_FILE"
xxd -ps "$REQUEST_FILE" | tr -d '\r\n' | sed -e 's/^.*0d0a0d0a//' | xxd -r -ps > "$DATA_FILE"




printf "\n\n================\n"
printf "Declared content-length:\n\t"
grep -ai 'Content-Length:' "$REQUEST_FILE"

printf "Received data:\n\tLength: %s\n\tSHA-1: %s\n" \
		"$(du -b "$DATA_FILE"	| awk '{print $1}')" \
		"$(sha1sum "$DATA_FILE" | awk '{print $1}')"

rm -i "$REQUEST_FILE"
```

Lo dicho: esta es una solución de apagafuegos, pero me sirve para lo que necesito.
