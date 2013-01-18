---
site_name: Deltacloud API
title: CIMI Resource Collections - Volume
---

<br/>

<div class="row">
  <div class="span9">

<h3 id="cimi-machine-image">Volume</h3>
<p>
<strong><em>
A Volume represents storage at either the block or the file-system level. Volumes can be connected to
Machines. Once connected, Volumes can be accessed by processes on that Machine.
<br/>
A Volume Collection resource represents the collection of Volumes within a Provider.
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
    <li class="active"><a href="/cimi-rest/cimi-rest-volumes.html">Volume</a></li>
    <li><a href="/cimi-rest/cimi-rest-volume-images.html">VolumeImage</a></li>
    <li><a href="/cimi-rest/cimi-rest-volume-configs.html">VolumeConfiguration</a></li>
    <li><a href="/cimi-rest/cimi-rest-volume-templates.html">VolumeTemplate</a></li>
  </ul>

</ul>

  </div>

</div>

<ul class="nav nav-pills">
  <li class="active"><a href="#volume-collection" data-toggle="tab">Retrieve the Volume Collection</a></li>
  <li><a href="#single-volume" data-toggle="tab">Retrieve a single Volume</a></li>
  <li><a href="#create-volume" data-toggle="tab">Create a Volume</a></li>
  <li><a href="#delete-volume" data-toggle="tab">Delete a Volume</a></li>
</ul>

<hr>

<div class="tab-content">
  <div class="tab-pane active" id="volume-collection">

<h4>Retrieve the Volume Collection</h4>

<p>Example request:</p>
<pre>
GET /cimi/volumes HTTP/1.1
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
Content-Length: 1521
ETag: 5e589664c1b03a34ad42ffe606bd61f1
Cache-Control: max-age=0, private, must-revalidate
 Date: Fri, 04 Jan 2013 16:43:27 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;Collection xmlns="http://schemas.dmtf.org/cimi/1"
          resourceURI="http://schemas.dmtf.org/cimi/1/VolumeCollection"&gt;
  &lt;id&gt;http://localhost:3001/cimi/volumes&lt;/id&gt;
  &lt;count&gt;3&lt;/count&gt;
  &lt;Volume&gt;
    &lt;id&gt;http://localhost:3001/cimi/volumes/vol3&lt;/id&gt;
    &lt;name&gt;vol3&lt;/name&gt;
    &lt;description&gt;Description of Volume&lt;/description&gt;
    &lt;created&gt;2009-07-30T14:35:11Z&lt;/created&gt;
    &lt;state&gt;IN-USE&lt;/state&gt;
    &lt;type&gt;http://schemas.dmtf.org/cimi/1/mapped&lt;/type&gt;
    &lt;capacity&gt;1048576&lt;/capacity&gt;
    &lt;bootable&gt;false&lt;/bootable&gt;
    &lt;operation rel="delete" href="http://localhost:3001/cimi/volumes/vol3" /&gt;
  &lt;/Volume&gt;
  &lt;Volume&gt;
    &lt;id&gt;http://localhost:3001/cimi/volumes/vol2&lt;/id&gt;
    &lt;name&gt;vol2&lt;/name&gt;
    &lt;description&gt;Description of Volume&lt;/description&gt;
    &lt;created&gt;2009-07-30T14:35:11Z&lt;/created&gt;
    &lt;state&gt;AVAILABLE&lt;/state&gt;
    &lt;type&gt;http://schemas.dmtf.org/cimi/1/mapped&lt;/type&gt;
    &lt;capacity&gt;1048576&lt;/capacity&gt;
    &lt;bootable&gt;false&lt;/bootable&gt;
    &lt;operation rel="delete" href="http://localhost:3001/cimi/volumes/vol2" /&gt;
  &lt;/Volume&gt;
  &lt;Volume&gt;
    &lt;id&gt;http://localhost:3001/cimi/volumes/vol1&lt;/id&gt;
    &lt;name&gt;vol1&lt;/name&gt;
    &lt;description&gt;Description of Volume&lt;/description&gt;
    &lt;created&gt;2009-07-30T14:35:11Z&lt;/created&gt;
    &lt;state&gt;AVAILABLE&lt;/state&gt;
    &lt;type&gt;http://schemas.dmtf.org/cimi/1/mapped&lt;/type&gt;
    &lt;capacity&gt;1048576&lt;/capacity&gt;
    &lt;bootable&gt;false&lt;/bootable&gt;
    &lt;operation rel="delete" href="http://localhost:3001/cimi/volumes/vol1" /&gt;
  &lt;/Volume&gt;
  &lt;operation rel="add" href="http://localhost:3001/cimi/volumes" /&gt;
&lt;/Collection&gt;
</pre>

  </div>

  <div class="tab-pane active" id="single-volume">

<h4>Retrieve a single Volume</h4>

<p>Example request:</p>
<pre>
GET /cimi/volumes/vol1 HTTP/1.1
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
Content-Length: 490
ETag: a4be42f0743b1a6efbd2ed431667e7d4
Cache-Control: max-age=0, private, must-revalidate
Date: Mon, 07 Jan 2013 13:57:46 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;Volume xmlns="http://schemas.dmtf.org/cimi/1" resourceURI="http://schemas.dmtf.org/cimi/1/Volume"&gt;
  &lt;id&gt;http://localhost:3001/cimi/volumes/vol1&lt;/id&gt;
  &lt;name&gt;vol1&lt;/name&gt;
  &lt;description&gt;Description of Volume&lt;/description&gt;
  &lt;created&gt;2009-07-30T14:35:11Z&lt;/created&gt;
  &lt;state&gt;AVAILABLE&lt;/state&gt;
  &lt;type&gt;http://schemas.dmtf.org/cimi/1/mapped&lt;/type&gt;
  &lt;capacity&gt;1048576&lt;/capacity&gt;
  &lt;bootable&gt;false&lt;/bootable&gt;
  &lt;operation rel="delete" href="http://localhost:3001/cimi/volumes/vol1" /&gt;
