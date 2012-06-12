---
site_name: Deltacloud API
title: Addresses
---

<br/>

<div class="row">
  <div class="span9">

<h3 id="addresses">Addresses</h3>

<p>
The addresses collection represents IP addresses and allows <strong>IP address management</strong>. 
</p>

<p>
This collection is currently implemented for the Amazon EC2 cloud driver. For EC2, IP address management corresponds to Amazon's 'Elastic IP' feature. 
</p>

<br/>

<p>
The addresses collection supports these operations:
</p>

<ul>
  <li>creating an address</li>
  <li>destroying an address</li>
  <li>association an address with a running instance</li>
  <li>dissociating an address from a running instance</li>
</ul>

<br/>
<br/>

<ul class="nav nav-pills">
  <li class="active"><a href="#tab1" data-toggle="tab">Get a list of all addresses</a></li>
  <li><a href="#tab2" data-toggle="tab">Get the details of an address</a></li>
  <li><a href="#tab3" data-toggle="tab">Create/delete an address</a></li>
  <li><a href="#tab4" data-toggle="tab">Associate/disassociate an address</a></li>
</ul>

<hr>

  </div>
  <div class="span3">

<ul class="nav nav-list well">
  <li class="nav-header">
    REST API
  </li>
  <li><a href="/rest-api.html">Introduction</a></li>
  <li><a href="/api-entry-point.html">API entry point</a></li>
  <li><a href="/compute-resources.html">Compute resources</a></li>
  <ul class="nav nav-list">
    <li><a href="/compute-resources.html">Realms</a></li>
    <li><a href="/hardware-profiles.html">Hardware profiles</a></li>
    <li><a href="/images.html">Images</a></li>
    <li><a href="/instance-states.html">Instance states</a></li>
    <li><a href="/instances.html">Instances</a></li>
    <li><a href="/keys.html">Keys</a></li>
    <li><a href="/firewalls.html">Firewalls</a></li>
    <li class="active"><a href="#addresses">Addresses</a></li>
    <li><a href="/load-balancers.html">Load balancers</a></li>
  </ul>
  <li><a href="/storage-resources.html">Storage resources</a></li>
</ul>

  </div>
</div>

<div class="tab-content">
  <div class="tab-pane active" id="tab1">
  
<h4>Get a list of all addresses</h4>

<p>
To retrieve a list of all addresses use call <strong>GET /api/addresses</strong>.
</p>

<p>
Example request:
</p>

<pre>
GET /api/addresses?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
</pre>

<p>
Server response:
</p>


<pre style="margin-top:0px">
HTTP/1.1 200 OK
Content-Type: application/xml
Date: Wed, 27 Jul 2011 12:55:16 GMT
Content-Length: 817

&lt;?xml version='1.0' encoding='utf-8' ?&gt;
&lt;addresses&gt;
  &lt;address href='http://localhost:3001/api/addresses/107.20.232.251' id='107.20.232.251'&gt;
    &lt;ip&gt;107.20.232.251&lt;/ip&gt;
    &lt;actions&gt;
      &lt;link href='http://localhost:3001/api/addresses/107.20.232.251' method='delete' rel='destroy' /&gt;
      &lt;link href='http://localhost:3001/api/addresses/107.20.232.251/associate' method='post' rel='associate' /&gt;
    &lt;/actions&gt;
  &lt;/address&gt;
  &lt;address href='http://localhost:3001/api/addresses/107.20.234.161' id='107.20.234.161'&gt;
    &lt;ip&gt;107.20.234.161&lt;/ip&gt;
    &lt;actions&gt;
      &lt;link href='http://localhost:3001/api/addresses/107.20.234.161' method='delete' rel='destroy' /&gt;
      &lt;link href='http://localhost:3001/api/addresses/107.20.234.161/associate' method='post' rel='associate' /&gt;
    &lt;/actions&gt;
  &lt;/address&gt;
&lt;/addresses&gt;
</pre>

  </div>
  <div class="tab-pane" id="tab2">

<h4>Get the details of an address</h4>

