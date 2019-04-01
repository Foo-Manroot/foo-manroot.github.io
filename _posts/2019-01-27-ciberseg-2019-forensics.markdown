---
layout: post
title:  "Ciberseg 2019: forensics"
date:	2019-01-27 15:54:54 +0100
author: foo
categories: ctf ciberseg write-up forensics
ref: ciberseg-2019-forensics
---

In this post I will explain my solutions for the challenges on the Ciberseg '19 CTF.
Specifically, these are the ones corresponding to the **exploiting** category.

[Ciberseg](https://ciberseg.uah.es/) is an annual congress which takes place in the
University of Alcalá de Henares. The truth is that previous years it has been always fun,
and this year wasn't less :) Also, the first places were disputed hard and there were
last-time surprises :D (in the end, I literally won at the last hour by just a few
points).

Anyways, these are the challenges and their solutions. For those that need it, I'll also
leave the necessary resources that we where given to try the challenge by yourselves.

-----------------------------------------------------------------------------------------

# 1.- Exfiltration files (25 points)

The description of the first challenge states:
> We have intercepted this photo seems to hide some message.


This is the image they give us:
{% include image.html
	src="/assets/posts/2019-01-23-ciberseg-2019-forensics/imagen.jpg"
	title="Initial image of the challenge"
	alt="Two racing cars viewed from the front"
%}

If we search with `binwalk`, we can find that there's an image inside:
```sh
$ binwalk imagen.jpg

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             JPEG image data, JFIF standard 1.01
51961         0xCAF9          JPEG image data, EXIF standard
51973         0xCB05          TIFF image data, big-endian, offset of first image directory: 8
71107         0x115C3         Unix path: /www.w3.org/1999/02/22-rdf-syntax-ns#"> <rdf:Description rdf:about="" xmlns:xmp="http://ns.adobe.com/xap/1.0/" xmlns:xmpMM="http
74915         0x124A3         Copyright string: "Copyright 1999 Adobe Systems Incorporated"
```

However, it can't extract the information. I don't know the reasons why _binwalk_
sometimes extracts the information and sometimes it doesn't. Anyway, we can execute
`dd id=imagen.jpg of=imagen_extracted.jpg bs=51961 skip=1` to get the embedded image.
Then, we just simply open the new image and we get the solution:
{% include image.html
	src="/assets/posts/2019-01-23-ciberseg-2019-forensics/imagen_extracted.jpg"
	title="Extracted image"
	alt="Image with the flag written: 'flag{RapidoYFurioso}'"
%}

Another way to solve it is by searching for the strings:
```sh
$ strings imagen.jpg | grep -Poi 'flag{[^}]*}'
flag{RapidoYFurioso}
flag{RapidoYFurioso}
```

Whatever the method you use, the _flag_ is: `flag{RapidoYFurioso}`.

-----------------------------------------------------------------------------------------

# 2.- Break the gesture (50 points)

This challenge had no description. It simply contained a file:
[gesture.key](/assets/posts/2019-01-23-ciberseg-2019-forensics/gesture.key).


Although it took me some time to figure out, this file is the one used by Android to
store the terminal's unlock pattern.

To decrypt the pattern, we can use any tool out there. For example, I used
[androidpatternlock](https://github.com/sch3m4/androidpatternlock) and it cracks it in a
couple of seconds:
```sh
$ time python2 aplc.py ../gesture.key

################################
# Android Pattern Lock Cracker #
#             v0.2             #
# ---------------------------- #
#  Written by Chema Garcia     #
#     http://safetybits.net    #
#     chema@safetybits.net     #
#          @sch3m4             #
################################

[i] Taken from: http://forensics.spreitzenbarth.de/2012/02/28/cracking-the-pattern-lock-on-android/

[:D] The pattern has been FOUND!!! => 210345876

[+] Gesture:

  -----  -----  -----
  | 3 |  | 2 |  | 1 |
  -----  -----  -----
  -----  -----  -----
  | 4 |  | 5 |  | 6 |
  -----  -----  -----
  -----  -----  -----
  | 9 |  | 8 |  | 7 |
  -----  -----  -----

It took: 1.1906 seconds

real	0m1.251s
user	0m3.894s
sys	0m0.084s
```

And that's it. It goes no more difficult than this.

The _flag_ is: `flag{210345876}`.

-----------------------------------------------------------------------------------------

# 3.- Pcap (250 points)

The description for this challenge states:
> I think they took something. ¿Can you tell me the name of the file?

Also, there's
[this network capture](/assets/posts/2019-01-23-ciberseg-2019-forensics/captura.zip)
attached.


When reading it with _Wireshark_ we see that there are a lot of different packets (TCP,
HTTPS...). If we order them from bigger to smaller, hoping that the exfiltrated file is
big enough to stand out, we see a couple of TCP packets carrying something that seems
like Base64:
{% include image.html
	src="/assets/posts/2019-01-23-ciberseg-2019-forensics/pcap-tcp.jpg"
	title="Packets as seen with Wireshark"
	alt="TCP packet with Base64 in its data field"
%}

If we follow this conversation, we can see that there's more data. After extracting and
decoding them we obtain something that is most likely an hex dump:
```
$ base64 -d b64
37 7A BC AF 27 1C 00 04 65 3D 77 8C 58 0F 00 00 00 00 00 00 6A 00 00 00 00 00 00 00 ...
```


This dump corresponds to a 7z file that we have to study to see whhich data have been
exfiltrated:
```sh
$ base64 -d b64 | tr -d '\r\n\t ' | xxd -r -ps > file.7z
$ file file.7z
file.7z: 7-zip archive data, version 0.4
$ 7z l file.7z

(...)
Scanning the drive for archives:
1 file, 4066 bytes (4 KiB)

Listing archive: file.7z

--
(...)
   Date      Time    Attr         Size   Compressed  Name
------------------- ----- ------------ ------------  ------------------------
2018-11-21 16:13:51 ....A        19385         3928  credit_cards.txt
------------------- ----- ------------ ------------  ------------------------
2018-11-21 16:13:51              19385         3928  1 files

```


And that's it. There's only one file inside the archive: `credit_cards.txt`.

The _flag_ is: `flag{credit_cards.txt}`

-----------------------------------------------------------------------------------------

# 4.- Pcap2 (300 points)

The description of this challenge says:
> No network traffic


And attached it's [this](/assets/posts/2019-01-23-ciberseg-2019-forensics/captura2.zip)
capture.


When opening it we see that it's a USB capture. I know that I'm supposed to extract the
ID of the USB we're interested in, to study the values and whatnot; but I didn't feel
like doing all that work and I opted by searching some script over the internet, as this
is a very common challenge and it's usually a matter of extracting the keyboard's
pressings. If you prefer a more detailed explanation, you can take a look at
[this](https://xbytemx.github.io/post/ciberseg19-writeups/#pcap2-300pts) write-ups by
**@xbytemx**, another one of this CTF participants. Explained very clearly, it's easy
to follow.

Anyways, the thing is that I used this script, which I ~~copied~~ adapted from
[this article](https://medium.com/@ali.bawazeeer/kaizen-ctf-2018-reverse-engineer-usb-keystrok-from-pcap-file-2412351679f4):
```python
# Sacado de
# https://medium.com/@ali.bawazeeer/kaizen-ctf-2018-reverse-engineer-usb-keystrok-from-pcap-file-2412351679f4

newmap = {
  2: "PostFail",
  4: "a",  5: "b",  6: "c",  7: "d",  8: "e",  9: "f", 10: "g", 11: "h", 12: "i",
 13: "j", 14: "k", 15: "l", 16: "m", 17: "n", 18: "o", 19: "p", 20: "q", 21: "r",
 22: "s", 23: "t", 24: "u", 25: "v", 26: "w", 27: "x", 28: "y", 29: "z", 30: "1",
 31: "2", 32: "3", 33: "4", 34: "5", 35: "6", 36: "7", 37: "8", 38: "9", 39: "0",
 40: "Enter", 41: "esc", 42: "del", 43: "tab", 44: "space",
 45: "-", 47: "[", 48: "]", 56: "/",
 57: "CapsLock", 79: "RightArrow", 80: "LetfArrow"
}

myKeys = open('hexoutput.txt')
i = 1
for line in myKeys:
    bytesArray = bytearray.fromhex(line.strip())
#    print "Line Number: " + str (i)
    for byte in bytesArray:
        if byte != 0:
            keyVal = int(byte)

            if keyVal in newmap:
#                print "Value map: " + str (keyVal) + " --> " + newmap [keyVal]
                print newmap[keyVal]
            else:
#                print "No map found for this value: " + str(keyVal)
                print format(byte, '02X')
    i+=1
```

Exporting the CSV with Wireshark (as that post says) and decoding the values returns the
solution:
```sh
$ python2 decode.py
f
l
l
a
a
a
g
g
PostFail
PostFail
[
PostFail
u
u
s
s
b
m
o
n
i
t
t
o
o
r
PostFail
PostFail
]
PostFail
```

I don't know why the value is repeated, because I didn't bothered to know how keyboard
interruptions work and how are they captured in a pcap, though maybe I should...

The _flag_ is: `flag{usbmonitor}`

-----------------------------------------------------------------------------------------

# 5.- I think I'm being spied on... (350 points)

The description of this challenge states:
> We suspect that the Android device has been compromised and we want you to investigate
> it. For this we give you the data partition and we need to know which is the APK that
> has infected it.


And, attached, we have the device's [memory image](/assets/posts/2019-01-23-ciberseg-2019-forensics/imagen_data.E01.7z)


Instead of opening it with _Autopsy_ we can decompress the image using `ewfmount` and
then mount it like a usual device. Once it's mounted, we start navigating through the
filesystem. Our first stop is the `app` directory, which seems to have a couple of
candidate APKs, but they're there only to distract us.

What we really want to do is to look at the installed applications (namely, the ones
under `/data/`). However, only a handful of them have data and only a couple of them are
installed by the use. The rest of them are the ones installed by default to use the
system (phone, contacts, etc.); so, instead of searching for the malicious application,
we can instead try to look for the **entry point** of this application. The more
promising candidates are: `com.android.email` and `com.android.browser`.

After analyzing the mail application we see that it's clean, so we look then at our
second option: the browser.

Just going into `/data/com.android.browser/` and listing its contents, we can see a
strange file called `wCLxU.dex`.
_Spoiler alert!_ This is our malicious application.
I didn't notice at first, so let's pretend that we didn't see that...


Poking around the DB inside `databases/` we see one file called _browser2.db_ where we
can see something quite interesting:
```
sqlite> select * from history;
(...)
_id	title						url					     created	date		visits	user_entered
8	http://192.168.74.128/i6ADxOqMEyyI		http://192.168.74.128/i6ADxOqMEyyI		0	1516629327266	1	0
9	http://192.168.74.128/i6ADxOqMEyyI/EeMVfx/	http://192.168.74.128/i6ADxOqMEyyI/EeMVfx/	0	1516629327667	1	0
```

This feels like we're on the right track. Apparently, someone downloaded a file from a
directory with a weird name from a server that doesn't even have a domain name, because
it requested it directly by IP (which, additionally, belongs to a private network). This
is most likely the entry point we were looking for.

Knowing that the user downloaded the wicked app, we start to dig into
`cache/webviewCacheChromium/`, as that's where the browser's cache seems to be stored.
Knowing that we're looking for a `.apk` file, we can _grep_ and hope for a short set of
results:
```sh
$ grep -PoR '[A-Za-z0-9]*[.]apk' .
./f_0000d6:wCLxU.apk
./f_0000d7:graphilos.apk
./f_0000d7:graphilos.apk
./f_0000d7:graphilos.apk
./f_0000d7:graphilos.apk
./f_0000d7:graphilos.apk
./f_0000d7:graphilos.apk
./f_0000d7:graphilos.apk
./f_0000d7:graphilos.apk
./f_0000d7:graphilos.apk
./f_0000d7:heagoo.apk
./f_0000d7:heagoo.apk
./f_0000d7:heagoo.apk
./f_0000d7:heagoo.apk
./f_0000d7:heagoo.apk
./f_0000d7:heagoo.apk
./f_0000d7:heagoo.apk
./f_0000d7:heagoo.apk
./f_0000d7:heagoo.apk
./f_0000d7:com.apk
./f_0000d7:com.apk
./f_0000d7:com.apk
./f_0000d7:com.apk
./f_0000d7:com.apk
./f_0000d7:com.apk
./f_0000d7:com.apk
./f_0000d7:com.apk
./f_0000d7:com.apk
./f_0000d7:www.apk
./f_0000d7:www.apk
./f_0000d7:www.apk
./f_0000d7:www.apk
./f_0000d7:www.apk
./f_0000d7:www.apk
./f_0000d7:www.apk
./f_0000d7:www.apk
./f_0000d7:www.apk
./f_0000d7:www.apk
./f_0000d7:www.apk
./f_0000d7:.apk
```

_Et voilà!_ Of all the results, the most suspicious one is the first, `wCLxU.apk`. Do you
remember that file we saw called `wCLxU.dex`? Well, now is when something goes _click_ in
my head and I realize that I've been losing an hour digging inside the damned browsing
history, when the solution was right in front of my eyes....

Anyway... The _flag_ is: `flag{wCLxU.apk}`

-----------------------------------------------------------------------------------------


And without even realizing it, we've already finished all the forensics challenges :)

I always enjoy Ciberseg's challenges, and this year they were over the top. I hope to
have time to compete next year. I'm sure they'll excel again :)

I also want to congratulate the organizers for all their effort and their creativity to
design challenges that differ from the usual.
