---
site_name: Deltacloud API
title: CIMI Resource Collections - Machine Image
---

<br/>

<div class="row">
  <div class="span9">

<h3 id="cimi-machine-image">Machine Image</h3>
<p>
<strong><em>
This resource represents the information necessary for hardware virtualized resources to create a Machine Instance; it contains configuration data such as startup instructions, including possible combinations of the following items, depending on the 'type' of Machine Image created: the software image, installation software, both a disk image and a set of software and parameters. <br/> <br/>
A Machine Image Collection resource represents the collection of Machine Image resources within a Provider.
</em></strong>
</p>

  </div>
  <div class="span3">

<ul class="nav nav-list well">
  <li class="nav-header">
    CIMI REST API
  </li>
  <li><a href="/cimi-rest.html">Introduction</a></li>
  <li><a href="/cimi-rest-entry-point.html">Cloud Entry Point</a></li>
  <li><a href="/cimi-rest-collections.html">CIMI Resources</a></li>
    <ul class="nav nav-list">
      <li><a href="/cimi-rest-collections.html">Machine</a></li>
      <li class="active"><a href="/cimi-rest-machine-images.html">MachineImage</a></li>
    </ul>

</ul>

  </div>

</div>

<ul class="nav nav-pills">
  <li class="active"><a href="#image-collection" data-toggle="tab">Retrieve the Machine Image Collection</a></li>
  <li><a href="#single-image" data-toggle="tab">Retrieve a single Machine Image</a></li>
  <li><a href="#create-image" data-toggle="tab">Create or Delete a Machine Image</a></li>
</ul>

<hr>

<div class="tab-content">
  <div class="tab-pane active" id="image-collection">

<h4>Retrieve the Machine Image Collection</h4>

<p>
Note the 'add' URI of the Machine Image Collection resource in the example response below. This is the URI that is used for creating a new Machine Image (adding to the Machine Image Collection). This URI is also returned when dereferencing a Machine resource, as the href attribute of the 'capture' operation (when this is possible for the given Machine on the particular Cloud Provider).
</p>

<p>Example request:</p>
<pre>
GET /cimi/machine_images HTTP/1.1
Authorization: Basic bW9ja3VzZXI6bW9ja3Bhc3N3b3Jk
User-Agent: curl/7.24.0 (i686-redhat-linux-gnu)
Host: localhost:3001
Accept: application/xml
</pre>

<p>Server response:</p>
<pre>
HTTP/1.1 200 OK
Content-Type: application/xml
CIMI-Specification-Version: 1.0.1
Content-Length: 1195
ETag: e2f73ed48eb2abeae77322eea56dfc5d
Cache-Control: max-age=0, private, must-revalidate
Date: Fri, 28 Dec 2012 14:23:35 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;Collection xmlns="http://schemas.dmtf.org/cimi/1"
          resourceURI="http://schemas.dmtf.org/cimi/1/MachineImageCollection"&gt;
  &lt;id&gt;http://localhost:3001/cimi/machine_images&lt;/id&gt;
  &lt;count&gt;3&lt;/count&gt;
  &lt;MachineImage&gt;
    &lt;id&gt;http://localhost:3001/cimi/machine_images/img1&lt;/id&gt;
    &lt;name&gt;img1&lt;/name&gt;
    &lt;description&gt;Fedora 10&lt;/description&gt;
    &lt;created&gt;2012-12-28T16:23:35+02:00&lt;/created&gt;
    &lt;state&gt;AVAILABLE&lt;/state&gt;
    &lt;type&gt;IMAGE&lt;/type&gt;
    &lt;imageLocation&gt;mock://img1&lt;/imageLocation&gt;
  &lt;/MachineImage&gt;
  &lt;MachineImage&gt;
    &lt;id&gt;http://localhost:3001/cimi/machine_images/img2&lt;/id&gt;
    &lt;name&gt;img2&lt;/name&gt;
    &lt;description&gt;Fedora 10&lt;/description&gt;
    &lt;created&gt;2012-12-28T16:23:35+02:00&lt;/created&gt;
    &lt;state&gt;AVAILABLE&lt;/state&gt;
    &lt;type&gt;IMAGE&lt;/type&gt;
    &lt;imageLocation&gt;mock://img2&lt;/imageLocation&gt;
  &lt;/MachineImage&gt;
  &lt;MachineImage&gt;
    &lt;id&gt;http://localhost:3001/cimi/machine_images/img3&lt;/id&gt;
    &lt;name&gt;img3&lt;/name&gt;
    &lt;description&gt;JBoss&lt;/description&gt;
    &lt;created&gt;2012-12-28T16:23:35+02:00&lt;/created&gt;
    &lt;state&gt;AVAILABLE&lt;/state&gt;
    &lt;type&gt;IMAGE&lt;/type&gt;
    &lt;imageLocation&gt;mock://img3&lt;/imageLocation&gt;
  &lt;/MachineImage&gt;
  &lt;operation rel="add" href="http://localhost:3001/cimi/machine_images" /&gt;
