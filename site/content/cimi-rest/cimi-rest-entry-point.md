---
site_name: Deltacloud API
title: CIMI Cloud Entry Point
---

<br/>

<div class="row">
  <div class="span9">

<h3 id="cimi-entry-point">The CIMI Cloud Entry Point</h3>

<p>
<strong><em>The Cloud Entry Point represents the entry point into the cloud defined by the CIMI Model. The Cloud
Entry Point implements a catalog of resources, such as Systems, System Templates, Machines, Machine
Templates, etc., that can be queried and browsed by the Consumer.</em></strong>
</p>
<p>
A deltacloud server exposes the CIMI Cloud Entry Point at /cimi/cloudEntryPoint. When dereferencing this URI, the resources listed in the response include only those that are supported by the current deltacloud driver - whether the 'default' driver the server was started with, or that specified with the <a href="/drivers.html">X-Deltacloud-Driver</a> header.
</p>

 </div>

  <div class="span3">

<ul class="nav nav-list well">
  <li class="nav-header">
    CIMI REST API
  </li>
  <li><a href="/cimi-rest.html">Introduction</a></li>
  <li class="active"><a href="/cimi-rest/cimi-rest-entry-point.html">Cloud Entry Point</a></li>
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

</ul>

  </div>

</div>

<p>
Example request:
</p>
<pre>
 GET /cimi/cloudEntryPoint HTTP/1.1
 Authorization: Basic bW9ja3VzZXI6bW9ja3Bhc3N3b3Jk
 User-Agent: curl/7.24.0 (i686-redhat-linux-gnu)
 Host: localhost:3001
 Accept: application/xml
</pre>

<p>
Example response:
</p>

<pre>
HTTP/1.1 200 OK
Content-Type: application/xml
CIMI-Specification-Version: 1.0.1
Content-Length: 1754
ETag: 503bc06f24d1a51eddc62b33b870c70f
Cache-Control: max-age=0, private, must-revalidate
Date: Thu, 27 Dec 2012 15:23:23 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;CloudEntryPoint xmlns="http://schemas.dmtf.org/cimi/1" resourceURI="http://schemas.dmtf.org/cimi/1/CloudEntryPoint"&gt;
  &lt;id&gt;http://localhost:3001/cimi/cloudEntryPoint&lt;/id&gt;
  &lt;name&gt;mock&lt;/name&gt;
  &lt;description&gt;Cloud Entry Point for the Deltacloud mock driver&lt;/description&gt;
  &lt;created&gt;2012-12-27T17:23:23+02:00&lt;/created&gt;
  &lt;baseURI&gt;http://localhost:3001/cimi/&lt;/baseURI&gt;
  &lt;resourceMetadata href="http://localhost:3001/cimi/resource_metadata" /&gt;
  &lt;machines href="http://localhost:3001/cimi/machines" /&gt;
  &lt;machineTemplates href="http://localhost:3001/cimi/machine_templates" /&gt;
  &lt;machineImages href="http://localhost:3001/cimi/machine_images" /&gt;
  &lt;credentials href="http://localhost:3001/cimi/credentials" /&gt;
  &lt;volumes href="http://localhost:3001/cimi/volumes" /&gt;
  &lt;volumeImages href="http://localhost:3001/cimi/volume_images" /&gt;
  &lt;networks href="http://localhost:3001/cimi/networks" /&gt;
  &lt;networkTemplates href="http://localhost:3001/cimi/network_templates" /&gt;
  &lt;networkPorts href="http://localhost:3001/cimi/network_ports" /&gt;
  &lt;networkPortTemplates href="http://localhost:3001/cimi/network_port_templates" /&gt;
  &lt;addresses href="http://localhost:3001/cimi/addresses" /&gt;
  &lt;addressTemplates href="http://localhost:3001/cimi/address_templates" /&gt;
  &lt;forwardingGroups href="http://localhost:3001/cimi/forwarding_groups" /&gt;
  &lt;forwardingGroupTemplates href="http://localhost:3001/cimi/forwarding_group_templates" /&gt;
  &lt;volumeConfigs href="http://localhost:3001/cimi/volume_configurations" /&gt;
  &lt;machineConfigs href="http://localhost:3001/cimi/machine_configurations" /&gt;
  &lt;networkConfigs href="http://localhost:3001/cimi/network_configurations" /&gt;
  &lt;networkPortConfigs href="http://localhost:3001/cimi/network_port_configurations" /&gt;
&lt;/CloudEntryPoint&gt;
</pre>
