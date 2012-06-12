---
site_name: Deltacloud API
title: Compute resources
---
<br/>

<div class="row">
  <div class="span9">

<h3 id="compute">Compute Resources</h3>

<p>
The compute resources are: instances, instance states, images, realms, hardware profiles, firewalls, load balancers, addresses and keys.
</p>

<h3 id="realms">Realms</h3>

<p>
A realm represents a boundary containing resources, such as a data center. The exact definition of a realm is given by the cloud provider. In some cases, a realm may represent different datacenters, different continents or different pools of resources within a single datacenter. A cloud provider may insist that all the resources exist within a single realm in order to cooperate. For instance, storage volumes may only be allowed to be mounted to instances within the same realm. Generally speaking, going from one realm to another within the same cloud may change many aspects of the cloud, such as SLA’s, pricing terms, etc.
</p>

<h4>Get a list of all realms</h4>

<p>
To list all realms use call <strong>GET /api/realms</strong>. You can filter the list by adding a request parameter <strong>architecture</strong> to the realms that support a specific architecture, such as <strong>i386</strong>. The example below shows the retrieval of all realms for the AWS EC2 driver, which correspond to EC2 "availability zones":
</p>

  </div>
  <div class="span3">

<ul class="nav nav-list well">
  <li class="nav-header">
    REST API
  </li>
  <li><a href="/rest-api.html">Introduction</a></li>
  <li><a href="/api-entry-point.html">API entry point</a></li>
  <li class="active"><a href="/compute-resources.html">Compute resources</a></li>
  <ul class="nav nav-list">
    <li><a href="#realms">Realms</a></li>
    <li><a href="/hardware-profiles.html">Hardware profiles</a></li>
    <li><a href="/images.html">Images</a></li>
    <li><a href="/instance-states.html">Instance states</a></li>
    <li><a href="/instances.html">Instances</a></li>
    <li><a href="/keys.html">Keys</a></li>
    <li><a href="/firewalls.html">Firewalls</a></li>
    <li><a href="/addresses.html">Addresses</a></li>
    <li><a href="/load-balancers.html">Load balancers</a></li>
  </ul>
  <li><a href="/storage-resources.html">Storage resources</a></li>
</ul>

  </div>
</div>

<p>Example request:</p>

<pre>
GET /api/realms?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 200 OK
Content-Type: application/xml
Content-Length: 639
&lt;?xml version='1.0' encoding='utf-8' ?&gt;
&lt;realms&gt;
  &lt;realm href='http://localhost:3001/api/realms/us-east-1a' id='us-east-1a'&gt;
    &lt;name&gt;us-east-1a&lt;/name&gt;
    &lt;state&gt;available&lt;/state&gt;
  &lt;/realm&gt;
  &lt;realm href='http://localhost:3001/api/realms/us-east-1b' id='us-east-1b'&gt;
    &lt;name&gt;us-east-1b&lt;/name&gt;
    &lt;state&gt;available&lt;/state&gt;
  &lt;/realm&gt;
  &lt;realm href='http://localhost:3001/api/realms/us-east-1c' id='us-east-1c'&gt;
    &lt;name&gt;us-east-1c&lt;/name&gt;
    &lt;state&gt;available&lt;/state&gt;
  &lt;/realm&gt;
  &lt;realm href='http://localhost:3001/api/realms/us-east-1d' id='us-east-1d'&gt;
    &lt;name&gt;us-east-1d&lt;/name&gt;
    &lt;state&gt;available&lt;/state&gt;
  &lt;/realm&gt;
&lt;/realms&gt;
</pre>

<h4>Get the details of a realm</h4>

<p>
To provide the details of a realm use call <strong>GET /api/realms/:id</strong>. The server responds with a <strong>name</strong>, a <strong>state</strong> and a <strong>limit</strong> applicable to the current requester. The name is an arbitrary label with no specific meaning in the API. The <strong>state</strong> can be either <strong>AVAILABLE</strong> or <strong>UNAVAILABLE</strong>. 
</p>

<p>
The example below shows the realm for the Rackspace driver. Since Rackspace does not currently have a notion of realms, the Deltacloud Rackspace driver provides a single realm called 'US', signifying that all compute resources for that cloud provider are hosted in the United States:
</p>

<p>Example request:</p>

<pre>
GET /api/realms/us?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3002
Accept: */*
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 200 OK
Content-Type: application/xml
Content-Length: 182

&lt;?xml version='1.0' encoding='utf-8' ?&gt;
&lt;realm href='http://localhost:3001/api/realms/us' id='us'&gt;
    &lt;name&gt;United States&lt;/name&gt;
    &lt;state&gt;AVAILABLE&lt;/state&gt;
    &lt;limit&gt;&lt;/limit&gt;
&lt;/realm&gt;
</pre>

<a class="btn btn-inverse btn-large" style="float: right" href="/hardware-profiles.html">Hardware profiles <i class="icon-arrow-right icon-white" style="vertical-align:baseline"> </i></a>

<br/>
