---
site_name: Deltacloud API
title: CIMI REST Examples
---

<br/>

<div class="row">
  <div class="span9">

<h3 id="rest">The CIMI REST API</h3>

<p>
Apache Deltacloud exposes the DMTF <a href="http://dmtf.org/cloud">Cloud Infrastructure Management Interface</a> (CIMI) as an alternative to the native <a href="/rest-api.html">Deltacloud API</a>. This means that clients can 'speak' the CIMI API to a Deltacloud server on the frontend, managing resources in any of the backend cloud providers <a href="/drivers.html#drivers">supported by Deltacloud</a>.
</p>


<div class="alert alert-error">
  <strong>Note: </strong>
  <p>
    This is <strong> NOT </strong> a definitive guide to the DMTF CIMI specification. The full CIMI spec is available from the DMTF <a href="http://dmtf.org/cloud">Cloud Management Initiative</a> (DSP0263).
  </p>
</div>

 </div>

  <div class="span3">


<ul class="nav nav-list well">
  <li class="nav-header">
    CIMI REST API
  </li>
  <li class="active"><a href="/cimi-rest.html">Introduction</a></li>
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

</ul>

  </div>

</div>
<p>
This page shows examples of interactions with the CIMI interface exposed by a Deltacloud server. The examples here cover the CIMI resources and collections that are currently supported in Deltacloud; we are constantly improving our CIMI implementation. If you come across any bugs or inconsistencies we'd be very happy to <a href="/contact.html">hear about them</a>.
</p>


<p>
In the following sections, the textual definitions following the title of each resource (e.g. "Machine") that are rendered in <strong><em>bold and italic type</em></strong> are taken from the CIMI 1.0.1 specification, available from the DMTF <a href="http://dmtf.org/cloud">Cloud Management Initiative</a> (DSP0263).
</p>

<hr>

<h3 id="cimi_rest_introduction">Starting Deltacloud with the CIMI interface</h3>

The <strong> --frontends (-f)</strong> flag is used to specify which frontends a deltacloud server should expose:
<br/>
<br/>
<pre>

[user@name ~]$ deltacloudd -i ec2 -f cimi
Starting Deltacloud API :: ec2 :: http://localhost:3001/cimi/cloudEntryPoint

>> Thin web server (v1.5.0 codename Knife)
>> Debugging ON
>> Maximum connections set to 1024
>> Listening on localhost:3001, CTRL+C to stop

</pre>
<br/>
The example above shows the deltacloud server with the CIMI interface and the EC2 driver. You can even expose both the deltacloud and the CIMI frontends with a single server, e.g. <strong> -f cimi,deltacloud </strong>.

As can be seen above, starting deltacloud in this way will expose the CIMI <a href="/cimi-rest-entry-point.html">cloud entry point</a> at localhost:3001/cimi/cloudEntryPoint.

