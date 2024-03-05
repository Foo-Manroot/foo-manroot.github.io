---
layout: post
title:  "Quick setup of an HTTPS server to transfer data"
date:	2024-03-05 22:44:19 +0100
author: foo
categories: utils
ref: quick-transfer-server
---

This post is simply for my own reference, to copy+paste my scripts below.
If you're reading this and have no clue how these scripts work, do not hesitate to [/about](contact me).

* Table of Contents
{:toc}

Sometimes I'm need to quickly transfer data between two clients in my local network, or between my server and a client I'm connected to via RDP or Citrix with file transfer disabled.

In those situations, I could of course use any file transfer solution like WeTransfer, OneDrive, etc.
However, I'm wary of uploading any data to random sites in the internet, since I don't really know what happens later with my data (which I, of course, encrypt locally before uploading, just in case).

Another alternative would be to host one such services, like [https://framagit.org/fiat-tux/hat-softwares/lufi](Lufi) in my own server.
That, however, requires two things I lack:
    - Planning skills
    - A server

Additionally, exposing that service to the internet might open it for abuse, so additional considerations (authentication or resource limiting, for example) are needed.


Since I'm too lazy and I don't really need the service to be running 24/7, I normally resort to the timeless `netcat` transfer (or `python -m http.server`, when the client doesn't have netcat installed).
This is suitable for many use cases, except for one: uploading data from a client with no netcat installed, to my netcat listener.

# Netcat server

A quick and dirty solution is to use netcat as a shitty HTTP server:
```
$ printf "HTTP/1.1 200 OK\r\n" ; ncat -nvlp 8080 > request
```

And use `curl` (normally installed by default in many Windows and Unix-like hosts) to upload a file:
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
On Windows, cURL seems to complain about the connection being dropped or something; but I get the data on my server anyways, so who cares ¯\\\_(ツ)\_/¯

And the contents are there:
```
$ cat data
PUT /qwer HTTP/1.1
Host: 127.0.0.1:1234
User-Agent: curl/8.6.0
Accept: */*
Content-Length: 5

asdf
```


# Serve over HTTPS with Python

Another situation I sometimes encounter is having to serve some files over HTTPS, because the target is behind a proxy that rejects plain HTTP.
In those cases, I can wrap Python's SimpleHttpServer (Python2, for now) on a TLS socket and run it like this:

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

Self-signed cert and key can be issued with the usual `openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 365 -nodes`

The behaviour from the client-side is the same as usual, just with an _https_ URL.


# Obtain files over HTTPS

Finally, to perform the equivalent of netcat's file upload server we showed before but over TLS this time, we can use the following script to serve using `openssl s_server`:
```
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

Again, this is a super dirty solution, but it works well enough for me.
