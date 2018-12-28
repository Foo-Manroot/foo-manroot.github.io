---
layout: post
title:  "Cybercamp 2018 write-ups: Medium (Part 2)"
date:	2018-12-26 20:32:53 +0100
author: foo
categories: ctf cybercamp write-up
ref: cybercamp-medium-2
---

In the [previous post]({% post_url 2018-10-14-cybercamp-medium %}) I only included the
challenges 5 and 6. As a lot of time has passed since, I decided to write a second
article with the rest of the _medium_ challenges.

-----------------------------------------------------------------------------------------

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


## 7.- Holidays

The description of this challenge states:
```
By order of a judge, a computer was intervened in the house of a suspected cybercriminal,
luckily his laptop was still on when the arrest occurred. It is known that he have tried
to delete evidences, but we believe that it is still possible to obtain some. What was
his nick in the network? (Answer: flag {NICK}).
```

We are provided with two files:
	- `dump.elf`: a 64-bit executable
	- `volume.bin`: a disk image


We'll start by mounting the disk image to see if we can recover anything. The first thing
to do when trying to mount an image is to look for the offset of the partition we want
to explore. For this purpose, `fdisk -l` come very handy:
```sh
$ fdisk -l volume.bin
Disk volume.bin: 64 MiB, 67108864 bytes, 131072 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x00000000

Device      Boot Start   End Sectors  Size Id Type
volume.bin1         63 16064   16002  7.8M 83 Linux
```

Note the value of _start_ sector and **multiply by 512**, because that's the size of a
sector and `mount` expects _Bytes_, not _sectors_. Then, to mount the image we can use
the following command:
```sh
$ sudo mount -o offset=32256 volume.bin mnt/
mount: ./mnt: unknown filesystem type 'crypto_LUKS'.
```

Oh, well... It seems that it won't be that easy :( The volume is encrypted using LUKS.
To mount it we'll have to figure out the password or recover it somehow.


Let's look at the other file, `dump.elf`.

