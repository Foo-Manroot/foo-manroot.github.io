---
layout: post
title:  "Impersonating a remote using SDR and GNURadio"
date:	2018-01-15 19:31:24 +0100
author: foo
categories: gnuradio sdr
ref: gnuradio-ook-transmit
---

A couple of months ago I [wrote a post]({% post_url 2017-11-18-gnuradio-ook %}) talking
about the capabilities of SDR, allowing us to sniff radio communications with very cheap
hardware; and now I'm going to talk about the next step: using that same hardware to
impersonate any device we want.

I've had everything ready for a long time but I couldn't find time to write this post
and record the videos with the demonstrations; so don't think that this took me three
months to prepare. In fact, it's very simple. I chose a ridiculously easy target; but
the same flow can be applied to any target you want and it should take you little time
to start playing around.


## Legal notice

**Disclaimer**:
```
I am not a lawyer, and everything I say on this section applies only to Spanish laws.
They may be similar in your country, or the may not. In any case, I recommend you to
take some time to consult someone who could tell you the legality of these experiments;
or at least take a look on your local regulations.
```


Before diving into the technical details, it's important to know the legality of
transmitting on certain frequency ranges. We didn't have to worry about this on the
previous part, listening to signals, as it's legal to do it (at least where I'm from,
Spain) except some special frequencies like military communications and the like.

