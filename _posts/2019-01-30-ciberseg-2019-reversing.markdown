---
layout: post
title:  "Ciberseg 2019: reverse engineering"
date:	2019-01-30 13:41:04 +0100
author: foo
categories: ctf ciberseg write-up reversing
ref: ciberseg-2019-reversing
---

In this post I will explain my solutions for the challenges on the Ciberseg '19 CTF.
Specifically, these are the ones corresponding to the **reverse engineering** category.

[Ciberseg](https://ciberseg.uah.es/) is an annual congress which takes place in the
University of Alcalá de Henares. The truth is that previous years it has been always fun,
and this year wasn't less :) Also, the first places were disputed hard and there were
last-time surprises :D (in the end, I literally won at the last hour by just a few
points).

Anyways, these are the challenges and their solutions. For those that need it, I'll also
leave the necessary resources that we where given to try the challenge by yourselves.


-----------------------------------------------------------------------------------------

# 1.- Doom 5 Alpha (25 points)

The description of this challenge states:
> The latest Doom version has been leaked, but I don't have the key :(

And we're given the binary where we have to get the key from:
[doom5_alpha](/assets/posts/2019-01-30-ciberseg-2019-reversing/doom5_alpha).

When we execute it, we're presented a message that says (translated from Spanish)
_To play this game you need a license_.


The first thing that we do is to take a quick look at the code, to form ourselves an idea
of what is the program doing:
```asm
$ objdump -M intel -d doom5_alpha
(...)
00000000000011be <main>:
    11be:	55                      push   %rbp
    11bf:	48 89 e5                mov    %rsp,%rbp
    11c2:	48 83 ec 30             sub    $0x30,%rsp
    11c6:	48 8b 05 d3 2e 00 00    mov    0x2ed3(%rip),%rax        # 40a0 <stdout@@GLIBC_2.2.5>
    11cd:	48 89 c1                mov    %rax,%rcx
    11d0:	ba 2d 00 00 00          mov    $0x2d,%edx
    11d5:	be 01 00 00 00          mov    $0x1,%esi
    11da:	48 8d 3d 27 0e 00 00    lea    0xe27(%rip),%rdi        # 2008 <_IO_stdin_used+0x8>
    11e1:	e8 8a fe ff ff          callq  1070 <fwrite@plt>
    11e6:	48 8b 15 c3 2e 00 00    mov    0x2ec3(%rip),%rdx        # 40b0 <stdin@@GLIBC_2.2.5>
    11ed:	48 8d 45 d0             lea    -0x30(%rbp),%rax
    11f1:	be 21 00 00 00          mov    $0x21,%esi
    11f6:	48 89 c7                mov    %rax,%rdi
    11f9:	e8 52 fe ff ff          callq  1050 <fgets@plt>
    11fe:	48 8d 45 d0             lea    -0x30(%rbp),%rax
    1202:	48 89 c6                mov    %rax,%rsi
    1205:	48 8d 3d 54 2e 00 00    lea    0x2e54(%rip),%rdi        # 4060 <pass>
    120c:	e8 4f fe ff ff          callq  1060 <strcmp@plt>
    1211:	85 c0                   test   %eax,%eax
    1213:	75 43                   jne    1258 <main+0x9a>
    1215:	48 8d 3d 1c 0e 00 00    lea    0xe1c(%rip),%rdi        # 2038 <_IO_stdin_used+0x38>
    121c:	b8 00 00 00 00          mov    $0x0,%eax
    1221:	e8 1a fe ff ff          callq  1040 <printf@plt>
    1226:	48 8d 3d ab 14 00 00    lea    0x14ab(%rip),%rdi        # 26d8 <_IO_stdin_used+0x6d8>
    122d:	e8 fe fd ff ff          callq  1030 <puts@plt>
    1232:	48 8d 3d 4f 2e 00 00    lea    0x2e4f(%rip),%rdi        # 4088 <flag>
    1239:	e8 37 ff ff ff          callq  1175 <xor>
    123e:	48 8d 35 43 2e 00 00    lea    0x2e43(%rip),%rsi        # 4088 <flag>
    1245:	48 8d 3d ab 14 00 00    lea    0x14ab(%rip),%rdi        # 26f7 <_IO_stdin_used+0x6f7>
    124c:	b8 00 00 00 00          mov    $0x0,%eax
    1251:	e8 ea fd ff ff          callq  1040 <printf@plt>
    1256:	eb 0c                   jmp    1264 <main+0xa6>
    1258:	48 8d 3d a9 14 00 00    lea    0x14a9(%rip),%rdi        # 2708 <_IO_stdin_used+0x708>
    125f:	e8 cc fd ff ff          callq  1030 <puts@plt>
    1264:	b8 00 00 00 00          mov    $0x0,%eax
    1269:	c9                      leaveq
    126a:	c3                      retq
    126b:	0f 1f 44 00 00          nopl   0x0(%rax,%rax,1)
(...)
```

We can see that it first calls _fwrite_ (line **:11e1**) to show the message asking for
the license key. Then, it calls _fgets_ to read the access code and it compares that with
`<pass>`, which is whatever string is located in **0x4060**. If they match, (line
**:1213**), it keeps going on to calculate the _flag_ and show it on screen.


There are multiple ways of solving this challenge: debug with _gdb_ and modify _$eip_ to
bypass the key comparison, so it goes directly to calculate the flag (`<xor>`, called in
line **:1239**)... Or we can see what string is in **0x4060** to introduce the correct
value and let the program execute normally.

To see the string used in the comparison (the license key), we can use _objdump_ again
and search in section `.data`:
```hexdump
$ objdump -s -j .data doom5_alpha

doom5_alpha:     file format elf64-x86-64

Contents of section .data:
 4040 00000000 00000000 48400000 00000000  ........H@......
 4050 00000000 00000000 00000000 00000000  ................
 4060 38383931 34353332 64667238 34373334  88914532dfr84734
 4070 6865666f 346b3564 32333835 37333435  hefo4k5d23857345
 4080 00000000 00000000 2818190b 3d071d11  ........(...=...
 4090 05130000                             ....
```

When we try to execute the program again using that value (from **0x4060** to **0x4080**,
before the null terminator), we can check that the key is correct and we get our flag:
```
$ ./doom5_alpha
Para jugar este juego necesitas una licencia 88914532dfr84734hefo4k5d23857345

+-----------------------------------------------------------------------------+
| |       |\                                           -~ /     \  /          |
|~~__     | \                                         | \/       /\          /|
|    --   |  \                                        | / \    /    \     /   |
|      |~_|   \                                   \___|/    \/         /      |
|--__  |   -- |\________________________________/~~\~~|    /  \     /     \   |
|   |~~--__  |~_|____|____|____|____|____|____|/ /  \/|\ /      \/          \/|
|   |      |~--_|__|____|____|____|____|____|_/ /|    |/ \    /   \       /   |
|___|______|__|_||____|____|____|____|____|__[]/_|----|    \/       \  /      |
|  \mmmm :   | _|___|____|____|____|____|____|___|  /\|   /  \      /  \      |
|      B :_--~~ |_|____|____|____|____|____|____|  |  |\/      \ /        \   |
|  __--P :  |  /                                /  /  | \     /  \          /\|
|~~  |   :  | /                                 ~~~   |  \  /      \      /   |
|    |      |/                        .-.             |  /\          \  /     |
|    |      /                        |   |            |/   \          /\      |
|    |     /                        |     |            -_   \       /    \    |
+-----------------------------------------------------------------------------+
|          |  /|  |   |  2  3  4  | /~~~~~\ |       /|    |_| ....  ......... |
|          |  ~|~ | % |           | | ~J~ | |       ~|~ % |_| ....  ......... |
|   AMMO   |  HEALTH  |  5  6  7  |  \===/  |    ARMOR    |#| ....  ......... |
+-----------------------------------------------------------------------------+

Correcto.. Esta es tu Flag!!!!
flag{ArrgPirata}
```

_Easy peasy_ :D

The flag is: `flag{ArrgPirata}`.

-----------------------------------------------------------------------------------------

# 2.- Negative (200 points)

The description of this challenge states:
> In the UAH we've created a highly secure app whose code is inaccessible.

Also, attached, there's [this file](/assets/posts/2019-01-30-ciberseg-2019-reversing/app.7z).


Once we've extracted its contents we obtain a binary called `ciberseg-ctf-19` incredibly
heavy (110 MB just to show three little windows...) and lasts like a whole year to start,
apart from the added 150 MB for some resources with names like _chrome\_100\_percent.pak_
or _LICENSES.chromium.html_ that give some pointers to how the application was made.
Also, inside the directory `resources/` there's a file that don't give more room to any
doubt: `electron.asar`.

Oh, God! The infamous _Electron_. I'm not going to start ranting about Electron because
I won't finish in a month. I just want to declare my profound dislike about Electron :(
Maybe I take some time to write a little post, or something. Who knows?


Anyways, our goal now is to reverse engineer it to get the source code back. Apparently,
it's archived with something called [asar](https://github.com/electron/asar) and, the
same way it was compressed, it can be decompressed to get the original source code simply
by executing the command `asar extract resources/app.asar ../extracted`.

Inside the directory where we've extracted everything, there's a file called `main.js`
which contains the main (duh) code of the application. In this case, as it's so simple,
we immediately see where the password is being checked:
```javascript
// (...)
  ipcMain.on('password', (event, arg) => {
    console.error(arg) // prints "ping"
    if(arg == Buffer.from("MTI2NWVmNmJjY2RhYzc5OTg1MzhiOTBjOGYxMjVjZjk4M2RiN2ZmZjE3OGUzNWRlMDY4MWQzNDQzM2QxMWM2YQ==", 'base64').toString('ascii')){
      let flag = cipher.decrypt('c93ae864e1b525ab1c64a02e7996ea52', arg);
      dialog.showMessageBox({title: "Congratulations", message: "The flag is", detail: flag});
    } else {
      mainWindow.setSize(800, 800)
      mainWindow.loadFile('logo.svg')
    }
  })
// (...)
```

The value of the password, once decoded in Base64, is
**1265ef6bccdac7998538b90c8f125cf983db7fff178e35de0681d34433d11c6a**. If we introduce
that value in the window asking for the password, we get the flag:

{% include image.html
	src="/assets/posts/2019-01-30-ciberseg-2019-reversing/flag-electron.jpg"
	title="Solution for the challenge"
	alt="Pop-up with the solution for the challenge"
%}

The flag is: `flag{show_the_code}`.


-----------------------------------------------------------------------------------------

# 3.- Argument (250 points)

The description for this challenge states:
> Because people agree speaking

We also get attached
[the binary](/assets/posts/2019-01-30-ciberseg-2019-reversing/a43b59111fef20ed7f8e2e53482076b99acea606.bin)
with which we have to work.

As the name of the challenge implies, this has something to do with the _arguments_ we
pass to the executable.

I have to admit that I spent a lot of time studying the code; but in the end it's just a
matter of looking for `cmp` instructions to see with which value it's compared at each
time and from there reconstruct the desired string, one character at a time.


The first checks are upon the number of arguments. The requirements are:

  - <img src="https://latex.codecogs.com/svg.latex?\fn_cm%20\left(%20argc%20\gg%201%20\right)%20\mathrel{\&}%201%20\neq%200" class="inline-math" alt="\left( argc \gg 1 \right) \mathrel{\&} 1 \neq 0"> That means that the number of arguments (including `argc [0]`, which is the program name) **divided by two** must be **odd**.

  - <img src="https://latex.codecogs.com/svg.latex?\fn_cm%20\left\{\begin{matrix}%20%26%20(5%20\mod%20argc)%20\neq%200%20%26%20\\%20%26%20(7%20\mod%20argc)%20\neq%200%20%26%20\\%20%26%20(10%20\mod%20argc)%20\neq%200%20%26%20\end{matrix}%20\right." class="inline-math" alt="\left\{ \begin{matrix} & (5 \mod argc) \neq 0 & \\ & (7 \mod argc) \neq 0 & \\ & (10 \mod argc) \neq 0 & \end{matrix} \right.">

A valid number of arguments, for example, is **2** (<img src="https://latex.codecogs.com/svg.latex?\fn_cm%20argc%20=%203" class="inline-math" alt="argc = 3">, including the name of the program).


After figuring out the appropriate number of arguments, the next step is to know its
value. I'd usually use IDA, but the demo version doesn't like 64-bit binaries, so I'll
use the [Hopper](https://latex.codecogs.com/svg.latex?\fn_cm%20argc%20=%203) demo, which
is also a great program.

The call graph returned by Hopper is the following one:
{% include image.html
	src="/assets/posts/2019-01-30-ciberseg-2019-reversing/call-graph.jpg"
	title="Call graph"
	alt="Boxes representing code fragments, with arrows joining different boxes to represent the execution flow"
%}

The left side, marked in red, corresponds with the comparison, character by character,
of the first argument with the string `flag:`. Each of the boxes at the bottom are meant
to check one of the different letters, and they're compared according to an index
iterating across `argv [1]`.


Then, we have the right side, marked in green. This side is a little more tricky; but,
basically, it compares `argv [2]` also character by character; but this time it does it
against an in-memory string which is filled right in the box that's before entering the
green zone. Its code is:
```nasm
mov        qword [rbp+var_35], 0x0
mov        dword [rbp+var_2D], 0x0
mov        byte [rbp+var_29], 0x0
mov        byte [rbp+var_35], 0x6c
mov        byte [rbp+var_34], 0x61
mov        byte [rbp+var_33], 0x63
mov        byte [rbp+var_32], 0x64
mov        byte [rbp+var_31], 0x72
mov        byte [rbp+var_30], 0x69
mov        byte [rbp+var_2F], 0x65
mov        byte [rbp+var_2E], 0x74
mov        byte [rbp+var_2D], 0x6f
mov        byte [rbp+var_2C], 0x67
mov        byte [rbp+var_2B], 0x66
mov        qword [rbp+var_28], 0x8
mov        dword [rbp+var_1C], 0x0
mov        dword [rbp+var_18], 0x0
```

This adds the value `lacdrietogf` into the variable. But, be careful! This is not the
value for the second argument. The comparisons are made according to an index that
changes (not sequentially) and selects the proper value. This string is more like a
query table, or something like that.

The thing is, after all this comparisons we have the value of this second argument:
`retorcido` (Spanish for twisted). Quite twisted, indeed XD
```sh
$ ./a43b59111fef20ed7f8e2e53482076b99acea606.bin flag: retorcido
¡Bien hecho!
```

Our _flag_ is `flag{retorcido}`.


-----------------------------------------------------------------------------------------

# 4.- Get your Nintendo PowerGlove™ and start playing (300 points)

The description of this challenge states:
> Everybody tells me that this Super Mario level is unbeatable, but I can go till the end
> without any problem. If you can't beat it, you don't deserve to be a Gamer.

We also get [this file](/assets/posts/2019-01-30-ciberseg-2019-reversing/smb3.nes')
 attached.

When we open it (I used the emulator [nestopia](http://nestopia.sourceforge.net/) and it
works without any problem in my Arch Linux), we see that it's a _Super Mario Bros 3_ ROM.
However, if we try to beat the first level, we can see that there's something wrong, and
we find with a cliff with an enormous hole, impossible to jump.


What I did was to search in the _interwebs_ for some program that could allow me to edit
the levels in _Super Mario Bros 3_ to make the hole a little smaller, or anything that
could be useful to me. After trying a couple of editors, I found
[SMB3 workshop](https://www.romhacking.net/utilities/298/) which turned out to be a
complete wonder. With this program I don't even need to edit the level to beat it
because, when trying to edit the next level, we can directly see the solution:
{% include image.html
	src="/assets/posts/2019-01-30-ciberseg-2019-reversing/flag-smb3.jpg"
	title="Level with the solution"
	alt="Next level, where we can see some coins spelling the word 'GOOMBA', the solution to the challenge."
%}


Even though the organizers had completely different idea to solve it XD

This is the _write-up_ that they sent once the CTF finished, seeing that everybody solve
the challenge using already existing tools (someone did edit the memory, though). It's
only available in Spanish:
{% include embed_pdf.html
	path="/assets/posts/2019-01-30-ciberseg-2019-reversing/sol_propuesta.pdf"
%}


Whichever method we used, the _flag_ is: `flag{goomba}`.


-----------------------------------------------------------------------------------------

# 5.- Cuisine revolution (300 points)

The description for this challenge states:
> The software added in this cooking utensil is highly complex

Also, we're given the binary we have to reverse engineer:
[crackme2](/assets/posts/2019-01-30-ciberseg-2019-reversing/crackme2).


As in the [third challenge](#3--argumenta-250-points), we begin by taking a look at the
binary to roughly see what is its functioning:
```asm
$ objdump -d crackme2
(...)
0000000000001212 <main>:
    1212:	55                      push   %rbp
    1213:	48 89 e5                mov    %rsp,%rbp
    1216:	48 83 ec 10             sub    $0x10,%rsp
    121a:	b9 00 00 00 00          mov    $0x0,%ecx
    121f:	ba 01 00 00 00          mov    $0x1,%edx
    1224:	be 00 00 00 00          mov    $0x0,%esi
    1229:	bf 00 00 00 00          mov    $0x0,%edi
    122e:	b8 00 00 00 00          mov    $0x0,%eax
    1233:	e8 18 fe ff ff          callq  1050 <ptrace@plt>
    1238:	48 85 c0                test   %rax,%rax
    123b:	79 16                   jns    1253 <main+0x41>
    123d:	48 8d 3d c4 0d 00 00    lea    0xdc4(%rip),%rdi        # 2008 <_IO_stdin_used+0x8>
    1244:	e8 e7 fd ff ff          callq  1030 <puts@plt>
    1249:	b8 00 00 00 00          mov    $0x0,%eax
    124e:	e9 a2 00 00 00          jmpq   12f5 <main+0xe3>
    1253:	48 8b 05 06 2e 00 00    mov    0x2e06(%rip),%rax        # 4060 <stdout@@GLIBC_2.2.5>
    125a:	48 89 c1                mov    %rax,%rcx
    125d:	ba 2d 00 00 00          mov    $0x2d,%edx
    1262:	be 01 00 00 00          mov    $0x1,%esi
    1267:	48 8d 3d d2 0d 00 00    lea    0xdd2(%rip),%rdi        # 2040 <_IO_stdin_used+0x40>
    126e:	e8 ed fd ff ff          callq  1060 <fwrite@plt>
    1273:	48 8b 15 f6 2d 00 00    mov    0x2df6(%rip),%rdx        # 4070 <stdin@@GLIBC_2.2.5>
    127a:	48 8d 45 f5             lea    -0xb(%rbp),%rax
    127e:	be 0a 00 00 00          mov    $0xa,%esi
    1283:	48 89 c7                mov    %rax,%rdi
    1286:	e8 b5 fd ff ff          callq  1040 <fgets@plt>
    128b:	48 8d 45 f5             lea    -0xb(%rbp),%rax
    128f:	48 89 c7                mov    %rax,%rdi
    1292:	e8 ce fe ff ff          callq  1165 <xor>
    1297:	48 8d 45 f5             lea    -0xb(%rbp),%rax
    129b:	48 8d 35 a6 2d 00 00    lea    0x2da6(%rip),%rsi        # 4048 <pass>
    12a2:	48 89 c7                mov    %rax,%rdi
    12a5:	e8 04 ff ff ff          callq  11ae <compare>
    12aa:	85 c0                   test   %eax,%eax
    12ac:	75 22                   jne    12d0 <main+0xbe>
    12ae:	48 8b 05 ab 2d 00 00    mov    0x2dab(%rip),%rax        # 4060 <stdout@@GLIBC_2.2.5>
    12b5:	48 89 c1                mov    %rax,%rcx
    12b8:	ba 33 00 00 00          mov    $0x33,%edx
    12bd:	be 01 00 00 00          mov    $0x1,%esi
    12c2:	48 8d 3d a7 0d 00 00    lea    0xda7(%rip),%rdi        # 2070 <_IO_stdin_used+0x70>
    12c9:	e8 92 fd ff ff          callq  1060 <fwrite@plt>
    12ce:	eb 20                   jmp    12f0 <main+0xde>
    12d0:	48 8b 05 89 2d 00 00    mov    0x2d89(%rip),%rax        # 4060 <stdout@@GLIBC_2.2.5>
    12d7:	48 89 c1                mov    %rax,%rcx
    12da:	ba 0a 00 00 00          mov    $0xa,%edx
    12df:	be 01 00 00 00          mov    $0x1,%esi
    12e4:	48 8d 3d b9 0d 00 00    lea    0xdb9(%rip),%rdi        # 20a4 <_IO_stdin_used+0xa4>
    12eb:	e8 70 fd ff ff          callq  1060 <fwrite@plt>
    12f0:	b8 00 00 00 00          mov    $0x0,%eax
    12f5:	c9                      leaveq
    12f6:	c3                      retq
    12f7:	66 0f 1f 84 00 00 00    nopw   0x0(%rax,%rax,1)
    12fe:	00 00
(...)
```

The most interesting bit of this challenge is that it start calling `ptrace` in **:1233**
to detect if there's any debugger attached. If there is, it directly ends the execution.
It's not really a problem, of course, because we can simply modify _$eip_ or _$eflags_
and we can pretend there was no anti-debugging taking place. It's just something we have
to be aware of, nothing more.


After checking if it's being executing directly or being debugged, it prints a string and
waits for the user input (en **:1286**). Then it calls the `xor` function with our string
and compares the result with something that's in memory.


It seems to be as easy as using `gdb`, jumping over the `ptrace` check and looking at the
value returned by `xor`.

Oversimplifying it, this is what this function does:
```c
void xor (char * str_in)
{
	int i;
	char a, b;

	for (i = 0; i <= 8; i++)
	{
		a = str_in [i]
		b = i + 0x69	// i + 105 I guess that this value is as good as any other... XD

		str_in [i] = a ^ b
	}
}
```

The answer, then, is to see the contents of the string being compared with the counter
(whose values we already know: 0x69, 0x61, 0x6b...). The obfuscated string is in the
data, so we can see its value:
```
$ objdump -s -j .data crackme2

crackme2:     file format elf64-x86-64

Contents of section .data:
 4038 00000000 00000000 40400000 00000000  ........@@......
 4048 3a060a1c 0e060000 500000             :.......P..
```

Now it's just a matter of calculating the _XOR_ of that value with the ounter. For
instance, we can do it with just a couple of lines in Python:
```python
# Python 3.7.2 (...)
# [...] on linux
# Type "help", "copyright", "credits" or "license" for more information.
>>> a = '\x3a\x06\x0a\x1c\x0e\x06\x00\x00\x50'
>>> b = [ chr (i) for i in range (0x69, 0x69 + 9, 1) ]
>>> b
['i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q']
>>> "".join ([ chr ( ord (a [i]) ^ ord (b [i])  ) for i in range (8) ])
'Slapchop'
>>> "".join ([ chr ( ord (a [i]) ^ ord (b [i])  ) for i in range (9) ])
'Slapchop!'
>>>
```

Then we just have to check that it's indeed the correct value and see what the program
returns (the output is translated from Spanish):
```
$ ./crackme2
This is going to Fascinate you!! Give me the password: Slapchop!
It's Correct.. The Password is your Flag, Champion!!!
```

Cool :D

The _flag_ is: `flag{Slapchop!}`.

-----------------------------------------------------------------------------------------

And here end the reverse engineering challenges :)

I always enjoy Ciberseg's challenges, and this year they were over the top. I hope to
have time to compete next year. I'm sure they'll excel again :)

I also want to congratulate the organizers for all their effort and their creativity to
design challenges that differ from the usual.
