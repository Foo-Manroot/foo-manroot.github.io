---
layout: project
title: "Time Wanderer"
tags: [java]
lang: en
ref: projects-time-wanderer
---

## Time Wanderer

{% include image.html
	src="/assets/projects/images/time-wanderer.png"
	title="Cover"
	alt="Time-Wanderer cover"
%}

This is a videogame that we (some classmates and I) made for the college's course
'_Videogames Technology_' as a final project.

Its written in Java, using [Slick2D](http://slick.ninjacave.com/), a low level graphics
engine (in fact, it's just a wrapper around OpenGL).


This is a Rogue-like game, where the goal of the player is to clear the level killing
the final boss, while opening the various chamber for the two characters to kill their
respective boss.

In this game, the player controls two characters (not simulataneously, but changing
between them) that are isolated between them, with each one of them on their timeline
(the first one is like an Indiana Jones archeologist on the present time, and the other
is some kind of warrior from past times) while collaborating, as the archeologist is on a
ruined temple with blocked chambers. Thus, the warrior from the past must activate some
levers to clear those blockades.


As it's stated before, Slick2D is just a wrapper around OpenGL; so this game is almost
done from scratch (including physics and AI).

----

This project is [hosted on Github](https://github.com/Foo-Manroot/Time-Wanderer). There
should be more info about the project and its directory structure to contribute to it.


Also, the latest release can be downloaded [here (82 MB)](/assets/projects/
Time-Wanderer-dist1.0.tar.gz).
It's ready to be played. Just doule click on it; or run `java -jar Time-Wanderer.jar`
from console.


The instructions are in spanish, but with the information from this page should be
enough to play the game without problems.