&lt;/Collection&gt;
</pre>

  </div>
  <div class="tab-pane" id="single-image">

<h4>Retrieve a single Machine Image</h4>

<p>Example request:</p>

<pre>
GET /cimi/machine_images/img1 HTTP/1.1
Authorization: Basic bW9ja3VzZXI6bW9ja3Bhc3N3b3Jk
User-Agent: curl/7.24.0 (i686-redhat-linux-gnu)
Host: localhost:3001
Accept: application/xml
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 200 OK
Content-Type: application/xml
CIMI-Specification-Version: 1.0.1
Content-Length: 385
ETag: 130f8e9592138afc544d65d73039e540
Cache-Control: max-age=0, private, must-revalidate
Date: Fri, 28 Dec 2012 14:55:42 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;MachineImage xmlns="http://schemas.dmtf.org/cimi/1"
          resourceURI="http://schemas.dmtf.org/cimi/1/MachineImage"&gt;
  &lt;id&gt;http://localhost:3001/cimi/machine_images/img1&lt;/id&gt;
  &lt;name&gt;img1&lt;/name&gt;
  &lt;description&gt;Fedora 10&lt;/description&gt;
  &lt;created&gt;2012-12-28T16:55:42+02:00&lt;/created&gt;
  &lt;state&gt;AVAILABLE&lt;/state&gt;
  &lt;type&gt;IMAGE&lt;/type&gt;
  &lt;imageLocation&gt;mock://img1&lt;/imageLocation&gt;
&lt;/MachineImage&gt;
</pre>

  </div>

  <div class="tab-pane" id="create-image">


<h4>Create a new Machine Image</h4>

<p>
The example below shows the creation of a new Machine Image resource from an existing Machine resource. When supported by the Machine and the given Cloud Provider, the href attribute of the serialized Machine resource's 'capture' operation provides the URI to which the request body should be sent with HTTP POST in order to create the new Machine Image. The message body is the representation of the to be created Machine Image resource, with the 'imageLocation' attribute referring to the Machine resource from which the Machine Image is to be created, as shown in the example below:
</p>

<p>Example request:</p>

<pre>
POST /cimi/machine_images HTTP/1.1
Authorization: Basic bW9ja3VzZXI6bW9ja3Bhc3N3b3Jk
User-Agent: curl/7.24.0 (i686-redhat-linux-gnu)
Host: localhost:3001
Content-Type: application/xml
Accept: application/xml
Content-Length: 188
&lt;MachineImage&gt;
  &lt;name&gt;some_name&lt;/name&gt;
  &lt;description&gt;my new machine_image&lt;/description&gt;
  &lt;type&gt;IMAGE&lt;/type&gt;
  &lt;imageLocation&gt;http://localhost:3001/cimi/machines/inst1&lt;/imageLocation&gt;
&lt;/MachineImage&gt;
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 201 Created
Content-Type: application/xml
Location: http://localhost:3001/cimi/machine_images/some_name
CIMI-Specification-Version: 1.0.1
Content-Length: 411
ETag: c929191a65da6564f9f69301d38eb6fc
Cache-Control: max-age=0, private, must-revalidate
Date: Fri, 28 Dec 2012 15:10:12 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;MachineImage xmlns="http://schemas.dmtf.org/cimi/1"
          resourceURI="http://schemas.dmtf.org/cimi/1/MachineImage"&gt;
  &lt;id&gt;http://localhost:3001/cimi/machine_images/some_name&lt;/id&gt;
  &lt;name&gt;some_name&lt;/name&gt;
  &lt;description&gt;my new machine image&lt;/description&gt;
  &lt;created&gt;2012-12-28T17:10:12+02:00&lt;/created&gt;
  &lt;state&gt;AVAILABLE&lt;/state&gt;
  &lt;type&gt;IMAGE&lt;/type&gt;
  &lt;imageLocation&gt;mock://some_name&lt;/imageLocation&gt;
&lt;/MachineImage&gt;
</pre>

<br/>
<hr/>

<h4>Delete a Machine Image</h4>

<p>Example request:</p>

<pre>
DELETE /cimi/machine_images/some_name HTTP/1.1
Authorization: Basic bW9ja3VzZXI6bW9ja3Bhc3N3b3Jk
User-Agent: curl/7.24.0 (i686-redhat-linux-gnu)
Host: localhost:3001
Accept: application/xml
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 200 OK
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Type: text/html;charset=utf-8
CIMI-Specification-Version: 1.0.1
Content-Length: 0
Date: Fri, 28 Dec 2012 15:21:14 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife
</pre>

  </div>
</div>
