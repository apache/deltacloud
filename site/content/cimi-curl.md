---
site_name: Deltacloud API
title: CIMI cURL Examples
---

<br/>

<div class="row">

  <div class="span8">

    <h3 id="command">Working with cURL against the Deltacloud CIMI frontend</h3>

    <p> The <a href="http://curl.haxx.se/docs/">cURL documentation</a> is pretty comprehensive, but the following are some general points to remember for using cURL against Deltacloud. All the examples on this page assume the deltacloud server is running at localhost:3001: </p>

  <ul>
    <li>
      Credentials are specified with <strong> --user "name:password"  </strong>
    </li>
    <li>
      Request headers are specified with <strong> -H "header: value" </strong>. For the "Accept" header Deltacloud offers a convenient way of specifying the desired response format; you can include the <strong>"?format="</strong> parameter into the request URL rather than setting the Accept header
    </li>
    <li>
      HTTP verbs are specified with <strong>-X VERB</strong>
    </li>
    <li>
      The <strong> -i </strong> flag will show you the response headers and the <strong> -v </strong> flag will show you request and response headers as well as info about cURL activity:
      <pre>
curl -v -X DELETE --user "username:password" -H "Accept: application/xml" http://localhost:3001/cimi/images/my_image
      </pre>
    </li>
  </ul>

  </div>

  <div class="span4">

    <ul class="nav nav-list well">
      <li class="nav-header">cURL as a deltacloud client</li>
      <li><a href="#machines">Work with Machines</a></li>
      <li><a href="#machine-images">Work with Machine Images</a></li>
    </ul>

  </div>
</div>

<hr/>

<h4 id="machines">Working with Machines</h4>

<p>Retrieve the Machine Collection in json format:</p>

<pre> curl --user "user:pass" -H "Accept: application/json" http://localhost:3001/cimi/machines </pre>

<p>Create a new Machine with the message body in XML format:</p>

<pre>
curl -v --user "mockuser:mockpassword" -X POST -H "Content-Type: application/xml" -H "Accept: application/xml" -d '&lt;MachineCreate xmlns="http://schemas.dmtf.org/cimi/1"&gt; &lt;name&gt; myMachine1 &lt;/name&gt; &lt;description&gt; my machine description &lt;/description&gt; &lt;machineTemplate&gt; &lt;machineConfig href="http://localhost:3001/cimi/machine_configurations/m1-small"&gt; &lt;/machineConfig&gt; &lt;machineImage href="http://localhost:3001/cimi/machine_images/img1"&gt; &lt;/machineImage&gt; &lt;/machineTemplate&gt; &lt;/MachineCreate&gt;'
</pre>

<p>Alternatively, specifying the message body in JSON:</p>
<pre>
 curl -v --user "user:password" -X POST -H "Content-Type: application/json" -H "Accept: application/xml" -d '{ "resourceURI": "http://schemas.dmtf.org/cimi/1/MachineCreate", "name": "myMachine3", "description": "My very first json machine", "machineTemplate": { "machineConfig": { "href": "http://localhost:3001/cimi/machine_configurations/m1.small" }, "machineImage": { "href": "http://localhost:3001/cimi/machine_images/ami-48aa4921" } } }' http://localhost:3001/cimi/machines
</pre>

<p>Perform a Machine operation - stop - with the message body in XML format:</p>

<pre>
curl -v -X POST --user "mockuser:mockpassword" -H "Content-Type: application/xml" -H "Accept: application/xml" -d '&lt;Action xmlns="http://schemas.dmtf.org/cimi/1"&gt;&lt;action&gt; http://http://schemas.dmtf.org/cimi/1/action/stop &lt;/action&gt; &lt;/Action&gt;'  http://localhost:3001/cimi/machines/inst3/stop
</pre>

<p>Alternatively, specifying the message body in JSON:</p>
<pre>
 curl -v -X POST --user "user:password" -H "Accept: application/json" -H "Content-Type: application/json" -d '{"resourceURI": "http://www.dmtf.org/cimi/1/Action", "action":"http://www.dmtf.org/cimi/action/stop"}' http://localhost:3001/cimi/machines/i-5feb7c20/stop
</pre>

<br/>

<hr/>

<h4 id="machine-images">Working with Machine Images</h4>

<p>Retrieve the Machine Image Collection:</p>

<pre>
curl --user "user:pass" -H "Accept: application/json" http://localhost:3001/cimi/machine_images
</pre>

<p>Create a new Machine Image from an existing Machine, with message body in JSON:</p>

<pre>
curl --user "mockuser:mockpassword" -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"resourceURI":"http://schemas.dmtf.org/cimi/1/MachineImage", "name":"new_image","description":"my new machine image","type":"IMAGE", "imageLocation":"http://localhost:3001/cimi/machines/inst1"}' http://localhost:3001/cimi/machine_images
</pre>


<p>Alternatively, specifying the message body in XML:</p>

<pre>
curl -v --user "mockuser:mockpassword" -H "Content-Type: application/xml" -H "Accept: application/xml" -X POST -d "&lt;MachineImage&gt;&lt;name&gt;some_name&lt;/name&gt;&lt;description&gt;my new machine image&lt;/description&gt;&lt;type&gt;IMAGE&lt;/type&gt;&lt;imageLocation&gt;http://localhost:3001/cimi/machines/inst1&lt;/imageLocation&gt;&lt;/MachineImage&gt;" http://localhost:3001/cimi/machine_images
</pre>


<p>Delete a Machine Image:</p>

<pre>curl -X DELETE --user "user:pass" http://localhost:3001/cimi/machine_images/my_image </pre>

