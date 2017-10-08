---
layout: post
title:  "Ciberseg '17 write-ups: crypto"
date:	2017-08-11 21:10:15 +0200
author: foo
categories: ctf ciberseg write-up crypto
ref: ciberseg-crypto
---


These are the cryptography challenges that formed part of the
[CTF](https://ciberseg.uah.es/ctf.html) organized at the
[Ciberseg 2017](https://ciberseg.uah.es), a conference about cibersecurity that takes
place every year in our university.


Last year was the first edition (hopefully, there will be more, as it was pretty fun) of
the CTF (and I won the first price, btw :D).


## First challenge

This was an easy challenge to solve, if we figure out the used method; but it was quite
tricky to realise the encipherment method.

The cryptogram is `MzkuM3gyLKA5K2AlrKO0ZS99`

Even though it may look hard to see it, as there is no padding (the final '=' symbol),
because the original message's bytes are aligned, the used alphabet makes one think
that it's base 64. Decoding the string, however, only reveals gibberish:
```sh
$ echo "MzkuM3gyLKA5K2AlrKO0ZS99" | base64 -d | xxd
00000000: 3339 2e33 7832 2ca0 392b 6025 aca3 b465  39.3x2,.9+`%...e
00000010: 2f7d                                     /}
```

For the second attempt, one can think that it may have been enciphered with some simple
method, like some transposition or monoalphabetic substitution, like Caesar cipher. In
fact, ROT13 (a special case of Caesar's, with a displacement of 13), looks like a good
candidate.


To decipher it using ROT13, one can use any service on the internet (in fact,
[duckduckgo](https://duckduckgo.com/html?q=rot13%20MzkuM3gyLKA5K2AlrKO0ZS99) answers with
the deciphered string to the query 'rot13 MzkuM3gyLKA5K2AlrKO0ZS99') or implement it by
your own.

The deciphered string is `ZmxhZ3tlYXN5X2NyeXB0MF99`

Now, the decoded string gives us the flag:
```sh
$ echo "ZmxhZ3tlYXN5X2NyeXB0MF99" | base64 -d | xxd
00000000: 666c 6167 7b65 6173 795f 6372 7970 7430  flag{easy_crypt0
00000010: 5f7d                                     _}
```

Finnaly, the flag is `flag{easy_crypt0_}`


-----------------------------------------------------------------------------------------


## Second challenge

The next callenge is the following ciphertext:
```
Pivfwrrk hl tairrvr cvkdr vk xnr lhceafa uw fiwjddf ernfsofrthtzud, ec ulfisgo uw
yixwqeiw hs ggoirdiaswwitg. Hs dmb ielhrvkdnkw dpiwqdvj hskg soiixe, rmqqlw hn cs
dckmdlzvdd eg ve lkh, nfk puvkwrr vh dffge mwqidgv. Lr xoax wv: fcsj{mvyxsksqlfkftw}
H.G. Sv vlcv ulfisu, nf wqciastrj.
```

Clearly, the bit of the string 'fcsj{mvyxsksglfkftw}' correspond with the plaintext
flag{...}. Also, it seems that it's enciphered with some substitution cipher. Another
important information is that the plaintext may be in spanish.

With this information, we can try to see if the encipherment method is the very common
Vigenère cipher. With this in mind, we can try to crack the key (or, at least, to reveal
a portion of it) with the bit of known plaintext.

<pre>
plaintext  =>  f l a g
ciphertext =>  f c s j
----------------------
key	   =>  a r s d
</pre>

The leaked part of the key seems to be "ARSD"

An important thing to note is that the name of one of the organizers is "DARS", so it may
be possible that the key is "DARS". Indeed, deciphering with this key gives us the
following message (in spanish):
```
Mientras el cifrado cesar es una tecnica de cifrado monoalfabetica, el cifrado de
vigenere es polialfabetico. Es muy interesante aprender esto porque, aunque en la
actualidad no se use, nos muestra de donde venimos. La flag es: flag{megustanlosctf}
P.D. se dice cifrar, no encriptar.
```

The flag is `flag{megustanlosctf}` (spanish for 'I like CTFs').


-----------------------------------------------------------------------------------------

## Third challenge

In this last challenge we are given three strings:
```
a522c8bf85a95c066bb2a8a85309c5c431652342
1e230c2310c38677c2d1f9bf358539616f2fd89a
c2b7df6201fdd3362399091f0a29550df3505b6a
```

Since all three strings has the same length and are in hexadecimal form, it seems that
they may be hashes; and, according to the length (20 Bytes), the used algorithm may be
SHA-1.

Using any online database, like [crackstation](https://crackstation.net/), we can find
the first and last part of the flag:

{% include image.html
	src="/assets/posts/2017-08-11-ciberseg-crypto/crackstation.jpg"
	title="Result obtained with CrackStation"
	alt="CrackStation result"
%}

Unfortunately, the middle part of the flag hasn't been found. However, we can use the
given clue, that it's like [UAH](https://www.uah.es)'s passwords (for those who don't
know it, the format is `[a-z]{3}[[:punct:]][0-9]{4}`). That makes the task easier. After
a couple of minutes, we have the answer:

{% include image.html
	src="/assets/posts/2017-08-11-ciberseg-crypto/cracked-hash.jpg"
	title="Result obtained with HashCat"
	alt="HashCat result"
%}

The last flag is `flag{uah#5674}`