&lt;/Volume&gt;


</pre>

  </div>


  <div class="tab-pane active" id="create-volume">

<h4>Create a Volume</h4>

<p>Using VolumeTemplate with VolumeConfiguration by reference - Example request:</p>
<pre>
POST //cimi/volumes HTTP/1.1
Authorization: Basic bW9ja3VzZXI6bW9ja3Bhc3N3b3Jk
User-Agent: curl/7.24.0 (i686-redhat-linux-gnu)
Host: localhost:3001
Content-Type:application/xml
Accept:application/xml
Content-Length: 224

&lt;VolumeCreate&gt;
  &lt;name&gt; marios_new_volume &lt;/name&gt;
  &lt;description&gt; a new volume &lt;/description&gt;
  &lt;volumeTemplate&gt;
    &lt;volumeConfig
      href="http://localhost:3001/cimi/volume_configurations/2"&gt;
    &lt;/volumeConfig&gt;
  &lt;/volumeTemplate&gt;
&lt;/VolumeCreate&gt;
</pre>

<p>Server response:</p>
<pre>
HTTP/1.1 201 Created
Content-Type: application/xml
Location: http://localhost:3001/cimi/volumes/Volume1357567397
CIMI-Specification-Version: 1.0.1
Content-Length: 523
ETag: 56c05e34776373022cefda3c3c4467cb
Cache-Control: max-age=0, private, must-revalidate
Date: Mon, 07 Jan 2013 14:03:17 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;Volume xmlns="http://schemas.dmtf.org/cimi/1" resourceURI="http://schemas.dmtf.org/cimi/1/Volume"&gt;
  &lt;id&gt;http://localhost:3001/cimi/volumes/Volume1357567397&lt;/id&gt;
  &lt;name&gt;marios_new_volume&lt;/name&gt;
  &lt;description&gt;a new volume&lt;/description&gt;
  &lt;created&gt;2013-01-07T16:03:17+02:00&lt;/created&gt;
  &lt;state&gt;AVAILABLE&lt;/state&gt;
  &lt;type&gt;http://schemas.dmtf.org/cimi/1/mapped&lt;/type&gt;
  &lt;capacity&gt;2097152&lt;/capacity&gt;
  &lt;bootable&gt;false&lt;/bootable&gt;
  &lt;operation rel="delete" href="http://localhost:3001/cimi/volumes/Volume1357567397" /&gt;
&lt;/Volume&gt;
</pre>

<br/>
<p>Using VolumeTemplate with VolumeConfiguration by value - Example request:</p>
<pre>
POST /cimi/volumes HTTP/1.1
Authorization: Basic bW9ja3VzZXI6bW9ja3Bhc3N3b3Jk
User-Agent: curl/7.24.0 (i686-redhat-linux-gnu) libcurl/7.24.0 NSS/3.13.5.0 zlib/1.2.5 libidn/1.24 libssh2/1.4.1
Host: localhost:3001
Accept:application/xml
Content-Type: application/xml
Content-Length: 239

&lt;VolumeCreate&gt;
  &lt;name&gt; marios_volume &lt;/name&gt;
  &lt;description&gt; a new volume &lt;/description&gt;
  &lt;volumeTemplate&gt;
    &lt;volumeConfig&gt;
      &lt;type&gt;http://schemas.dmtf.org/cimi/1/mapped&lt;/type&gt;
      &lt;capacity&gt; 1024 &lt;/capacity&gt;
    &lt;/volumeConfig&gt;
  &lt;/volumeTemplate&gt;
&lt;/VolumeCreate&gt;
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 201 Created
Content-Type: application/xml
Location: http://localhost:3001/cimi/volumes/Volume1357567628
CIMI-Specification-Version: 1.0.1
Content-Length: 516
ETag: d82624fda83c895cbeaebb08fff005c6
Cache-Control: max-age=0, private, must-revalidate
Date: Mon, 07 Jan 2013 14:07:08 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;Volume xmlns="http://schemas.dmtf.org/cimi/1" resourceURI="http://schemas.dmtf.org/cimi/1/Volume"&gt;
  &lt;id&gt;http://localhost:3001/cimi/volumes/Volume1357567628&lt;/id&gt;
  &lt;name&gt;marios_volume&lt;/name&gt;
  &lt;description&gt;a new volume&lt;/description&gt;
  &lt;created&gt;2013-01-07T16:07:08+02:00&lt;/created&gt;
  &lt;state&gt;AVAILABLE&lt;/state&gt;
  &lt;type&gt;http://schemas.dmtf.org/cimi/1/mapped&lt;/type&gt;
  &lt;capacity&gt;1024&lt;/capacity&gt;
  &lt;bootable&gt;false&lt;/bootable&gt;
  &lt;operation rel="delete" href="http://localhost:3001/cimi/volumes/Volume1357567628" /&gt;
&lt;/Volume&gt;
</pre>

  </div>

  <div class="tab-pane active" id="delete-volume">

<h4>Retrieve the Volume Collection</h4>

<p>Example request:</p>
<pre>
DELETE /cimi/volumes/Volume1357567628 HTTP/1.1
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
Date: Mon, 07 Jan 2013 14:16:21 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

</pre>

  </div>

</div>
