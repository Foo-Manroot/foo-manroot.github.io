---
layout: post
title:  "Ciberseg '17 write-ups: reversing"
date:	2017-08-15 20:23:20 +0200
author: foo
categories: ctf ciberseg write-up reversing
ref: ciberseg-reversing
---


These are the reverse engineering challenges that formed part of the
[CTF](https://ciberseg.uah.es/ctf.html) organized at the
[Ciberseg 2017](https://ciberseg.uah.es), a conference about cibersecurity that takes
place every year in our university.


Last year was the first edition (hopefully, there will be more, as it was pretty fun) of
the CTF (and I won the first price, btw :D).

## First challenge: Easy reversing

For this challenge I assume some basic knowledge of x8086 assembler (specifically, the
[AT&T syntax](http://csiflabs.cs.ucdavis.edu/~ssdavis/50/att-syntax.htm)).

### Materials

The only needed thing on the first challenge is [this file](/assets/posts
/2017-08-15-ciberseg-reversing/b8c7903110ebdf9fa487e899b3bdefe4).

### The challenge

This one is pretty simple to solve. The first thing we notice is a strange set of `mov`
instructions. We can observe them using `objdump -d b8c7903110ebdf9fa487e899b3bdefe4`:
```
  40055c:    00 00
  40055e:    48 89 45 f8          mov    %rax,-0x8(%rbp)
  400562:    31 c0                xor    %eax,%eax
  400564:    c6 45 c0 66          movb   $0x66,-0x40(%rbp)
  400568:    c6 45 c1 6c          movb   $0x6c,-0x3f(%rbp)
  40056c:    c6 45 c2 61          movb   $0x61,-0x3e(%rbp)
  400570:    c6 45 c3 67          movb   $0x67,-0x3d(%rbp)
  400574:    c6 45 c4 7b          movb   $0x7b,-0x3c(%rbp)
  400578:    c6 45 c5 73          movb   $0x73,-0x3b(%rbp)
  40057c:    c6 45 c6 31          movb   $0x31,-0x3a(%rbp)
  400580:    c6 45 c7 5f          movb   $0x5f,-0x39(%rbp)
  400584:    c6 45 c8 6c          movb   $0x6c,-0x38(%rbp)
  400588:    c6 45 c9 30          movb   $0x30,-0x37(%rbp)
  40058c:    c6 45 ca 5f          movb   $0x5f,-0x36(%rbp)
  400590:    c6 45 cb 68          movb   $0x68,-0x35(%rbp)
  400594:    c6 45 cc 34          movb   $0x34,-0x34(%rbp)
  400598:    c6 45 cd 35          movb   $0x35,-0x33(%rbp)
  40059c:    c6 45 ce 5f          movb   $0x5f,-0x32(%rbp)
  4005a0:    c6 45 cf 68          movb   $0x68,-0x31(%rbp)
  4005a4:    c6 45 d0 33          movb   $0x33,-0x30(%rbp)
  4005a8:    c6 45 d1 63          movb   $0x63,-0x2f(%rbp)
  4005ac:    c6 45 d2 68          movb   $0x68,-0x2e(%rbp)
  4005b0:    c6 45 d3 30          movb   $0x30,-0x2d(%rbp)
  4005b4:    c6 45 d4 5f          movb   $0x5f,-0x2c(%rbp)
  4005b8:    c6 45 d5 63          movb   $0x63,-0x2b(%rbp)
  4005bc:    c6 45 d6 30          movb   $0x30,-0x2a(%rbp)
  4005c0:    c6 45 d7 6e          movb   $0x6e,-0x29(%rbp)
  4005c4:    c6 45 d8 5f          movb   $0x5f,-0x28(%rbp)
  4005c8:    c6 45 d9 72          movb   $0x72,-0x27(%rbp)
  4005cc:    c6 45 da 34          movb   $0x34,-0x26(%rbp)
  4005d0:    c6 45 db 64          movb   $0x64,-0x25(%rbp)
  4005d4:    c6 45 dc 34          movb   $0x34,-0x24(%rbp)
  4005d8:    c6 45 dd 72          movb   $0x72,-0x23(%rbp)
  4005dc:    c6 45 de 33          movb   $0x33,-0x22(%rbp)
  4005e0:    c6 45 df 5f          movb   $0x5f,-0x21(%rbp)
  4005e4:    c6 45 e0 68          movb   $0x68,-0x20(%rbp)
  4005e8:    c6 45 e1 31          movb   $0x31,-0x1f(%rbp)
  4005ec:    c6 45 e2 67          movb   $0x67,-0x1e(%rbp)
  4005f0:    c6 45 e3 68          movb   $0x68,-0x1d(%rbp)
  4005f4:    c6 45 e4 5f          movb   $0x5f,-0x1c(%rbp)
  4005f8:    c6 45 e5 66          movb   $0x66,-0x1b(%rbp)
  4005fc:    c6 45 e6 31          movb   $0x31,-0x1a(%rbp)
  400600:    c6 45 e7 76          movb   $0x76,-0x19(%rbp)
  400604:    c6 45 e8 33          movb   $0x33,-0x18(%rbp)
  400608:    c6 45 e9 7d          movb   $0x7d,-0x17(%rbp)
  40060c:    c6 45 ea 00          movb   $0x0,-0x16(%rbp)
  400610:    b8 00 00 00 00       mov    $0x0,%eax
```

To see what values are being pushed on the stack, we can use gdb and set a breakpoint
right after the last strange mov:
```sh
$ gdb b8c7903110ebdf9fa487e899b3bdefe4
GNU gdb (Ubuntu 7.11.1-0ubuntu1~16.5) 7.11.1
Copyright (C) 2016 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
<http://www.gnu.org/software/gdb/documentation/>.
For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from b8c7903110ebdf9fa487e899b3bdefe4...(no debugging symbols found)...done.
(gdb) break *0x400610
Breakpoint 1 at 0x400610
(gdb) r
Starting program: b8c7903110ebdf9fa487e899b3bdefe4

Breakpoint 1, 0x0000000000400610 in main ()
(gdb) x/10s $rsp
0x7fffffffd8e0:layout"\030\332\377\377\377\177"
0x7fffffffd8e7:layout""
0x7fffffffd8e8:layout""
0x7fffffffd8e9:layout""
0x7fffffffd8ea:layout""
0x7fffffffd8eb:layout"\377\001"
0x7fffffffd8ee:layout""
0x7fffffffd8ef:layout""
0x7fffffffd8f0:layout"flag{s1_l0_h45_h3ch0_c0n_r4d4r3_h1gh_f1v3}"
0x7fffffffd91b:layout""
(gdb)
```

And we see that all those _mov_ where just pushing the flag in the stack:
`flag{s1_l0_h45_h3ch0_c0n_r4d4r3_h1gh_f1v3}`.


-----------------------------------------------------------------------------------------


## Second challenge: Reversing CPP

### Materials

The only needed file for this challenge can be [downloaded here](/assets/posts
/2017-08-15-ciberseg-reversing/82dba1aba3278a9a617ed4635cce47fe).

### The challenge

This time the challenge is not about reading assembler, but reverse engineering the
output of the program; as we were told that the flag is the SHA-1 of the number that
generated the sequence:
```sh
$ ./82dba1aba3278a9a617ed4635cce47fe
[15745687,47237062,23618531,70855594,35427797,106283392,53141696,26570848,13285424,6642712,3321356,1660678,830339,2491018,1245509,3736528,1868264,934132,467066,233533,700600,350300,175150,87575,262726,131363,394090,197045,591136,295568,147784,73892,36946,18473,55420,27710,13855,41566,20783,62350,31175,93526,46763,140290,70145,210436,105218,52609,157828,78914,39457,118372,59186,29593,88780,44390,22195,66586,33293,99880,49940,24970,12485,37456,18728,9364,4682,2341,7024,3512,1756,878,439,1318,659,1978,989,2968,1484,742,371,1114,557,1672,836,418,209,628,314,157,472,236,118,59,178,89,268,134,67,202,101,304,152,76,38,19,58,29,88,44,22,11,34,17,52,26,13,40,20,10,5,16,8,4,2,1]
```

To get the generator, we must first figure out the rule that follows this series. For
that, we can substract every number to its predecessor, and see if we can conclude
anything:
```
Number           Diff               Comments
             (n_i - n_(i-1)
15745687          -             Initial number, so no diff
47237062       -31491375          -
23618531        23618531        47237062 / 2 = 23618531
70855594       −47237063        47237063 = (23618531 * 2) + 1
35427797        35427797        70855594 / 2 = 35427797
106283392      −70855595        70855595 = (35427797 * 2) + 1
53141696        53141696        106283392 / 2 = 53141696
26570848       −26570848        53141696 / 2 = 26570848
13285424       −13285424        26570848 / 2 = 13285424
6642712         −6642712        13285424 / 2 = 6642712
...
```

It seems that some numbers are divided by 2, while others are added
<img src="https://latex.codecogs.com/svg.latex?%5Cinline%20%5Cbg_white%20%5C
%20%282%20*%20n%29%20&plus;%201" class="inline-math" alt="2n + 1"> to themselves,
resulting in the following rule:

<img src="https://latex.codecogs.com/svg.latex?%5Cbg_white%20f%28n%29%3D%7B%20%5Cbegin%7Bcases%7D%20n/2%20%26%7B%20%5Ctext%7Bif%20%7D%20%7D%20%3F%20%5C%5C%203n&plus;1%20%26%7B%20%5Ctext%7Bif%20%7D%20%7D%20%3F%20%5Cend%7Bcases%7D%20%7://latex.codecogs.com/svg.latex?%5Cbg_white%20f%28n%29%3D%7B%20%5Cbegin%7Bcases%7D%20n/2%20%26%7B%20%5Ctext%7Bif%20%7D%20%7D%20%3F%20%5C%5C%20n&plus;2n&plus;1%20%26%7B%20%5Ctext%7Bif%20%7D%20%7D%20%3F%20%5Cend%7Bcases%7D%20%7D"
title="Deduced formula"
alt="f(n)={
    \begin{cases}
        n/2     %26{ \text{if } } ? \\
        n+2n+1  %26{ \text{if } } ?
    \end{cases}
}"
class="math">

Then, we have to determine when each formula is used. We can observe that all odd numbers
are multiplied; while the even ones are divided by two:

<img src="https://latex.codecogs.com/svg.latex?%5Cbg_white%20f%28n%29%3D%7B%20%5Cbegin%7Bcases%7D%20n/2%20%26%7B%20%5Ctext%7Bif%20%7D%20%7D%20n%20%5Cequiv%200%20%7B%5Cpmod%20%7B2%7D%7D%20%5C%5C%203n&plus;1%20%26%7B%20%5Ctext%7Bif%20%7D%20%7D%20n%20%5Cequiv%201%20%7B%5Cpmod%20%7B2%7D%7D%20%5Cend%7Bcases%7D%20%7D"
alt="f(n)={
    \begin{cases}
        n/2   %26{ \text{if } } n \equiv 0 {\pmod {2}} \\
        3n+1  %26{ \text{if } } n \equiv 1 {\pmod {2}}
    \end{cases}
}"
class="math">

And this is exactly the [Collatz conjecture](https://en.wikipedia.org/wiki
/Collatz_conjecture). Now, we can recover the generator of the series.

As we know that the last digit of the first number is __7__, the previous number must
have ended at __4__ (we know that because the series has a
[known pattern](https://www.reddit.com/r/math/comments/5n1m5h
/i_created_an_arrow_diagram_to_show_how_the_ones/) on the units). Therefore, 15745687 is
the result of dividing this first number (that ends in a 4, so it's even) by 2, so we can
calculate the generator:
<img src="https://latex.codecogs.com/svg.latex?%5Cbg_white%2015745687%20%3D%20x%20/%202%20%5Crightarrow%20x%20%3D%2015745687%20*%202%20%5Crightarrow%20x%20%3D%2031491374"
alt="15745687 = x / 2 \rightarrow x = 15745687 * 2 \rightarrow x = 31491374"
class="math">

To get the flag, we just have to calculate the sha1sum of this number:
```sh
$ printf "31491374" | sha1sum
1693083796038695739252687f70ddf09991181b  -
```

Our flag is: `flag{1693083796038695739252687f70ddf09991181b}`.


-----------------------------------------------------------------------------------------


## Third challenge: Crackme

### Materials

The binary to be reversed can be [downloaded here](/assets/posts
/2017-08-15-ciberseg-reversing/26890d22b8e912c822df40c825de96c7).

### The challenge

As in the first challenge, we start by disassembling the executable with `objdump -d
26890d22b8e912c822df40c825de96c7`. We note that there are four important functions:
  - `main ()`: checks that all arguments are correct, then calls *check_pass()*, and,
	if it returns 0 (on address 0x804850f: `test   %eax,%eax`), calls *one()*.

  - `one ()`: iterates through a string, making some calculations on every character
	(xoring its characters with something) and prints its content.

  - `two ()`: does the same than the previous function, but with other data.

  - `chek_pass ()`: checks the password, that has to be of length 6 or more (on address
	0x8048611: `cmp    $0x5,%eax`), and it seems that it returns the sum of all the
	characters in the password.


The most curious thing about this, is that the function _two()_ never gets called...

There is no point in figuring out the password (even if we try it... how can we get a
string of length 6 or more that the sum of its characters is 0, knowing that there is no
character with negative numeric value and 0x00 indicates the end of string?), so we can
just change the value of __%eip__ (the Index Pointer, the register that tells us which
instruction comes next) and go to execute the function _one()_ to see what it prints out:
```sh
$ gdb 26890d22b8e912c822df40c825de96c7
GNU gdb (Ubuntu 7.11.1-0ubuntu1~16.5) 7.11.1
Copyright (C) 2016 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
<http://www.gnu.org/software/gdb/documentation/>.
For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from 26890d22b8e912c822df40c825de96c7...(no debugging symbols found)...done.
(gdb) break *0x80484e1
Breakpoint 1 at 0x80484e1
(gdb) r
Starting program: ./26890d22b8e912c822df40c825de96c7

Breakpoint 1, 0x080484e1 in main ()
(gdb) info registers $eip
eip            0x80484e10x80484e1 <main+22>
(gdb) p one
$1 = {<text variable, no debug info>} 0x804859a <one>
(gdb) set $eip=0x804859a
(gdb) info registers $eip
eip            0x804859a0x804859a <one>
(gdb) continue
Continuing.
https://www.youtube.com/watch?v=dQw4w9WgXcQb

Program received signal SIGSEGV, Segmentation fault.
0xf7f9d3dc in ?? () from /lib/i386-linux-gnu/libc.so.6
(gdb)
```


The program segfaults, but we don't care, because we have a YouTube link that could be
the answer. Cool, let's see where does [https://www.youtube.com/watch?v=dQw4w9WgXcQ](
https://www.youtube.com/watch?v=dQw4w9WgXcQ) point to...

Oh.

Okey.

Well...

After been rickrolled, we can continue searching for the answer.


The other interesting function (even more than the previous, as it never gets called) is
_two()_. Lets do the same as before and modify __%eip__:
```sh
$ gdb 26890d22b8e912c822df40c825de96c7
GNU gdb (Ubuntu 7.11.1-0ubuntu1~16.5) 7.11.1
Copyright (C) 2016 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
<http://www.gnu.org/software/gdb/documentation/>.
For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from 26890d22b8e912c822df40c825de96c7...(no debugging symbols found)...done.
(gdb) break *0x080484e1
Breakpoint 1 at 0x80484e1
(gdb) r
Starting program: ./26890d22b8e912c822df40c825de96c7

Breakpoint 1, 0x080484e1 in main ()
(gdb) info registers $eip
eip            0x80484e10x80484e1 <main+22>
(gdb) p two
$1 = {<text variable, no debug info>} 0x8048537 <two>
(gdb) set $eip=0x8048537
(gdb) info registers $eip
eip            0x80485370x8048537 <two>
(gdb) continue
Continuing.
https://www.youtube.com/watch?v=PmHyI5vFlGob

Program received signal SIGSEGV, Segmentation fault.
0xf7f9d3dc in ?? () from /lib/i386-linux-gnu/libc.so.6
(gdb)
```


Again, the program segfaults but we don't care. Hopefully, the new link,
[https://www.youtube.com/watch?v=PmHyI5vFlGob](https://www.youtube.com
/watch?v=PmHyI5vFlGob), won't leads us to another silly meme...

Yay, it didn't. The title of that last video is the flag:
`flag{ee1784da5ebc7941f9478e21d36a3e1b}`.


-----------------------------------------------------------------------------------------

## Fourth challenge: Reversing Android

### Materials

For this last challenge we're going to need [this apk](/assets/posts
/2017-08-15-ciberseg-reversing/reto.tar.gz).

### The challenge

After downloading the Android App, we can use an emulator to install and explore it a
bit. It only has a button with the text (translated from spanish) "calculate flag"; and,
once pressed, shows the text (again, translated from spanish) "flag calculated".

![Exploration of the app](/assets/posts/2017-08-15-ciberseg-reversing/apk-first-run.png
"First run of the app")

It seems that something is happening in the back-end, but it isn't showed to us. Now it's
time to examine the source code. We can use any online service to decompile an apk file;
but we can also do it locally using some tools.

First, we use [dex2jar](https://github.com/pxb1988/dex2jar) to convert the apk, with its
_.dex_ files, into a jar, with _.class_ files. Then, we decompile the bytecode using
a [Java decompiler](http://jd.benow.ca/), and we find a class named
__CalculateFlagAction__, where we can see:

![Decompiled app](/assets/posts/2017-08-15-ciberseg-reversing/apk-decompiled.png
"CalculateFlagAction viewed on the decompiler")

We see there the flag being calculated by appending the character codes one by one into
an array that is later formatted as a string with the flag ("flag{...}").

At this point we have two options: to change the code to show the flag on the app and
compile it again; or simply take the function where the flag is calculated and compile it
as a single Java application to print the flag. I used the latter, as I thought it was
faster and easier.

There are a couple of strange characters, so it's better to save the decompiled file
(from the decompiler's menu) and then modify it than to copy it from by hand. After all
the appropriate changes, we can print the flag:

__NOTE: as the strange characters gives problems parsing the XML (for the RSS Feed),
they have been removed from the text (in particular, the character `0x1f`)__

```sh
$ javac Flag.java
$ java Flag
flag{693f'$da %d""d"ac#"#'a"ce333 3##$}
$ java Flag | xxd
00000000: 666c 6167 7b36 3933 6627 2464 6120 2564  flag{693f'$da %d
00000010: 2222 6422 6163 2322 2327 6122 6365 3333  ""d"ac#"#'a"ce33
00000020: 3320 3323 1f23 247d 0a                   3 3#.#$}.
```

So, the flag is `flag{693f'$da %d""d"ac#"#'a"ce333 3##$}` (the problematic `0x1f`
character  has been removed).
