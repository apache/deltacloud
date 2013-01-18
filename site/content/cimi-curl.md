---
site_name: Deltacloud API
title: CIMI cURL Examples
---

<br/>

<div class="row">

  <div class="span8">

    <h3 id="command">Working with cURL against the Deltacloud CIMI frontend</h3>

    <p> The <a href="http://curl.haxx.se/docs/">cURL documentation</a> is pretty comprehensive, but the following are some general points to remember for using cURL against the Deltacloud CIMI frontend. All the examples on this page assume the Deltacloud server is running at localhost:3001: </p>

  <ul>
    <li>
      Credentials are specified with <strong> --user "name:password"  </strong>
    </li>
    <li>
      Request headers are specified with <strong> -H "header: value" </strong>.
    </li>
    <li>
      HTTP verbs are specified with <strong>-X VERB</strong>
    </li>
    <li>
      The <strong> -i </strong> flag will show you the response headers and the <strong> -v </strong> flag will show you request and response headers as well as info about cURL activity:
    </li>
  </ul>

      <pre>
curl -v -X DELETE --user "username:password" -H "Accept: application/xml" http://localhost:3001/cimi/machine_images/my_image
      </pre>

<p>
Select a CIMI resource from the right-hand navigation bar to see cURL examples for that resource.
</p>

 </div>

  <div class="span4">

<ul class="nav nav-list well">
  <li class="nav-header">
      <a href="/cimi-curl.html">curl for CIMI Resources</a>
  </li>
  <ul class="nav nav-list">
    <li><a href="/cimi-curl/cimi-curl-machines.html">Machine</a></li>
    <li><a href="/cimi-curl/cimi-curl-volumes.html">Volume</a></li>
    <li><a href="/cimi-curl/cimi-curl-resource_metadata.html">ResourceMetadata</a></li>
  </ul>
  <br/>
</ul>

  </div>

</div>

