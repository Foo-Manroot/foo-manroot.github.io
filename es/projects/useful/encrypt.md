---
layout: project
title: "Encriptado de directorios"
tags: [sh, gpg, openssl]
lang: es
ref: projects-encrypt
---

## Cifrado de directorios de manera recursiva

Este proyecto fue el producto de la necesidad que tuve de cifrar el contenido de un
directorio con muchos archivos y subdirectorios. Estoy seguro de que el _script_
resultante puede no ser la herrramienta más rápida, pero sirve a su propósito principal.
Además, hay que tener cuidado de usarlo en máquinas en las que no se confía, puesto que
__la contraseña se muestra en texto plano en los procesos en ejecución__, como en el
siguiente ejemplo (se ve `--pasphrase asdf`, en la última línea):
```sh
$ ps -elf | grep -i "encrypt_files"
0 S foo-man+ 31143 27198  0  80   0 -  1128 wait   12:33 pts/20   00:00:00 /bin/sh /usr/local/bin/encrypt_files encryption/
1 S foo-man+ 31154 31143  0  80   0 -  1128 wait   12:33 pts/20   00:00:00 /bin/sh /usr/local/bin/encrypt_files encryption/
0 S foo-man+ 31162 30455  0  80   0 -  3940 pipe_w 12:33 pts/17   00:00:00 grep --color=auto -i encrypt_files
$ pstree -a 31143
encrypt_files /usr/local/bin/encrypt_files encryption/
  └─encrypt_files /usr/local/bin/encrypt_files encryption/
      └─gpg --passphrase asdf --output encryption/hmHc3ntwOx.enc --symmetric encryption/large_file.zip
```


Este pequeño _script_ usa GPG y OpenSSL para cifrar uno a uno todos los ficheros en un
directorio dado, y luego destruye los originales. El nombre de los directorios también se
encripta.

Por supuesto, el _script_ también soporta el descifrado, con la opción `-d`.

### Ejemplo de uso

Para estos ejemplos, la estructura de directorios usada es la que se crea con `jekyll new
encryption_test`:
```
encryption_test/
├── 404.html
├── about.md
├── _config.yml
├── Gemfile
├── .gitignore
├── index.md
└── _posts
    └── 2017-08-30-welcome-to-jekyll.markdown
```

Cuando se encripta, obtenermos la misma estructura de directorios, pero con los nombres
cifrados (hay que notar que se ha ejecutado con las opciones para que muestre todos los
mensajes posibles):
```sh
$ encrypt_files encryption_test/ -vv

 ----------------
 Encrypting files
 ----------------

==> Encrypting 'encryption_test/_config.yml'
gpg: using cypher AES
gpg: writing to 'encryption_test/a1ZmOTv7Zg.enc'
 ----> DONE <----
shred: encryption_test/_config.yml: pass 1/3 (random)...
shred: encryption_test/_config.yml: pass 2/3 (random)...
shred: encryption_test/_config.yml: pass 3/3 (random)...
==> Encrypting 'encryption_test/index.md'
gpg: using cypher AES
gpg: writing to 'encryption_test/Uy5MvTDkpX.enc'
 ----> DONE <----
shred: encryption_test/index.md: pass 1/3 (random)...
shred: encryption_test/index.md: pass 2/3 (random)...
shred: encryption_test/index.md: pass 3/3 (random)...
==> Encrypting 'encryption_test/about.md'
gpg: using cypher AES
gpg: writing to 'encryption_test/3vahSDieaZ.enc'
 ----> DONE <----
shred: encryption_test/about.md: pass 1/3 (random)...
shred: encryption_test/about.md: pass 2/3 (random)...
shred: encryption_test/about.md: pass 3/3 (random)...
==> Encrypting 'encryption_test/2017-08-30-welcome-to-jekyll.markdown'
gpg: using cypher AES
gpg: writing to 'encryption_test/jEpgQ53f1B.enc'
 ----> DONE <----
shred: encryption_test/_posts/2017-08-30-welcome-to-jekyll.markdown: pass 1/3 (random)...
shred: encryption_test/_posts/2017-08-30-welcome-to-jekyll.markdown: pass 2/3 (random)...
shred: encryption_test/_posts/2017-08-30-welcome-to-jekyll.markdown: pass 3/3 (random)...
==> Encrypting 'encryption_test/Gemfile'
gpg: using cypher AES
gpg: writing to 'encryption_test/3U3ZPiwlFd.enc'
 ----> DONE <----
shred: encryption_test/Gemfile: pass 1/3 (random)...
shred: encryption_test/Gemfile: pass 2/3 (random)...
shred: encryption_test/Gemfile: pass 3/3 (random)...
==> Encrypting 'encryption_test/404.html'
gpg: using cypher AES
gpg: writing to 'encryption_test/5OKMYJVl9m.enc'
 ----> DONE <----
shred: encryption_test/404.html: pass 1/3 (random)...
shred: encryption_test/404.html: pass 2/3 (random)...
shred: encryption_test/404.html: pass 3/3 (random)...
==> Encrypting 'encryption_test/.gitignore'
gpg: using cypher AES
gpg: writing to 'encryption_test/neoI4uqQy1.enc'
 ----> DONE <----
shred: encryption_test/.gitignore: pass 1/3 (random)...
shred: encryption_test/.gitignore: pass 2/3 (random)...
shred: encryption_test/.gitignore: pass 3/3 (random)...

 ----------------------
 Encrypting directories
 ----------------------

==> Encrypting 'encryption_test/_posts'
 ----> DONE <----
==> Encrypting 'encryption_test/encryption_test'
 ----> DONE <----
New encrypted directory name: 'KNQWY5DFMRPV6SQKYTE53CFV2RLCDSGP66HTLWFWO6FKJPYVHY======.enc'
 ==> DONE <==
```

