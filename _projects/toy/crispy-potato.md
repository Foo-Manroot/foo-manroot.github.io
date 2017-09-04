---
layout: project
title: "Crispy potato"
tags: [php, html5, css3, javascript]
lang: en
ref: projects-crispy-potato
---

## Crispy potato

This is a project I made (in fact, the initiative was from me and some friends from
college, but only {% include icon-github.html username="sergio-sanchezl" %} did some
work) to learn HTML5, CSS3, Javascript and PHP while creating a personal webpage (all
done without any framework, as it was mean to _learn_). In fact, thanks to the knowledge
I aquired on front-end development, I could build this site (the one you're currently
on).

The page has an awful code, but _it works_. I have a server (well, more like my personal
computer with Apache installed) on my house with this page running, waiting for me to
make something useful with it.

For the moment, it has some dummy data and the following functionalities (the page is in
spanish, and so are the screenshots):


### Account handling

Based on Unix access control (with users and groups, every one of them with its uid and
guid, respectively), one can create an account and login/logout to perform all the
actions that need identification (like writing articles).


### File uploading and downloading

With some access control also based on Unix file system's access control, one can view
available files (the ones that has permissions to be viewed) and manage its own files:

![file downloading](/assets/projects/images/crispy-potato_Files-download.png
"Files downloading page")

Also, one can upload new files:

![file uploading](/assets/projects/images/crispy-potato_Files-upload.png
"Uploading page")


### Articles

Using [TinyMCE](https://www.tinymce.com/) I managed to create some basic articles. I only
tried to create articles with media, links and text; so maybe more advanced usage and
formatting may break everything...

A great thing that I haven't implemented is to update media content (like deleting an
image from an article, that should also be deleted from the server's database).


Aside from that, there are a lot of things that aren't done (like managing posts with
tags and every other thing that's already implemented on this site).

----

This project is [hosted on Github](https://github.com/Foo-Manroot/Crispy-potato).
