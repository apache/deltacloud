---
site_name: Deltacloud API
title: CIMI cURL Examples - Resource Metadata Resources
---

<br/>

<div class="row">

  <div class="span8">

    <h3 id="command">cURL examples for CIMI Resource Metadata resources</h3>

  </div>

  <div class="span4">

<ul class="nav nav-list well">
  <li class="nav-header">
    <a href="/cimi-curl.html">curl for CIMI Resources</a>
  </li>
  <ul class="nav nav-list">
    <li><a href="/cimi-curl/cimi-curl-machines.html">Machine</a></li>
    <li><a href="/cimi-curl/cimi-curl-volumes.html">Volume</a></li>
    <li class="active"><a href="/cimi-curl/cimi-curl-resource_metadata.html">ResourceMetadata</a></li>
  </ul>
  <br/>
</ul>

  </div>

</div>


  <p> Retrieve the Resource Metadata collection in xml format:<p>

  <pre>curl -v --user "mockuser:mockpassword" -H "Accept: application/xml" http://localhost:3001/cimi/resource_metadata</pre>

  <p> Retrieve the Resource Metadata resource corresponding to the Cloud Entry Point resource, in json format:</p>

  <pre>curl -v --user "mockuser:mockpassword" -H "Accept: application/xml" http://localhost:3001/cimi/resource_metadata/cloud_entry_point </pre>

  <p> Retrieve the Resource Metadata resource corresponding to the Machine resource, in xml format:</p>

  <pre>curl -v --user "mockuser:mockpassword" -H "Accept: application/json" http://localhost:3001/cimi/resource_metadata/machine </pre>
