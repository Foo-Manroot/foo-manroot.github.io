---
layout: post
title:  "Side-channel attacks"
date:	2018-01-09 11:03:27 +0100
author: foo
categories: side-channel
ref: side-channel-attacks-cso
---

I haven't post anything in a while, and the recent disclosure of the
[Meltdown and Spectre](https://meltdownattack.com/) attacks reminded me of a little
presentation a friend of mine, Alberto Serrano, and I did as an assignment for the
course _Computer Structure & Organization_, from the past year on the university.

Spectre and Meltdown both rely on
[side-channel attacks](https://en.wikipedia.org/wiki/Side-channel_attack), measuring the
time taken to access memory to determine if some value was on cache memory or not,
allowing any process to read any memory position it wants to. Of course, it's more
complicated than that; but the point is that side-channel attacks still are a very
dangerous attack vector. One that should be taken in account when designing (or
attacking) any system.

On this course, _CS & O_, we were told to make a little presentation of roughly 10
minutes, so it's very short; but it may still have some interesting things.

{% include embed_pdf.html
	path="/assets/posts/2018-01-09-side-channel-attacks-cso/cso_slides.pdf"
%}

