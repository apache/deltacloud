CIMI Frontend
==============

Prerequisites
-------------

Start Deltacloud API with CIMI option:

    $ cd core/server
    $ ./bin/deltacloud -i mock --cimi

Then start CIMI Frontend server and point to Deltacloud API URL:

    $ cd core/clients/cimi
    $ bundle
    $ ./bin/start -u "http://localhost:3001/cimi"
