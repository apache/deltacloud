---
site_name: Deltacloud API
title: CIMI Resource Collections - Machine Configuration
---

<br/>

<div class="row">
  <div class="span9">

<h3 id="cimi-machine-config">Machine Configuration</h3>
<p>
<strong><em>
The Machine Configuration resource represents the set of configuration values that define the (virtual)
hardware resources of a to-be-realized Machine Instance. Machine Configurations are created by
Providers and may, at the Providers discretion, be created by Consumers.

A Machine Configuration Collection resource represents the collection of Machine Configuration
resources within a Provider
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
    Machine Resources
  </li>
  <ul class="nav nav-list">
    <li><a href="/cimi-rest/cimi-rest-collections.html">Machine</a></li>
    <li><a href="/cimi-rest/cimi-rest-machine-images.html">MachineImage</a></li>
    <li class="active"><a href="/cimi-rest/cimi-rest-machine-configs.html">MachineConfiguration</a></li>
    <li><a href="/cimi-rest/cimi-rest-machine-templates.html">MachineTemplate</a></li>
  </ul>

</ul>

  </div>

</div>

<ul class="nav nav-pills">
  <li class="active"><a href="#config-collection" data-toggle="tab">Retrieve the Machine Configuration Collection</a></li>
  <li><a href="#single-config" data-toggle="tab">Retrieve a single Machine Configuration</a></li>
</ul>

<hr>

<div class="tab-content">
  <div class="tab-pane active" id="config-collection">

<h4>Retrieve the Machine Configuration Collection</h4>

<p>Example request:</p>
<pre>
GET /cimi/machine_configurations HTTP/1.1
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
Content-Length: 1504
ETag: 69348a8afa58a1c35b6cfad7c4066a9e
Cache-Control: max-age=0, private, must-revalidate
Date: Wed, 02 Jan 2013 14:12:23 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;Collection xmlns="http://schemas.dmtf.org/cimi/1"
          resourceURI="http://schemas.dmtf.org/cimi/1/MachineConfigurationCollection"&gt;
  &lt;id&gt;http://localhost:3001/cimi/machine_configurations&lt;/id&gt;
  &lt;count&gt;3&lt;/count&gt;
  &lt;MachineConfiguration&gt;
    &lt;id&gt;http://localhost:3001/cimi/machine_configurations/m1-small&lt;/id&gt;
    &lt;name&gt;m1-small&lt;/name&gt;
    &lt;description&gt;Machine Configuration with 1782579 KiB of memory and 1 CPU&lt;/description&gt;
    &lt;created&gt;2013-01-02T16:12:23+02:00&lt;/created&gt;
    &lt;cpu&gt;1&lt;/cpu&gt;
    &lt;memory&gt;1782579&lt;/memory&gt;
    &lt;disk&gt;
      &lt;capacity&gt;167772160&lt;/capacity&gt;
      &lt;format&gt;unknown&lt;/format&gt;
    &lt;/disk&gt;
  &lt;/MachineConfiguration&gt;
  &lt;MachineConfiguration&gt;
    &lt;id&gt;http://localhost:3001/cimi/machine_configurations/m1-large&lt;/id&gt;
    &lt;name&gt;m1-large&lt;/name&gt;
    &lt;description&gt;Machine Configuration with 10485760 KiB of memory and 1 CPU&lt;/description&gt;
    &lt;created&gt;2013-01-02T16:12:23+02:00&lt;/created&gt;
    &lt;cpu&gt;1&lt;/cpu&gt;
    &lt;memory&gt;10485760&lt;/memory&gt;
    &lt;disk&gt;
      &lt;capacity&gt;891289600&lt;/capacity&gt;
      &lt;format&gt;unknown&lt;/format&gt;
    &lt;/disk&gt;
  &lt;/MachineConfiguration&gt;
  &lt;MachineConfiguration&gt;
    &lt;id&gt;http://localhost:3001/cimi/machine_configurations/m1-xlarge&lt;/id&gt;
    &lt;name&gt;m1-xlarge&lt;/name&gt;
    &lt;description&gt;Machine Configuration with 12582912 KiB of memory and 4 CPU&lt;/description&gt;
    &lt;created&gt;2013-01-02T16:12:23+02:00&lt;/created&gt;
    &lt;cpu&gt;4&lt;/cpu&gt;
    &lt;memory&gt;12582912&lt;/memory&gt;
    &lt;disk&gt;
      &lt;capacity&gt;1073741824&lt;/capacity&gt;
      &lt;format&gt;unknown&lt;/format&gt;
    &lt;/disk&gt;
  &lt;/MachineConfiguration&gt;
&lt;/Collection&gt;
</pre>
  </div>


  <div class="tab-pane" id="single-config">

<h4>Retrieve a single Machine Configuration</h4>

<p>Example request:</p>
<pre>
GET /cimi/machine_configurations/m1-large HTTP/1.1
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
Content-Length: 508
ETag: 33c094bbcec51437860280fd053f1023
Cache-Control: max-age=0, private, must-revalidate
Date: Wed, 02 Jan 2013 14:20:52 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;MachineConfiguration xmlns="http://schemas.dmtf.org/cimi/1"
          resourceURI="http://schemas.dmtf.org/cimi/1/MachineConfiguration"&gt;
  &lt;id&gt;http://localhost:3001/cimi/machine_configurations/m1-large&lt;/id&gt;
  &lt;name&gt;m1-large&lt;/name&gt;
  &lt;description&gt;Machine Configuration with 10485760 KiB of memory and 1 CPU&lt;/description&gt;
  &lt;created&gt;2013-01-02T16:20:52+02:00&lt;/created&gt;
  &lt;cpu&gt;1&lt;/cpu&gt;
  &lt;memory&gt;10485760&lt;/memory&gt;
  &lt;disk&gt;
    &lt;capacity&gt;891289600&lt;/capacity&gt;
    &lt;format&gt;unknown&lt;/format&gt;
  &lt;/disk&gt;
&lt;/MachineConfiguration&gt;


</pre>
  </div>
</div>

