---
layout: post
title:  "Setting up an OCSP responder with ActiveMQ"
date:   2018-07-21 14:01:40 +0200
author: foo
categories: ocsp activemq programming
ref: activemq-ocsp
---

Some time ago I faced a problem at work where I had to learn a couple of interesting
things. The problem was to control the access of producers and consumers on an ActiveMQ
queue, allowing us to control which probes (consumers or producers) where given access.

If you don't know what ActiveMQ is, it's basically composed of a server, the _broker_,
who manages a queue. This queue is populated by a client, the _producer_, and then the
data is **asynchronously** read by another client, the _consumer_. Once it has been read,
the data can be deleted or simply marked as read, depending on the type of queue used.
This process is shown, more or less, on the following diagram:
```
            ________
           |        |  2) Enqueue
           | Broker | <---> Database (queues)
           |________|  4) Dequeue

            ^       ^
 1) Write  /         \  3) Read
          /           \
    __________      __________
   |          |    |          |
   | Producer |    | Consumer |
   |__________|    |__________|
```

Although ActiveMQ has an option to set up a password, this only works globally for every
probe on the system. This is just a measure to deny access to unauthenticated probes;
but, what if we want to revoke only the permissions of a single producer? Should we
change the password and inform only the allowed probes about the change[^1]? Or should we
write our own extension control access?

