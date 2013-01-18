---
site_name: Deltacloud API
title: CIMI Resource Collections - Volume Template
---

<br/>

<div class="row">
  <div class="span9">

<h3 id="cimi-volume-template">Volume Template</h3>
<p>
<strong><em>
This resource captures the configuration values for realizing a Volume. A Volume Template may be used
to create multiple Volumes.
<br/>
<br/>
A Volume Template Collection resource represents the collection of VolumeTemplate resources within a
Provider.
</em></strong>
</p>

<p>The Volume Template in another example of the template pattern used by CIMI, as explained in the introduction of the <a href="/cimi-rest/cimi-rest-machine-templates.html">Machine Template</a> resource. That is, in general, CIMI a resource is instantiated with the use of a template and a template itself usually consists of an image and a configuration.</p>
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
    <li><a href="/cimi-rest/cimi-rest-volume-images.html">VolumeImage</a></li>
    <li><a href="/cimi-rest/cimi-rest-volume-configs.html">VolumeConfiguration</a></li>
    <li class="active"><a href="/cimi-rest/cimi-rest-volume-templates.html">VolumeTemplate</a></li>
  </ul>

</ul>

  </div>

</div>

<ul class="nav nav-pills">
  <li class="active"><a href="#volume-template-collection" data-toggle="tab">Retrieve the Volume Template Collection</a></li>
  <li><a href="#single-volume-template" data-toggle="tab">Retrieve a single Volume Template</a></li>
  <li><a href="#create-volume-template" data-toggle="tab">Create a Volume Template</a></li>
  <li><a href="#delete-volume-template" data-toggle="tab">Delete a Volume Template</a></li>

</ul>

<hr>

<div class="tab-content">

  <div class="tab-pane active" id="volume-template-collection">

<h4>Retrieve the Volume Template Collection</h4>

<p>Example request:</p>

<pre>
GET /cimi/volume_templates HTTP/1.1
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
Content-Length: 1045
ETag: 3ca6eecb1450ebe3a9fa6714bff542c1
Cache-Control: max-age=0, private, must-revalidate
Date: Fri, 11 Jan 2013 13:02:47 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;Collection xmlns="http://schemas.dmtf.org/cimi/1"
          resourceURI="http://schemas.dmtf.org/cimi/1/VolumeTemplateCollection"&gt;
  &lt;id&gt;http://localhost:3001/cimi/volume_templates&lt;/id&gt;
  &lt;count&gt;2&lt;/count&gt;
  &lt;VolumeTemplate&gt;
    &lt;id&gt;http://localhost:3001/cimi/volume_templates/3&lt;/id&gt;
    &lt;name&gt;marios_vol_template&lt;/name&gt;
    &lt;description&gt;my first volume template&lt;/description&gt;
    &lt;volumeConfig href="http://localhost:3001/cimi/volume_configs/1" /&gt;
    &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/delete"
          href="http://localhost:3001/cimi/volume_templates/3" /&gt;
  &lt;/VolumeTemplate&gt;
  &lt;VolumeTemplate&gt;
    &lt;id&gt;http://localhost:3001/cimi/volume_templates/4&lt;/id&gt;
    &lt;name&gt;YAVT&lt;/name&gt;
    &lt;description&gt;yet another volume template&lt;/description&gt;
    &lt;volumeConfig href="http://localhost:3001/cimi/volume_configs/6" /&gt;
    &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/delete"
          href="http://localhost:3001/cimi/volume_templates/4" /&gt;
  &lt;/VolumeTemplate&gt;
  &lt;operation rel="add" href="http://localhost:3001/cimi/volume_templates" /&gt;
&lt;/Collection&gt;
</pre>

  </div>

  <div class="tab-pane" id="single-volume-template">

<h4>Retrieve a single Volume Template</h4>

<p>Example request:</p>

<pre>
GET /cimi/volume_templates/3 HTTP/1.1
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
Content-Length: 470
ETag: a527b1170f798affc88a0ea0fa4ede7a
Cache-Control: max-age=0, private, must-revalidate
Date: Fri, 11 Jan 2013 13:05:42 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;VolumeTemplate xmlns="http://schemas.dmtf.org/cimi/1"
          resourceURI="http://schemas.dmtf.org/cimi/1/VolumeTemplate"&gt;
  &lt;id&gt;http://localhost:3001/cimi/volume_templates/3&lt;/id&gt;
  &lt;name&gt;marios_vol_template&lt;/name&gt;
  &lt;description&gt;my first volume template&lt;/description&gt;
  &lt;volumeConfig href="http://localhost:3001/cimi/volume_configs/1" /&gt;
  &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/delete"
          href="http://localhost:3001/cimi/volume_templates/3" /&gt;
&lt;/VolumeTemplate&gt;
</pre>

  </div>
  <div class="tab-pane" id="create-volume-template">

<h4>Create a Volume Template</h4>

<p>Example request:</p>

<pre>
POST /cimi/volume_templates HTTP/1.1
Authorization: Basic bW9ja3VzZXI6bW9ja3Bhc3N3b3Jk
User-Agent: curl/7.24.0 (i686-redhat-linux-gnu)
Host: localhost:3001
Content-Type: application/xml
Accept: application/xml
Content-Length: 232

&lt;VolumeTemplate xmlns="http://schemas.dmtf.org/cimi/1"&gt;
  &lt;name&gt; YAVT &lt;/name&gt;
  &lt;description&gt; yet another volume template &lt;/description&gt;
  &lt;volumeConfig href="http://localhost:3001/cimi/volume_configs/6"&gt; &lt;/volumeConfig&gt;
&lt;/VolumeTemplate&gt;
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 201 Created
Content-Type: application/xml
Location: http://localhost:3001/cimi/volume_templates/5
CIMI-Specification-Version: 1.0.1
Content-Length: 458
ETag: 66d7d08c49a5e81923ac124d71af50ad
Cache-Control: max-age=0, private, must-revalidate
Date: Fri, 11 Jan 2013 13:07:00 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;VolumeTemplate xmlns="http://schemas.dmtf.org/cimi/1"
          resourceURI="http://schemas.dmtf.org/cimi/1/VolumeTemplate"&gt;
  &lt;id&gt;http://localhost:3001/cimi/volume_templates/5&lt;/id&gt;
  &lt;name&gt;YAVT&lt;/name&gt;
  &lt;description&gt;yet another volume template&lt;/description&gt;
  &lt;volumeConfig href="http://localhost:3001/cimi/volume_configs/6" /&gt;
  &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/delete"
          href="http://localhost:3001/cimi/volume_templates/5" /&gt;
&lt;/VolumeTemplate&gt;
</pre>

  </div>
  <div class="tab-pane" id="delete-volume-template">

<h4>Delete a Volume Template</h4>

<p>Example request:</p>

<pre>
DELETE /cimi/volume_templates/5 HTTP/1.1
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
Date: Fri, 11 Jan 2013 13:07:34 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife
</pre>

  </div>
</div>
