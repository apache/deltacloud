Deltacloud API
==============

Hooray, you have successfully checked out Deltacloud Core.
Deltacloud protects yourapps from cloud API changes and incompatibilities,
so you can concentrate on managing cloud instances the way you want.

You can find more documentation at the Deltacloud web site at:
[deltacloud.apache.org/](http://deltacloud.apache.org/)

Prerequisites
-------------

Deltacloud Core depends on a number of other Ruby libraries. The easiest
way to install them is to either install the deltacloud-core package from
your distribution is repository, e.g. `yum install deltacloud-core` on
Fedora, or install the gem with `gem install deltacloud-core`.

If you do not want to do that, have a look at the dependencies in the gem
spec for deltacloud-core and install them manually from git repository:

    $ git clone git://git.apache.org/deltacloud.git
    $ cd deltacloud/server
    $ bundle install

Running
-------

To get started, run `./bin/deltacloudd -i mock`; this will run Deltacloud
Core with the mock driver, a driver that does not talk to a cloud, but
simulates being one. It will store data about its instances etc. in
`/var/tmp/deltacloud-mock-$USER`; that directory will automatically populated
with sample data if it does not exist. Subsequent runs will continue using
the data found there. If you need to start over from scratch, just delete
that directory and restart deltacloudd.

Once you have the server running, point your browser at
[localhost:3001/api](http://localhost:3001/api) to get a HTML version of
Deltacloud Core.  If you want to look at the XML that REST clients will
see, simply add `?format=xml` to URLs. Deltacloud Core does content
negotiation; REST clients should not set _format_ to URLs, they should
simply set the _Accept_ header appropriately.

Some operations require authentication. For the mock driver, the username
and password are *mockuser* and *mockpassword*. A current list of drivers
and what kind of credentials they need can be found at
the Deltacloud site (http://deltacloud.apache.org/drivers.html)

Happy hacking - and do not forget to send patches to the mailing list (to
subscribe send email to dev-subscribe@deltacloud.apache.org)

You could send patches using `git format-patch master` and then `git
send-email --thread`. Example _.git/config_ file:

    [sendemail]
        to = dev@deltacloud.apache.org
        signedoffbycc=no
        chainreplyto=no
        smtpserver=YOUR_SMTP_SERVER_HERE
        thread=yes
        from=YOUR_EMAIL_HERE
        suppresscc=all
