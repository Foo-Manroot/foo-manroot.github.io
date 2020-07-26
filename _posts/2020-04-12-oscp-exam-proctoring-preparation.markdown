---
layout: post
title:  "Oscp exam proctoring preparation"
date:	2020-04-12 11:51:37 +0200
author: foo
categories: oscp
ref: oscp-exam-proctoring-preparation
---

`TL;DR: don't use Wayland for your OSCP exam`

Recently, I took my exam for the [OSCP](https://www.offensive-security.com/pwk-oscp/) and
I had some technical problems with the proctoring software they use.


I'm tempted to tell you my experience on the OSCP and give you some tips; but there are a
lot of good resources out there and I don't have anything to say what's not already been
said. You just have to study the course materials and practice as much as you can on the
labs and with any other platform you can put your hands on
([VulnHub](https://www.vulnhub.com/), [HTB](https://www.hackthebox.eu/)...).


However this post is for all the people who want to take the exam and may face the same
technical problems as I did. As you may already know, the exam is proctored. That means,
someone is watching you (literally, you have to keep the webcam turned on all the time)
and your screen is recorded.


In the exam guide they recommend[^1] to use their Kali VM to go through the lab and the
exam. That being said, my computer is not precisely a very high-end model, and tends to
die while trying to crack passwords, let alone cracking passwords from _inside_ a Virtual
Machine.


Therefore, I decided to use Kali in my host, without any virtual machine. I went through
the labs[^2] without mayor problems, getting my tools ready and everything perfectly
tuned to be a...

{% include image.html
	src="/assets/posts/2020-04-12-oscp-exam-preparation/hackerman.gif"
	title="Hackerman"
	alt="Hackerman meme"
%}


Little I knew that all disgrace would fall upon me the day of the exam. The examiner kept
saying that they didn't see my screen, just the mouse moving in a black background.
Something like this:

{% include video.html
	src="/assets/posts/2020-04-12-oscp-exam-preparation/screen-recording.webm"
%}

I tried to solve it for around half an hour, using different browsers and configurations,
until I gave up and used another computer I had with Windows 10. After another hour
downloading VMWare, the VM they provided and moving files around, I finally could start
my exam. That was not a good sign, not gonna lie...


Of course, I lacked all my tools and configurations: most of the programs were very old
and had different options and didn't even have the same functionalities I tend to use. I
tried to update it, but that destroyed the whole machine (God bless VM snapshots).

In the end, as you may all expect, I failed that exam attempt. I took it as a lesson and
prepared me better for the next attempt.

----

So, my question now is: what the hell happened? Why didn't they see my screen?

To answer that question, I had to know what technology does the proctoring software use.
During the set up, they told me to install [this plugin](https://chrome.google.com/webstore/detail/janus-webrtc-screensharin/hapfgfdkleiggjjpfpenajgdnfckjpaj)
for Chrome. The plugin's title, _Janus WebRTC Screensharing_ pointed me towards the right
track, as screen sharing was exactly what wasn't working for me.

So I started digging and digging about WebRTC screen sharing, narrowing down the problem
as I got deeper in it, testing it in other platforms and desktop environments. I used
[a couple](https://webrtc.github.io/samples/src/content/getusermedia/getdisplaymedia/) of
[webpages](https://janus.conf.meetecho.com/screensharingtest.html) to test this WebRTC
capability. And that raised further questions:

  - Why did it work perfectly on Arch Linux, and Windows, but not on Kali?

  - Even more: why did changing from the default Gnome environment to Xfce, for example,
	make it suddenly work on Kali?


At some point, I tried other applications, like Discord, and they didn't work either. So
the problem seemed to be in the screen sharing capabilities of the system itself, not on
the specific browser I'm using.


After some more _googling_[^3], I came across
[this question](https://superuser.com/questions/1221333/screensharing-under-wayland),
which finally settled it: Wayland is the problem.

The solution, switching back to anything but Gnome on Wayland:

{% include image.html
	src="/assets/posts/2020-04-12-oscp-exam-preparation/change_DE.png"
	title="How to change Desktop Environments"
	alt="Kali's password prompt with a dropdown to choose a Desktop Environment from"
%}

When the day of my second attempt arrived, I was more than ready. There were no problems
and I could start at the scheduled time, without stress and with my perfectly customised
Kali ready to go. This time, I rooted all machines but the 10-pointer in around 7 hours,
with plenty of time to take breaks, eat, and even write the report and deliver it before
my VPN access time run out.

<br/>
**Final note**: by default, the new Kali (2019 and 2020) comes with Xfce+X11 (I think)
instead of Gnome+Wayland. If that's the case and you like Xfce, then you won't have any
problem. Good luck with your exam attempt :)


----

[^1]: At least in the previous version, before they updated the course...


[^2]: Little incise here to give a little advice: please, please, don't be as stupid as I
    was and don't buy just a month of lab access. Your mental health will thank you. I
    think that two months of lab access is better. You know, to have some live and go
    outside from time to time, like normal people do...


[^3]: More like _duckduckgoing_... But that sounds a little bit too much XD
