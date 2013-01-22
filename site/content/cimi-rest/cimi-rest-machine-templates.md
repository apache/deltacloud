---
site_name: Deltacloud API
title: CIMI Resource Collections - Machine Template
---

<br/>

<div class="row">
  <div class="span9">

<h3 id="cimi-machine-template">Machine Template</h3>
<p>
<strong><em>
A Machine Template represents the set of metadata and instructions used in the creation of a Machine.

A Machine Template Collection resource represents the collection of Machine Template resources within
a Provider.
</em></strong>
</p>

<p>
The CIMI specification follows a distinctive pattern with respect to creation of new resources - the machine template is a good example of this:
</p>

<pre>
machineConfiguration + machineImage = machineTemplate ===> machine
</pre>

<p>
A CIMI client (a <strong>consumer</strong> in CIMI terminology) uses a Machine Template to <a href="/cimi-rest/cimi-rest-collections.html#create-machine"> create a new Machine</a>; a Machine Template consists of (amongst other attributes) a Machine Configuration and a Machine Image. Generally speaking - many CIMI resources require use of a template for their creation and a template will typically consist of an image plus a configuration resource.
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
    Machine Resources
  </li>
  <ul class="nav nav-list">
    <li><a href="/cimi-rest/cimi-rest-collections.html">Machine</a></li>
    <li><a href="/cimi-rest/cimi-rest-machine-images.html">MachineImage</a></li>
    <li><a href="/cimi-rest/cimi-rest-machine-configs.html">MachineConfiguration</a></li>
    <li class="active"><a href="/cimi-rest/cimi-rest-machine-templates.html">MachineTemplate</a></li>
  </ul>

</ul>

  </div>

</div>

<ul class="nav nav-pills">
  <li class="active"><a href="#template-collection" data-toggle="tab">Retrieve the Machine Template Collection</a></li>
  <li><a href="#single-template" data-toggle="tab">Retrieve a single Machine Template</a></li>
  <li><a href="#create-template" data-toggle="tab">Create a new Machine Template</a></li>
  <li><a href="#delete-template" data-toggle="tab">Delete a Machine Template</a></li>
</ul>

<hr>

<div class="tab-content">
  <div class="tab-pane active" id="template-collection">

<h4>Retrieve the Machine Template Collection</h4>
<p>Example request:</p>
<pre>
GET /cimi/machine_templates HTTP/1.1
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
Content-Length: 1275
ETag: fba471ae32eca2b58fa02644b81b73aa
Cache-Control: max-age=0, private, must-revalidate
Date: Thu, 03 Jan 2013 15:04:26 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;Collection xmlns="http://schemas.dmtf.org/cimi/1"
          resourceURI="http://schemas.dmtf.org/cimi/1/MachineTemplateCollection"&gt;
  &lt;id&gt;http://localhost:3001/cimi/machine_templates&lt;/id&gt;
  &lt;count&gt;2&lt;/count&gt;
  &lt;MachineTemplate&gt;
    &lt;id&gt;http://localhost:3001/cimi/machine_templates/1&lt;/id&gt;
    &lt;name&gt;myXmlTestMachineTemplate1&lt;/name&gt;
    &lt;description&gt;Description of my MachineTemplate&lt;/description&gt;
    &lt;property key="test"&gt;value&lt;/property&gt;
    &lt;machineConfig href="http://localhost:3001/cimi/machine_configurations/m1-xlarge" /&gt;
    &lt;machineImage href="http://localhost:3001/cimi/machine_images/img3" /&gt;
    &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/delete"
          href="http://localhost:3001/cimi/machine_templates/1" /&gt;
  &lt;/MachineTemplate&gt;
  &lt;MachineTemplate&gt;
    &lt;id&gt;http://localhost:3001/cimi/machine_templates/2&lt;/id&gt;
    &lt;name&gt;my_template_2&lt;/name&gt;
    &lt;description&gt;Description of my MachineTemplate&lt;/description&gt;
    &lt;property key="test"&gt;value&lt;/property&gt;
    &lt;machineConfig href="http://localhost:3001/cimi/machine_configurations/m1-small" /&gt;
    &lt;machineImage href="http://localhost:3001/cimi/machine_images/img1" /&gt;
    &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/delete"
          href="http://localhost:3001/cimi/machine_templates/2" /&gt;
  &lt;/MachineTemplate&gt;
