---
layout: post
title:  "Some impressions on OSWP (and a bit of ranting)"
date:	2024-09-08 11:29:58 +0200
author: foo
categories: offsec
ref: oswp-and-offsec-rants
---

Yesterday I finished the OSWP exam.
I don't know yet if I passed or not; but I got enough points and my report should be good.

But, anyways, I'm not here for another "yay, I passed, here are my tips to be a l33t h4x0r"; the exam is easy as fuck, you don't need my help with it.
I honestly think you can pass it without even going through the course.[^1]

No, no... I'm a grumpy bastard, so I'm going to complain about the course, the exam, and the OffSec company in general.
I got a cuestionary at the end of the exam where I roughly said the same as I do here.
Even though I doubt I was the first person to give a similar feedback, I sincerely hope Offsec sees past my harshness[^3] and takes the opportunity to improve.

This article is divided in 2 main parts:
 - [The course](#the-course-pen-210), where I talk about the PEN-210 course, without the exam
 - [The exam itself](#the-exam-oswp), with the whole experience of booking the exam and actually going through it

I won't give any specific examples from the actual course content or exam for obvious reasons, but I think everybody who has done any Offsec course can relate to what I'll say.

Here is the table of contents:
* ToC
{:toc}


# The course (PEN-210)

Let's start with the course.
In two words: **outdated** and **really bad**, in terms of the knowledge gained.
I'll cover these two topics on their own subsection, because I have a lot to say regarding each of them.


## Outdated

I remember a small workshop I attended back in University (so: ages ago) made by another student on his free time, because he just wanted to share knowledge.
That course was a very basic "intro to WiFi hacking" and, yet, covered basically the same topics as [OSWP](https://manage.offsec.com/app/uploads/2023/01/PEN-210-Syllabusv1.2.pdf).
And that workshop was 10 years ago, mind you, made by a total noob in the field.

Basically, **the knowledge I gained from this course boils down to remembering things I've forgotten**.
I don't really need to pay huge bucks for that; I can just go watch a basic tutorial on YouTube and it'll be faster than going through the PEN-210.

WPA-3 is barely mentioned (as in: "yeah, it exists but we're not covering it on this course"); while WPS has a whole module dedicated to it.
When was the last time you saw an exploitable WPS, especially on an enterprise setup?


This issue is **not limited to the PEN-210/OSWP**.
For example, I was convinced by a colleague to join the **EXP-301/OSED** (Windows exploitation) course: turns out, that it **only covers 32-bit exploitation and how to bypass DEP and ASLR**.
And that's it[^4].

I guess that was fine for a beginner course 10 or 15 years ago, but in 2024 there are dozens of courses (which I'll definitely check out next) which have a more relevant content and actually go deeper.

I also went through the WEB-300/OSWE a couple of years ago, and some of the chapters felt like they were written in the early 2000s.
My experience here might not be true anymore, though, since I was told they updated some topics right after I finished it.



## Bad quality

My first issue with the quality of the course itself, regardless of how up-to-date it might be, is that many topics covered are not really relevant nor properly explained.
This part is actually one of my major pain points with Offsec (besides their stupid "try harder" culture, but I'll get to it in due time), because learning is the sole reason why I'm doing the course.
If it's not of good quality, then I'm only wasting my time.


### No expert knowledge


In general, I feel that some modules are just a rip-off from some old blog posts stitched together by someone who kinda knows what the topic is about.
But it definitely does not feel like exclusive or relevant knowledge curated by an expert.
Which, in the end, is what I normally expect from a course that costs thousands of dollars.

I mostly get this impression from the **lack of depth in the explanations**, but also from how the course **beats around the bush**.
For instance, when explaining how a program works the course might randomly start explaining in depth how to compile it, sometimes even being pedantic about the proper usage of so-or-so options.
However, the actual value of the tool or even its inner workings are completely ignored besides the bare minimum, which sometimes might be summarised with "just RTFM, man".
I wouldn't be surprised if at some point the course starts ranting about how to properly edit a file with _the only true editor, emacs_[^5], instead of focusing on what that file is for.


Instead, what I get is a **basic overview** on the topics at hand with **_a looooot_ of filler**.


### Too much filler, but a gap in knowledge

With this I mean stuff like dedicating a chapter to the "inner workings" of RC4.
I put it in quotes, because it really is just a summary of the Wikipedia page, while the actual vulnerability isn't even properly explained.
Not that it matters, because RC4 is irrelevant besides breaking WEP and this is not a cryptography course in the first place.

By the way: did I mention that, besides saying that WEP is vulnerable, **they don't explain how to actually break it**?
This probably aligns with their "try harder" mentality, but I'd rather go deeper on something that was already explained (for example, exploring RC4 out of curiosity), than having to search the actual contents the course shoulöd be teaching me about.


On the other hand, it's remarkable how **little relevant content** is inside the course.
During the exam, I actually had to search online how to perform one attack, because the course simply didn't cover it.
Luckily for me, tutorials for basic WiFi hacking are everywhere, so I found it on the first try.


### External resources

Let's go with a pet-peeve of mine: the links to external resources.
<br/>
(almost) **All references are just Wikipedia links**.

Seriously. WTF

If I don't know a term, I can go to Wikipedia myself.
What I expect from external references is either links to tools (sometimes there are too many forks and repos with the same name) or other resources that might help me get deeper or get more info about a certain topic.

Goes without saying, that I quickly stopped checking the referenced links, because I knew they were just going to be Wikipedia articles.


### The videos

Speaking about things I stopped checking.
Have you seen the videos from the course material?

Well, I did.
It turns out that they're literally the **same sentences as in the text form, but just read out-loud**.
After a couple of videos, I obviously stopped caring about them.



## How to improve

Compare all of the previous points with the [CRTO](https://training.zeropointsecurity.co.uk/courses/red-team-ops) courses from Rastamouse, which I also finished and I only have good things to say about:
  - The course was **created by a recognised expert**. He does not try to sell you a dozen courses in very different topics, because he's an expert obiously only on his field.
  - **Modules are explained clearly and go to the point**. If you want to go deeper on a specific topic, it's up to you ( _this_ is what "try harder" actually means, dear Offsec)
  - Even though the **videos** cover the same topic that was already explained in text form, Rastamouse **does add very interesting insights** with his in-video comments.
  - The **links** he provides do **add value** to the explained topic and are actually super interesting reads.
  - As a bonus, I do have access to the **contents for life**, so I can always go back and check the new additions to make sure my knowledge is up-to-date.


# The exam (OSWP)

Let's talk about the exam now.
Again, two major pain points from my point of view: the tools used by Offsec have a **very bad UX**, and the **time pressure** is ridiculous.


## Tools' UX

This might be a silly point, but I think is a very important one.
I actually ordered the wrong exam because, when clicking on "book your exam", I got **redirected to booking the exam for another course** I hadn't even started (PEN-103/KLCP).
Luckily, I realised when re-reading the email with instructions a couple of times (another UX improvement: why so much text explaining the same over and over?).
But it was a tiny detail, just the course name in a couple of sentences.
That was very easy to miss.

Had I not noticed, I would've easily ended up in the wrong exam.

Another example of bad UX is the **report delivery page**: the irreversible **"submit" action is coloured in red** (as if it where a "cancel" button), whereas the **"Select a new file" is greyed-out and barely visible**.
If I were to quickly pick a "cancel" button because the file wasn't correctly uploaded, I would certainly go for the big, red button; but I'd end up sending the definite version instead.

In general, my impression is that all tools are **too text-heavy**[^7], which as a byproduct increase the pressure making me think I'm definitely going to forget something, and not very user-firendly.
Even the new, redesigned webpage is not really good, since I'm never able to find what I need (aka: my courses to continue where I left).
Instead, I get bombarded with their other courses to which I don't have access to, probably so I get curious and buy them.

However, as I said, I'm not a UX expert, so I might be totally wrong here.


## Lack of support

A small caveat here: this whole section deals with the support I got via email, the FAQs and their (useless) chatbot, "OSCAR".
I do not have a Discord account and, therefore, couldn't request help there.


Before beginning the exam, we have to go to the proctoring tool[^6] and follow an initial setup process.
To do that, we're given a hash which we must enter in that portal as a login, along with our student ID.
Unfortunately, I kept getting an error message ( **"Invalid OSID / MD5 value"** ).

"No problem", I thought, "there's an email address written in the message where I can (supposedly) get support in a timely manner".
Lo and behold, the replied came... half an hour later... with the exact same email I got two days eralier: "just use _\<the same MD5 as before\>_ to log in".
As expected, it was still not working.

After reaching out to them a couple of times more and continuing my login attempts with a stupid faith that it my let me in, it suddenly worked.
Almost an hour after I was supposed to start the exam.
I assume someone on the support team finally granted me access but didn't let me know.

My experience with both the support team and the proctors that later helped me sort out the confusion (I got an extra hour, which I ended up not using because I'm an idiot and confused GMT with my local timezone) is that they don't really read your messages and simply keep following what's in their booklets.
If you reply with anything more complex than "yes" or "no", they mostly ignore your additional explanation.

But, honestly, they're probably not to blame.
They're most likely getting a shitty salary and are overworked, so they won't go out of their way to help you out.
Unfortunately, that means you shouldn't really count on the support team to help you in a timely manner.


## More problems with quality

Here is where the knowledge gaps in the course really showed up.

Without disclosing too much about the exam, I'll just say that **I spent more trying to connect to a network** (after I've already cracked the key) using `wpa_supplicant` **than actually cracking the key**, which is what is actually taught in the course (well, not really, but we've [discussed it already](#too-much-filler-but-a-gap-in-knowledge)).
This, in my opinion, is a distraction from the main goal and does not really show any realistic real-world scenario.
Furthermore, this is an intentional stone put on the path of students, because the network managers had actively been removed from the exam VMs.


Finally, I'd like to dedicate a paragraph to something that has always astonished me: the quality of the report templates.
I understand that it's a report from an exam, done with a huge time pressure, so it doesn't have to be perfect.
However, Offsec seems weirdly proud of their templates, stating that they expect a "professional" report.
However, what they present as an example would not even qualify to go to QA: using the first person, describing irrelevant details, using a not-really-good structure and that horrible font...
Ok, I'm probably being a bit irrationally picky now.
Let's just say it's not a professinal report.



## How to improve

My proposals are quite simple, but the implementation requires probably quite a lot of effort.
In any case, I hope this broad ideas can help improve the exams:
  - Improve the UX of the internal tools, giving more visual clues regarding what actions are being taken (or whatever current guidelines are out there, I'm no UX designer)
  - Adjust the allocated time or the exam contents to reduce unecessary pressure. The students are already under pressure, so there's no reason to add rocks on the way which don't really evaluate the student's knoweledge (i.e.: fabricating unrealistic scenarios like hiding a password in an image)
  - Adjust the expectations of the exam. This means: if the goal of the certification is not to teach how to connect to an AP without using a network manager, then make it easy for students to do it. Or, rather: don't make it intentionally harder just for the sake of it



# The bright side

Ok, not eeeverything was bad, just _almost_ everything.
There were a couple of good points around the OSWP experience, which I touched before already.

The first one is regarding the time allocated for the exam, which is 3 hours and 45 minutes.
While most other Offsec exams are really tight, I managed to get 2 our of 3 scenarios of the OSWP quite comfortably in around 2 hours.
My only problem was actually connecting to the networs after obtaining the credentials, but I'm positive that the last scenario (which I didn't complete because I'm an idiot who can't count and I though my time was already over) wouldn't have taken more than half an hour.

The second one is that they actually send out a cuestionary to gather the students' opinions, so I guess they _do_ have interesting in improving (maybe?).



----


[^1]: Side note: [https://github.com/drewlong/oswp_notes](https://github.com/drewlong/oswp_notes) helped me a lot, because I couldn't manage to get the right config file to connect to the WPA-MGT network using `wpa_supplicant`. So, thanks @drewlong ! :D

[^3]: I _am_ quite harsh and I might express myself in very crude language. I hope you, the reader, can also see past that and focus on the actual ideas I'm conveying.

[^4]: Well, I'm being a bit unfair here: they also cover exploiting format strings. Very relevant for 2024, huh?

[^5]: I'm writing this from the _superior_ vim, of course

[^6]: This is a point which has really improved since the last time I took an exam with them: the system requirements are more detailed (for instancee, [Wayland](/post/oscp/2020/04/12/oscp-exam-proctoring-preparation.html) is explicitly stated as not working), and no more weird extensions have to be installed (on Firefox, at least). The only improvement I'd like to see here is a page where we can test that our setup is actually working. There are dozens of WebRTC test pages out there, but I'd like to make 100% sure that the code used by OffSec is actually picking up my displays, for example.

[^7]: Ironic, seeing my writing style XD