Regarding transmission, this is all I could find about the laws here on Spain (all cited
sources are on Spanish):
  - According to the [E.U. regulation (p. 11)](https://www.boe.es/doue/2017/214/L00003-00027.pdf),
	"unspecific short range devices" (telemetry, remotes, alarms...) on the
	433'92 MHz band can freely transmit with up to 10 mW of effective radiated power.
  - On the latest [frequencies assignations table (p. 12)](http://www.minetad.gob.es/telecomunicaciones/espectro/CNAF/notas-UN-2017.pdf)
	from the Spanish government it seems to corroborate the 10 mW limit, stating also
	that anything that works on that band must accept interferences from other
	devices operating on that same frequencies.

If you are on the European Union, maybe this regulations apply to you, too; but it would
be better if you'd check it, just in case...



## Set up

As on the previous post, I'm going to work with the
[HackrfOne](https://greatscottgadgets.com/hackrf/) transceiver (the cheaper RTL won't
work here, as it doesn't transmit). Also, the remote I'll try to impersonate is the same
one (an [EM_MAN-001](http://dinuy.com/es/rss/86-productos/domotica/229-em-man-001)).

To test if the signal is correctly transmitted, I'll plug two lights on a couple of
receivers I had around the house.


That was the hardware. On the software side, this time I'll use only
[GNURadio](https://www.gnuradio.org/), with some custom blocks written in Python.


As a final note, the studied remote works with
[On-Off Keying - OOK](https://en.wikipedia.org/wiki/On-off_keying), modulated in ASK, so
the shown flowgraphs are designed to modulate in AM. This information was gathered on the
previous post, along with the baseband frequency (needed to synthesize the signal).


## Replaying the signal

This is the first and easiest method to try. It consists in capturing the desired signals
and store them to simply replay them whenever we want.

The actual method to do it (with the flowgraphs) is more deeply explained on the
[previous post]({% post_url 2017-11-18-gnuradio-ook %}#transmitting-the-signal).

Although quite rudimentary, it's a very simple first step that tells us a lot of things
about the signal, whether it works or not:
  - If the replayed signal generates a response from the receiver **every time** we
	transmit, we can conclude that the packets are always the same, without rolling
	codes, counters or any other variable.
  - If, on the other hand, it only **works sometimes** (or at all), we can deduce that
	there's some part of the packet that's changing (like a counter or a rolling
	code). This tells us that the protocol is more complex and simply replaying
	a captured signal is not good enough. However, if it only works sometimes, we can
	stay a long time transmitting until the receiver accepts the message. This may
	not be very useful when activating a light; but it can be even dangerous if our
	car can be opened " _only sometimes_ " (this may be caused by a rolling code
	with a short cycle).

Even when we fail to replay the signal, we can extract some information about the target.

If this method works for you (it should if your target is a remote like mine, or some
toy), then congratulations :)

If it doesn't, don't give up, as there are other techniques you can try. Also, check
that the signal is being transmitted correctly with another SDR. You should also check
that all the parameters are correct (sampling rate, frequency...). If none of this works,
you could change your target to an easier one.


## Synthesizing the signal

The next step is to create the desired signal on the fly, directly from GNURadio, without
any stored file with the captured signal, because this files tend to be very heavy and
it's very annoying to capture _all the possible packets_ by hand.

So, how do we synthesize a signal?

The first thing is to create a squared wave with the signal we want. In this case, the
coding used by the remote is
[On-Off Keying - OOK](https://en.wikipedia.org/wiki/On-off_keying), and so the generated
wave has to be like this:
```
To represent a '1': 3/4 of a period high, 1/4 low
To represent a '0': 1/4 of a period high, 3/4 low


Period:      |0       |1       |2       |3       |
Bit:         |  '1'   |   '1'  |   '0'  |   '0'  |

High ->       _____    _____    __      __
             |     |  |     |  |  |    |  |
             |     |  |     |  |  |    |  |
Low  ->  ----+     +--+     +--+  +-----  +------
```

Now, to generate this signal we can simply generate nibbles (4-bit numbers) and serialize
them to obtain the consecutive samples that are needed: let's say we want to produce a
'1', represented by a long burst. If we stipulate that 4 bits are one period, then our
'1' would be `1110` (0xE), while a '0' would be `1000` (0x8).

Knowing this, we'll just generate an infinite series of 0's and 1's with the
`Vector Source` block and we'll convert them to 0x8 or 0xE respectively with the `Map`
block. Finnally, the `Unpack K bits` block can be used to serialize those 4-bit numbers.
I also added some 2s that where mapped to 0x0 to create some blank space between packets.
The result is the following:

{% include image.html
	src="/assets/posts/2018-01-15-gnuradio-ook-transmit/square_wave.jpg"
	title="Stem plot of the generated signal"
	alt="Generated stem plot of the signal as seen on GNURadio's time sink"
%}

To ease my work I created a variable with the packet in a string and the vector source
is generated using the following Python code:
```python
[ int (x) for x in packet ] + [ 2 ] * spacing
```


Now that we have a squared signal, it's time to upsample it to our desired sampling rate.
To do this, we can use the `Rational Resampler` block and set the interpolation to
`samples_per_symbol / 4` (the '4' comes from the fact that we're generating 4 samples
for every bit), using the knowledge of the signal that we acquired when we
studied it. The _samples_per_symbol_ variable is calculated using the baseband frequency
and the sampling rate as follows: `int (samp_rate / baseband_freq)`. After the resampler,
I used a `Moving Average` filter (setting the length to `samples_per_symbol / 4`) to
create the pretty signal that can be seen on the following image:

{% include image.html
	src="/assets/posts/2018-01-15-gnuradio-ook-transmit/squared_upsampled.jpg"
	title="Final upsampled square signal"
	alt="Generated plot of the upsampled signal"
%}


Now it's just a matter of modulating this squared wave to AM and send it. In fact... we
don't even need to modulate it (I guess the HackRF does it for us). This is the final
flowgraph, that can be downloaded
[here](/assets/posts/2018-01-15-gnuradio-ook-transmit/transmit.grc):

{% include image.html
	src="/assets/posts/2018-01-15-gnuradio-ook-transmit/transmit_flowgraph.jpg"
	title="Final flowgraph to synthesize the signal"
	alt="Complete flowgraph to synthesize a signal modulated with ASK"
%}

## Bruteforcing

Once we can transmit data, the next step is to bring chaos to the world, sending every
possible packet and turning everything on and off. I haven't tested it yet, but I guess
that this technique could also be used to defeat rolling codes by testing all
combinations until the car opens...


To this end, the flowgraph is left untouched, except the generator of numbers, where
the `Vector Source` has been replace by a custom block whose code can be downloaded
[here](/assets/posts/2018-01-15-gnuradio-ook-transmit/gen_packets.py). The new flowgraph
can also be downloaded
[over here](/assets/posts/2018-01-15-gnuradio-ook-transmit/bruteforce.grc).

{% include image.html
	src="/assets/posts/2018-01-15-gnuradio-ook-transmit/bruteforcer_flowgraph.jpg"
	title="Modified flowgraph to generate different packets"
	alt="Modification of the previous flowgraph, showing the changed block"
%}


This custom block takes a pattern (a regular expression) as an argument and, using
either [exrex](https://github.com/asciimoo/exrex) or pure bruteforcing (whichever method
is faster), generates all possible strings of 0's and 1's to be passed to the serializer.

The code of this block is quite simple, as it only uses a generator that `yield`s every
packet (string of 0's, 1's and 2's) and groups them into an array to be passed to the
next block.

As always, you are completely free (as in _freedom_) to modify these scripts and
flowgraphs, and use them for whatever you want. The only thing I ask you is not to blame
me when something goes wrong :D (although I'd appreciate some suggestions to
improve them).


To show the bruteforcer in action, I used a couple of receivers to turn on and off some
lights. In the following video I first show the remote being used, and then I start the
bruteforcer, that goes through all the combinations (only on one channel), turning on
and off the two lights:

{% include video.html
	src="/assets/posts/2018-01-15-gnuradio-ook-transmit/demo.webm"
%}