<p>
To retrieve details for a specific address use call <strong>GET /api/addresses/:id</strong>.
</p>

<p>Example request:</p>

<pre>
GET /api/addresses/107.20.232.251?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 200 OK
Content-Type: application/xml
Date: Wed, 27 Jul 2011 12:57:27 GMT
Content-Length: 402

&lt;?xml version='1.0' encoding='utf-8' ?&gt;
&lt;address href='http://localhost:3001/api/addresses/107.20.232.251' id='107.20.232.251'&gt;
  &lt;ip&gt;107.20.232.251&lt;/ip&gt;
  &lt;actions&gt;
    &lt;link href='http://localhost:3001/api/addresses/107.20.232.251' method='delete' rel='destroy' /&gt;
    &lt;link href='http://localhost:3001/api/addresses/107.20.232.251/associate' method='post' rel='associate' /&gt;
  &lt;/actions&gt;
&lt;/address&gt;
</pre>

  </div>
  <div class="tab-pane" id="tab3">

<h4>Create an address</h4>

<p>
To create a new address use call <strong>POST /api/addresses</strong>. The Deltacloud server will respond with <strong>HTTP 201 Created</strong> and provide the details of the new address after a succesful operation:
</p>

<p>Example request:</p>

<pre>
POST /api/addresses?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 201 Created
Content-Type: application/xml
Content-Length: 388

&lt;?xml version='1.0' encoding='utf-8' ?&gt;
&lt;address href='http://localhost:3001/api/addresses/107.20.232.251' id='107.20.232.251'&gt;
  &lt;ip&gt;107.20.232.251&lt;/ip&gt;
  &lt;actions&gt;
    &lt;link href='http://localhost:3001/api/addresses/107.20.232.251' method='delete' rel='destroy' /&gt;
    &lt;link href='http://localhost:3001/api/addresses/107.20.232.251/associate' method='post' rel='associate' /&gt;
  &lt;/actions&gt;
&lt;/address&gt;
</pre>

<h4>Delete an address</h4>

<p>
To delete a specified address use call <strong>DELETE /api/addresses/:id</strong>. The Deltacloud server responds with a <strong>HTTP 204 No Content</strong> after a succesful operation.
</p>

<p>Example request:</p>

<pre>
DELETE /api/addresses/107.20.232.251?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 204 No Content
Date: Wed, 27 Jul 2011 13:29:00 GMT
</pre>

  </div>
  <div class="tab-pane" id="tab4">

<h4>Associate an adress with an instance</h4>

<p>
To associate a given address with a running instance use call <strong>POST /api/addresses/:id/associate</strong>. The client must specify the <strong>instance_id</strong> as a parameter to this call. For Amazon EC2, the specified address will replace the currently assigned public_address of the instance. A succesful operation results in a <strong>HTTP 202 Accepted</strong> response. The example client request below specifies the required instance_id parameter using the application/x-www-form-urlencoded content-type, however client can also use multipart/form-data.
</p>

<p>Example request:</p>

<pre>
POST /api/addresses/107.20.232.251/associate?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
Content-Length: 22
Content-Type: application/x-www-form-urlencoded

instance_id=i-9d8a3dfc
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 202 Accepted
Content-Type: application/xml
Date: Wed, 27 Jul 2011 13:01:11 GMT
Content-Length: 0
</pre>

<h4>Disassociate an address from an instance</h4>

<p>
To disassociate a given address from the instance to which it is currently assigned use call <strong>POST /api/addresses/:id/disassociate</strong>.
</p>

<p>Example request:</p>

<pre>
POST /api/addresses/107.20.232.251/disassociate?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 202 Accepted
Content-Type: application/xml
Date: Wed, 27 Jul 2011 13:05:38 GMT
Content-Length: 0
</pre>

  </div>
</div>

<a class="btn btn-inverse btn-large" style="float: right" href="/load-balancers.html">Load Balancers  <i class="icon-arrow-right icon-white" style="vertical-align:baseline"> </i></a>

<br/>

