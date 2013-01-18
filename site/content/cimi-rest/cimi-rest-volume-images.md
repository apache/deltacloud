---
site_name: Deltacloud API
title: CIMI Resource Collections - Volume Image
---

<br/>

<div class="row">
  <div class="span9">

<h3 id="cimi-volume-image">Volume Image</h3>
<p>
<strong><em>
This resource represents an image that could be placed on a pre-loaded volume.
<br/>
<br/>
A Volume Image Collection resource represents the collection of Volume Image resources within a
Provider.
</em></strong>
</p>

  </div>
  <div class="span3">


<ul class="nav nav-list well">
  <li class="nav-header">
    CIMI REST API
  </li>
  <li><a href="/cimi-rest.html">Introduction</a></li>
  <li><a href="/cimi-rest/cimi-rest-entry-point.html">Cloud Entry Point</a></li>
  <li class="dropdown">
    <a href="#" class="dropdown-toggle" data-toggle="dropdown">
      CIMI Resources
      <b class="caret"></b>
    </a>
    <ul class="dropdown-menu">
      <li><a href="/cimi-rest/cimi-rest-resource-metadata.html">ResourceMetadata</a></li>
      <li><a href="/cimi-rest/cimi-rest-collections.html">Machine</a></li>
      <li><a href="/cimi-rest/cimi-rest-volumes.html">Volume</a></li>
    </ul>
  </li>
  <hr/>
  <li class="nav-header">
    Volume Resources
  </li>
  <ul class="nav nav-list">
    <li><a href="/cimi-rest/cimi-rest-volumes.html">Volume</a></li>
    <li class="active"><a href="/cimi-rest/cimi-rest-volume-images.html">VolumeImage</a></li>
    <li><a href="/cimi-rest/cimi-rest-volume-configs.html">VolumeConfiguration</a></li>
    <li><a href="/cimi-rest/cimi-rest-volume-templates.html">VolumeTemplate</a></li>
  </ul>

</ul>

  </div>

</div>

<ul class="nav nav-pills">
  <li class="active"><a href="#volume-image-collection" data-toggle="tab">Retrieve the Volume Image Collection</a></li>
  <li><a href="#single-volume-image" data-toggle="tab">Retrieve a single Volume Image</a></li>
  <li><a href="#create-volume-image" data-toggle="tab">Create a Volume Image</a></li>
  <li><a href="#delete-volume-image" data-toggle="tab">Delete a Volume Image</a></li>
</ul>

<hr>

<div class="tab-content">

  <div class="tab-pane active" id="volume-image-collection">

<h4>Retrieve the Volume Image Collection</h4>

<p>Example request:</p>

<pre>
GET /cimi/volume_images HTTP/1.1
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
Content-Length: 1095
ETag: ae3be87f858bb7c9b1000e5409c497f9
Cache-Control: max-age=0, private, must-revalidate
Date: Mon, 07 Jan 2013 15:18:00 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;Collection xmlns="http://schemas.dmtf.org/cimi/1" resourceURI="http://schemas.dmtf.org/cimi/1/VolumeImageCollection"&gt;
  &lt;id&gt;http://localhost:3001/cimi/volume_images&lt;/id&gt;
  &lt;count&gt;3&lt;/count&gt;
  &lt;VolumeImage&gt;
    &lt;id&gt;http://localhost:3001/cimi/volume_images/snap1&lt;/id&gt;
    &lt;name&gt;snap1&lt;/name&gt;
    &lt;description&gt;snap1&lt;/description&gt;
    &lt;created&gt;2009-07-29T18:15:24Z&lt;/created&gt;
    &lt;imageLocation href="http://localhost:3001/cimi/volumes/vol1" /&gt;
    &lt;bootable&gt;false&lt;/bootable&gt;
  &lt;/VolumeImage&gt;
  &lt;VolumeImage&gt;
    &lt;id&gt;http://localhost:3001/cimi/volume_images/snap3&lt;/id&gt;
    &lt;name&gt;snap3&lt;/name&gt;
    &lt;description&gt;snap3&lt;/description&gt;
    &lt;created&gt;2009-07-29T18:15:24Z&lt;/created&gt;
    &lt;imageLocation href="http://localhost:3001/cimi/volumes/vol2" /&gt;
    &lt;bootable&gt;false&lt;/bootable&gt;
  &lt;/VolumeImage&gt;
  &lt;VolumeImage&gt;
    &lt;id&gt;http://localhost:3001/cimi/volume_images/snap2&lt;/id&gt;
    &lt;name&gt;snap2&lt;/name&gt;
    &lt;description&gt;snap2&lt;/description&gt;
    &lt;created&gt;2009-07-29T18:15:24Z&lt;/created&gt;
    &lt;imageLocation href="http://localhost:3001/cimi/volumes/vol2" /&gt;
    &lt;bootable&gt;false&lt;/bootable&gt;
  &lt;/VolumeImage&gt;
