---
layout: post
title:  "Clickjacking and the complexity of Web testing"
date:	2024-03-29 13:58:18 +0100
author: foo
categories: web
ref: clickjacking-and-the-complexity-of-the-web
---


Table of Contents:
* Table of Contents
{:toc}

----

Many times I've joked with profession colleagues about having to report a bunch of *highly critical* findings, such as [Missing security headers](https://cheatsheetseries.owasp.org/cheatsheets/HTTP_Headers_Cheat_Sheet.html).
We joke because we know that most of those "findings" are almost irrelevant when it comes to the actual security of the page we're testing.

Like everything in life, it all depends on the context: `X-Frame-Options` is deprecated in favour of `Content-Security-Policy: frame-ancestors ...` [^1]; but you might want to set it if, for whatever reason, you still want to support Internet Explorer or whatever.
But, again, the security headers are just an extra layer of security.
The main problem would be that you still have some random machines using IE.

A similar reasoning is applicable to many of the other headers: you don't need to set the `Strict-Transport-Security` if your page is not served over plain HTTP at all in the first place[^2].

## Clickjacking

The other day, a workmate who I deeply respect for their knowledge and willingness to learn new things and re-learn old ones, came to me with a question: is clickjacking a finding?
They were QA'ing a report which contained a finding: "Web application vulnerable to clickjacking".
And, of course, the question arose whether it was an issue in the context of that specific page (or even an issue _at all_).

The site was indeed "vulnerable" to clickjacking[^3].
A very simple PoC, which can be copy+pasted from the templates, will show the page is being loaded inside the iframe:

{% include image.html
        src="/assets/posts/2024-03-29-clickjacking-and-the-complexity-of-the-web/clickjacking-poc.png"
        title="Clickjacking PoC"
        alt="Target page loading inside an iFrame"
%}

Pack it up, boys, our job here is done!

Or is it?
...


## PoC||GTFO

When reporting this type of findings, all of the templates end up saying something along these lines[^4]:
> The impact of this clickjacking vulnerability on https://example.com could be significant.
> Since users are unaware that they are interacting with deceptive elements overlaid on top of legitimate content, they may inadvertently perform actions such as clicking on malicious links, submitting sensitive information, or performing unintended transactions.

Let's read that again (and ignore the shitty AI phrasing for a second).
"perform actions such as [...] *performing unintended transactions*".

According to that description, it should be possible to abuse the user's existing session[^5] in the target site to perform actions like reposting a blog post, accepting a bank transaction, ...

So, let's test that theory, shall we?

For this purpose I created the following target application, which is just a simple Flask server with some basic session handling:
```py
#!/usr/bin/env python3

from flask import Flask, Response, session, request
import json

app = Flask(__name__)
app.secret_key = b"idc bro, just give me da sessi0n!"


@app.route('/set_session', methods = ["POST"])
def set_session ():
    response = {}
    key = request.form ["key"]
    value = request.form ["value"]
    session [key] = value

    for k in session:
        response [k] = session [k]

    return Response (json.dumps (response), mimetype = "application/json")

@app.route('/')
def hello():
    response_text  = "Your session contains: [<br/>"
    for k in session:
        response_text += f"{k} => {session [k]}<br/>"
    response_text += "]"

    response_text += """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Clickjacking victim</title>
</head>
<body>
    <h1>Set Session Parameter</h1>
    <label for="key">Key:</label>
    <input type="text" id="key"><br><br>
    <label for="value">Value:</label>
    <input type="text" id="value"><br><br>
    <button onclick="setSession()">Set Session Parameter</button>

    <script>
        function setSession() {
            var key = document.getElementById('key').value;
            var value = document.getElementById('value').value;

            var xhr = new XMLHttpRequest();
            xhr.open("POST", "/set_session", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    alert("New session data: " + xhr.response);
                } else if (xhr.readyState === 4 && xhr.status !== 200) {
                    alert("Failed to set session parameter");
                }
            };
            xhr.send("key=" + encodeURIComponent(key) + "&value=" + encodeURIComponent(value));
        }
    </script>
</body>
</html>
    """

    session ["asdf"] = "qwer"

    resp = Response (response_text)
    return resp

if __name__ == '__main__':
    app.run(host = '0.0.0.0')
```

This server returns information about the current session and allows a user to change the items by clicking on the "Set Session Parameter" button:
{% include image.html
        src="/assets/posts/2024-03-29-clickjacking-and-the-complexity-of-the-web/set-session-data.png"
        title="Victim setting their session on the target site"
        alt="The target website loaded in its own tab, after the user created the 'my login' session property"
%}


After reloading the page or opening it in a new tab, the information is still there as expected:

{% include image.html
        src="/assets/posts/2024-03-29-clickjacking-and-the-complexity-of-the-web/get-session-data.png"
        title="Session data still present at reload"
        alt="Target site after reloading the tab, still showing the 'my login' session property"
%}


Since no special headers are set, this server should be vulnerable to Clickjacking, according to what we've seen until now.
To test that assumption, let's create the "attacker" page with the following contents:
```html
<html>
<body>
	<iframe id="target" src="http://192.168.0.13:5000">
</body>
</html>
```

