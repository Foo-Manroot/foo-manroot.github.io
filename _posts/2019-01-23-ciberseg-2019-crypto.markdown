---
layout: post
title:  "Ciberseg 2019: crypto"
date:	2019-01-23 15:38:22 +0100
author: foo
categories: ctf ciberseg write-up crypto
ref: ciberseg-2019-crypto
---


Hi there! In this first post of the year I bring you this year Ciberseg's write-ups.
Specifically, these are the ones corresponding to the **cryptology** category.

[Ciberseg](https://ciberseg.uah.es/) is an annual congress which takes place in the
University of Alcalá de Henares. The truth is that previous years it has been always fun,
and this year wasn't less :) Also, the first places were disputed hard and there were
last-time surprises :D (in the end, I literally won at the last hour by just a few
points).


Anyways, these are the challenges and their solutions. For those that need it, I'll also
leave the necessary resources that we where given to try the challenge by yourselves.

-----------------------------------------------------------------------------------------

# 1.- Complutum message (15 points)

The description of this message states:
> PbzcyhgvHeovfHavirefvgnf


As the challenge was worth so little points and had that title, we're positive about the
cipher being a simple Caesar's cipher. For those who don't know, _Complutum_ was the name
of the roman settlement that preceded the modern city of Alcalá de Henares, where the
congress takes place.

If you decipher it (either by pure bruteforce, by analyzing the frequencies or using any
webpage), the clear text that we get is `COMPLUTIURBISUNIVERSITAS`, with the key **n**.

It was a piece of cake, wasn't it? Not bad to heat up and boost our morale :D

The _flag_ is `flag{COMPLUTIURBISUNIVERSITAS}`.

-----------------------------------------------------------------------------------------

# 2.- Alien message from XXXI century (50 points)

This challenge has the following description:
> We have received an alien message!! Can you help us understand it?


Also, an image is attached:
{% include image.html
	src="/assets/posts/2019-01-23-ciberseg-2019-crypto/alienMessage.jpg"
	title="File attached to the challenge"
	alt="An image with white background and a series of strange symbols at the foreground, in black, which doesn't seem to be any standard alphabet (latin, cyrillic...)"
%}


These symbols are a little bit wire, but I'm pretty sure that some people have already
seen them in the past. If that's not the case, we could always search _alien language_ on
the _interwebs_ with **DuckDuckGo**, for example, or something like that, and we'll
quickly arrive to [Futurama's Alien language](https://theinfosphere.org/Alien_languages),
that has exactly those same symbols we're looking for.


Once we know the alphabet, we can just go letter by letter comparing the table and we end
up with the following text: `PLANET EXPRESS UAH`. And that's all, we have 50 points more
without batting and eye :D

The _flag_ is `flag{PLANETEXPRESSUAH}`

-----------------------------------------------------------------------------------------

# 3.- Classical (75 points)

The description of this challenge states:
> In cryptography, like with beer, a classic one always comes handy:
>
> sa okhbx dpejaja gc uad ei wlk tau becufwielhtkfaf effi uw sa okhbx pvmxauan ne zlm
> sgygjigxtbv oszvfaa fo chdohs jw btkvimdce xrhvn fo cbudls p ubyc loghmpe jw llcloedce
> eillscxaypfrxv hhsq k drqpqmesysg waurv gprkpcc on zlm rsmwjigxtbv oszvfaa a drrv ei
> gfdvr fyrngp ewgwjtq lrvomerkw f cworcr nshvjhdq nefwbge ggy sw caors wyrnl y deea
> hrymcairky ea epge jm hrqwa rv mmkvjv ahbugdes gff aopys sopvecwz dg vúphop psj
> hyipmicdmiw zfnrgnirquiw jgu lgfaqxse plhblq kghd z qeclh sqwof pvc gcszieys rq ushf
> hhrc va phsziqs f pcba yd dvmglvgtkfvd qsv vkv hgwof gfgmuako ootru fwxv tvnkdo
> ilhirvjl lc plnj fw lrurapnbrhsw ulw zop nof fpwej ibe uo lyhwer dmf bkon crs iwf
> vllgqaplpr siyhnkjaod fp zzsqe c va sdcvmts ke nk cruwidr


As the Caesar cipher has already made appearance, it most probably is something like
Vigenère, another one who's always used in CTFs. In those cases I don't complicate myself
and go directly to webpages like [guballa.de](https://guballa.de/vigenere-solver) or
[dcode.fr](https://www.dcode.fr/vigenere-cipher), that tend to work pretty well.

Bear in mind that **the solution will be a text in spanish**.

In this case, guballa extracts the key in no time: _hackandbeers_. The decrypted text (in
spanish) is:
```
la mahou clasica es una de sus mas representativas bebe de la mahou original de mil
ochocientos noventa de cuando se utilizaba tapon de corcho y cuya botella se elaboraba
artesanalmente paso a denominarse mahou clasica en mil novecientos noventa y tres de
color dorado aspecto brillante y cuerpo moderado destaca por su sabor suave y buen
equilibrio en boca su aroma es ligero afrutado con tonos florales de lúpulo los
principales ingredientes son levadura lupulo agua y malta somos muy clasicos en todo para
la cerveza y para la criptografia por eso hemos decidido meter este bonito vigenere la
flag es hackandbeers que son dos cosas que se llevan muy bien por eso delegacion
organizaba el viaje a la fabrica de la cerveza
```

And that's it.
As the text says, in the penultimate line, the _flag_ is `flag{hackandbeers}`.


-----------------------------------------------------------------------------------------

# 4.- Cryptography is not steganography (150 points)


The description of this challenge states:
> Let it clear! Hiding is not encrypting!


We also get the following video:

{% include video.html
	src="/assets/posts/2019-01-23-ciberseg-2019-crypto/harder.webm"
%}


With this challenge the thing start to be a little bit more interesting. At first sight,
the video is quite normal; except for the ending, where the image goes to black but the
sound is still going. This made me suspect that something was hidden in the final part of
the file. As the title talks about steganography, I spent a few hours trying to get some
data out of it, without any luck.

That went until, after looking at the video 876512348756123478 times, we realize a little
detail: there's a dancing pixel on the top left corner. Do you see it?

Well, it took me some time; but I finally saw it. There are people who would've made a
_script_ to extract the values of that pixel; but I decided to extract all the 181 frames
(`ffmpeg -i ../harder.mp4 fotogramas/output%05d.png`) and take a little piece of paper
taking note of each of thos values. It's not precisely efficient, but at least it's
effective... ¯\\\_(ツ)\_/¯


At first glance I though it was Morse; but, after seing its irregular pattern and that
there was no way to translate that into dots and dashes, I decided to pass onto my second
option: binary.

If we take a black pixel as a _1_ and a white pixel as a _0_, we get the following:
```
01100110	f
01101100	l
01100001	a
01100111	g
01111011	{
01100100	d
01100001	a
01101110	n
01100011	c
01101001	i
01101110	n
01100111	g
01011111	_
01110000	p
01101001	i
01111000	x
01100101	e
01101100	l
```


There's the flag. In the end we just had to be aware of that tiny dancing pixel :)

I guess that I didn't take note of the last Byte and that's why the closing bracket, _}_,
is missing.

The _flag_ is `flag{dancing_pixel}`.


-----------------------------------------------------------------------------------------

# 5.- To be XOR not to be (200 points)

The description of this challenge states:
> They have censored the video broadcast, but let's see if we can get the name of the
> character that appears in it


And [this video](/assets/posts/2019-01-23-ciberseg-2019-crypto/result.mp4) is attached.


To solve this challenge we have to realise that the first frame is quite different to the
rest. If we add that to the title, _to be **XOR** not to be_, we can conclude that the
video is encrypted using an XOR between each frame and the first one.


To perform the XOR, we first extract all the frames with
`ffmpeg -i result.mp4 frames/output%05d.png`. This gives us 3045 files with which we
have to calculate the XOR. For this task I used a program named _gmic_, pretty easy to
use:
```sh
mkdir decrypted
cd frames

for f in *
do
	printf "%s\n" "$f"
	gmic ../key.png "$f" -blend xor -o ../decrypted/"$f" 2>/dev/null
done
```

Then, we can recover the video again by executing
`ffmpeg -i decrypted/%05d.png recompuesto.mp4`, which gives us back this video:

{% include video.html
	src="/assets/posts/2019-01-23-ciberseg-2019-crypto/recompuesto.webm"
%}


This doesn't really reveals which is the original video. After a couple of days without
anybody solving it, the CTF staff left a couple of clues:
> Hint! In this CTF we didn't create the OSINT category, but ... Have you considered
> looking for the decrypted frames on the internet? Remember: We look for the name of the
> character!


> Hint! We left a clue in our Twitter accoun
> https://twitter.com/ciberseguah/status/1086750900167819265


If we decrypt the image of the hint the same way we did with the video frames, we get
this clue:

{% include image.html
	src="/assets/posts/2019-01-23-ciberseg-2019-crypto/pista_descifrada.jpg"
	title="Decrypted hint"
	alt="Close-up of a face with the text (in spanish) 'if you prick us, do we not bleed?'"
%}

After searching on the internet, we arrive to the scene of
[Shylock's speech](https://www.youtube.com/watch?v=th7euZ30wDE), the character in
Shakespeare's _The merchant of Venice_.

As we were told that the answer was the name of the character in that scene, the _flag_
is `flag{shylock}`.

-----------------------------------------------------------------------------------------

# 6.- YUVEYUVEYU (350 points)

The description of this challenge states:
> From Ulan Bator plains we receive a strange signal

Also, the file **20190116_120900Z_106520122Hz_IQ.wav** is attached. Because it's too
heavy for Github Pages, I had to split it into 8 parts:
  - [Part 1](/assets/posts/2019-01-23-ciberseg-2019-crypto/20190116_120900Z_106520122Hz_IQ.wav.7z.001)
  - [Part 2](/assets/posts/2019-01-23-ciberseg-2019-crypto/20190116_120900Z_106520122Hz_IQ.wav.7z.002)
  - [Part 3](/assets/posts/2019-01-23-ciberseg-2019-crypto/20190116_120900Z_106520122Hz_IQ.wav.7z.003)
  - [Part 4](/assets/posts/2019-01-23-ciberseg-2019-crypto/20190116_120900Z_106520122Hz_IQ.wav.7z.004)
  - [Part 5](/assets/posts/2019-01-23-ciberseg-2019-crypto/20190116_120900Z_106520122Hz_IQ.wav.7z.005)
  - [Part 6](/assets/posts/2019-01-23-ciberseg-2019-crypto/20190116_120900Z_106520122Hz_IQ.wav.7z.006)
  - [Part 7](/assets/posts/2019-01-23-ciberseg-2019-crypto/20190116_120900Z_106520122Hz_IQ.wav.7z.007)
  - [Part 8](/assets/posts/2019-01-23-ciberseg-2019-crypto/20190116_120900Z_106520122Hz_IQ.wav.7z.008)


I've [already]({% post_url 2017-11-18-gnuradio-ook %}) done
[a couple of things]({% post_url 2018-01-15-gnuradio-ook-transmit %}) with SDR before,
the name of the file already gives me a big clue. In fact, the moment I saw it I went
directly to try this challenge :D


Usually, when we save a radio capture, we name the resultant file with the signal
properties, like sample rate, frequency, date... In this case, we have:

  - `20190116_120900Z`. Date: January, the 16th of 2019, along with its timezone

  - `106520122Hz`. The **center frequency**: 106.520 MHz

  - `IQ`. The type of recording: the samples are in [I/Q format](http://www.ni.com/tutorial/4805/en/)


Because the frequency of the capture is in the same band as commercial FM radio, we
expect to hear voices or music. This will help us to know if our demodulation is on the
right track.

Even though we could be using GNURadio to demodulate the signal, it usually is simple to
just use one of the popular spectrum analyzers, like GQRX or SDR#, which already
implement some common demodulators like wide-band FM.

For some reason, GQRX goes crazy trying to read the file and SDR# runs quite badly on my
Arch Linux with Wine; so I decided to create a Windows VM to open the file with SDR#.
Once open, we navigate around the different radio stations until we arrive to a signal
that doesn't seem to be one of the commercial stations and is more powerful than the
others. If we focus on it, we discover the following song:

{% include video.html
	src="/assets/posts/2019-01-23-ciberseg-2019-crypto/sdr-sharp.webm"
%}

Hmmm... Isn't there some weird sounds in there, in the middle of the song?


I almost go insane, because I love to unnecessarily complicate myself and I kept looking
for things like NRSC5 (HD radio), RDS... But eventually I asked myself, what if it's not
an extraneous signal on top of the music track, but something that's _inside_ the music
track itself?

In the end, it seems that it was as easy as extracting the audio (in SDR# there's a
_record_ button) and inspecting the spectrogram:

{% include image.html
	src="/assets/posts/2019-01-23-ciberseg-2019-crypto/lord_chinggis.jpg"
	title="Spectrogram of the music track"
	alt="Visualización del espectrograma de la pista de audio extraida, donde se lee 'flag{lord_chinggis}'"
%}

And there it is, the _flag_: `flag{lord_chinggis}`.

-----------------------------------------------------------------------------------------

These were all the challenges of the cryptology category. I always enjoy Ciberseg's
challenges, and this year they were over the top. I hope to have time to compete next
year. I'm sure they'll excel again :)

I also want to congratulate the organizers for all their effort and their creativity to
design challenges that differ from the usual.