&lt;/Collection&gt;
</pre>

  </div>


  <div class="tab-pane active" id="single-volume-image">

<h4>Retrieve a single Volume Image</h4>

<p>Example request:</p>

<pre>
GET /cimi/volume_images/snap2 HTTP/1.1
Authorization: Basic bW9ja3VzZXI6bW9ja3Bhc3N3b3Jk
User-Agent: curl/7.24.0 (i686-redhat-linux-gnu) libcurl/7.24.0 NSS/3.13.5.0 zlib/1.2.5 libidn/1.24 libssh2/1.4.1
Host: localhost:3001
Accept: application/xml
</pre>


<p>Server response:</p>

<pre>
HTTP/1.1 200 OK
Content-Type: application/xml
CIMI-Specification-Version: 1.0.1
Content-Length: 377
ETag: 134b5cae11297fd59b2a783a0ee430ed
Cache-Control: max-age=0, private, must-revalidate
Date: Tue, 08 Jan 2013 13:40:54 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;VolumeImage xmlns="http://schemas.dmtf.org/cimi/1" resourceURI="http://schemas.dmtf.org/cimi/1/VolumeImage"&gt;
  &lt;id&gt;http://localhost:3001/cimi/volume_images/snap1&lt;/id&gt;
  &lt;name&gt;snap1&lt;/name&gt;
  &lt;description&gt;snap1&lt;/description&gt;
  &lt;created&gt;2009-07-29T18:15:24Z&lt;/created&gt;
  &lt;imageLocation href="http://localhost:3001/cimi/volumes/vol1" /&gt;
  &lt;bootable&gt;false&lt;/bootable&gt;
&lt;/VolumeImage&gt;
</pre>

  </div>

  <div class="tab-pane active" id="create-volume-image">

<h4>Create a Volume Image</h4>

<p>A new Volume Image can be created from an existing Volume, by referencing the Volume
resource with the imageLocation attribute in the message body. This is illustrated in
the example below.</p>

<p>Example request:</p>

<pre>
POST /cimi/volume_images HTTP/1.1
Authorization: Basic bW9ja3VzZXI6bW9ja3Bhc3N3b3Jk
User-Agent: curl/7.24.0 (i686-redhat-linux-gnu) libcurl/7.24.0 NSS/3.13.5.0 zlib/1.2.5 libidn/1.24 libssh2/1.4.1
Host: localhost:3001
Content-Type: application/xml
Accept: application/xml
Content-Length: 210

&lt;VolumeImage xmlns="http://schemas.dmtf.org/cimi/1"&gt;
  &lt;name&gt; my_vol_image &lt;/name&gt;
  &lt;description&gt; marios first volume image &lt;/description&gt;
  &lt;imageLocation href="http://localhost:3001/cimi/volumes/vol1"/&gt;
&lt;/VolumeImage&gt;
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 201 Created
Content-Type: application/xml
Location: http://localhost:3001/cimi/volume_images/store_snapshot_1357663577
CIMI-Specification-Version: 1.0.1
Content-Length: 429
ETag: 5d4bdca8ed98295d1c463012bb8ff427
Cache-Control: max-age=0, private, must-revalidate
Date: Tue, 08 Jan 2013 16:46:17 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;VolumeImage xmlns="http://schemas.dmtf.org/cimi/1" resourceURI="http://schemas.dmtf.org/cimi/1/VolumeImage"&gt;
  &lt;id&gt;http://localhost:3001/cimi/volume_images/store_snapshot_1357663577&lt;/id&gt;
  &lt;name&gt;my_vol_image&lt;/name&gt;
  &lt;description&gt;marios first volume image&lt;/description&gt;
  &lt;created&gt;2013-01-08T18:46:17+02:00&lt;/created&gt;
  &lt;imageLocation href="http://localhost:3001/cimi/volumes/vol1" /&gt;
  &lt;bootable&gt;false&lt;/bootable&gt;
&lt;/VolumeImage&gt;
</pre>

  </div>

  <div class="tab-pane active" id="delete-volume-image">

<h4>Delete a Volume Image</h4>

<p>Example request:</p>

<pre>
DELETE /cimi/volume_images/snap1 HTTP/1.1
Authorization: Basic bW9ja3VzZXI6bW9ja3Bhc3N3b3Jk
User-Agent: curl/7.24.0 (i686-redhat-linux-gnu) libcurl/7.24.0 NSS/3.13.5.0 zlib/1.2.5 libidn/1.24 libssh2/1.4.1
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
Date: Wed, 09 Jan 2013 15:45:32 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife
</pre>

  </div>

</div>
