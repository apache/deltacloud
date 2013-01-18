---
site_name: Deltacloud API
title: CIMI Resource Collections - Volume Configuration
---

<br/>

<div class="row">
  <div class="span9">

<h3 id="cimi-volume-config">Volume Configuration</h3>
<p>
<strong><em>
The Volume Configuration resource represents the set of configuration values needed to create a Volume
with certain characteristics. Volume Configurations are created by Providers and may, at the Providers
discretion, be created by Consumers.
<br/>
<br/>
A Volume Configuration Collection resource represents the collection of Volume Configuration resources
within a Provider.
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
      <li><a href="/cimi-rest/cimi-rest-resource-metadata.html">Resource Metadata</a></li>
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
    <li class="active"><a href="/cimi-rest/cimi-rest-volume-configs.html">VolumeConfiguration</a></li>
    <li><a href="/cimi-rest/cimi-rest-volume-templates.html">VolumeTemplate</a></li>
  </ul>

</ul>

  </div>

</div>


<ul class="nav nav-pills">
  <li class="active"><a href="#volume-config-collection" data-toggle="tab">Retrieve the Volume Configuration Collection</a></li>
  <li><a href="#single-volume-config" data-toggle="tab">Retrieve a single Volume Configuration</a></li>
  <li><a href="#create-volume-config" data-toggle="tab">Create a Volume Configuration</a></li>
  <li><a href="#delete-volume-config" data-toggle="tab">Delete a Volume Configuration</a></li>
</ul>

<hr>

<div class="tab-content">

  <div class="tab-pane active" id="volume-config-collection">

<h4>Retrieve the Volume Configuration Collection</h4>

<p>Example request:</p>

<pre>
GET /cimi/volume_configurations HTTP/1.1
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
Content-Length: 1112
ETag: 5aee339b405efd86f41f33105c62623e
Cache-Control: max-age=0, private, must-revalidate
Date: Wed, 09 Jan 2013 16:08:51 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;Collection xmlns="http://schemas.dmtf.org/cimi/1"
          resourceURI="http://schemas.dmtf.org/cimi/1/VolumeConfigurationCollection"&gt;
  &lt;id&gt;http://localhost:3001/cimi/volume_configurations&lt;/id&gt;
  &lt;count&gt;2&lt;/count&gt;
  &lt;VolumeConfiguration&gt;
    &lt;id&gt;http://localhost:3001/cimi/volume_configurations/6&lt;/id&gt;
    &lt;name&gt;marios_volume_config&lt;/name&gt;
    &lt;description&gt;a volume configuration&lt;/description&gt;
    &lt;format&gt;qcow2&lt;/format&gt;
    &lt;capacity&gt;10485760&lt;/capacity&gt;
    &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/delete"
          href="http://localhost:3001/cimi/volume_configurations/6" /&gt;
  &lt;/VolumeConfiguration&gt;
  &lt;VolumeConfiguration&gt;
    &lt;id&gt;http://localhost:3001/cimi/volume_configurations/7&lt;/id&gt;
    &lt;name&gt;YAVC&lt;/name&gt;
    &lt;description&gt; yet another volume configuration&lt;/description&gt;
    &lt;format&gt;ext3&lt;/format&gt;
    &lt;capacity&gt;1073741824&lt;/capacity&gt;
    &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/delete"
          href="http://localhost:3001/cimi/volume_configurations/7" /&gt;
  &lt;/VolumeConfiguration&gt;
  &lt;operation rel="add" href="http://localhost:3001/cimi/volume_configurations" /&gt;
&lt;/Collection&gt;
</pre>

  </div>

  <div class="tab-pane" id="single-volume-config">

<h4>Retrieve a single Volume Configuration</h4>

<p>Example request:</p>

<pre>
GET /cimi/volume_configurations/2 HTTP/1.1
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
Content-Length: 386
ETag: 72e733ff826d0a3e486df8de3fe8c57c
Cache-Control: max-age=0, private, must-revalidate
Date: Thu, 10 Jan 2013 08:51:03 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;VolumeConfiguration xmlns="http://schemas.dmtf.org/cimi/1"
          resourceURI="http://schemas.dmtf.org/cimi/1/VolumeConfiguration"&gt;
  &lt;id&gt;http://localhost:3001/cimi/volume_configurations/2&lt;/id&gt;
  &lt;name&gt;volume-2&lt;/name&gt;
  &lt;description&gt;Volume configuration with 2097152 kibibytes&lt;/description&gt;
  &lt;created&gt;2013-01-10T10:51:03+02:00&lt;/created&gt;
  &lt;capacity&gt;2097152&lt;/capacity&gt;
&lt;/VolumeConfiguration&gt;
</pre>

  </div>
  <div class="tab-pane" id="create-volume-config">

<h4>Create a Volume Configuration</h4>

<p>Example request:</p>
<pre>
POST /cimi/volume_configurations HTTP/1.1
Authorization: Basic bW9ja3VzZXI6bW9ja3Bhc3N3b3Jk
User-Agent: curl/7.24.0 (i686-redhat-linux-gnu)
Host: localhost:3001
Content-Type: application/xml
Accept: application/xml
Content-Length: 183

&lt;VolumeConfigurationCreate&gt;
  &lt;name&gt;marios_volume_config&lt;/name&gt;
  &lt;description&gt;a volume configuration&lt;/description&gt;
  &lt;format&gt;qcow2&lt;/format&gt;
  &lt;capacity&gt;10&lt;/capacity&gt;
&lt;/VolumeConfigurationCreate&gt;
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 201 Created
Content-Type: application/xml
Location: http://localhost:3001/cimi/volume_configurations/6
CIMI-Specification-Version: 1.0.1
Content-Length: 481
ETag: 536caa3e459fc2aa9a0796f317317369
Cache-Control: max-age=0, private, must-revalidate
Date: Fri, 11 Jan 2013 13:25:35 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;VolumeConfiguration xmlns="http://schemas.dmtf.org/cimi/1"
          resourceURI="http://schemas.dmtf.org/cimi/1/VolumeConfiguration"&gt;
  &lt;id&gt;http://localhost:3001/cimi/volume_configurations/6&lt;/id&gt;
  &lt;name&gt;marios_volume_config&lt;/name&gt;
  &lt;description&gt;a volume configuration&lt;/description&gt;
  &lt;format&gt;qcow2&lt;/format&gt;
  &lt;capacity&gt;10485760&lt;/capacity&gt;
  &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/delete"
          href="http://localhost:3001/cimi/volume_configurations/6" /&gt;
&lt;/VolumeConfiguration&gt;
</pre>

  </div>

  <div class="tab-pane" id="delete-volume-config">

<h4>Delete a Volume Configuration</h4>

<p>Example request:</p>

<pre>
DELETE /cimi/volume_configurations/7 HTTP/1.1
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
Date: Fri, 11 Jan 2013 13:27:35 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife
</pre>
  </div>

</div>
