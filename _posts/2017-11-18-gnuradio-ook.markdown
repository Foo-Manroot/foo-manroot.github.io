---
layout: post
title:  "Studying radio communications with GNURadio and SDR"
date:	2017-11-18 16:51:19 +0100
author: foo
categories: gnuradio sdr
ref: gnuradio-ook
---

This is my last year in college, and for my end-of-degree project I'm investigating the
usage of SDR (Software Defined Radio) to intercept and attack insecure radio
communications.

The initial applications were just to intercept wireless keyboards and mice; but that
work [has already been done](https://www.mousejack.com/), so I decided to give it a more
broad scope and to study all radio communications, including garage remotes, wireless
keys of some cars...

For now, I'm just playing around learning how to use [GNURadio](http://gnuradio.org/) and
trying to decode simple signals from domotic remotes that used for things like turning
on or off some lights on the house.


## Hardware

First of all, we need the devices used to intercept and transmit signals at the desired
frequencies.

### Receivers

There are multiple cheap options to receive signals. You just have to seach for
"RTL2832U" (I bought mine for about 5$, but the antenna isn't very good).

Note that this cheap dongles **_won't allow you to transmit_**. They are good receivers,
though, and should be enough to start playing with SDR.

More info about the RTL-SDR can be found on [rtl-sdr.com](https://www.rtl-sdr.com),
including a store to buy hardware and multiple tutorials to build or buy an antenna that
suits your needs, decode NOAA signals to get
[amazing meteorologic images](https://www.reddit.com/r/RTLSDR/search?q=noaa&restrict_sr=on)...


### Transceivers

If you're more comfortable working with radio signals, or you think that you can use it
for more projects, you can buy a transceiver for a couple of hundred dollars, like the
[HackRF One](https://greatscottgadgets.com/hackrf/).


```
I'll provide some samples to work without needing a hardware device; but, if you'd like
to play around with your own remotes, you should get one of the devices listed above.
```


## Software

The only needed software will be GNURadio, but you can use any program to locate and
take a look at the received signals. Two popular options are [GQRX](http://gqrx.dk/) and
[SDR#](https://airspy.com/download/), but there are hundredths of other useful programs.


## The remote

I'm going to work with the remote I had on my home: [EM_MAN-001
, made by  Dinuy](http://dinuy.com/es/rss/86-productos/domotica/229-em-man-001). On the
linked page there are a couple of characteristics of this remote; but the interesting
ones are (translated from spanish):

	- Comunication:	By radio frequency (433,92MHz)
	- Modulation:	ASK

{% include image.html
	src="/assets/posts/2017-11-18-gnuradio-ook/EM_MAN-001.jpg"
	title="Remote to be studied"
	alt="Dinuy EM_MAN-001 remote to be studied"
	style="max-height: 300px"
%}

So, just looking at that table provided by the manufacturer, we know two essential
things: the __frequency__ and the __modulation__. We could figure those searching on the
spectrum (usually, these remotes use the 433 MHz
[ISM band](https://en.wikipedia.org/wiki/ISM_band)) and examining the wave (again, these
remotes usually modulate with
[On-Off Keying - OOK](https://en.wikipedia.org/wiki/On-off_keying)).

-----------------------------------------------------------------------------------------

## Intercepting and analyzing the signal

Once we set the receiver tuned to 433'92 MHz, we should see something similar to this on
GQRX:

{% include video.html
	src="/assets/posts/2017-11-18-gnuradio-ook/Screencast-GQRX.webm"
%}

And looking at the recorded WAV file using on Audacity, we can see a very pretty signal:

{% include image.html
	src="/assets/posts/2017-11-18-gnuradio-ook/gqrx_capture-audacity.jpg"
	title="Capture of the signal"
	alt="Signal viewed on Audacity, showing the digital squared wave"
%}


The WAV file with the recorded signal can be downloaded from
[here](/assets/posts/2017-11-18-gnuradio-ook/gqrx_capture.wav).


## Retrieving the data by hand

The codification shown on the image above is very simple, and can be decoded by hand.
Basically, long bursts are interpreted as one bit (for example, a _1_), and short bursts
are interpreted as the other bit (for example, a _0_). To tell apart long and short
bursts, we can look at the center of the period (high means a 1 and low means a 0, for
example).


{% include image.html
	src="/assets/posts/2017-11-18-gnuradio-ook/signal-hand-decode.jpg"
	title="Decoded data from the signal"
	alt="Signal viewed on Audacity, showing the digital squared wave; and showing the decoded bits"
%}


Thus, the data that corresponds to the first button pressed on the capture is `0100 0001
0101 0100 0001 0101 0`


On the capture there are three different button pulsations:
  - Channel II, button 4 (ON):	`0100000101010100000101010`
  - Channel II, button 4 (OFF):	`0100000101010100000000000`
  - Channel II, button 4 (ON):	`0100000101010100000101010`


These kind of devices use this simple encoding to avoid losing information (as those
bands have a lot of interferences), and is pretty common for the information to be
repeated multiple times, like on this remote, where the packets are repeated after
waiting one or two periods.


I used Python to automate the process of decoding the recorded signals (although I found
that GNURadio was better for the task), extracting the following data, to study the
protocol:

{% include image.html
	src="/assets/posts/2017-11-18-gnuradio-ook/protocol-study.jpg"
	title="Study of the protocol"
	alt="Bits received, depending on the button pressed"
%}

As a side note, I made a little syntax file for vim (as can be seen on the image above),
that can be downloaded [from here](/assets/posts/2017-11-18-gnuradio-ook/signal.vim). To
use it, create a `.vim.custom` file on your working directory with the following content
(or add it directly to your `.vimrc`, or however you prefer to do it...):
```vim
autocmd BufRead,BufNewFile *.signal set filetype=signal
autocmd Syntax signal so **/syntax/signal.vim
```

Also, even though the main purpose is to use GNURadio, I'll leave
[here](/assets/posts/2017-11-18-gnuradio-ook/wav_data_extract.tar.gz) the code (Python2)
used to extract bits from the WAV recording, that I used before learning about GNURadio.
To know more about its usage, simply execute `./decode.py --help`.


-----------------------------------------------------------------------------------------

## Using GNURadio

Now that we know everything we have to know about the signal, we can start using GNURadio
to analyze or decode in real time. I'll take for granted that you have some basic
knowledge of GNURadio or Digital Signal Processing (I'm not an expert either... just
some basic concepts are enough to follow this part).

To learn more about any of those subjects, there are a lot of useful tutorials on the
internet, like [this series](https://greatscottgadgets.com/sdr/) about DSP, made by the
creator of the HackRFi,
or [this other series](https://wiki.gnuradio.org/index.php/Guided_Tutorial_Introduction),
from the GNURadio wiki.


From now on, I'll be working with
[this IQ file](/assets/posts/2017-11-18-gnuradio-ook/cap.iq.tar.bz2), captured using
GNURadio, for it's simpler to work with it than to plug the dongle.


### Getting the digital signal

The captured signal is [modulated](https://en.wikipedia.org/wiki/Modulation) on AM. That
means that we have the carrier wave (at 433 MHz), but we have to recover the original
signal to start decoding. As the modulation method used is very simple, we can simply use
the `Complex to Mag^2` block. Also, a `Threshold` can be used to reduce the signal to a
perfectly squared wave.

This first flowgraph (with a widget to tune the frequency) can be downloaded from
[here](/assets/posts/2017-11-18-gnuradio-ook/flowgraphs/analyze.grc):

{% include image.html
	src="/assets/posts/2017-11-18-gnuradio-ook/flowgraph_receiver.jpg"
	title="Flowgraph to extract the digital signal"
	alt="Flowgraph with the mentioned blocks to demodulate the signal"
%}

For now, we can only view the digital signal (along with the different stadiums while
processing the captured wave). We can also add a band-pass filter to reduce noise.

### Analyzing the signal

To accurately retrieve data from the signal while it's been captured, we have to get
some statistics, like the baseband frequency (to know the number of samples per period,
so we can distinguish between long and short bursts). To do so, we can use the previous
flowgraph along with a custom block whose code can be downloaded from
[here](/assets/posts/2017-11-18-gnuradio-ook/flowgraphs/stats_collector.py), and add it
to the output of the `Threshold` block, as shown on the image:

{% include image.html
	src="/assets/posts/2017-11-18-gnuradio-ook/flowgraph_get_stats.jpg"
	title="Flowgraph to analyze the digital signal"
	alt="Flowgraph with the new custom block to get statistics of the signal"
%}

This new flowgraph can be downloaded from
[here](/assets/posts/2017-11-18-gnuradio-ook/flowgraphs/get_stats.grc).

An example of the output may be like the following:
```
(...)
******************************
=> General stats:
	 -> Min burst: 688
	 -> Max burst: 2319
	 -> Mean: 1206.8630303
=> Short bursts:
	 -> Median: 716
	 -> Longer burst: 748
=> Long bursts:
	 -> Median: 2243
	 -> Shorter burst: 2223
=> Signal period (median): 2959 samples (675.904021629 Hz)
(...)
```

Now we know the baseband frequency, 675'9 Hz, and we can start decoding the data on the
fly, as we capture signals.


### Decoding in real time

To decode the data, I'll substitute the `statistics sink` for
[another custom block](/assets/posts/2017-11-18-gnuradio-ook/flowgraphs/ook2bin.py) to
dump the bits on stdout. I guess there may be a simpler method to dump the data, but I
chose this one because Python is a language where development is very fast, and I didn't
know how to do it with the available blocks.

This flowgraph can be downloaded from
[here](/assets/posts/2017-11-18-gnuradio-ook/flowgraphs/decode.grc); and this is an
example of it decoding packets in real time:

{% include video.html
	src="/assets/posts/2017-11-18-gnuradio-ook/Screencast-flowgraph_decoding.webm"
%}


### Transmitting the signal

Finally, we've arrived to the cool part!, where we can play with
lights / doorbell / _whatever-your-remote-is-for_ ...

If you have one of the RTL-SDR dongles, you won't be able to transmit; but there are a
lot of cheap alternatives to the HackRF (that I'll use for transmitting) out there. The
HackRF and other similar transceivers are expensive because of the wide range of
frequencies they can handle; but little chips that transmit on 433 MHz should cost about
5-10$. I haven't tried it, but I guess it could be easy to use an Arduino or a Raspberry
and, along with one of those chips, synthesize the desired signal.


Anyway, there are to methods to impersonate the remote: replaying the captured signals,
or creating our own signal and broadcast it for the end point (the light, the doorbell,
etc.) to receive it.

Replaying the signal is a very easy method. We just have to store the signal into a file
and then, use that file as a source to transmit.

It's not the better method, as we'll have to capture every possible value, from every
one of the different buttons; and this method doesn't scale. When you have more than
three or four buttons, it's starting to get boring. Also, we should be careful with the
parameters (frequency and sample rate), to replay the exact same signal we received.

The flowgraphs are very simple.

Receive:
{% include image.html
	src="/assets/posts/2017-11-18-gnuradio-ook/flowgraph_capture.jpg"
	title="Flowgraph to capture the signal to be replayed"
	alt="Flowgraph with the needed blocks to store the signal into a file"
%}

Replay:
{% include image.html
	src="/assets/posts/2017-11-18-gnuradio-ook/flowgraph_replay.jpg"
	title="Flowgraph to capture the signal to be replayed"
	alt="Flowgraph with the needed blocks to store the signal into a file"
%}


For the other method, synthesizing a signal, I'll create another post, as it requires a
longer explanation and this post is already too long.
