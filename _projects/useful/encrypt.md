---
layout: project
title: "Encrypt directories"
tags: [sh, gpg, openssl]
lang: en
ref: projects-encrypt
---

## Recursive encryption of directories

This project was the product of the need I had of fully encrypting the contents of a
certain directory with a lot of files and subdirectories. I'm sure that the resulting
script may not the fastest tool, but it serves its main goal. Also, beware of using it
on untrusted machines, as __the password is shown in cleartext on the running
processes__, like on the following example (note the `--passphrase asdf`, on the last
line):
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

This little script uses GPG and OpenSSL to encrypt one by one all the files on the
given directory, and then shreds all the original files. The name of the directories are
encrypted, too.

Of course, the script also supports decryption, with the `-d` flag.

### Example usage

To the examples, the directory structure to be used is the one created with `jekyll new
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

When we encrypt it, we get the same directory structure, but with encrypted names (note
that this run has been made with extra verbosity):
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

Even though it's not shown, the program asks for a password to encrypt everything, as GPG
does; but this prompt is then erased to print new messages.

This is the new directory structure:
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

Then, to decrypt (this time with only one `-v` flag), we only have to provide the extra
flag for the decryption:

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

And we get again the original directory tree, with the decrypted files:
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

This project is not hosted anywhere but [here](/assets/projects/encrypt_files.sh), where
it can be downloaded and freely used and modified. Of course, there's a lot of room for
improvement, so you're very welcome to contribute, if you want to.
