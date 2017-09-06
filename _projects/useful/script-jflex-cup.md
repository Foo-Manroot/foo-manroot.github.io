---
layout: project
title: "Script JFlex/CUP"
tags: [sh, lex, cup, java]
lang: en
ref: projects-script-jflex-cup
---

## Script JFlex/CUP

This project started when, in the laboratory of our '_Language Processors_' course, we
were told to use [CUP](http://www.cs.princeton.edu/~appel/modern/java/CUP/) and
[JFLEX](http://jflex.de/) to generate a parser to a language with the specifications they
gave us.

The problem was that the only useful way to work with it (at least, the only way that the
professors told us about) was to use a plugin for [Eclipse](https://www.eclipse.org/),
and I just didn't wanted to install all that useless stuff (yup, you guessed it: I'm a
[vim](http://www.vim.org/) fan) just for one semester.

With things as they were, my initial reaction was to use every tool by hand (also, you
guessed it again: I love to use the console for almost everything), but that was insanely
repetitive and boring; so I just created a little script to generate and compile
everything for me.

But, as I always try to make things better, I started to add more options and
functionalities until I had a quite complete script.

Also, I added some examples and even [the final work](https://github.com/Foo-Manroot
/Script-JFlex-CUP/blob/master/test/sem/Memoria.pdf) resulting from that semester, with
the report and full source code (everyhing in spanish, of course).

{% include image.html
	src="/assets/projects/images/script-jflex-cup.png"
	title="Parser in action"
	alt="Parser output"
%}

----

This project is [hosted on Github](https://github.com/Foo-Manroot/Script-JFlex-CUP).
There should be more info about the project and its directory structure.