I decided to host it using `python -m http.server 1234`, but you can also simply open it from the browser as a static file.
In any case, we can indeed see that the target page is loaded inside the iframe:

{% include image.html
        src="/assets/posts/2024-03-29-clickjacking-and-the-complexity-of-the-web/inside-iframe.png"
        title="Target application loaded inside an iFrame within the attacker's page"
        alt="The target application loads successfuly inside the iframe, but the cookie is different"
%}

But... shouldn't the previously set session value (`my login`) be present?

Not only it isn't there, but the cookie value is also different!



## Web testing is not a piece of cake

Turns out, the web is _extremely_ complex, with many moving parts and constant changes.
Even though this attack used to work (although I don't remember hearing about a real world exploit), browsers have been quite active trying to mitigate vulnerabilities and limit tracking from third-party sites.
Those changes made clickjacking attacks a thing of the past (if they were ever a thing... I guess I'm too young to remember those times)


In this case, the following conditions must be met for the cookies on the main page to be set also inside the iframe:
  - Both the target and the attacker sites must be **served over HTTPS**.
    This is not a difficult requisite to meet, but it's something to pay attention to when creating a PoC.

  - The target's cookies must be set with `SameSite=None; Secure`.
    This is harder to find in the wild, especially since most modern browsers set `SameSite=Lax` by default [^6] [^7].

  - Any additional **tracking protection**, adblocker or similar privacy solutions must be **disabled**.
    While testing only the server, we can imagine the worst case and safely assume that the victim doesn't have any adblocker or third party extension. However, anti-tracking protection is enabled by default in many browsers like Firefox, and the user has to actively disable it to accept third-party cookies.
    Moreover, Chrome [has announced](https://developers.google.com/privacy-sandbox/blog/cookie-countdown-2024jan) that they will also block third-party cookies by default.


To make sure that our Flask server is vulnerable, we first have to serve it over HTTPS and set the appropriate cookie values:

```py
# (...)
app.config.update (
    SESSION_COOKIE_SECURE = True,
    SESSION_COOKIE_HTTPONLY = True,
    SESSION_COOKIE_SAMESITE = 'None'
)

if __name__ == '__main__':
    app.run (host = '0.0.0.0', ssl_context = 'adhoc')
```

Then, the attacker server also has to be served over HTTPS (check out [my previous post](/post/utils/2024/03/05/quick-transfer-server.html#serve-over-https-with-python) for some quick copy+paste code).


Finally, tracking protection must be disabled.
For example, with Firefox:
{% include image.html
        src="/assets/posts/2024-03-29-clickjacking-and-the-complexity-of-the-web/firefox-disable-tracking-protection.png"
        title="Firefox settings to disable tracking protection"
        alt="Firefox menu under about:preferences#privacy, with the 'Custom' option selected and the 'Cookies' checkbox within it deselected"
%}

After doing this, we can see the cookie within the iframe. Yay!
{% include image.html
        src="/assets/posts/2024-03-29-clickjacking-and-the-complexity-of-the-web/final-poc.png"
        title="Final PoC"
        alt="Screenshot showing both the attacker and the target site with the same session cookie set"
%}

Of course, for this to be something worth reporting there must be an actual vulnerable component (some state change triggerable by clicking around), but at least we have a _real_ working Proof-of-Concept.


Turns out, that something as simple as a Clickjacking is not as critical nor easy to exploit as some bug bounters and low-hanging-fruit testers seem to think.


## Conclusion

I've heard multiple times in the past that "everybody can do web testing", and people complaining about having to test web apps all the time, because they thing is dull and not interesting.
I hold a different opinion: being a _good_ web tester requires _a lot_ of knowledge which has to be constantly updated, and you have to take into account all the browsers that a victim might be using, the proxies that might be between the victim and the server, the type of server that's running under the application, ...

This exercise helped me revisit some things that I thought I knew, but I ended up discovering that a lot has changed since the last time I looked into this, not too many years back, when I was starting to get more into cybersecurity and had to learn it as new.


My main takeaway from all this is: Clickjacking is no longer a low-hanging fruit; it fell from the tree and now is rotting there.
Let's leave it alone and start focusing on real, impactful vulnerabilities like _"'Server' header information disclosure"_ ;)


-----------------------------------------------------------------------------------------

[^1]: [https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options#sect3](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options#sect3)

[^2]: Counter-point: maybe in _very_ particular cases ther might be some proxy magic where the browser might start the connection using plain HTTP to the proxy, while the proxy waits to open the connection with your server on the other end.<br/>
    However, I'd argue that this is _very_ unlikely to end in any kind of attack to the end user...

[^3]: Or that's what Burp and other automated scanners will say anyways.

[^4]: I obviously used ChatGPT (which is very adamant that Clickjacking is indeed a serious vulnerability) to generate this text

[^5]: This means that, if the target site doesn't implement any kind of user management, there is nothing to exploit to begin with.

[^6]: https://blog.heroku.com/chrome-changes-samesite-cookie#prepare-for-chrome-80-updates

[^7]: https://hacks.mozilla.org/2020/08/changes-to-samesite-cookie-behavior/
