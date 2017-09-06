---
layout: project
title: "Super duper umbrella"
tags: [c, cuda, c++, makefile]
lang: en
ref: projects-super-duper-umbrella
---

## Super duper umbrella

This project was made to create the program needed in our '_Advanced Programming II_'
course where we were asked to do a game similar to Candy Crush, using NVidia's GPUs (and,
therefore, using CUDA to program them).

The `README.md` file on the repository documents the project extensively (in spanish),
because we 'open-sourced' the project a couple of days before the due date, because not
many people had it complete (in fact, I think that only one group, apart from us, made
every part of the requested assignment, including the GUI with OpenGL) and we wanted to
help them.

To execute any of the multiple version that were asked (just CPU, GPU, GPU with
optimizations and GPU with optimizations and a GUI made using OpenGL), just compile
everything (running `make`) and execute the resulting binary.

To compile everything at once, there's a main `Makefile` that can be used to compile all
the directories recursively (or, for example, just `make openGL` to compile, execute and
clean only the GUI part).


Of course, an NVidia GPU is needed to run the code (except for the implementation on
CPU).


We didn't have time to give it a name (nor we wanted to), so we chose the name
automatically suggested by Github.

{% include image.html
	src="/assets/projects/images/super-duper-umbrella.png"
	title="Screenshot of the game with extra verbosity enabled"
	alt="Game with extra verbosity option enabled"
%}

----

This project is [hosted on Github](https://github.com/Foo-Manroot/super-duper-umbrella).