Aunque no se muestra, el programa pide una contraseña para cifrarlo todo, tal y como lo
hace GPG; pero esos mensajes son borrados para imprimir otros nuevos.

Esta es la nueva estructura de directorios:
```
$ tree KNQWY5DFMRPV6SQKYTE53CFV2RLCDSGP66HTLWFWO6FKJPYVHY\=\=\=\=\=\=.enc/
KNQWY5DFMRPV6SQKYTE53CFV2RLCDSGP66HTLWFWO6FKJPYVHY======.enc/
├── 3U3ZPiwlFd.enc
├── 3vahSDieaZ.enc
├── 5OKMYJVl9m.enc
├── a1ZmOTv7Zg.enc
├── KNQWY5DFMRPV657M5PAEBYZOOLGVWWOBN7JQ====.enc
│   └── jEpgQ53f1B.enc
├── neoI4uqQy1.enc
└── Uy5MvTDkpX.enc
```

Luego, para desencriptar (esta vez sólo con una `-v`), sólo tenemos que añadir la opción
extra para el descifrado:
```sh
$ encrypt_files -dv KNQWY5DFMRPV6SQKYTE53CFV2RLCDSGP66HTLWFWO6FKJPYVHY\=\=\=\=\=\=.enc/

 ----------------
 Decrypting files
 ----------------

==> Decrypting 'KNQWY5DFMRPV6SQKYTE53CFV2RLCDSGP66HTLWFWO6FKJPYVHY======.enc/3U3ZPiwlFd.enc'
gpg: AES encrypted data
gpg: encrypted with 1 passphrase
gpg: original file name='Gemfile'
 ----> DONE <----
==> Decrypting 'KNQWY5DFMRPV6SQKYTE53CFV2RLCDSGP66HTLWFWO6FKJPYVHY======.enc/a1ZmOTv7Zg.enc'
gpg: AES encrypted data
gpg: encrypted with 1 passphrase
gpg: original file name='_config.yml'
 ----> DONE <----
==> Decrypting 'KNQWY5DFMRPV6SQKYTE53CFV2RLCDSGP66HTLWFWO6FKJPYVHY======.enc/KNQWY5DFMRPV657M5PAEBYZOOLGVWWOBN7JQ====.enc/jEpgQ53f1B.enc'
gpg: AES encrypted data
gpg: encrypted with 1 passphrase
gpg: original file name='2017-08-30-welcome-to-jekyll.markdown'
 ----> DONE <----
==> Decrypting 'KNQWY5DFMRPV6SQKYTE53CFV2RLCDSGP66HTLWFWO6FKJPYVHY======.enc/5OKMYJVl9m.enc'
gpg: AES encrypted data
gpg: encrypted with 1 passphrase
gpg: original file name='404.html'
 ----> DONE <----
==> Decrypting 'KNQWY5DFMRPV6SQKYTE53CFV2RLCDSGP66HTLWFWO6FKJPYVHY======.enc/neoI4uqQy1.enc'
gpg: AES encrypted data
gpg: encrypted with 1 passphrase
gpg: original file name='.gitignore'
 ----> DONE <----
==> Decrypting 'KNQWY5DFMRPV6SQKYTE53CFV2RLCDSGP66HTLWFWO6FKJPYVHY======.enc/Uy5MvTDkpX.enc'
gpg: AES encrypted data
gpg: encrypted with 1 passphrase
gpg: original file name='index.md'
 ----> DONE <----
==> Decrypting 'KNQWY5DFMRPV6SQKYTE53CFV2RLCDSGP66HTLWFWO6FKJPYVHY======.enc/3vahSDieaZ.enc'
gpg: AES encrypted data
gpg: encrypted with 1 passphrase
gpg: original file name='about.md'
 ----> DONE <----

 ----------------------
 Decrypting directories
 ----------------------

==> Decrypting 'KNQWY5DFMRPV6SQKYTE53CFV2RLCDSGP66HTLWFWO6FKJPYVHY======.enc/KNQWY5DFMRPV657M5PAEBYZOOLGVWWOBN7JQ====.enc'
 ----> DONE <----
==> Decrypting 'KNQWY5DFMRPV6SQKYTE53CFV2RLCDSGP66HTLWFWO6FKJPYVHY======.enc'
 ----> DONE <----
New decrypted directory name: 'encryption_test'
 ==> DONE <==
```

Y obtenemos de nuevo el árbol de directorios original, con los archivos desencriptados:
```
$ tree encryption_test/
encryption_test/
├── 404.html
├── about.md
├── _config.yml
├── Gemfile
├── index.md
└── _posts
    └── 2017-08-30-welcome-to-jekyll.markdown
```

----

Este proyecto no está almacenado en ningún sitio más que
[aquí](/assets/projects/encrypt_files.sh), donde se puede descargar para ser usado y
modificado libremente. Por supuesto, hay mucho sitio para mejoras; así que todo el mundo
es bienvenido a contribuir, si quiere.
