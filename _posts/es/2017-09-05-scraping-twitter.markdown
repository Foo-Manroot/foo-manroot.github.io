---
layout: post
title:  "Scraping Twitter por diversión... y necesidad"
date:	2017-09-05 13:19:12 +0200
author: foo
categories: es scraping twitter
lang: es
ref: scraping-twitter
---

Hace como una semana, después de leer un
[post en Reddit](https://www.reddit.com/r/netsecstudents/comments/6wj7xq
/most_efficenteffective_way_to_keep_up_with_netsec/) con algunas cuentas de Twitter para
seguir y estar al tanto de las últimas noticias en seguridad informática, y decidí
seguirlas.

Sin embargo, no pude encontrar ningún modo de obtener la información, como normalmente se
hace con RSS para los blogs y páginas similares. Y no quería crearme una cuenta nueva
y sólo recibir noticias, sin interactuar de ningún modo.

En resumen, sólo quería leer noticias, como hago con mi cuenta de Reddit, donde tengo un
[multireddit](https://www.reddit.com/r/CracktheCode+DSP+Exhibit_Art+GNURadio+MachineLearning+OpenToAllCTFteam+ProgramAnalysisStudy+REMath+RTLSDR+ReverseEngineering+algorithms+artificial+blackhat+breakmycode+codes+commandline+compsci+computerforensics+crypto+cryptography+gamedev+hackrf+learnmath+logic+lowlevel+math+memoryforensics+netsec+netsecstudents+op011+programming+programmingchallenges+puzzles+rfelectronics+security+securityCTF+unix+web_design+webdev/) con todos los subreddits que creo que son útiles
o interesantes.

Parecía que se me forzaba a crear una nueva cuenta, significando que me tendría que crear
un nuevo usuario y contraseña (aunque eso tampoco es un gran problema, porque uso un
_password manager_) y debería instala las herramientas oficiales (básicamente, la
aplicación de Twitter) para estar al tanto de las noticias.

Y la verdad es que no me apetecía crearme una cuenta, ni usar su aplicación; así que
creé mi propio _script_ para obtener los datos que quería.

## Reconocimiento

Como con cualquier proyecto, lo primero que hay que hacer es el diseño; y eso implica
saber cómo la página Twitter (en escritorio, con JavaScript habilitado) carga más
contenido cuando se alcanza el final de la página; y cómo sabe que hay nuevos tweets
disponibles.

Para ello, sólo tenemos que inspeccionar el tráfico entre el navegador y el servidor; y
las herramientas de desarrollo de Firefox son suficientes para esta tarea.

### Obteniendo actualizaciones

La primera cosa que notamos inspeccionando el tráfico (la pestaña 'network', en las
herramientas de desarrollo) es que, periódicamente (cada medio minuto, más o menos), hay
algunas peticiones a lo que parece ser una página de actualización:
```
https://twitter.com/i/profiles/show/malwareunicorn/timeline/tweets?composed_count=0
	&include_available_features=1
	&include_entities=1
	&include_new_items_bar=true
	&interval=30000
	&latent_count=0
	&min_position=904803707652411392).
```

{% include image.html
	src="/assets/posts/2017-09-05-scraping-twitter/twitter-update-requests.jpg"
	title="Peticiones vistas con las herramientas de desarrollo de Firefox"
	alt="Vista de las herramientas de desarrollo"
%}

Y la respuesta es la siguiente:
```sh
$ curl -Ls "https://twitter.com/i/profiles/show/malwareunicorn/timeline/tweets?composed_count=0&include_available_features=1&include_entities=1&include_new_items_bar=true&interval=30000&latent_count=0&min_position=904803707652411392" 2>&1 | jq "."
{
  "max_position": null,
  "has_more_items": false,
  "items_html": "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n \n",
  "new_latent_count": 0
}
```
Cuando hay una nueva actualización, `items_html` contiene el HTML de los tweets nuevos,
listo para ser añadido al _stream_ (una lista ordenada con `id="stream-items-id"`).

No sé exactamente qué significa cada uno de los parámetros en la petición (aunque los
nombres dan alguna pista); pero lo más importante a tener en cuenta es:

  - **Username**: Las peticiones de actualización se hacen a https://twitter.com/i
	/profiles/show/**USUARIO**/(...), así que estas peticiones se pueden hacer sin
	problema por cada usuario

  - **Min\_position**: Probablemente, el ID del último tweet obtenido. Esta teoría se
	refuerza con el hecho de que el ID del primer tweet (el valor de `data-tweet-id`
	en el _feed_ (obviando el tweet anclado) es, efectivamente, *904803707652411392*.
	Además, en el contenedor de los tweets (el div con `class="stream-container"`)
	hay un par de parámetros que están seguramente relacionados con este:
	```html
	<div class="stream-container" data-max-position="904803707652411392" data-min-position="903449933658722305">
	```

Para probar nuestra hipótesis sobre el significado de cada parámetro, vamos a crear una
petición para obtener el primer tweet (el de ID *904803707652411392*). Para ello, debemos
obtener el ID del tweet *anterior*, que resulta ser *904803158697717760*. Este es el
resultado:
<pre>
$ curl -Ls "https://twitter.com/i/profiles/show/malwareunicorn/timeline/tweets?composed_count=0&include_available_features=1&include_entities=1&include_new_items_bar=true&interval=30000&latent_count=0&min_position=904803158697717760" 2>&1 | jq "."
{
  "max_position": "904803707652411392",
  "has_more_items": false,
  "items_html": "\n      <li class=\"js-stream-item stream-item stream-item\n\" data-item-id=\"904803707652411392\"\nid=\"stream-item-tweet-904803707652411392\"\ndata-item-type=\"tweet\"\n data-suggestion-json=\"{&quot;suggestion_details&quot;:{},&quot;tweet_ids&quot;:&quot;904803707652411392&quot;,&quot;scribe_component&quot;:&quot;tweet&quot;}\">\n    \n\n\n\n  <div class=\"tweet js-stream-tweet js-actionable-tweet js-profile-popup-actionable dismissible-content\n       original-tweet js-original-tweet\n      \n       \n\"\n      \ndata-tweet-id=\"904803707652411392\"\ndata-item-id=\"904803707652411392\"\ndata-permalink-path=\"/malwareunicorn/status/904803707652411392\"\ndata-conversation-id=\"904803158697717760\"\n data-is-reply-to=\"true\" \n data-has-parent-tweet=\"true\" \n\ndata-tweet-nonce=\"904803707652411392-e2263fa7-0890-4ac8-9258-116b952e8d04\"\ndata-tweet-stat-initialized=\"true\"\n\n\n\n\n\n\n  data-screen-name=\"malwareunicorn\" data-name=\"Malware Unicorn\" data-user-id=\"2344060088\"\n  data-you-follow=\"false\"\n  data-follows-you=\"false\"\n  data-you-block=\"false\"\n\n\ndata-reply-to-users-json=\"[{&quot;id_str&quot;:&quot;2344060088&quot;,&quot;screen_name&quot;:&quot;malwareunicorn&quot;,&quot;name&quot;:&quot;Malware Unicorn&quot;,&quot;emojified_name&quot;:{&quot;text&quot;:&quot;Malware Unicorn&quot;,&quot;emojified_text_as_html&quot;:&quot;Malware Unicorn&quot;}}]\"\n\n\n\n\n\n\n\ndata-disclosure-type=\"\"\n\n\n\n\n\n\n\n\n\n\n\n\n\n    >\n\n    <div class=\"context\">\n      \n      \n    </div>\n\n    <div class=\"content\">\n      \n\n      \n\n      \n      <div class=\"stream-item-header\">\n          <a  class=\"account-group js-account-group js-action-profile js-user-profile-link js-nav\" href=\"/malwareunicorn\" data-user-id=\"2344060088\">\n    <img class=\"avatar js-action-profile-avatar\" src=\"https://pbs.twimg.com/profile_images/902049789587501056/TtjvBlud_bigger.jpg\" alt=\"\">\n    <span class=\"FullNameGroup\">\n      <strong class=\"fullname show-popup-with-id \" data-aria-label-part>Malware Unicorn</strong><span>&rlm;</span><span class=\"UserBadges\"></span><span class=\"UserNameBreak\">&nbsp;</span></span><span class=\"username u-dir\" dir=\"ltr\" data-aria-label-part>@<b>malwareunicorn</b></span></a>\n\n        \n        <small class=\"time\">\n  <a href=\"/malwareunicorn/status/904803707652411392\" class=\"tweet-timestamp js-permalink js-nav js-tooltip\" title=\"13:29 - 4 sept. 2017\"  data-conversation-id=\"904803158697717760\"><span class=\"_timestamp js-short-timestamp js-relative-timestamp\"  data-time=\"1504556989\" data-time-ms=\"1504556989000\" data-long-form=\"true\" aria-hidden=\"true\">17 h</span><span class=\"u-hiddenVisually\" data-aria-label-part=\"last\">hace 17 horas</span></a>\n</small>\n\n          <div class=\"ProfileTweet-action ProfileTweet-action--more js-more-ProfileTweet-actions\">\n    <div class=\"dropdown\">\n  <button class=\"ProfileTweet-actionButton u-textUserColorHover dropdown-toggle js-dropdown-toggle\" type=\"button\">\n      <div class=\"IconContainer js-tooltip\" title=\"Más\">\n        <span class=\"Icon Icon--caretDownLight Icon--small\"></span>\n        <span class=\"u-hiddenVisually\">Más</span>\n      </div>\n  </button>\n  <div class=\"dropdown-menu is-autoCentered\">\n  <div class=\"dropdown-caret\">\n    <div class=\"caret-outer\"></div>\n    <div class=\"caret-inner\"></div>\n  </div>\n  <ul>\n    \n      <li class=\"copy-link-to-tweet js-actionCopyLinkToTweet\">\n        <button type=\"button\" class=\"dropdown-link\">Copiar enlace del Tweet</button>\n      </li>\n      <li class=\"embed-link js-actionEmbedTweet\" data-nav=\"embed_tweet\">\n        <button type=\"button\" class=\"dropdown-link\">Insertar Tweet</button>\n      </li>\n  </ul>\n</div>\n</div>\n\n  </div>\n\n      </div>\n\n      \n\n        <div class=\"ReplyingToContextBelowAuthor\" data-aria-label-part>\n    En respuesta a <a class=\"pretty-link js-user-profile-link\" href=\"/malwareunicorn\" data-user-id=\"2344060088\" rel=\"noopener\" dir=\"ltr\"><span class=\"username u-dir\" dir=\"ltr\" >@<b>malwareunicorn</b></span></a>\n\n\n\n</div>\n\n\n      \n        <div class=\"js-tweet-text-container\">\n  <p class=\"TweetTextSize TweetTextSize--normal js-tweet-text tweet-text\" lang=\"en\" data-aria-label-part=\"0\">Was made with a PE and ELF binary with IDA</p>\n</div>\n\n\n      \n\n      \n        \n\n\n      \n      \n\n      \n      <div class=\"stream-item-footer\">\n  \n      <div class=\"ProfileTweet-actionCountList u-hiddenVisually\">\n    \n    \n    <span class=\"ProfileTweet-action--reply u-hiddenVisually\">\n      <span class=\"ProfileTweet-actionCount\"  data-tweet-stat-count=\"1\">\n        <span class=\"ProfileTweet-actionCountForAria\" id=\"profile-tweet-action-reply-count-aria-904803707652411392\" data-aria-label-part>1 respuesta</span>\n      </span>\n    </span>\n    <span class=\"ProfileTweet-action--retweet u-hiddenVisually\">\n      <span class=\"ProfileTweet-actionCount\" aria-hidden=\"true\" data-tweet-stat-count=\"0\">\n        <span class=\"ProfileTweet-actionCountForAria\" id=\"profile-tweet-action-retweet-count-aria-904803707652411392\" >0 retweets</span>\n      </span>\n    </span>\n    <span class=\"ProfileTweet-action--favorite u-hiddenVisually\">\n      <span class=\"ProfileTweet-actionCount\"  data-tweet-stat-count=\"21\">\n        <span class=\"ProfileTweet-actionCountForAria\" id=\"profile-tweet-action-favorite-count-aria-904803707652411392\" data-aria-label-part>21 Me gusta</span>\n      </span>\n    </span>\n  </div>\n\n  <div class=\"ProfileTweet-actionList js-actions\" role=\"group\" aria-label=\"Acciones del Tweet\">\n    <div class=\"ProfileTweet-action ProfileTweet-action--reply\">\n  <button class=\"ProfileTweet-actionButton js-actionButton js-actionReply\"\n    data-modal=\"ProfileTweet-reply\" type=\"button\"\n    aria-describedby=\"profile-tweet-action-reply-count-aria-904803707652411392\">\n    <div class=\"IconContainer js-tooltip\" title=\"Responder\">\n      <span class=\"Icon Icon--medium Icon--reply\"></span>\n      <span class=\"u-hiddenVisually\">Responder</span>\n    </div>\n      <span class=\"ProfileTweet-actionCount \">\n        <span class=\"ProfileTweet-actionCountForPresentation\" aria-hidden=\"true\">1</span>\n      </span>\n  </button>\n</div>\n\n    <div class=\"ProfileTweet-action ProfileTweet-action--retweet js-toggleState js-toggleRt\">\n  <button class=\"ProfileTweet-actionButton  js-actionButton js-actionRetweet\"\n    \n    data-modal=\"ProfileTweet-retweet\"\n    type=\"button\"\n    aria-describedby=\"profile-tweet-action-retweet-count-aria-904803707652411392\">\n    <div class=\"IconContainer js-tooltip\" title=\"Retwittear\">\n      <span class=\"Icon Icon--medium Icon--retweet\"></span>\n      <span class=\"u-hiddenVisually\">Retwittear</span>\n    </div>\n      <span class=\"ProfileTweet-actionCount ProfileTweet-actionCount--isZero\">\n    <span class=\"ProfileTweet-actionCountForPresentation\" aria-hidden=\"true\"></span>\n  </span>\n\n  </button><button class=\"ProfileTweet-actionButtonUndo js-actionButton js-actionRetweet\" data-modal=\"ProfileTweet-retweet\" type=\"button\">\n    <div class=\"IconContainer js-tooltip\" title=\"Deshacer Retweet\">\n      <span class=\"Icon Icon--medium Icon--retweet\"></span>\n      <span class=\"u-hiddenVisually\">Retwitteado</span>\n    </div>\n      <span class=\"ProfileTweet-actionCount ProfileTweet-actionCount--isZero\">\n    <span class=\"ProfileTweet-actionCountForPresentation\" aria-hidden=\"true\"></span>\n  </span>\n\n  </button>\n</div>\n\n\n    <div class=\"ProfileTweet-action ProfileTweet-action--favorite js-toggleState\">\n  <button class=\"ProfileTweet-actionButton js-actionButton js-actionFavorite\" type=\"button\"\n    aria-describedby=\"profile-tweet-action-favorite-count-aria-904803707652411392\">\n    <div class=\"IconContainer js-tooltip\" title=\"Me gusta\">\n      <span role=\"presentation\" class=\"Icon Icon--heart Icon--medium\"></span>\n      <div class=\"HeartAnimation\"></div>\n      <span class=\"u-hiddenVisually\">Me gusta</span>\n    </div>\n      <span class=\"ProfileTweet-actionCount\">\n    <span class=\"ProfileTweet-actionCountForPresentation\" aria-hidden=\"true\">21</span>\n  </span>\n\n  </button><button class=\"ProfileTweet-actionButtonUndo ProfileTweet-action--unfavorite u-linkClean js-actionButton js-actionFavorite\" type=\"button\">\n    <div class=\"IconContainer js-tooltip\" title=\"Deshacer me gusta\">\n      <span role=\"presentation\" class=\"Icon Icon--heart Icon--medium\"></span>\n      <div class=\"HeartAnimation\"></div>\n      <span class=\"u-hiddenVisually\">Gustado</span>\n    </div>\n      <span class=\"ProfileTweet-actionCount\">\n    <span class=\"ProfileTweet-actionCountForPresentation\" aria-hidden=\"true\">21</span>\n  </span>\n\n  </button>\n</div>\n\n\n    \n\n    \n\n  </div>\n\n</div>\n  \n\n\n\n      \n      \n\n    </div>\n  </div>\n\n\n\n    \n<div class=\"dismiss-module\">\n  <div class=\"dismissed-module\">\n      <div class=\"feedback-action\" data-feedback-type=\"DontLike\">\n        <div class=\"action-confirmation\">Gracias. Twitter usará esto para mejorar tu cronología. <span class=\"undo-action u-textUserColor\">Deshacer</span></div>\n      </div>\n  </div>\n</div>\n\n</li>\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n \n",
  "new_latent_count": 1,
  "new_tweets_bar_html": "  <div class=\"new-tweets-bar js-new-tweets-bar\" data-item-count=\"1\">\n      Ver 1 Tweet nuevo\n  </div>\n",
  "new_tweets_bar_alternate_html": []
}
</b></ul></b></span>
</pre>

¡Bien! Tenemos el tweet deseado (sí, tiene *un montón* de código). Para comprobarlo,
podemos filtrar el texto con *grep*, para ver si contiene *"Was made with a PE and ELF
binary with IDA"* (el texto del tweet que queremos):
```sh
$ curl -Ls "https://twitter.com/i/profiles/show/malwareunicorn/timeline/tweets?composed_count=0&include_available_features=1&include_entities=1&include_new_items_bar=true&interval=30000&latent_count=0&min_position=904803158697717760" 2>&1 | grep -o "Was made with a PE and ELF binary with IDA"
Was made with a PE and ELF binary with IDA
```

Perfecto, ahora podemos obtener tweets. Ahora simplemente se trata de interpretar el
HTML (yo usé [BeautifulSoup](https://www.crummy.com/software/BeautifulSoup/) para ello)
y obtener todos los datos que queramos.

### Página infinita

Con todo lo que hemos aprendido de cómo se obtienen los tweets nuevos, tenemos una tarea
más fácil, puesto que tenemos mucha información interesante sobre la organización de la
página.

Cuando bajamos al final de la página, vemos una nueva petición GET, similar a la primera,
a la siguiente dirección:
```
https://twitter.com/i/profiles/show/malwareunicorn/timeline/tweets
	?include_available_features=1
	&include_entities=1
	&max_position=903449933658722305
	&reset_error_state=false
```

Y la respuesta es otro JSON con las siguientes claves y valores:

  - **min\_position**: 902568467332603904
  - **has\_more\_items**: true
  - **items\_html**: (mucho HTML con los nuevos tweets)
  - **new\_latent\_count**: 20


Ahora se ve claramente que las peticiones se hacen de acuerdo a unos límites, indicados
con los parámetros `max_position` y `min_position`, que son tomados por primera vez del
contenedor de los tweets y luego actualizados con las respuestas JSON.


## Construyendo el scraper y notificando las actualizaciones

Tras obtener toda la información, es trivial construir un programa que pida las páginas
e interprete el HTML (como ya dije antes, se puede usar BeautifulSoup con Python) para
obtener la información deseada.

Luego, se pueden usar diferentes métodos para notificar los tweets, ya sea usando
`subprocess.Popen` para llamar a `notify-send` (al menos en sistemas tipo UNIX) o usando
una biblioteca de Python. Yo lo hice con [notify2](https://pypi.python.org/pypi/notify2),
permitiéndome cargar fácilmente el texto del tweet en una notificación y obtener las
actualizaciones mientras hago otras cosas, como jugar a videojuegos o trabajar.

A veces a demasiadas actualizaciones y algunas no se muestran, así que debería intentar
buscar otro método para obtener una herramienta más útil.

## Usando el _scraper_ con otro propósito

Aunque la idea inicial es simplemente obtener los tweets de la gente a la que "sigo"
(realmente no les sigo con mi cuenta, porque no tengo...), este _scraper_ puede
resultarle más útil a otra gente sindo usado sólo como biblioteca.

Por supuesto, si el _scraper_ te resulta útil, eres libre de usarlo y modificarlo (bajo
los términos especificados en la licencia, si es que hay).


Por ejemplo, para obtener los 2 últimos tweets de una persona, se puede usar la función
`get_tweets`, que recibe una lista con los nombres de las cuentas (se puede leer la
documentación de cada función para más información), como se ve a continuación:
```python
>>> import scraper
>>> data = scraper.get_tweets (["mzbat"], max_count = 2)
>>> data
>>> data
{'mzbat': {'902887483704320004': {'permalink': u'/Rainmaker1973/status/902887483704320004', 'stats': {'likes': 6407, 'retweets': 3659, 'replies': 64}, 'conversation': 902887483704320004, 'text': u'A really cool visual explanation of how potential &amp; kinetic energy are\nexchanged on a trampoline [http://buff.ly/2qhkllZ\xa0](https://t.co/a4NepKyZnj\n"http://buff.ly/2qhkllZ"\n)[pic.twitter.com/gAR1WWBHiu](https://t.co/gAR1WWBHiu)\n\n', 'tweet_age': 1504100125, 'pinned': False, 'retweet_info': {'retweet_id': u'904701461153681408', 'retweeter': u'mzbat'}, 'user': {'username': u'Rainmaker1973', 'displayname': u'Massimo', 'uid': 177101260, 'avatar': u'https://pbs.twimg.com/profile_images/686298118904786944/H4aoP8vA_bigger.jpg'}, 'tweet_id': '902887483704320004', 'retweet': True}, '720999941225738240': {'profile_pic': u'https://pbs.twimg.com/profile_images/683177128943337472/4CSt778e_400x400.jpg', 'permalink': u'/mzbat/status/720999941225738240', 'stats': {'likes': 3068, 'retweets': 854, 'replies': 67}, 'tweet_id': '720999941225738240', 'text': u'A dude told me I hacked like a girl. I told him if he popped shells a little\nfaster, he could too.[pic.twitter.com/PgiyYw41oo](https://t.co/PgiyYw41oo)\n\n', 'tweet_age': 1460734756, 'pinned': True, 'conversation': 720999941225738240, 'user': {'username': u'mzbat', 'displayname': u'b\u0360\u035d\u0344\u0350\u0310\u035d\u030a\u0341a\u030f\u0344\u0343\u0305\u0302\u0313\u030f\u0304t\u0352', 'uid': 253608265, 'avatar': u'https://pbs.twimg.com/profile_images/683177128943337472/4CSt778e_bigger.jpg'}, 'retweet': False}}}

>>> print json.dumps (data, indent=4)
{
    "mzbat": {
        "902887483704320004": {
            "permalink": "/Rainmaker1973/status/902887483704320004",
            "stats": {
                "likes": 6407,
                "retweets": 3659,
                "replies": 64
            },
            "conversation": 902887483704320004,
            "text": "A really cool visual explanation of how potential &amp; kinetic energy are\nexchanged on a trampoline [http://buff.ly/2qhkllZ\u00a0](https://t.co/a4NepKyZnj\n\"http://buff.ly/2qhkllZ\"\n)[pic.twitter.com/gAR1WWBHiu](https://t.co/gAR1WWBHiu)\n\n",
            "tweet_age": 1504100125,
            "pinned": false,
            "retweet_info": {
                "retweet_id": "904701461153681408",
                "retweeter": "mzbat"
            },
            "user": {
                "username": "Rainmaker1973",
                "displayname": "Massimo",
                "uid": 177101260,
                "avatar": "https://pbs.twimg.com/profile_images/686298118904786944/H4aoP8vA_bigger.jpg"
            },
            "tweet_id": "902887483704320004",
            "retweet": true
        },
        "720999941225738240": {
            "profile_pic": "https://pbs.twimg.com/profile_images/683177128943337472/4CSt778e_400x400.jpg",
            "permalink": "/mzbat/status/720999941225738240",
            "stats": {
                "likes": 3068,
                "retweets": 854,
                "replies": 67
            },
            "tweet_id": "720999941225738240",
            "text": "A dude told me I hacked like a girl. I told him if he popped shells a little\nfaster, he could too.[pic.twitter.com/PgiyYw41oo](https://t.co/PgiyYw41oo)\n\n",
            "tweet_age": 1460734756,
            "pinned": true,
            "conversation": 720999941225738240,
            "user": {
                "username": "mzbat",
                "displayname": "b\u0360\u035d\u0344\u0350\u0310\u035d\u030a\u0341a\u030f\u0344\u0343\u0305\u0302\u0313\u030f\u0304t\u0352",
                "uid": 253608265,
                "avatar": "https://pbs.twimg.com/profile_images/683177128943337472/4CSt778e_bigger.jpg"
            },
            "retweet": false
        }
    }
}
```

En ese ejemplo, dos tweets son obtenidos e impresos por pantalla usando `json.dumps`.

Los datos obtenidos están en un diccionario con el siguiente formato:
```python
{
    <cuenta>: {
        <tweet-id>: {
              "profile_pic": <avatar de la cuenta>
            , "permalink": <enlace al tweet>
            , "stats": {
                  "likes": <número de 'likes'>
                , "retweets": <número de retweets>
                , "replies": <número de respuestas>
            }
            , "tweet_id": <id del tweet>
            , "text": <texto del tweet>
            , "tweet_age": <hora del tweet, con formato epoch de UNIX>
            , "pinned": <indicación para saber si el tweet está anclado>
            , "conversation": <id de la conversación>
            , "user": {
                # Información de la cuenta propietaria del tweet (importante si es un retweet)
                  "username": <nombre de la cuenta (twitter.com/nombre)>
                , "displayname": <nickname de la cuenta>
                , "uid": <id de la cuenta>
                , "avatar": <imagen de la cuenta>
            }
            , "retweet": <indicación para saber si ha sido un tweet de otra persona>
            # Sólo si "retweet" es True
            , "retweet_info" {
                  "retweet_id": <id del retweet>
                , "retweeter": <nombre de la cuenta que retweeteó (la misma de la que se están extrayendo los datos)>
            }
        }
        # ... (más tweets en la cuenta)
    }
    # ... (más cuentas con sus tweets)
}
```

Probablemente algunas cosas se deben cambiar para exponer sólo los métodos necesarios
para obtener datos (de hecho, sólo `get_tweets` debería ser público, haciendo al resto
métodos privados), pero por el momento no creo que sea necesario.

-----------------------------------------------------------------------------------------

El proyecto entero explicado en este artículo
[está en Github](https://github.com/Foo-Manroot/tweet-feed), así que cualquiera puede
usarlo y contribuir libremente, si quiere.