This second option seems to be better, but still too complicated. Before starting to
implement a custom plug-in, we should try to dive more into the configuration and
documentation of ActiveMQ. After some time, we find a viable option using certificates.
The problem is that we need a way to revoke and add new certificates live, without
restarting the broker. However, changing the revocation status of a certificate means
changing the Certificate Revocation List (CRL), and this is not possible in Java without
restarting the JVM. But there's still hope, as we could try to see of we could use an
OCSP responder. This is not a very well documented feature on Java nor ActiveMQ (at least
I couldn't find any useful information), thus this post.


## What is an OCSP responder?

The [Online Certificate Status Protocol](https://en.wikipedia.org/wiki/Online_Certificate_Status_Protocol)
is a method used in a [Public Key Infrastructure](https://en.wikipedia.org/wiki/Public_key_infrastructure)
by clients to check the revocation status of a certificate. This is done by asking a
server in which the client trusts, who answers with the status. This way, if a
certificate is revoked, we only have to inform this central server, instead of having to
update every CRL of any agent on the system.

Returning to our initial problem, we wanted to control the access to the broker by the
probes without restarting the server. We can do this with an additional process on the
server who will answer any question from the broker about the revocation status of any
certificate. On any new connection from a probe, the broker will allow or deny the
request based on the response returned from this new process. The diagram is now a bit
different than before:
```
 ___________  2,6) OCSP request   ________
|           |   <--------------  |        |  4) Enqueue
| Responder |   -------------->  | Broker | <---> Database (queues)
|___________| 3,7) OCSP response |________|  8) Dequeue

                                  ^       ^
                       1) Write  /         \  5) Read
                                /           \
                          __________      __________
                         |          |    |          |
                         | Producer |    | Consumer |
                         |__________|    |__________|
```

This would be the perfect solution, allowing us to change the status of any certificate
at any time without restarting any service. Now, the challenge is to easily implement
this solution on ActiveMQ. If it turns out that it's easier to create a custom plug-in,
we'll have to do that instead.

After investigating a couple of hours, we find out that it should be possible to do it,
as there exists an option on the [`java.security`](http://activemq.apache.org/how-do-i-use-ssl.html#HowdoIuseSSL-Certificaterevocation)
configuration file. On the linked documentation page, there's also
[a demo](https://github.com/dejanb/sslib) that, with some tweaks, finally gives us the
answer to our problem. The key options that we have to enable on this file are:
```conf
ocsp.enable=true
ocsp.responderURL=http://ocsp.responder.example
```
Obviously, the responder URL will have to be changed with our own.

As the linked demo from [dejanb](https://github.com/dejanb/sslib) doesn't work and the
instructions are a bit off (but not too much), this post aims to fill the gaps on that
explanation. The updated certificates and documentation live under
[my fork on Github](https://github.com/Foo-Manroot/sslib).


## OpenSSL responder

For this series of tests we're going to use a simple responder provided by OpenSSL, as
we're only interested on the broker's part (for now). Later on the project we implemented
our own responder, that searched on the database the answer that had to give to ActiveMQ.
This task is (almost) trivial and left as an exercise for the reader[^2].

To start the OpenSSL responder we're gonna use the following command:
```sh
openssl ocsp -port 2560 -text \
        -index demoCA/index.txt \
        -CA demoCA/cacert.pem \
        -rkey demoCA/private/cakey.pem \
        -rsigner demoCA/cacert.pem
```

There needs to be a custom
[Certificate Authority (CA)](https://en.wikipedia.org/wiki/Certificate_authority) to
issue all the certificates for our probes and to sign the responses (after all, we are
asking the issuer about the status of one of its certificates) sent to the broker[^3]. We
use the CA's certificate, `demoCA/cacert.pem`, and private key,
`demoCA/private/cakey.pem`, to sign the responses. There's also a file with the
revocation status of all the certificates issued by this CA (in other words, a CRL):
```sh
$ cat index.txt
V   21171114205545Z     D7455D88CE0EBB0D    unknown /C=AA/ST=Example State/O=CA Company/CN=example.com/emailAddress=CA@example.com
V   271206210849Z       D7455D88CE0EBB0F    unknown /C=AA/O=Broker Company/CN=broker.example/emailAddress=broker@broker.example
V   271206211359Z       D7455D88CE0EBB10    unknown /C=AA/O=Client - 1 Company/CN=client-1.company/emailAddress=client-1@client-1.company
```

## Creation of the required certificates

We'll need two different kind of certificates: the broker's and the probes'. Both types
will be issued by our custom CA: `demoCA`.

The broker needs a certificate so the probes can verify the his identity. This is only
required when using the pre-built _jars_ provided by ActiveMQ, which let us test the set
up without coding anything. When everything is completed, we can implement our own
producer and consumer, ignoring any certificate error (if we want to).

To create the certificates I'll use the [CA.pl](https://github.com/openssl/openssl/blob/master/apps/CA.pl.in)
utility. Beware of directly using the linked file, as it's just a template to fill with
the configuration). On most Unix-like systems, it's available with the default
installation of the OpenSSL library (`/usr/lib/ssl/misc/CA.pl`, in my case).

### Create the CA

First things first, we have to start creating the Authority that will issue the rest
of the certificates. To do that, we can use the provided script; or you can do it by
yourself just looking at the source of `CA.pl` or searching one of the tutorials
available on the internet:
```sh
$ /usr/lib/ssl/misc/CA.pl -newca
```

As simple as that. After answering the questions needed for the certificate (country,
domain name, etc.), you'll have a new directory called `demoCA` with the private key of
the CA, its certificate and the index with the CRL for the issued certificates. Right
now, it should only have the CA's own certificate.

There's no need for more configuration for the CA. We can now create a new Certificate
Signing Request (CSR) from the probe with `CA.pl -newreq`, sign it from the CA with
`CA.pl -sign` and create a [PKCS#12](https://en.wikipedia.org/wiki/PKCS_12) to import the
cert chain into the probe's key-store.

### Broker's certificate

The broker is just a server running on the JVM, so we need to add our new certificate
chain (the PKCS#12) into its key-store and the CA's certificate into the broker's
trust-store. This last step is the one who dejanb got wrong, as in their repository the
broker didn't trust on the CA, so every request was dropped.

To create the certificates for the broker, we just have to create a CSR, sign it with the
CA and create the chain to import it:
```sh
$ /usr/lib/ssl/misc/CA.pl -newreq
$ /usr/lib/ssl/misc/CA.pl -sign
$ /usr/lib/ssl/misc/CA.pl -pkcs12

$ mv newcert.pem broker/broker.cert.pem
$ mv newcert.p12 broker/broker.p12
$ mv newkey.pem broker/broker.key.pem
$ rm newreq.pem
```

Now we can create the broker key-store by adding his and CA's certificates into it. The
CA certificate has the default alias "my certificate", given by the `CA.pl` helper
script. If we don't want a PKCS#12 type store but a JKS one, we just have to tweak a
couple of options (see `man keytool(1)`):
```sh
$ keytool -importkeystore \
        -srckeystore broker/broker.p12 \
        -destkeystore broker/broker-keys.ks \
        -srcstoretype pkcs12 \
        -deststoretype pkcs12 \
        -alias "my certificate" \
        -destalias broker

$ keytool -import \
        -file demoCA/cacert.pem \
        -alias "ca" -trustcacerts \
        -keystore broker/broker-keys.ks
```

After this step, we only have to add the CA into the broker's trust-store:
```sh
$ keytool -import \
        -file demoCA/cacert.pem \
        -alias "ca" -trustcacerts \
        -keystore broker/broker-trust.ts
```

The broker is now ready and can be run. Also, we'll only need the broker's certificate.
Except this file (`broker/broker.cert.pem`), we can delete the rest of that directory.
It's not needed, though, so you should keep it around just in case.

### Clients' certificates

The process to create the key- and trust-stores is very similar to the one on [the
previous section](#brokers-certificate), and it's identical on every probe that will be
added.

As before, we create the CSR, sign it and store the chain of the new certificate in
PKCS#12 format:
```sh
$ /usr/lib/ssl/misc/CA.pl -newreq
$ /usr/lib/ssl/misc/CA.pl -sign
$ /usr/lib/ssl/misc/CA.pl -pkcs12

$ mv newcert.pem client-1/client-1.cert.pem
$ mv newcert.p12 client-1/client-1.p12
$ mv newkey.pem client-1/client-1.key.pem
$ rm newreq.pem
```

And the key-store for the client:
```sh
$ keytool -importkeystore \
        -srckeystore client-1/client-1.p12 \
        -destkeystore client-1/client-1-keys.ks \
        -srcstoretype pkcs12 \
        -deststoretype pkcs12 \
        -alias "my certificate" \
        -destalias client-1

$ keytool -import \
        -file demoCA/cacert.pem \
        -alias "ca" -trustcacerts \
        -keystore client-1/client-1.ks
```

To finalize, we have to add not only the certificate of the CA to the client's
trust-store; but the certificate of the broker too. This is needed because the clients
won't ask the OCSP responder, but they'll trust always on the broker. To add the
certificates, we use a similar command as before (note that `broker.cert.pem` has the
full chain, so we don't have to import also the CA):
```sh
$ keytool -import \
    -file broker/broker.cert.pem \
    -alias "broker" -trustcacerts \
    -keystore client-1/client-1.ts
```

### Test of the OCSP responder

To start the OpenSSL OCSP responder, run:
```sh
openssl ocsp -port 2560 -text \
        -index demoCA/index.txt  -CA demoCA/cacert.pem \
        -rkey demoCA/private/cakey.pem \
        -rsigner demoCA/cacert.pem
```

You can test the responder like:
```sh
openssl ocsp -CAfile demoCA/cacert.pem \
        -url http://127.0.0.1:2560 -resp_text \
        -issuer demoCA/cacert.pem \
        -cert client-1.cert.pem
```

## Configuration on ActiveMQ

Before testing the connection, we have to tell ActiveMQ to use the OCSP responder and the
right key- and trust-stores. The files to be edited are `java.security` and
`activemq.xml`.

In the first one there has to be the following options (with the correct URL):
```conf
ocsp.enable=true
ocsp.responderURL=http://localhost:2560
```

In the second one, the configuration for the broker, we'll add this into the `<broker>`
element (changing the passwords for the ones we used on the stores):
```xml
<sslContext>
    <sslContext
        keyStore="file:${activemq.conf}/broker.ks"
        keyStorePassword="activemq"
        trustStore="file:${activemq.conf}/broker.ts"
        trustStorePassword="activemq"
    />
</sslContext>

<!-- The SSL connector may be already present -->
<transportConnectors>
    <transportConnector name="ssl" uri="ssl://0.0.0.0:61617?transport.closeAsync=false&amp;wantClientAuth=true&amp;needClientAuth=true"/>
</transportConnectors>
```

Now we're ready to go.

## Demonstration

In the following video the whole setup is shown. Any connection made by the client is
validated through the OCSP responder. You can also try to create a connection from a
client without a valid certificate (or a revoked one), and see how the responder answers
with an "unknown" or "revoked" status, after which the broker will deny the connection.

{% include video.html
    src="/assets/posts/2018-07-21-activemq-ocsp/demo.webm"
%}

I hope to help someone who has the same problem as I had, asking myself why the setup
pointed to on the official documentation doesn't work.

Cheers :)

-----------------------------------------------------------------------------------------

[^1]: I know, I know: that's a horrible system

[^2]: He he... I bet you've read these words more than once on your maths books :D

[^3]: Even though we could use a completely different set of keys to sign the response,
    the usual set up is to use the OCSP responder run by the CA's servers. Doing it any
    other way wouldn't very helpful. I'd say that it's even harmful to our academic
    purposes.
