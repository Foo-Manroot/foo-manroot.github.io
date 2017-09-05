---
layout: post
title:  "Scraping Twitter for fun... but no profit"
date:	2017-09-05 13:19:12 +0200
author: foo
categories: scraping twitter
ref: scraping-twitter
---

## Scraping Twitter for fun... but no profit

A week ago, after reading a
[Reddit post](https://www.reddit.com/r/netsecstudents/comments/6wj7xq
/most_efficenteffective_way_to_keep_up_with_netsec/) with some Twitter accounts to follow
to be updated with the latest news on netsec field, and I decided to follow them.

However, I couldn't find any way to create a feed, like a normal RSS feed with blogs and
similar pages. And I didn't want to make a new account just for lurk around, without
interacting in any form.

In brief, I just wanted to read news, as I do with my Reddit account, where I have a
[multireddit](https://www.reddit.com/r/CracktheCode+DSP+Exhibit_Art+GNURadio+MachineLearning+OpenToAllCTFteam+ProgramAnalysisStudy+REMath+RTLSDR+ReverseEngineering+algorithms+artificial+blackhat+breakmycode+codes+commandline+compsci+computerforensics+crypto+cryptography+gamedev+hackrf+learnmath+logic+lowlevel+math+memoryforensics+netsec+netsecstudents+op011+programming+programmingchallenges+puzzles+rfelectronics+security+securityCTF+unix+web_design+webdev/)
with all the subreddits that I find useful or interesting.


Now, seeming that I was being forced to create a new account; meaning that I'll have
a new user/passwd (even though that's not a big problem, as I use a password manager)
and should install the official tools (mainly, the Twitter App) to stay update.

And I didn't really wanted to create an account, nor use their app; so I just created
my own script to gather the data I wanted.


### Reconnaissance

As with every project, the first thing to do is to design it; and that implies to know
how does the Twitter page (on desktop, with JavaScript enabled) load more content when
one reaches the bottom of the page; and also how does it know that there are new tweets
available.

To this end, we just have to inspect the traffic between the browser and the server; and
Firefox's developer tools are sufficient for this task.

#### Getting updates

The first thing we notice inspecting the traffic (the 'network' tab, on the developer
tools) is that, periodically (every half a minute, or so), there are some requests to
what seems to be an update page:
```
https://twitter.com/i/profiles/show/malwareunicorn/timeline/tweets?composed_count=0
	&include_available_features=1
	&include_entities=1
	&include_new_items_bar=true
	&interval=30000
	&latent_count=0
	&min_position=904803707652411392).
```

[![View from the developer tools](
	/assets/posts/2017-09-05-scraping-twitter/twitter-update-requests.png
	"Requests viewed with Firefox's developer tools"
)](/assets/posts/2017-09-05-scraping-twitter/twitter-update-requests.png)

And the response is the following one:
```sh
$ curl -Ls "https://twitter.com/i/profiles/show/malwareunicorn/timeline/tweets?composed_count=0&include_available_features=1&include_entities=1&include_new_items_bar=true&interval=30000&latent_count=0&min_position=904803707652411392" 2>&1 | jq "."
{
  "max_position": null,
  "has_more_items": false,
  "items_html": "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n \n",
  "new_latent_count": 0
}
```

When there is a new update, `items_html` contains the HTML of the new tweets, ready to
be appended inside the stream (an ordered list with `id="stream-items-id"`).

I don't know exactly what does every parameter on the update request mean (although the
names can give some clues); but the important thing to note are:

  - **Username**: the update requests are made to https://twitter.com/i/profiles/show
	/**USERNAME**/(...), so these requests can be made without problem by user

  - **Min\_position**: Probably, the ID of the last tweet fetched. This theory is
	supported by the fact that the ID of the first tweet (the value of
	`data-tweet-id`) on the feed (obviating the pinned one) is, indeed,
	*904803707652411392*. Also, on the container of the tweets (the div with
	`class="stream-container"`) there are a couple of parameters that are most
	likely related to this one:
	```html
	<div class="stream-container" data-max-position="904803707652411392" data-min-position="903449933658722305">
	```

To test our hypothesis about the meaning of each parameter, lets forge a request to get
the first tweet (the one with ID *904803707652411392*). To do that, we must get the ID
of *the previous* tweet, that happens to be *904803158697717760*. This is the result:
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

Yay! We got the desired tweet (yes, it has *a lot* of code). To check it, we can grep
the text, to see if it contains *"Was made with a PE and ELF binary with IDA"* (the text
of the previous tweet):
```sh
$ curl -Ls "https://twitter.com/i/profiles/show/malwareunicorn/timeline/tweets?composed_count=0&include_available_features=1&include_entities=1&include_new_items_bar=true&interval=30000&latent_count=0&min_position=904803158697717760" 2>&1 | grep -o "Was made with a PE and ELF binary with IDA"
Was made with a PE and ELF binary with IDA
```

Perfect, now we can get the new tweets. It's just a matter of parse the HTML (I used
[BeautifulSoup](https://www.crummy.com/software/BeautifulSoup/) for that purpose) and
get all the data we want.


#### Infinite scrolling

With all the knowledge we acquired investigating the update, we have now an easier task,
as we already have some valuable information about the organization of the page.

When we scroll down, we see a new GET request, similar to the previous ones, to the
following address:
```
https://twitter.com/i/profiles/show/malwareunicorn/timeline/tweets
	?include_available_features=1
	&include_entities=1
	&max_position=903449933658722305
	&reset_error_state=false
```

And the response is another JSON with the following keys and values:

  - **min\_position**: 902568467332603904
  - **has\_more\_items**: true
  - **items\_html**: (a lot of HTML with the new tweets)
  - **new\_latent\_count**: 20


Now it becomes clear that the updates are made according to some limits, indicated with
the `max_position` and `min_position` parameters, that are taken the first time from
the stream container and later updated with the response JSONs.


### Building the scraper and notify the updates

After getting all the information, it's trivial to build a program that requests that
pages and parses the HTML (as I said earlier, you can use BeautifulSoup with Python) to
retrieve the desired information.

Then, different methods may be used to notificate on new tweets, either using
`subprocess.Popen` to call `notify-send` (at least on UNIX-like systems) or using a
Python library. I did it with [notify2](https://pypi.python.org/pypi/notify2), allowing
me to easily load the text of the tweet on a notification message and get the updates
while I'm doing other things, like playing videogames or working.

Sometimes there are too much updates and some are not shown, so I should try to search
another method to really get a useful feeder.


## Using the scraper with other purposes

Although the initial idea was just to get the tweets of the people I "follow" (because
I'm not really following them with my account, as I have none...), this scraper may
result more useful to other people used only as a library.


Of course, if the scraper is useful to you, you are free to use and modifiy it (under the
terms stated on the license, if there's one).

For example, to get the first tweet from a user, you can use the function `get_tweets`,
that recieves a list with the users (read the docstring for more info), as follows:
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

In that example, two tweets are retrieved and pretty-printed using `json.dumps`.

The retrieved data is a dictionary with the following format:
```python
{
    <user>: {
        <tweet-id>: {
              "profile_pic": <avatar of the tweet owner>
            , "permalink": <link to the tweet>
            , "stats": {
                  "likes": <number of likes>
                , "retweets": <number of retweets>
                , "replies": <number of replies>
            }
            , "tweet_id": <tweet-id>
            , "text": <text of the tweet>
            , "tweet_age": <timestamp of the tweet, in UNIX epoch format>
            , "pinned": <indication to know if the tweet is pinned>
            , "conversation": <conversation-id>
            , "user": {
                # Information of the owner of the tweet (important if it's a retweet)
                  "username": <account name (twitter.com/username)>
                , "displayname": <nickname for the user>
                , "uid": <user id>
                , "avatar": <profile pic>
            }
            , "retweet": <indication to know if it has been tweeted by someone else>
            # Only if "retweet" is True
            , "retweet_info" {
                  "retweet_id": <id of the retweet>
                , "retweeter": <username who retweeted (the one whose data is being extracted)>
            }
        }
        # ... (more tweeets from the user)
    }
    # ... (more users and their tweets)
}
```

Probably some thing should be changed to expose only the needed methods to get data (in
fact, only `get_tweets` should be public, making the others private methods), but for
the moment I don't think it's necessary.

-----------------------------------------------------------------------------------------

The whole project explained on this article is
[hosted on Github](https://github.com/Foo-Manroot/tweet-feed), so you can use it freely
and contribute if you want to.
