---
layout: post
title:  "Cybercamp 2018 write-ups: Medium"
date:	2018-10-14 16:21:34 +0200
author: foo
categories: ctf cybercamp write-up
ref: cybercamp-medium
---

Every year, the [INCIBE](https://www.incibe.es/en) (a Spanish agency whose goal is to
raise awareness on cybersecurity issues) organises the [CyberCamp](cybercamp.es)
congress.

These are the write-ups for the CTF quals that took place a couple of weeks ago. As the
results have already been announced[^1] and [they said that we can upload our
write-ups](https://twitter.com/CybercampEs/status/1048129712491569152), I'm writing here
my solutions for the challenges I solved. The materials for the challenges in this post
are available for download here:

  - [Challenge 5](/assets/posts/2018-10-14-cybercamp-medium/5_Medium.7z)
  - [Challenge 6](/assets/posts/2018-10-14-cybercamp-medium/6_Medium.7z)
  - [Challenge 7](/assets/posts/2018-10-14-cybercamp-medium/7_Medium.7z)
  - [Challenge 8](/assets/posts/2018-10-14-cybercamp-medium/8_Medium.7z)
  - [Challenge 9](/assets/posts/2018-10-14-cybercamp-medium/9_Medium.7z)
  - Challenge 10 was too big, so it's split in parts:
	- [Part 1](/assets/posts/2018-10-14-cybercamp-medium/10_Medium.7z.001)
	- [Part 2](/assets/posts/2018-10-14-cybercamp-medium/10_Medium.7z.002)
	- [Part 3](/assets/posts/2018-10-14-cybercamp-medium/10_Medium.7z.003)
	- [Part 4](/assets/posts/2018-10-14-cybercamp-medium/10_Medium.7z.004)
  - [Challenge 11](/assets/posts/2018-10-14-cybercamp-medium/11_Medium.7z)

Here, I'll explain my solutions for the challenges labelled as _medium_.

-----------------------------------------------------------------------------------------


## 5.- Wi-Fi things

The description of this challenge states:
```
The monitoring of wireless traffic of one of the networks of your organization has been
carried out. There is a suspicion that one of the users is logging into a website that is
phishing and supplanting the legitimate one. Your goal is to recover the credentials, the
FLAG will be the password that the user uses to login.
```

Well, let's open the provided `.pcap` file with Wireshark, and see what's in there...

{% include image.html
	src="/assets/posts/2018-10-14-cybercamp-medium/01.- Wireshark first recon.jpg"
	title="First open of the file"
	alt="Opening the provided file for the first time. With Wireshark, we can see a lot of raw 802.11 (Wi-Fi) frames."
%}

OK, no problem. We're on the _medium_ category. Did you thought it would be as easy as
opening the file and looking for HTTP? Yeah, I though that too :(
But worry not, because we're l33t hax0rs and we know how to crack Wi-Fi, right?

There are a lot of different tools to crack an AP's password; but now we're going to use
one of the most popular: `aircrack-ng`. Usually, we should discover the AP's BSSID to
compute the possible keys; but _aircrack-ng_ prompts us with a message to select the
desired AP and performs all calculations for us.

For a first try, we can use the default wordlist (at least on Unix-like systems),
`/usr/share/dict/words`, that contains a small dictionary that can be quickly checked:
```sh
$ aircrack-ng medium_5.cap -w /usr/share/dict/words

(...)

Passphrase not in dictionary

Quitting aircrack-ng...
```

Dammit... Let's use another, more powerful, bigger (and, thus, slower) dictionary: the
ultra famous _rockyou_. Instead of looking through the web looking for it, I just use the
[SecLists repository on Github](https://github.com/danielmiessler/SecLists), that
contains an enormous quantity of dictionaries, fuzzing rules, common usernames... I have
the repository cloned in my computer[^2], so I can use and update it whenever I need it.

Let's try again with this new dictionary:
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

YAY! After around 10 minutes we get the key: `iw4108604`. Now it's time to decrypt the
capture file. Again, we can do it in multiple ways (doing it from within Wireshark would
be an easy option). In this case, we're going to use another tool from the _aircrack-ng_
suite: `airdecap-ng`.
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

Now it's as easy as opening the file `medi_5-dec.pcap` and looking for the suspicious
HTTP traffic... Or maybe not. If we apply the display filter `HTTP` on Wireshark, we just
get only a message that seems to be a connection test, but no suspicious data is found.
We have to keep looking.

Fortunately, this file is small; but with larger ones is not feasible to look through
_all_ the capture. Hence, we need to use filters and reorder the packets using
Wireshark's tools. One thing to look, for example, is abnormally large packets, based on
which is the used protocol. For example, if we order the packets from heavier to lighter,
we see a strange ICMP _ping_ request with 605 Bytes of data _and no response_:

{% include image.html
	src="/assets/posts/2018-10-14-cybercamp-medium/01.2- Wireshark large ICMP.jpg"
	title="Inspecting the abnormally large ICMP packet"
	alt="While inspecting the decrypted capture, we can see an unusually large ICMP packet. Inspecting it, we can see that there's HTML data in it."
%}

The data of this suspicious packet seems to be an HTTP request. Copying the value gives
the data captured by the attacker (remember that our goal is to recover the stolen
credentials):
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

It seems that the phishing page was trying to disguise as the _Santander Bank_, and the
user _john_ was tricked to put its password (the flag): _qwertyFpass1234_.

As a side note, we could have completed this challenge in a way easier way (once the
packets has already been decrypted):
```sh
$ strings ../medium_5-dec.cap | grep -i pass
              <label class="lb02" for="password">Password
                <input class="it02" id="password" type="password" name="f_Login_Password" value="">
f_Login_Name=john&f_Login_Password=qwertyFpass1234&bt_Login=Submit&Login_Page=%2FLogin_Santander.a4dmc3[</label>
```
And we're done XD

Finally, the flag is `qwertyFpass1234`.


-----------------------------------------------------------------------------------------


## 6.- Unnecessary redundancy


The description of this challenge states:
```
Our experts have captured a pendrive containing these two files, but it seems that one of
them has suffered damage... (Answer: flag {X})
```

The two provided files are `secret.txt`, a binary file, and `key.pem`. The latter seems
to be the private key used to decrypt the former. However, the private key is not
complete :(
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

Before continuing with the challenge, we have to learn a few things about the format used
to store the information of a private key, because this is the key (he he) to solve the
problem.

There are two formats to store a private key: **PEM** and **DER**. In fact, it's just one
format; because a _PEM_ file is just base64'd _DER_ data with a header and a footer.
Thus, we have to understand how does _DER_ encoding works[^3].

As we all know, an RSA private key is composed (in theory) of the **modulo** and the
**private exponent**. However, in practice, the private key is composed of lots of other
parameters used to speed up the operations. The
[RFC 3447](https://tools.ietf.org/html/rfc3447#appendix-A.1.2) states that a private key
should have the following fields (ASN.1 encoded):
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

As you can see, there are redundant parameters (we only really need `n` and `e`).
This way, in our partial private key we may have enough information to decrypt the file.


Let's begin by creating a file, `partial_key.der`, with the known Bytes of our key:
```sh
$ base64 -d > partial_key.der
MIIBOwIBAAJBAMSwf+/I42wFwNpDQiGuv0fb9w5Ria2JJAjzrYEYKp4HAKB8nXxm
yGx6OWAhI+4PYFYT3pf95J/mg5buCvP19fMCAwEAAQJAKuxRnyR57PL8eSVAY1Vd
TPNF4QwOPZ62DHYRISEC++UtRemqE1eBPkRgswiJ91+r9y8EnVw/SvL4GYQmeovS
sQIhAOq8Heinxe4udriNOd35SgJV9e87YglCCIfCoAirR0qtAiEA1oIMcKaiRiUj
2S/Q4YFTNySdT+fH16huoSQrEapD9x8
base64: invalid input
```

The decoder complains about `invalid input`, because the last Base64 block is incomplete,
and it can't be used to recover the last Byte of information. However, we don't care
about it right now.

The next step is to interpret the Bytes with the described ASN.1 format. To do that, we
can either do it by hand (I'd rather not, please), or using one of the available
libraries to do it for us. In this case, I chose the Python library
[pyasn1](http://snmplabs.com/pyasn1/). Also, the [pyasn1gen](https://github.com/kimgr/asn1ate)
tool will be pretty useful to automate the process as much as possible.

These are the steps to get the information.

### Create the ASN.1 key definition and store it in a file, `pkcs1.asn`

We part from the original definition, the one in the RFC:
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

### Translate it into Python

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

### Load the class `RSAPrivateKey` into the interpreter & try to decode

We'll first need a couple of imports and read some data before trying to decode the file:
```python
>>> data = open ("partial_key.der", "rb").read ()
>>> from pyasn1.codec.der.decoder import decode as der_decoder
>>> from pkcs1 import RSAPrivateKey
```

Now we can try to decode:
```
>>> pk, rest = der_decoder (data, asn1spec = RSAPrivateKey ())
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/usr/local/lib/python3.5/dist-packages/pyasn1/codec/ber/decoder.py", line 1182, in __call__
    raise error.SubstrateUnderrunError('%d-octet short' % (length - len(substrate)))
pyasn1.error.SubstrateUnderrunError: 104-octet short
```

We didn't expected this error (`104-octet short`), right? I didn't; but I guessed that it
had something to do with the way ASN.1 works: at the beginning of a record, we put its
type (INTEGER, SEQ...). Next, we put its length ( **in octets** ), and then we start with
the value of the object itself. The message `104-octet short` is telling us that the
object is defined to have 104 octets more than it has. To solve this we could carefully
analyse `partial_key.der` to modify the record length and successfully decode it (in
which case we would be better decoding the object by hand)... Or we could just add 104
more octets of pure junk. Of course, I decided to do it by appending 104 Bytes from
`/dev/zero` :D
```sh
$ cp partial_key.der partial_key_append.der
$ cat /dev/zero | fold -w 140 | head -n 1 | tr -d '\n' >> partial_key_append.der
```

We can now continue with our efforts.

After some time without any luck (the library keeps giving errors), I almost give up...
Until I notice that I haven't tried to use OpenSSL's `asn1parse`. With the original key,
it said the same error as _pyasn1_ (`ASN1_get_object:too long`). However, with our new
key with zeroes appended, we can decode without any problem:
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

Obviously, the parser only tells us the objects it finds; but we know which are the
registers being parsed:
  - First comes the **SEQUENCE** _RSAPrivateKey_
  - Then, comes another _INTEGER_: the **version** (`0x00`)
  - The first data inside the _SEQUENCE_ is an _INTEGER_: the **modulus** (`0xC4B0...F5F3`)
  - The second item is another _INTEGER_: the **publicExponent** (`0x010001`)
  - Then, comes the **privateExponent** (`0x2AEC...D2B1`).

With this information we can already decrypt the message; but let's see what other data
is in the key:
  - The **prime1** (_p_): `0xEABC...4AAD`
  - The **prime2** (_q_): `0xD682...F71F`


We can check that <img src="https://latex.codecogs.com/svg.latex?\fn_cm p * q %3D n"
class="inline-math" alt="p * q = n"> and verify that we've got the correct data.

To decrypt the original message, we can now try use Python (again), and create a
private key to decrypt using OpenSSL[^4]. To do that, we're going to use Python's built-in
`Crypto.PublicKey.RSA` class:
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

To decrypt the file, we just have to use our new private key with OpenSSL:
```sh
$ openssl rsautl -inkey key_NEW.pem -in secret.txt -decrypt
flag{gk83h280fwlo2}
```

It turns out I lost a lot of time trying to use _pyasn1_, when in reality _openssl_ could
be used without problem...

After all the dead ends and thinking too much, we got the flag: `flag{gk83h280fwlo2}`


-----------------------------------------------------------------------------------------

[^1]: Unfortunately, I only got something around 2900-3000 points, while the minimum
    necessary to enter the finals was like 3100... :(


[^2]: It's very useful to [partially clone a git repo](https://stackoverflow.com/a/28039894),
     instead of downloading thousands of files you'll never use.

[^3]: This is just a quick explanation. If you need further information, you can visit
    [this useful page](https://tls.mbed.org/kb/cryptography/asn1-key-structures-in-der-and-pem),
    or just start by reading the Wikipedia entry.

[^4]: Technically, we should be able to decrypt using Python, with either
	`pow (msg, priv_exp, mod)` or `RSA.decrypt ()`; but, for some reason, it just
	spits junk. I guess OpenSSL adds something to the file and that's why we're
	unable to decrypt it...
