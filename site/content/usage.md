---
site_name: Deltacloud API
title: Usage
---
<br/>

<h3 id="usingapi">Using API</h3>

<h3 id="clients">Clients</h3>
Instead of dealing with HTTP interface you can use various clients to communicate with Deltacloud server.

<h3>The Deltacloud Ruby Client</h3>
You need to install Ruby client seperately to the Deltacloud API server. Assuming you already have Ruby and RubyGems setup, you can install the Deltacloud client by simply typing:

<pre>$ sudo gem install deltacloud-client</pre>

<p>The Deltacloud client consists of a Ruby library (packaged as a Ruby gem) which you can use to interact with the Deltacloud server and control your cloud infrastructure across cloud providers. <p>

<p>To use the client, you must require <strong>deltacloud</strong>:</p>

<pre>require 'deltacloud'</pre>

<p>Connect to a Deltacloud provider:</p>

<pre>
require 'deltacloud'

api_url      = 'http://localhost:3001/api'
api_name     = 'mockuser'
api_password = 'mockpassword'

client = DeltaCloud.new( api_name, api_password, api_url )

# work with client here
</pre>

<p>In addition to creating a client, you can specify operations within a block included on the initialization.</p>

<pre>
DeltaCloud.new( api_name, api_password, api_url ) do |client|
  # work with client here
end
</pre>

<p>In case of a failure, any underlying HTTP transport exceptions will be thrown away and returned back to the caller.</p>

<p>
To work with another driver, just switch the client:
</p>

<pre>
client = DeltaCloud.new( api_name, api_password, api_url )

# switch the client to use EC2 driver
ec2 = client.with_config(:driver => :ec2)

# switch the client to use OpenStack driver
openstack = client.with_config(:driver => :openstack)
</pre>

<a class="btn btn-inverse btn-large" style="float: right" href="/ruby-client.html">Work with the Ruby client</a>

<br/>
<br/>

<h3>HTTP clients - cURL</h3>

<p>
Basically, you interact with the Deltacloud server via HTTP calls, so you can use any HTTP client to talk to Deltacloud using the <a href="/rest-api.html">Deltacloud REST API</a>.
</p>

<p>
<a href="http://curl.haxx.se/">cURL</a> is a popular command line tool available on most modern linux distributions. See the following examples to learn how to use cURL to interact with Deltacloud. There is an assumption that the Deltacloud server is running on locahost:3001 and was started with the 'ec2' driver (i.e., deltacloudd -i ec2 ).
</p>

<p>
Get a list of all <strong>images</strong> available in the back-end cloud:
</p>

<pre>
curl  --user "pGbAJ1TsVg5PKs3BK27O:dPs47ralgBlldqYNbLg3scthsg4g8v0L9d6Mb5DK"
"http://localhost:3001/api/images?format=xml"
</pre>

<p>
The cURL <strong>--user</strong> option is used to specify the <strong>username:password</strong> credentials for access to the back-end cloud provider (Amazon EC2 in this case).</p>

<p>Create a new <strong>instance</strong> from the image with id 'ami-f51aff9c', in realm 'us-east-1c', with the hardware profile 'c1.medium', in firewall 'default':
</p>

<pre>
curl -X POST -F "keyname=eftah" -F "image_id=ami-f51aff9c"
-F "realm_id=us-east-1c" -F "hwp_id=c1.medium" -F "firewalls1=default"
--user "pGbAJ1TsVg5PKs3BK27O:dPs47ralgBlldqYNbLg3scthsg4g8v0L9d6Mb5DK"
"http://localhost:3001/api/instances?format=xml"
</pre>

<p>Delete a <strong>firewall</strong> called 'develgroup':</p>

<pre>
curl -X DELETE
--user "pGbAJ1TsVg5PKs3BK27O:dPs47ralgBlldqYNbLg3scthsg4g8v0L9d6Mb5DK"
http://localhost:3001/api/firewalls/develgroup?format=xml
</pre>

<p>
Create a <strong>blob</strong> called 'my_new_blob' within the bucket 'mybucket' from a local file with <strong>HTTP PUT</strong> specifying its content type and setting some metadata <strong>key:value</strong> pairs:
</p>

<pre>
curl -H 'content-type: text/html' -H 'X-Deltacloud-Blobmeta-Name:mariosblob'
-H 'X-Deltacloud-Blobmeta-Version:2.1' --upload-file
"/home/marios/Desktop/somefile.html"
--user "pGbAJ1TsVg5PKs3BK27O:dPs47ralgBlldqYNbLg3scthsg4g8v0L9d6Mb5DK"
http://localhost:3001/api/buckets/mybucket/my_new_blob?format=xml
</pre>

<p>
Retrieve <strong>blob metadata</strong> for the blob called 'my_new_blob':
</p>

<pre>
curl -iv -X HEAD
--user "pGbAJ1TsVg5PKs3BK27O:dPs47ralgBlldqYNbLg3scthsg4g8v0L9d6Mb5DK"
http://localhost:3001/api/buckets/mybucket/my_new_blob?format=xml
</pre>

<p>
The <strong>'-iv'</strong> flags will ensure that cURL displays the request and response headers (blob metadata are reported in the response headers with an empty response body).
</p>


<a class="btn btn-inverse btn-large" style="float: right" href="/curl-examples.html">Working with cURL</a>

<br/>
<br/>

<h3>Libdeltacloud Client (C library)</h3>
<p>
Libdeltacloud is a C/C++ library for accessing the Deltacloud API. It exports convenient structures and functions for manipulating cloud objects through the Deltacloud API.
</p>

Get the source code:
<pre>
$ git clone git://git.fedorahosted.org/deltacloud/libdeltacloud.git
</pre>

<p>
As of version 0.9, libdeltacloud is mostly <strong>API stable</strong>, but not ABI stable. The difference between the two is subtle but important. A library that is ABI (Application Binary Interface) stable means, that programs using the library don't need to be modified nor re-compiled when a new version of the library comes out. A library that is API (Application Programming Interface) stable means that programs using the library don't need to be modified, but may need to be re-compiled when a new version of the library comes out. The reason is that the sizes of structures in the library might change, which can lead to a misunderstanding between what the library and the program thinks the size of a structure is.
</p>

<p>
Due to the magic of libtool versioning, programs built against an older version of libdeltacloud will refuse to run against a newer version of libdeltacloud if the size of the structures has changed. If this happens, then the program must be recompiled against the newer libdeltacloud.
</p>

<a class="btn btn-inverse btn-large" style="float: right" href="http://deltacloud.apache.org/libdeltacloud/index.html">Libdeltacloud documentation</a>

<br/>

