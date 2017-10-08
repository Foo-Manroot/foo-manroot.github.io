---
layout: post
title:  How this page is done - part 2
date:	2017-08-11 12:35:58 +0200
author: foo
categories: site-info
ref: intro-cont
---


Continuing with the [previous article]({% include post_link ref="intro-post" %}),
I'm going to describe how did I built this website, for anybody curious about it or
willing to make another similar one.


## Front-end

This theme is based on the [default one](https://github.com/jekyll/minima) with some
important modifications.

This site doesn't use any JavaScript, so I'll only talk about HTML and CSS.


### HTML and CSS

The first thing that I've changed is the way everything is layed out. Even though
everything looks quite similar than the default theme (except the colours, obviously),
this webpage is made using the CSS properties [grid](https://developer.mozilla.org/en
/docs/Web/CSS/grid) and [flex](https://developer.mozilla.org/en/docs/Web/CSS/flex), thus
avoiding the unnecessary use of uncountable `div` elements (the so-called 'divitis').

Moreover, the grid properties has been quite useful when trying to align elements like
the tags at the above of a post, where one can have multiple elements and the objective
is that they stay aligned and visible, no matter the amount of rows or columns.

When we give an element the following styling, it has this needed flexible baheviour:

```css
#elem {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
}
```

This code allows to all the elements inside the one with `id="elem"` to flow, filling
the all the available space, but with these elements never being smaller than 100px wide.
To test this, you can go to the page of [my project 'Collatz'](/projects/toy/collatz),
resize the window and see how the tags rearrange themselves.

Also, the footer is layed out using a grid, so it's easier to reorder at will. In fact,
two different templates are used on this site (one for mobile devices and one for the
others). These two layouts are changed by simply modifying the value of `grid-template`.

These are the layouts, shown using the Mozilla Firefox's developer tools (the background
colour has been removed to see the grid more easily):

{% include image.html
	src="/assets/posts/2017-08-11-intro-cont/footer-grid.jpg"
	title="Grid shown using the developer tools"
	alt="Grid on non-mobile devices"
%}

and on mobile:

{% include image.html
	src="/assets/posts/2017-08-11-intro-cont/footer-grid-mobile.jpg"
	title="Grid shown using the developer tools"
	alt="Grid on mobile devices"
%}


More examples of this are on [this website](https://gridbyexample.com/learn/), where I
learned everything I know about CSS grid.


Aside from these technical changes, I've made another ones to arrange the site to my
taste (apart from changing the colours, of course), being the most notable ones the use
of the [checkbox hack](https://stackoverflow.com/a/32721572) to simulate JavaScript's
`onClick` event to display the sidebar (except on mobile, where there's another layout).
That's the reason why there's a div around almost all the contents on the page named
"page-wrap", to move it all to the side when the navigation bar is visible.


## Back-end

Although it's a static site, when I say here "back-end" I'm speaking about how Jekyll and
Liquid were used to generate the pages.

### Internationalization

The only remarkable thing that I did is the internationalization (there should be a
couple of buttons at the top of this article, where one can change the language of the
article).

To make it without plugins (as this site depends on the accepted plugins on Github
Pages), I based my approach on
[this article](https://www.sylvaindurand.org/making-jekyll-multilingual/), where the
author proposes to add two attributes, `lang` and `ref`, to every post so it can be
referenced depending on the current language of the page.


I also added a file on the *_data/* directory named *i18n.yml* to store the translations
of some common strings, like the  months or the language's name.


Additionally, I extended the internationalization to the collections _projects_ and
_tools_, creating a special directory for each one of the available languages, with a
subdirectory for every collection (also, there are the translations for the main
index.html and about.md files). The content of these directories are the following:
<pre>
lang-code (es, fr...)/
├── index.html
├── about.md
├── categories
│   └── index.html
├── projects
│   ├── index.md
 ...
└── tools
    ├── index.md
    ...
</pre>