&lt;/Collection&gt;
</pre>
  </div>

  <div class="tab-pane" id="single-template">

<h4>Retrieve a single Machine Template</h4>
<p>Example request:</p>
<pre>
GET /cimi/machine_templates/2 HTTP/1.1
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
Content-Length: 607
ETag: 8f720ffacb6439a6920a5f5b0ec7bbfc
Cache-Control: max-age=0, private, must-revalidate
Date: Thu, 03 Jan 2013 15:06:14 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;MachineTemplate xmlns="http://schemas.dmtf.org/cimi/1"
          resourceURI="http://schemas.dmtf.org/cimi/1/MachineTemplate"&gt;
  &lt;id&gt;http://localhost:3001/cimi/machine_templates/2&lt;/id&gt;
  &lt;name&gt;my_template_2&lt;/name&gt;
  &lt;description&gt;Description of my MachineTemplate&lt;/description&gt;
  &lt;property key="test"&gt;value&lt;/property&gt;
  &lt;machineConfig href="http://localhost:3001/cimi/machine_configurations/m1-small" /&gt;
  &lt;machineImage href="http://localhost:3001/cimi/machine_images/img1" /&gt;
  &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/delete"
          href="http://localhost:3001/cimi/machine_templates/2" /&gt;
&lt;/MachineTemplate&gt;
</pre>
  </div>

  <div class="tab-pane" id="create-template">

<h4>Create a new Machine Template</h4>
<p>Example request:</p>
<pre>
POST /cimi/machine_templates HTTP/1.1
Authorization: Basic bW9ja3VzZXI6bW9ja3Bhc3N3b3Jk
User-Agent: curl/7.24.0 (i686-redhat-linux-gnu)
Host: localhost:3001
Content-Type: application/xml
Accept: application/xml
Content-Length: 334

&lt;MachineTemplateCreate&gt;
  &lt;name&gt;myXmlTestMachineTemplate1&lt;/name&gt;
  &lt;description&gt;Description of my MachineTemplate&lt;/description&gt;
  &lt;property key="test"&gt;value&lt;/property&gt;
  &lt;machineConfig href="http://localhost:3001/cimi/machine_configurations/m1-xlarge"/&gt;
  &lt;machineImage href="http://localhost:3001/cimi/machine_images/img3"/&gt;
&lt;/MachineTemplateCreate&gt;
</pre>

<p>Server response:</p>
<pre>
HTTP/1.1 201 Created
Content-Type: application/xml
Location: http://localhost:3001/cimi/machine_templates/1
CIMI-Specification-Version: 1.0.1
Content-Length: 620
ETag: e848e33fa0886e6c3d2df3cb674485d7
Cache-Control: max-age=0, private, must-revalidate
Date: Thu, 03 Jan 2013 14:48:03 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;MachineTemplate xmlns="http://schemas.dmtf.org/cimi/1" resourceURI="http://schemas.dmtf.org/cimi/1/MachineTemplate"&gt;
  &lt;id&gt;http://localhost:3001/cimi/machine_templates/1&lt;/id&gt;
  &lt;name&gt;myXmlTestMachineTemplate1&lt;/name&gt;
  &lt;description&gt;Description of my MachineTemplate&lt;/description&gt;
  &lt;property key="test"&gt;value&lt;/property&gt;
  &lt;machineConfig href="http://localhost:3001/cimi/machine_configurations/m1-xlarge" /&gt;
  &lt;machineImage href="http://localhost:3001/cimi/machine_images/img3" /&gt;
  &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/delete" href="http://localhost:3001/cimi/machine_templates/1" /&gt;
&lt;/MachineTemplate&gt;

</pre>
  </div>

  <div class="tab-pane" id="delete-template">

<h4>Delete a Machine Template</h4>
<p>Example request:</p>
<pre>
DELETE /cimi/machine_templates/2 HTTP/1.1
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
Date: Thu, 03 Jan 2013 15:06:38 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife
</pre>
  </div>
</div>
