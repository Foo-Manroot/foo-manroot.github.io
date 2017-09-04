---
layout: post
title:  "Ciberseg '17 write-ups: forensics"
date:	2017-08-13 10:32:29 +0200
author: foo
categories: ctf ciberseg write-up forensics
ref: ciberseg-forensics
---


These are the forensics challenges that formed part of the
[CTF](https://ciberseg.uah.es/ctf.html) organized at the
[Ciberseg 2017](https://ciberseg.uah.es), a conference about cibersecurity that takes
place every year in our university.


Last year was the first edition (hopefully, there will be more, as it was pretty fun) of
the CTF (and I won the first price, btw :D).


## First challenge: Living in the fast lane

### Materials

For this challenge, we were given a game that can be downloaded on the following versions
  - [GNU/Linux](/assets/posts/2017-08-13-ciberseg-forensics/Living-in-the-fast-Lain-1.0-dists/Living-in-the-fast-Lain-1.0-linux.tar.bz2)
  - [Windows](/assets/posts/2017-08-13-ciberseg-forensics/Living-in-the-fast-Lain-1.0-dists/Living-in-the-fast-Lain-1.0-mac.zip)
  - [MAC](/assets/posts/2017-08-13-ciberseg-forensics/Living-in-the-fast-Lain-1.0-dists/Living-in-the-fast-Lain-1.0-win.zip)

### The challenge

After examining all the files and searching for strings on them, without any result, we
can start trying to look on the game's assets.

This game was written with the [renpy engine](https://www.renpy.org/). This engine uses
a special file to store the data used on the game. In this file, `archive.rpa`, the
information is stored compressed. To uncompress it, we can use any of the available
tools, like [rpatool](https://raw.githubusercontent.com/Shizmob/rpatool/master/rpatool).

Uncompressing this file, we can see the following list of assets:
{% highlight sh linenos %}
$ ./rpatool -l archive.rpa
icon.png
resources/backgrounds/bedroom.jpg
resources/backgrounds/bedroom_dark.jpg
resources/backgrounds/dorm_hallway.jpg
resources/backgrounds/lecture_front.png
resources/backgrounds/lecture_hall.jpg
resources/backgrounds/menu.png
resources/backgrounds/uni.jpg
resources/characters/jobs/jobs.png
resources/characters/jobs/jobs_gun.png
resources/characters/jobs/jobs_gun_fire.png
resources/characters/jobs/jobs_side.jpg
resources/characters/lain/lain_relaxed_side.png
resources/characters/stallman/stallman.png
resources/characters/stallman/stallman_angry - Copy.png
resources/characters/stallman/stallman_angry.png
resources/characters/stallman/stallman_embarrassed.png
resources/characters/stallman/stallman_embarrassed_side.png
resources/characters/stallman/stallman_shocked.png
resources/characters/stallman/stallman_shocked_side.png
resources/characters/stallman/stallman_sicp.png
resources/characters/stallman/stallman_side.png
resources/characters/stallman/stallman_side_angry.png
resources/characters/torvalds/torvalds.png
resources/characters/torvalds/torvalds_angry.png
resources/characters/torvalds/torvalds_card.png
resources/characters/torvalds/torvalds_side.png
resources/flag.png
resources/music/main_menu.ogg
resources/sounds/breathing.ogg
resources/sounds/door-open.wav
resources/sounds/reee.ogg
$
{% endhighlight %}

And there it is, on line 29: `resources/flag.png`. And it's an image. That's why we
couldn't get the answer searching the strings.

Extracting the files gives us the following image with the answer:

![image with the flag](/assets/posts/2017-08-13-ciberseg-forensics/flag.png "Flag")

The flag is: `flag{4077fb6a74ea5a5b6ac7d0b74e5a379d}`


-----------------------------------------------------------------------------------------


## Second challenge: Mimikatz

### Materials

For this second challenge, we have to download a
[RAM image (159.5 MB)](https://drive.google.com/drive/folders
/0BzLA9WAiAXudNEZRYTgxZkxjWWM?usp=sharing), where we were told that maybe we could
'recover some passwords'. It seems that the flag is one of the passwords.

### The challenge

In this challenge we'll be using [volatility](http://www.volatilityfoundation.org/), a
framework for memory forensics tools. First of all, we're going to determine the profile
of the memory image, so we can perform the rest of the tests with accuracy. For that
purpose, we can use the plugin 'imageinfo':
```sh
$ volatility -f ram1.mem imageinfo
Volatility Foundation Volatility Framework 2.5
INFO    : volatility.debug    : Determining profile based on KDBG search...
          Suggested Profile(s) : Win7SP0x86, Win7SP1x86
                     AS Layer1 : IA32PagedMemoryPae (Kernel AS)
                     AS Layer2 : FileAddressSpace (./ram1.mem)
                      PAE type : PAE
                           DTB : 0x185000L
                          KDBG : 0x82961c30L
          Number of Processors : 1
     Image Type (Service Pack) : 1
                KPCR for CPU 0 : 0x82962c00L
             KUSER_SHARED_DATA : 0xffdf0000L
           Image date and time : 2017-01-09 13:03:38 UTC+0000
     Image local date and time : 2017-01-09 05:03:38 -0800

```

Even though it may be incorrect (in which case we should try another profile), lets start
working under the assumption of it being a Windows 7, ServicePack 0, x86 memory image.

At this point, there are two approaches we can follow.


#### First approach

The more direct method (but not the best one) is to dump all the passwords and try to
crack them, expecting that one of them has the format 'flag{...}'. With that goal in
mind, we first dump the passwords on the system:
```sh
$ volatility -f ram1.mem --profile Win7SP0x86 hashdump
Volatility Foundation Volatility Framework 2.5
Administrator:500:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
IEUser:1000:aad3b435b51404eeaad3b435b51404ee:ea0026d2bc07d7f56ea8e3599cabed43:::
```

Now, we just have to crack the hashes using any tool we want, like hashcat, using the
incremental filter `flag{?a?a?a?a?a?a?a?a?a?a}`, that will search all possibilities from
`flag{a}` to `flag{~~~~~~~~~~~}`. With this rule, the password is cracked in a couple of
hours. Nevertheless, this increment can (and should) be done manually, to avoid hashcat
to try passwords that doesn't end in '}'. This is not a problem until it reaches a mask
with 6 '?a' elements, where it takes hours to perform the search. Fortunately, we find
the flag on the first try using `hashcat -m 1000 -a 3 -o cracked ctf.hashes
flag{?a?a?a?a?a}`, taking only a couple of minutes:

![result of hashcat](/assets/posts/2017-08-13-ciberseg-forensics/hashcat-crack.png
"Cracked password by HashCat")


#### Second approach

As the challenge's name suggests, we could also use [mimikatz](https://github.com
/gentilkiwi/mimikatz), a tool to dump passwords of currently logged in users (exploiting
Windows vulnerabilities, of course). There is a
[plugin for volatility](https://github.com/RealityNet/hotoloti/blob/master
/volatility/mimikatz.py) that we can use; and we can obtain the answer in seconds:
```sh
$ volatility --plugins=/usr/share/volatility/contrib/plugins/ -f ram1.mem --profile=Win7SP0x86 mimikatz
Volatility Foundation Volatility Framework 2.5
Module   User             Domain           Password
-------- ---------------- ---------------- ----------------------------------------
wdigest  IEUser           IE8Win7          flag{cadia}
wdigest  IE8WIN7$         WORKGROUP
```

Anyway, the flag is: `flag{cadia}`.


-----------------------------------------------------------------------------------------


## Third challenge: TrueCrypt

### Materials

Again, we must [download (55 MB + 1.2 GB)](https://drive.google.com/drive/folders
/0BzLA9WAiAXudZ0RFTzN0MnB4bG8?usp=sharing) a RAM image and an encrypted "MyDocuments"
folder; and we have to recover the password from memory in order to decrypt this files.


### The challenge

For this challenge, we're going to use again the
[volatility framework](http://www.volatilityfoundation.org/), as the title of this
challenge suggests that it has something to do with TrueCrypt (maybe we have to find the
encryption keys...), and volatility has a couple of plugins to dump the passwords, that
are stored on memory in plaintext.

The image seems to be corrupt, because I can't read the data from it. Anyway, the
solution is quite simple: use the plugin `truecryptpassphrase` and dump the passphrase
to decrypt the file. The password should be `GetRektTrueCrypt7.0`. Then, we just have
to use TrueCrypt to decrypt `MyDocuments` and find the .txt file with the flag:
 `flag{useVeracrypt}`.


-----------------------------------------------------------------------------------------


## Fourth challenge: MrRobot

### Materials

For this challenge we only need [this zip file](/assets/posts
/2017-08-13-ciberseg-forensics/Light_of_the_Seven.zip), with an audio file inside.

### The challenge

After looking around for a bit, we can't find anything interesting (neither on the
metadata, searching for strings, nor on the spectrogram).

The name of this challenge gives us a clue, as the main character of the series
_Mr. Robot_ uses a program called [DeepSound](http://www.jpinsoft.net/DeepSound/) to
hide information on music files.

As the data is unencrypted, we can simply extract it and get the flag:

![extracted file](/assets/posts/2017-08-13-ciberseg-forensics/deepsound.png
"Secret data extracted using DeepSound")

And we have that last flag of this set of challenges:
`flag{thelannistersendtheirregards}`.
