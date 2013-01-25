---
site_name: Deltacloud API
title: CIMI cURL Examples - Machine Resources
---

<br/>

<div class="row">

  <div class="span8">

    <h3 id="command">cURL examples for CIMI Machine resources</h3>

<ul class="nav nav-pills">
  <li class="active"><a href="#machines" data-toggle="tab">Working with Machines</a></li>
  <li><a href="#machine-images" data-toggle="tab">Working with MachineImages</a></li>
  <li><a href="#machine-configs" data-toggle="tab">Working with MachineConfigurations</a></li>
  <li><a href="#machine-templates" data-toggle="tab">Working with MachineTemplates</a></li>
  <li><a href="#machine-volumes" data-toggle="tab">Working with Machine Volumes</a></li>
</ul>


  </div>

  <div class="span4">

<ul class="nav nav-list well">
  <li class="nav-header">
    <a href="/cimi-curl.html">curl for CIMI Resources</a>
  </li>
  <ul class="nav nav-list">
    <li class="active"><a href="/cimi-curl/cimi-curl-machines.html">Machine</a></li>
    <li><a href="/cimi-curl/cimi-curl-volumes.html">Volume</a></li>
    <li><a href="/cimi-curl/cimi-curl-resource_metadata.html">ResourceMetadata</a></li>
  </ul>
  <br/>
</ul>

  </div>

</div>

<div class="tab-content">

  <div class="tab-pane active" id="machines">

<hr/>

<h4 id="machines">Working with Machines</h4>

<p>Retrieve the Machine Collection in json format:</p>

<pre> curl --user "user:pass" -H "Accept: application/json" http://localhost:3001/cimi/machines </pre>

<p>Create a new Machine with the message body in XML format:</p>

<pre>
curl -v --user "mockuser:mockpassword" -X POST -H "Content-Type: application/xml" -H "Accept: application/xml" -d '&lt;MachineCreate xmlns="http://schemas.dmtf.org/cimi/1"&gt; &lt;name&gt; myMachine1 &lt;/name&gt; &lt;description&gt; my machine description &lt;/description&gt; &lt;machineTemplate&gt; &lt;machineConfig href="http://localhost:3001/cimi/machine_configurations/m1-small"&gt; &lt;/machineConfig&gt; &lt;machineImage href="http://localhost:3001/cimi/machine_images/img1"&gt; &lt;/machineImage&gt; &lt;/machineTemplate&gt; &lt;/MachineCreate&gt;' http://localhost:3001/cimi/machines
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

</div>

<div class="tab-pane" id="machine-images">

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

<br/>

<hr/>

</div>

<div class="tab-pane" id="machine-configs">

<h4 id="machine-configs">Working with Machine Configurations</h4>

<p>Retrieve the Machine Configuration Collection:</p>

<pre>
curl --user "user:pass" -H "Accept: application/json" http://localhost:3001/cimi/machine_configurations
</pre>

<p>Retrieve a specific Machine Configuration:</p>

<pre>
curl --user "user:pass" -H "Accept: application/json" http://localhost:3001/cimi/machine_configurations/m1-large
</pre>
</div>


<div class="tab-pane" id="machine-templates">

<h4>Working with Machine Templates</h4>
<p>Retrieve the Machine Template Collection:</p>

<pre>
curl --user "user:pass" -H "Accept: application/json" http://localhost:3001/cimi/machine_templates
</pre>

<p>Retrieve a specific Machine Template:</p>

<pre>
curl --user "user:pass" -H "Accept: application/json" http://localhost:3001/cimi/machine_templates/m1-large
</pre>

<p> Create a Machine Template with XML body: </p>

<pre>
curl -v --user "mockuser:mockpassword" -X POST -d '&lt;MachineTemplateCreate&gt;&lt;name&gt;myXmlTestMachineTemplate1&lt;/name&gt;&lt;description&gt;Description of my MachineTemplate&lt;/description&gt;&lt;property key="test"&gt;value&lt;/property&gt;&lt;machineConfig href="http://localhost:3001/cimi/machine_configurations/m1-xlarge"/&gt;&lt;machineImage href="http://localhost:3001/cimi/machine_images/img3"/&gt;&lt;/MachineTemplateCreate&gt;' -H "Content-Type: application/xml"  -H "Accept: application/xml" http://localhost:3001/cimi/machine_templates
</pre>

<p> Create a Machine Template with JSON body: </p>

<pre>
curl -v --user "mockuser:mockpassword" -X POST -d '{"resourceURI": "http://schemas.dmtf.org/cimi/1/MachineTemplateCreate","name": "myMachineDemoTemplate","description": "My very loved machine template","machineConfig": { "href": "http://localhost:3001/cimi/machine_configurations/m1-xlarge" },"machineImage": { "href": "http://localhost:3001/cimi/machine_images/img3" },"properties": { "foo": "bar","life": "is life"}}' -H "Content-Type: application/json"  -H "Accept: application/json" http://localhost:3001/cimi/machine_templates
</pre>

<p> Delete a Machine Template: </p>

<pre>
curl -v --user "mockuser:mockpassword" -H "Accept: application/xml" -X DELETE http://localhost:3001/cimi/machine_templates/2
</pre>

</div>

<div class="tab-pane" id="machine-volumes">

<h4>Working with Machine Volumes </h4>
<p>Retrieve the Machine Volume Collection of a given Machine resource:</p>

<pre>
curl -v --user "mockuser:mockpassword" -H "Accept: application/xml" http://localhost:3001/cimi/machines/inst1/volumes
</pre>

<p>Attach a Volume to a Machine, with XML body:</p>

<pre>
curl -v --user "mockuser:mockpassword" -H "Content-Type: application/xml" -H "Accept: application/xml" -X POST -d '<MachineVolume xmlns="http://schemas.dmtf.org/cimi/1/MachineVolume"><initialLocation> /dev/sdf </initialLocation> <volume href="http://localhost:3001/cimi/volumes/vol3"/></MachineVolume>'  http://localhost:3001/cimi/machines/inst1/volume_attach
</pre>

<p>Attach a Volume to a Machine, with JSON body:</p>

<pre>
curl -v --user "mockuser:mockpassword" -H "Content-Type: application/json" -H "Accept: application/xml" -X POST -d '{"resourceURI":"http://schemas.dmtf.org/cimi/1/MachineVolume", "initialLocation": "/dev/sdf", "volume": {"href":"http://localhost:3001/cimi/volumes/vol2"}}' http://localhost:3001/cimi/machines/inst1/volume_attach
</pre>

<p>Detach a Volume from a Machine:</p>

<pre>
curl -v --user "mockuser:mockpassword" -H "Accept: application/xml" -X DELETE http://localhost:3001/cimi/machines/inst1/volumes/vol2
</pre>

</div>