At first glance, it seems like a normal 64-bit executable. It has the correct headers to
trick `file` into thinking that. However, if we look closer, we can see that it has a lot
of things in the inside, starting from a 64-bit executable. For example, with
[binwalk](https://github.com/ReFirmLabs/binwalk) we extract _a lot_ of things:
```
DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             ELF, 64-bit LSB core file AMD x86-64, version 1 (SYSV)
48047         0xBBAF          Copyright string: "Copyright (C) 1994-2015 H. Peter Anvin et al"
935207        0xE4527         Copyright string: "Copyright (C) 1997-2000 Intel Corporation"
935250        0xE4552         Copyright string: "Copyright (C) 2010-2017 Oracle Corporation"
1058104       0x102538        gzip compressed data, maximum compression, from Unix, NULL date (1970-01-01 00:00:00)
7094968       0x6C42B8        gzip compressed data, maximum compression, from Unix, NULL date (1970-01-01 00:00:00)
21275960      0x144A538       gzip compressed data, maximum compression, from Unix, NULL date (1970-01-01 00:00:00)
24771468      0x179FB8C       ELF, 32-bit LSB executable, Intel 80386, version 1 (SYSV)
87520568      0x5377538       Linux kernel version "4.14.52-0-virt (buildozer@build-3-8-x86) (gcc version 6.4.0 (Alpine 6.4.0)) #1-Alpine SMP Tue Jun 26 07:14:31 UTC 2018"
87654648      0x53980F8       CRC32 polynomial table, little endian
88712398      0x549A4CE       Unix path: /home/buildozer/aports/main/linux-vanilla/src/linux-4.14/init/main.c
(...)
```
It seems that it's some kind of dump. Maybe it's from the memory, where the keys to
decrypt the disk can be found? Let's use
[findaes](https://sourceforge.net/projects/findaes/) to, you guessed, find AES keys (LUKS
normally uses AES):
```sh
$ ./findaes ../../dump.elf
Searching ../../dump.elf
Found AES-256 key schedule at offset 0xe414ce8:
0a b4 d6 ef 72 82 6b c6 03 a8 89 9f 32 5b b6 7e 9b 32 41 77 1c fd 03 30 56 9a ce ab 16 f2 51 bd
Found AES-128 key schedule at offset 0xe4158f8:
84 bc d9 8c fc f2 de db 26 06 35 bf ca a9 a4 7d
```

_Et voilà_, we have two possible candidates. We have to wait to know which one to use.


We can't decrypt the normal file like that. We can only decrypt a _device file_. In Unix
filesystems everything is a file, and devices (disks, keyboards, mics...) aren't an
exception. However, there are different types of files (named pipes, regular files,
sockets...) To convert a _regular file_ into a _device file_ we use the _loop device_,
combined with the `losetup` utility. After executing
`sudo losetup /dev/loop0 volume.bin -o 32256` (remember that we want to decrypt the
partition that starts at sector 63) we may continue working with `/dev/loop0`.

Now that we have the partition ready, we can use the `cryptsetup` utility to gather more
information about the key that we should use:
```sh
$ sudo cryptsetup luksDump /dev/loop0
LUKS header information for /dev/loop0

Version:        1
Cipher name:    aes
Cipher mode:    cbc-essiv:sha256
Hash spec:      sha256
Payload offset: 2048
MK bits:        128
(...)
```

So, it's AES-128, so let's use that key:
```sh
$ printf "84 bc d9 8c fc f2 de db 26 06 35 bf ca a9 a4 7d" | tr -d ' ' | xxd -r -ps > key_file
$ sudo cryptsetup open /dev/loop0 cybercamp-7-decrypted --master-key-file key_file
$ sudo mount /dev/mapper/cybercamp-7-decrypted mnt/
$ ls -a mnt/
.  ..
```

Well, this is awkward... I was hoping to find something here, but it's empty. Or is it
not?

Hmmmm...

We know that the criminal tried to erase some evidences, so they maybe deleted the
contents of the disk but didn't really deleted (as in `shred`ing) them. If the files
hasn't been overwritten, they may still be there. There are a lot of tools to recover
"deleted" files. One of them is [scalpel](ihttps://github.com/sleuthkit/scalpel). Once it
ends its job, we are left with a single _.zip_ that seems to be encrypted, as `file`
returns the `Zip archive data, at least v1.0 to extract`.

As always, we have multiple ways to recover the password; but I'll use John The Ripper,
as it has a lot of tools to convert from different formats to the one used by JTR. In
this case we convert it with `zip2john` and then run `john <hash_file>`. In a matter of
seconds it extracts the password: `iloveyou`.

Then, we extract the file (using `7z`, as `unzip` doesn't support password-protected
files) and see the contents of the text file that was inside:
```sh
$ cat secret.txt
_z3r0.c00l!_ was here! :)
```

So we have recovered the nick, good job.
The flag is `flag{z3r0.c00l!}`

-----------------------------------------------------------------------------------------

## 8.- Oh, my GOd!


The description of this challenge states:
```
A code has been intercepted in the conversation between two criminals whose operation you
will have to figure out to get to the FLAG.
```

This challenge is way easier than the rest on this level, and only involves a Python
bytecode file, `medium_8.pyc`.

We may try to import it into a Python interpreter; but it's not advisable to simply run
any code without inspecting it first, especially in CTFs where we'll most probably have
to do it anyways...

To decompile Python bytecode[^2] I've used [pycdc](https://github.com/zrax/pycdc), which
it's simple to use and works pretty well:
```python
$ pycdc medium_8.pyc
# Source Generated with Decompyle++
# File: medium_8.pyc (Python 2.7)

print '$$$$$$$$$ ^-^ \xe2\x95\xa6 \xe2\x95\xa6\xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90\xe2\x94\xac  \xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90\xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90\xe2\x94\x8c\xe2\x94\xac\xe2\x94\x90\xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90  \xe2\x94\x8c\xe2\x94\xac\xe2\x94\x90\xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90  \xe2\x94\x8c\xe2\x94\xac\xe2\x94\x90\xe2\x94\xac \xe2\x94\xac\xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90  \xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90\xe2\x94\xac \xe2\x94\xac\xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90\xe2\x94\xac  \xe2\x94\xac  \xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90\xe2\x94\x8c\xe2\x94\x90\xe2\x94\x8c\xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90\xe2\x94\x8c\xe2\x94\x80\xe2\x94\x90'
print '              \xe2\x95\x91\xe2\x95\x91\xe2\x95\x91\xe2\x94\x9c\xe2\x94\xa4 \xe2\x94\x82  \xe2\x94\x82  \xe2\x94\x82 \xe2\x94\x82\xe2\x94\x82\xe2\x94\x82\xe2\x94\x82\xe2\x94\x9c\xe2\x94\xa4    \xe2\x94\x82 \xe2\x94\x82 \xe2\x94\x82   \xe2\x94\x82 \xe2\x94\x9c\xe2\x94\x80\xe2\x94\xa4\xe2\x94\x9c\xe2\x94\xa4   \xe2\x94\x82  \xe2\x94\x9c\xe2\x94\x80\xe2\x94\xa4\xe2\x94\x9c\xe2\x94\x80\xe2\x94\xa4\xe2\x94\x82  \xe2\x94\x82  \xe2\x94\x9c\xe2\x94\xa4 \xe2\x94\x82\xe2\x94\x82\xe2\x94\x82\xe2\x94\x82 \xe2\x94\xac\xe2\x94\x9c\xe2\x94\xa4 '
print '              \xe2\x95\x9a\xe2\x95\xa9\xe2\x95\x9d\xe2\x94\x94\xe2\x94\x80\xe2\x94\x98\xe2\x94\xb4\xe2\x94\x80\xe2\x94\x98\xe2\x94\x94\xe2\x94\x80\xe2\x94\x98\xe2\x94\x94\xe2\x94\x80\xe2\x94\x98\xe2\x94\xb4 \xe2\x94\xb4\xe2\x94\x94\xe2\x94\x80\xe2\x94\x98   \xe2\x94\xb4 \xe2\x94\x94\xe2\x94\x80\xe2\x94\x98   \xe2\x94\xb4 \xe2\x94\xb4 \xe2\x94\xb4\xe2\x94\x94\xe2\x94\x80\xe2\x94\x98  \xe2\x94\x94\xe2\x94\x80\xe2\x94\x98\xe2\x94\xb4 \xe2\x94\xb4\xe2\x94\xb4 \xe2\x94\xb4\xe2\x94\xb4\xe2\x94\x80\xe2\x94\x98\xe2\x94\xb4\xe2\x94\x80\xe2\x94\x98\xe2\x94\x94\xe2\x94\x80\xe2\x94\x98\xe2\x94\x98\xe2\x94\x94\xe2\x94\x98\xe2\x94\x94\xe2\x94\x80\xe2\x94\x98\xe2\x94\x94\xe2\x94\x80\xe2\x94\x98'
print '                                                                                    ^-^ $$$$$$$$$$'
import md5
SHA1 = [
    0xBA4439EE9A46D9D9F14C60F88F45F87L,
    0xDB0F6F37EBEB6EA09489124345AF2A45L,
    0x52A8CBE3663CD6772338701016AFD2DFL,
    0x56AB24C15B72A457069C5EA42FCFC640L,
    0xB61A6D542F9036550BA9C401C80F00EFL]
print 'If you are a good programer you know what you need to do to read the script'
Flag = raw_input('Please enter the flags: ')
if len(Flag) > 25:
    print 'The flag is to long'
    exit()
if len(Flag) % 5 != 0:
    print 'The flag is to short'
    exit()
if len(Flag) == 0:
    print 'Please enter the Flags'
    exit()
for r00t in range(0, len(Flag), 5):
    z3r0 = Flag[r00t:r00t + 5]
    if int('0x' + md5.new(z3r0).hexdigest(), 16) != SHA1[r00t / 5]:
        print 'try harder the next time'
        exit()
        continue
if len(Flag) == 25:
    print 'The Flag Is : ', Flag
    exit()
exit()
if len(Flag) / 25 != '0b1'[2:]:
    print 'try with binary'
    exit()
```

This **Python 2** code is quite easy to understand: it asks the user for an input,
`Flag`, that has to be 25 characters long and then performs some check in a loop. In this
loop, chunks of 5 characters are extracted from `Flag`. Then, asserts that the computed
MD5 of this chunk matches with a hard-coded hash, the ones stored in `SHA1` (the name is
obviously a distraction, as it clearly uses the `md5` module).

In the end, the flag is the concatenation of five words with five characters with a
particular MD5 hash.

So, we only have to crack these hashes to get the flag. Or, even better, use any of the
online databases that are available in the internet. After searching in a couple of them,
we arrive quickly to the result (ordered the same way they are checked):
```
0ba4439ee9a46d9d9f14c60f88f45f87 MD5 : check
db0f6f37ebeb6ea09489124345af2a45 MD5 : group
52a8cbe3663cd6772338701016afd2df MD5 : zezex
56ab24c15b72a457069c5ea42fcfc640 MD5 : happy
b61a6d542f9036550ba9c401c80f00ef MD5 : tests
```

Easy peasy, right? :)
The flag is `checkgroupzezexhappytests`.

-----------------------------------------------------------------------------------------

## 9.- Monkey Island

The description of this challenge states:
```
A computer belonging to the member of an APT has been seized, after a thorough forensic
analysis it has not been possible to obtain evidence that has been eliminated or
encrypted. The most significant content of the offender that has been recovered is a
video that they suspect may contain some type of criminal evidence. (The flag is
case sensitive)
```

The first thing I usually do with media files in CTFs, even before reading the challenge
description, is to use `binwalk`. Hiding a file inside another by simply concatenating
them is a technique so widely used (at least in CTFs) that I do it almost by instinct :D
It doesn't always find something; buy this time it does:
```
$ binwalk MonkeyIsland.avi

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
26013116      0x18CEDBC       Zip archive data, at least v2.0 to extract, compressed size: 613, uncompressed size: 811, name: bandera64.txt
26013883      0x18CF0BB       End of Zip archive
```

The extracted zip file contained a text file with some base64 encoded data:
```sh
$ cat bandera64.txt
UEsDBAoACQBjALpE5UyE1fPolAEAAHgBAAALAAsAYmFuZGVyYS5wbmcBmQcAAQBBRQMAAPKu8K6x
c7GJh/VmKva+f8JqD7Pe3X95ttenp+LwVVKiTrs1N450IIK7cjKsIYwqYBWiSwcClH2S51vh+L6/
xnICJFdIYuqD+sB282j0guUmoXbdIwU3dMtkYeUs/tOm7yd4TxHMfEQ2wM+i64R/iuhx9xvvh5PV
jnyPiKnjKPTQf9tH1XflKezQ8lHDAFPeEWZSMlRBaOwVWLywkiopyEYSuJGzJchCoRtiMX3fmfJX
8bD3SozBFIOPMjje/3/Xn6tVdmaaAVpAt8+iXu05VwXmmg8Ub7isi2KJBljiGMTQ+knFndW3gCEr
V3pk1OfNOGWAI09l5QXe6I+UKJZ5p9bpLi0fBbTHJCFcFu5y/IJHr9Vr5rzi6vpPU7p0ZtNJyYoK
EUB18DsmONtxc+xuqloJtzhRUQ5ZHRWumnfMk9Cw1tYT/KHa4gWh/GOVHLEAkizskRobAfanZ0OY
TfmYtjl/60UaL/sFkDYH4+uNt9MKLLiLR4WomoTq2Qi4o+EyzLDO0drgZXjsd1aN9s3EYkNY+Ug6
UEsHCITV8+iUAQAAeAEAAFBLAQIfAAoACQBjALpE5UyE1fPolAEAAHgBAAALAC8AAAAAAAAAIAAA
AAAAAABiYW5kZXJhLnBuZwoAIAAAAAAAAQAYAABwYYR+FNQBD0sSrJY51AHbTw9ChznUAQGZBwAB
AEFFAwAAUEsFBgAAAAABAAEAaAAAANgBAAAAAA==
```

Its name (_bandera_ means _flag_ in Spanish) suggests that decoding the base64 will give
us the flag. Let's see if it's true:
```sh
$ base64 -d bandera64.txt > decoded
$ file decoded
decoded: Zip archive data, at least v1.0 to extract
```

Dammit, it's an encrypted Zip file. But this is not the first time we encounter these
kind of files. Remember the [7th challenge](#7--holidays)?

Let's use the same tools again (`zip2john` and `john`) and try to crack it. There's no
clue as to which the password may be; so we start the usual way, trying first the common
dictionaries (`/usr/share/dict/words`, `rockyou`...). With our first try, we find the
password: `grog`.

From this zip file we extract a file named _bandera.png_ (_flag.png_ in Spanish). But I'm
just unable to know what this means:

{% include image.html
	src="/assets/posts/2018-12-26-cybercamp-medium-2/bandera.png"
	title="File extracted from the encrypted zip"
	alt="The image is a strange sequence of pixels (its size is 76 x 12 pixels) with different colours, but without any apparent order"
%}

Is this the flag? How do I enter the solution in the CTF webpage?

I was quite lost with this final step, so I decided to get a clue from the webpage, and
this is the clue:
```
The second message has been hidden with the PIET programming language
https://gabriellesc.github.io/piet/
```

Okay, this clue was really helpful. Now, it's just a matter of uploading this image into
the interpreter given on the clue and running it. It prints the message `THESevenSamurai`
which is also the flag.

Finally, the flag is `THESevenSamurai`.

-----------------------------------------------------------------------------------------

## 9.- Chicken Dinner

The description of this challenge states:
```
It is suspected that a colleague in your office is selling state secrets through a widely
used messaging application. You have been provided with the image of his Android
terminal with which you must retrieve and locate these messages. In them you will find
the FLAG you need.
```

To start this challenge, let's mount the provided image and start browsing the filesystem
a little bit. Remember to look up the partitions offset using `fdisk -l` and to multiply
by the sector size (512 Bytes) to tell `mount` the correct offset.

As we're trying to find some deleted messages, we need to locate potential apps that may
have been used. In this case, we find four of them:
	- WhatsApp
	- Telegram
	- Facebook Messenger
	- Instagram

Of these four, only Instagram and WhatsApp directories have any contents. The Instagram
app, however, seems to have only stored some local configurations and cache, but no
database of anything that could have messages in it; so let's take a closer look at
WhatsApp.

This is the content of the WhatsApp directory:
```
android-6.0-rc1/data/data/com.whatsapp/
├── app_minidumps
├── cache
├── databases
│   ├── _jobqueue-WhatsAppJobManager
│   └── _jobqueue-WhatsAppJobManager-journal
├── files
│   ├── Avatars
│   ├── key
│   ├── Logs
│   │   └── whatsapp.log
│   ├── rc2
│   ├── statistics
│   ├── .trash
│   └── wam.wam
├── no_backup
│   └── com.google.android.gms.appid-no-backup
└── shared_prefs
    ├── com.google.android.gms.appid.xml
    ├── com.google.android.gms.measurement.prefs.xml
    ├── com.whatsapp_preferences.xml
    ├── _has_set_default_values.xml
    ├── keystore.xml
    └── qr_data.xml
```

Unfortunately, there isn't anything over here. The only databases found there only have
some configuration values, but no messages. However, there's a file named _key_ that may
be useful in the future...


Another place where we could retrieve some data is from the user's home directory under
`/android-6.0-rc1/data/media`:
```
data/media
├── 0
├── DCIM
│   ├── Camera
│   ├── Screenshots
│   └── .thumbnails
├── obb
└── WhatsApp
    ├── Databases
    │   └── msgstore.db.crypt12
    ├── Media
    │   ├── WallPaper
    │   ├── WhatsApp Animated Gifs
    │   │   ├── Private
    │   │   │   └── .nomedia
    │   │   └── Sent
    │   │       └── .nomedia
    │   ├── WhatsApp Audio
    │   │   ├── Private
    │   │   │   └── .nomedia
    │   │   └── Sent
    │   │       └── .nomedia
    │   ├── WhatsApp Documents
    │   │   ├── Private
    │   │   │   └── .nomedia
    │   │   └── Sent
    │   │       └── .nomedia
    │   ├── WhatsApp Images
    │   │   ├── Private
    │   │   │   └── .nomedia
    │   │   └── Sent
    │   │       └── .nomedia
    │   ├── WhatsApp Profile Photos
    │   ├── WhatsApp Stickers
    │   │   └── .nomedia
    │   ├── WhatsApp Video
    │   │   ├── Private
    │   │   │   └── .nomedia
    │   │   └── Sent
    │   │       └── .nomedia
    │   └── WhatsApp Voice Notes
    │       ├── 201815
    │       │   └── .nomedia
    │       └── .nomedia
    ├── .Shared
    └── .trash
```

That's a BINGO! Well, sort of... We can see that there's a file named _msgstore.db_...
With a _crypt12_ extension :(

Though an extension by itself doesn't mean anything, a quick look to the header shows us
that the file is indeed encrypted. However, there are multiple tools out there that
allows you to decrypt it, given that we have the key. I decided to use
[WhatsApp-Crypt12-Decrypter](https://github.com/EliteAndroidApps/WhatsApp-Crypt12-Decrypter/)
without any special reason other than that being the first result in DuckDuckGo at the
time.

As a side note, I found [this other repo](https://github.com/mgp25/Crypt12-Decryptor)
where they explain less the encryption method of Crypt12 (AES-GCM), which I find quite
interesting.

That user, @mgp25, has some other interesting stuff. I recommend you to take a look at
their other projects.

Back again on the challenge, remember the file named _key_ that we saw earlier? Maybe we
can use it here:
```sh
$ java -jar decrypt12.jar ../key ../msgstore.db.crypt12 decrypted.db
Decryption of crypt12 file was successful.
$ file decrypted.db
decrypted.db: SQLite 3.x database, user version 1, last written using SQLite version 3011000
```

Great, this is going well. Now it's time to examine the contents of the database. There
are multiple tables; but the one that attracts our attention the most is one called
_messages_. Indeed, there are the exchanged messages. This is the transcript, being _A_
the owner of the phone and _B_ the peer on the other end, _+34 628 205 625_:

> A: Hey!! Are u online? I think they have discovered me...
>
> A: This is my last message...i want my money
>
> A: And the chicken dinner...u know what it is
>
> B: Ok no problem...
>
> B: Send me the chicken dinner now and delete this conversation
>
> A: Ok, 1min, need to encode it
>
> A: iVBORw0KGgoAAAANSUhEUgAAAyAAAAJYCAYAAACadoJwAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBI
>    WXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4gYZCggdk0GemwAAAAxpVFh0Q29tbWVudAAAAAAAvK6y
>    mQAAIABJREFUeNrt3XmYFOWB+PFihhkchmtAkGNUDkWBcHjhgRxmAwRJsoqKqNldo0TDk6BBIIJB
>    o+IK67UadReIiTGiuBFcg7qocQHlkM0DCowrXly6HAqogNzj8/7++D36JE4VzMB093TP5/M89QfD
>    AQAABAgAAIAAAQAABAgAACBAAAAABAgAACBAAAAABAgAACBAAAAAAQIAACBAAAAAAQIAACBAAAAA
>    (...)
>    AAAQIAAAgAABAAAQIAAAgAABAAAQIAAAgAABAAAECAAAgAABAAAECAAAgAABAAAECAAAIEAAAAAE
>    CAAAIEAAAAAECAAAIEAAAAABAgAAIEAAAAABAgAAIEAAAAABAgAACBAAAAABAgAACBAAAAABAgAA
>    CBAAAECAAAAACBAAAECAAAAACBAAAECAAAAACBAAAECAAAAAAgQAAECAAAAANd//AyfU84FIjoOV
>    AAAAAElFTkSuQmCC
>
> A: This is my last message, send me the money on the same account
>
> B: Ok...


That long string is too suspicious, and resembles base64. In fact, if we extract it and
decode it, we end up with a PNG image that contains the flag:

{% include image.html
	src="/assets/posts/2018-12-26-cybercamp-medium-2/decoded-flag-10.png"
	title="Result of decoding the base64 message"
	alt="All-black background with the words TOO_MANY_SECRETS written in white, in the foreground."
%}

And we're done here.
The flag is `TOO_MANY_SECRETS`.



-----------------------------------------------------------------------------------------

## 10.- The Knights Templar Order

The description of this challenge states:
```
The computer of a suspect of terrorism is seized. Within it there are files that could be
considered of vital importance to continue with the investigation, but many of those
files are encrypted and known to be symmetric PGP.

Thanks to the investigation of the suspect, your colleagues have given you the following
guidelines that the suspect follows when creating his passwords:

     They are of length of 6 to 7 characters.
     Only contain lowercase letters
     Only these letters are used: eghotu
     None of the letters of the password are repeated
     Some of them contain two numbers among these: 0134

Your job will be to try to decipher the file thanks to the research done on the suspect
and the data provided to determine if the content is of vital importance for the
investigation in progress.
```

This is a pretty simple exercise, as the description already provides the guidelines to
create the correct dictionary. Oddly enough, these are the kind of exercises where I
struggle the most :(

However, thanks to John The Ripper's
[mask mode](https://github.com/magnumripper/JohnTheRipper/blob/bleeding-jumbo/doc/MASK),
I've finally been able to crack the first part of this challenge (two months after the
deadline, I think it's rather late) in around an hour or two, with this simple command:
```
john -mask=[eghotu0134] -min-len=6 -max-len=7 medium_11.gpg_HASH --format=gpg-opencl
```

The explanation of all the switches:

  - `-mask` tells JTR to use the _mask_ mode, using `eghotu0134` as a charset. Though it
	doesn't follows exactly the guidelines, concretely the _no repeated letters_ and
	_contains **two** numbers_, I think it's easier to just through _all_ the
	combinations instead of triaging the dictionary. Obviously, someone with more
	knowledge on JTR's rules will get to the answer more quickly.

  - `-min-len` and `-max-len` are there because the guidelines state that the length of
	the password is either 6 or 7 characters.

  - `medium_11.gpg_HASH` is the hash as extracted by `gpg2john`, another of those
	incredibly useful tools to convert anything to a format that can be cracked by
	JTR.

  - Finally, `--format` is there to tell JTR to use the GPU, instead of the CPU (which is
	way slower).


After an hour and a half, JTR cracks the password: `eg1u03`. Is interesting to note that
there are _three_ numbers there, while the guidelines told us that it may have _two_
numbers. I'll take that as a lesson that these guidelines may not be always 100% correct.
If you can't crack the password and you're sure that your dictionary is correct, try to
expand the search to other cases that may not follow all the guides but only some of them
(like using three numbers instead of two).


Anyways, the decrypted data is the following image:

{% include image.html
	src="/assets/posts/2018-12-26-cybercamp-medium-2/ordendelos.png"
	title="Decrypted data"
	alt="A big croix pattée (a Templar symbol) with some strange symbols, like triangles with dots inside, on the corners"
%}


Some may recognized the symbols that appear on that image as similar as the ones used
in the [Pigpen Cipher](https://en.wikipedia.org/wiki/Pigpen_cipher#Variants). The symbols
on the top and the bottom are the same; and, decrypted, give the following plaintext
(with the spaces fixed by me):
> ERES MUY GOLOSO

Which, translated from Spanish, means:
> YOU ARE VERY GREEDY

So, the flag is (at least I guess so, because I couldn't complete the challenge in time)
`ERESMUYGOLOSO`

-----------------------------------------------------------------------------------------


[^1]: Unfortunately, I only got something around 2900-3000 points, while the minimum
    necessary to enter the finals was like 3100... :(


[^2]: At this point you may be tired of listening to this; but yeah, there are multiple
    ways to do it :D
