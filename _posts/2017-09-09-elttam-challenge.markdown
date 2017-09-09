---
layout: post
title:  "Elttam challenge"
date:	2017-09-09 16:41:04 +0200
author: foo
categories: write-up challenge elttam
lang: en
ref: elttam-challenge
---

Some time ago I read an interesting post on the [Elttam](https://www.elttam.com.au/blog)
(an infosec company) blog, and I decided to take a look on the rest of the webpage.
I don't know how, but I ended on the [jobs section](https://www.elttam.com.au/careers/),
where a little challenge has to be completed before applying.

I didn't have any intention to apply, because I don't think I have the skills they're
searching for (basically, because I haven't even ended the degree yet...); but the
challenge seemed fun, so I decided to give it a shot.

---

**NOTE: I've changed some of the data to not reveal the real solution of the
challenge, although the methodology to solve it is exactly the same.**

---

## The challenge

{% include image.html
	src="/assets/posts/2017-09-09-elttam-challenge/challenge-screenshot.png"
	title="Screenshot of the challenge"
	alt="Screenshot of the challenge page"
%}


The first thing to do is to get the hexdump and reverse it, to see what data is being
represented. Maybe we can find some recognizable format. I'm doing everything in just
one step, so there's an extra `0d 0a 00` at the end (that doesn't affect us in any way):
```
$ cat - | tr -d "\n" | sed -e "s/ //g" | xxd -r -ps > dump.bin
2c 54 2d f0 0d 2a 08 00 27 c3 59 62 08 00 45 00
01 a1 f3 33 40 00 40 06 bd 8d c0 a8 7b 2d 68 69
6a 6b 88 90 00 50 c9 c9 77 90 1f e5 d2 bd 50 18
00 e5 8a 29 00 00 50 4f 53 54 20 2f 63 61 72 65
65 72 20 48 54 54 50 2f 31 2e 31 0d 0a 48 6f 73
74 3a 20 77 77 77 2e 65 6c 74 74 61 6d 2e 63 6f
6d 2e 61 75 0d 0a 55 73 65 72 2d 41 67 65 6e 74
3a 20 65 6c 74 74 61 6d 20 72 6f 63 6b 73 21 0d
0a 41 63 63 65 70 74 2d 4c 61 6e 67 75 61 67 65
3a 20 65 6e 2d 55 53 2c 65 6e 3b 71 3d 30 2e 35
0d 0a 41 63 63 65 70 74 2d 45 6e 63 6f 64 69 6e
67 3a 20 67 7a 69 70 2c 20 64 65 66 6c 61 74 65
0d 0a 43 6f 6f 6b 69 65 3a 20 5a 57 31 68 61 57
77 39 4d 57 4d 77 4d 44 41 30 4d 47 51 79 4e 54
41 77 4d 44 6b 78 4d 54 45 78 4d 44 51 77 4f 44
52 69 4d 44 59 77 59 54 41 34 4e 47 49 77 4e 44
45 77 0d 0a 43 6f 6e 74 65 6e 74 2d 54 79 70 65
3a 20 61 70 70 6c 69 63 61 74 69 6f 6e 2f 78 2d
77 77 77 2d 66 6f 72 6d 2d 75 72 6c 65 6e 63 6f
64 65 64 0d 0a 43 6f 6e 74 65 6e 74 2d 4c 65 6e
67 74 68 3a 20 38 31 0d 0a 43 6f 6e 6e 65 63 74
69 6f 6e 3a 20 63 6c 6f 73 65 0d 0a 0d 0a 71 3d
54 68 65 2b 65 6d 61 69 6c 2b 61 64 64 72 65 73
73 2b 69 73 2b 68 69 64 64 65 6e 2b 69 6e 2b 74
68 69 73 2b 72 65 71 75 65 73 74 26 62 6f 6e 75
73 3d 57 68 61 74 2b 69 73 2b 73 6f 75 72 63 65
2b 49 50 2b 61 64 64 72 65 73 73 0d 0a 0d 0a 00
$ xxd dump.bin
00000000: 2c54 2df0 0d2a 0800 27c3 5962 0800 4500  ,T-..*..'.Yb..E.
00000010: 01a1 f333 4000 4006 bd8d c0a8 7b2d 6869  ...3@.@.....{-hi
00000020: 6a6b 8890 0050 c9c9 7790 1fe5 d2bd 5018  jk...P..w.....P.
00000030: 00e5 8a29 0000 504f 5354 202f 6361 7265  ...)..POST /care
00000040: 6572 2048 5454 502f 312e 310d 0a48 6f73  er HTTP/1.1..Hos
00000050: 743a 2077 7777 2e65 6c74 7461 6d2e 636f  t: www.elttam.co
00000060: 6d2e 6175 0d0a 5573 6572 2d41 6765 6e74  m.au..User-Agent
00000070: 3a20 656c 7474 616d 2072 6f63 6b73 210d  : elttam rocks!.
00000080: 0a41 6363 6570 742d 4c61 6e67 7561 6765  .Accept-Language
00000090: 3a20 656e 2d55 532c 656e 3b71 3d30 2e35  : en-US,en;q=0.5
000000a0: 0d0a 4163 6365 7074 2d45 6e63 6f64 696e  ..Accept-Encodin
000000b0: 673a 2067 7a69 702c 2064 6566 6c61 7465  g: gzip, deflate
000000c0: 0d0a 436f 6f6b 6965 3a20 5a57 3168 6157  ..Cookie: ZW1haW
000000d0: 7739 4d57 4d77 4d44 4130 4d47 5179 4e54  w9MWMwMDA0MGQyNT
000000e0: 4177 4d44 6b78 4d54 4578 4d44 5177 4f44  AwMDkxMTExMDQwOD
000000f0: 5269 4d44 5977 5954 4134 4e47 4977 4e44  RiMDYwYTA4NGIwND
00000100: 4577 0d0a 436f 6e74 656e 742d 5479 7065  Ew..Content-Type
00000110: 3a20 6170 706c 6963 6174 696f 6e2f 782d  : application/x-
00000120: 7777 772d 666f 726d 2d75 726c 656e 636f  www-form-urlenco
00000130: 6465 640d 0a43 6f6e 7465 6e74 2d4c 656e  ded..Content-Len
00000140: 6774 683a 2038 310d 0a43 6f6e 6e65 6374  gth: 81..Connect
00000150: 696f 6e3a 2063 6c6f 7365 0d0a 0d0a 713d  ion: close....q=
00000160: 5468 652b 656d 6169 6c2b 6164 6472 6573  The+email+addres
00000170: 732b 6973 2b68 6964 6465 6e2b 696e 2b74  s+is+hidden+in+t
00000180: 6869 732b 7265 7175 6573 7426 626f 6e75  his+request&bonu
00000190: 733d 5768 6174 2b69 732b 736f 7572 6365  s=What+is+source
000001a0: 2b49 502b 6164 6472 6573 730d 0a0d 0a00  +IP+address.....
```

It turns out that it's a POST request, and there are a couple of clues on the parameters:
  - **q**: The email address is hidden in this request
  - **bonus**: What is source IP address

Now we must find those two things.

### Email address

As stated by the first clue, the email address has to be hidden somewhere on the request,
so we can try to find it first on the other parameters of the request... like the cookie.
Lets see what does that base64 encoded string decode to:
```sh
$ cat - | base64 -d
ZW1haWw9MWMwMDA0MGQyNTAwMDkxMTExMDQwODRiMDYwYTA4NGIwNDEw
email=1c00040d250009111104084b060a084b0410
```

Great! We have an email address that doesn't look like an address at all...
The address [**MUST**](https://tools.ietf.org/html/rfc5322#section-3.4.1) have a local
part (some string, using a subset of ASCII, to identify the mail account), an '@'
symbol, and then a domain string (using another, more restrictive, subset of ASCII).
Thus, that hexadecimal string that we're given has to be encoded or enciphered.

The tries to decode the string doesn't pay off, so lets have a closer look at the
string, taking for granted that it's a cipher, and start assuming that it's a simple
substitution cipher. As with any other cipher, the first thing is to count the different
used symbols:
```
String: 1c 00 04 0d 25 00 09 11 11 04 08 4b 06 0a 08 4b 04 10

Count:
    Symbol    Count
      1c       1
      00       2
      04       3
      0d       1
      25       1
      00       1
      09       1
      11       2
      04       2
      0a       1
      08       2
      4b       2
      06       1
      10       1
```

There's not a lot of information there... Maybe 0x04 is an 'e', but there's not enough
text to conclude anything.

Anyway, we can try to extract some information from there; because, as I said before, the
email addresses have a clearly defined format (`<local>@<domain>`), and the domain will
most likely be `elttam.au`, or `elttam.com.au`; or something like that.

If this is a monoalphabetic substitution (meaning that every character is enciphered
always with the same character) and the domain is `elttam.<something>`, that pattern
should be visible at the end of the string (the domain part).

There's only one position where a symbol is repeated two times, one after another (that
would be the 'tt' part of 'elttam'), so there's only one candidate:
```
1c 00 04 0d 25 00 09 11 11 04 08 4b 06 0a 08 4b 04 10
                e  l  t  t  a  m
```

With that info, we can try to recover some other parts of the text (again, only if our
initial assumption is right):
```
1c 00 04 0d 25 00 09 11 11 04 08 4b 06 0a 08 4b 04 10
                e  l  t  t  a  m           m     a
```

That's not much text; but enough to make us thing of one of the possible domains:
```
1c 00 04 0d 25 00 09 11 11 04 08 4b 06 0a 08 4b 04 10
                e  l  t  t  a  m  .  c  o  m  .  a  u
```

Now we can say with some confidence that we're on the right track. Now, we should recover
the encipherment method. One thing that can help us is to note that the cipher generates
binary data (non-printable characters), so it's almost sure that it's not about the
classical methods (Vigenère, Caesar...), but a relatively modern one, maybe operating at
the bit level. The first thing coming to our minds is
[Vernam](https://en.wikipedia.org/wiki/Gilbert_Vernam#The_Vernam_cipher). Now it's time
to test this hypothesis:
```sh
$ cat - > /dev/null
# Hex char codes (can be consulted with `man ascii`):
e -> 0x65
l -> 0x6c
t -> 0x74
a -> 0x61
m -> 0x6d
$ # First test to recover the key: 'e' xor 0x00 (obviously, it will be 'e')
$ printf "%#x\n" "$((0x65 ^ 0x00))"
0x65
$ # Second test: 'l' xor 0x09
$ printf "%#x\n" "$((0x6c ^ 0x09))"
0x65
$ # Okay, I'm going to say that the key is 0x65 ('e')
$ printf "%#x\n" "$((0x74 ^ 0x11))"
0x65
$ # Wow! What a surprise! I didn't expect it to be 0x65 at all...
$ printf "%#x\n" "$((0x61 ^ 0x04))"
0x65
```

Well, that's enough. Definitely, the algorithm used is to xor every character with 'e'.

Now, we only have to recover the whole address. I used this simple Python script:
```sh
#!/usr/bin/env python
# -*- coding: utf-8 -*-

import binascii

mail = "1c00040d250009111104084b060a084b0410"
key = ord ("e")

arr = [ mail [i:(i + 2)] for i in xrange (0, len (mail), 2) ]

xored = [ key ^ int (elem, 16) for elem in arr ]

print "Mail address: " \
    + "".join ( [ binascii.unhexlify (hex (x).lstrip ("0x")) for x in xored ] )
```

And we finnaly have the mail address (as I said before, that's not the real address):
```sh
$ ./decrypt_mail.py
Mail address: yeah@elttam.com.au
```

### The source IP

This is a simpler task, as we only have to read the bytes of packet and, as it has a
standarized format, get the source IP. To do that, we can use a tool like
[scapy](http://www.secdev.org/projects/scapy/) and simply build the packet with the
request and read the data:
```python
>>> data = open ("dump.bin").read ()
>>> Ether (data)
<Ether  dst=2c:54:2d:f0:0d:2a src=08:00:27:c3:59:62 type=0x800 |<IP  version=4L ihl=5L tos=0x0 len=417 id=62259 flags=DF frag=0L ttl=64 proto=tcp chksum=0xbd8d src=192.168.123.45 dst=104.105.106.107 options=[] |<TCP  sport=34960 dport=http seq=3385423760 ack=535155389 dataofs=5L reserved=0L flags=PA window=229 chksum=0x8a29 urgptr=0 options=[] |<Raw  load='POST /career HTTP/1.1\r\nHost: www.elttam.com.au\r\nUser-Agent: elttam rocks!\r\nAccept-Language: en-US,en;q=0.5\r\nAccept-Encoding: gzip, deflate\r\nCookie: ZW1haWw9MWMwMDA0MGQyNTAwMDkxMTExMDQwODRiMDYwYTA4NGIwNDEw\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: 81\r\nConnection: close\r\n\r\nq=The+email+address+is+hidden+in+this+request&bonus=What+is+source+IP+address\r\n\r\n' |<Padding  load='\x00' |>>>>>
```

And, just like that, we have the source and destination IP addresses (as the email, they
have been changed):
  - **Source**: 192.168.123.45
  - **Destination**: 104.105.106.107



That's all, folks!

I think it's good when sometimes  companies do these kind of challenges to filter out
candidates and avoid spam (just in case there's some bot scraping email addresses on
the wild). Also, it's quite fun and I enjoyed the time it took me to complete it.
