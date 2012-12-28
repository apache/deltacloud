---
site_name: Deltacloud API
title: CIMI Resource Collections - Machine
---

<br/>

<div class="row">
  <div class="span9">

<h3 id="cimi-entry-point">CIMI Resources and Collections</h3>

<p> We are continually improving CIMI support in Deltacloud. If you come across any inconsistencies or errors in the Deltacloud CIMI implementation we'll be very glad to <a href="/contact.html">hear about them</a>.</p>

<p>
In the following sections, the textual definitions following the title of each resource (e.g. "Machine") that are rendered in bold and italic type are taken from the CIMI 1.0.1 specification, available from the DMTF <a href="http://dmtf.org/cloud">Cloud Management Initiative</a> (DSP0263).
</p>

<hr/>

<h3 id="cimi-machine">Machine</h3>
<p>
<strong><em>
An instantiated compute resource that encapsulates both CPU and Memory.
A Machine Collection resource represents the collection of Machine resources within a Provider
</em></strong>
</p>

 </div>

 <div class="span3">

<ul class="nav nav-list well">
  <li class="nav-header">
    CIMI REST API
  </li>
  <li><a href="/cimi-rest.html">Introduction</a></li>
  <li><a href="/cimi-rest-entry-point.html">Cloud Entry Point</a></li>
  <li><a href="/cimi-rest-collections.html">CIMI Resources</a></li>
    <ul class="nav nav-list">
      <li class="active"><a href="/cimi-rest-collections.html">Machine</a></li>
      <li><a href="/cimi-rest-machine-images.html">MachineImage</a></li>
    </ul>

</ul>

  </div>

</div>

<ul class="nav nav-pills">
  <li class="active"><a href="#tab1" data-toggle="tab">Retrieve the Machine Collection</a></li>
  <li><a href="#single-machine" data-toggle="tab">Retrieve a single Machine</a></li>
  <li><a href="#create-machine" data-toggle="tab">Create a new Machine</a></li>
  <li><a href="#machine-action" data-toggle="tab">Perform a Machine Operation</a></li>
</ul>

<hr>

<div class="tab-content">
  <div class="tab-pane active" id="tab1">

<h4>Retrieve the Machine Collection</h4>

Note the 'add' URI of the Machine Collection resource in the example response below. This is the URI that is used for creating a new Machine (adding to the Machine Collection).
<br/>
<br/>

<p>Example request:</p>

<pre>
GET /cimi/machines HTTP/1.1
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
Content-Length: 2293
ETag: 5c6dc8cfbceeb1f3c610765a4aa600dd
Cache-Control: max-age=0, private, must-revalidate
Date: Fri, 28 Dec 2012 11:08:27 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;Collection xmlns="http://schemas.dmtf.org/cimi/1"
        resourceURI="http://schemas.dmtf.org/cimi/1/MachineCollection"&gt;
  &lt;id&gt;http://localhost:3001/cimi/machines&lt;/id&gt;
  &lt;count&gt;2&lt;/count&gt;
  &lt;Machine&gt;
    &lt;id&gt;http://localhost:3001/cimi/machines/inst0&lt;/id&gt;
    &lt;name&gt;Mock Instance With Profile Change&lt;/name&gt;
    &lt;description&gt;No description set for Machine Mock Instance With Profile Change&lt;/description&gt;
    &lt;created&gt;2012-12-28T13:08:27+02:00&lt;/created&gt;
    &lt;property key="machine_image"&gt;http://localhost:3001/cimi/machine_images/img1&lt;/property&gt;
    &lt;property key="credential"&gt;http://localhost:3001/cimi/credentials&lt;/property&gt;
    &lt;state&gt;STARTED&lt;/state&gt;
    &lt;cpu&gt;1&lt;/cpu&gt;
    &lt;memory&gt;12582912&lt;/memory&gt;
    &lt;disks href="http://localhost:3001/cimi/machines/inst0/disks" /&gt;
    &lt;volumes href="http://localhost:3001/cimi/machines/inst0/volumes" /&gt;
    &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/restart"
        href="http://localhost:3001/cimi/machines/inst0/restart" /&gt;
    &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/stop"
        href="http://localhost:3001/cimi/machines/inst0/stop" /&gt;
    &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/capture"
        href="http://localhost:3001/cimi/machine_images" /&gt;
  &lt;/Machine&gt;
  &lt;Machine&gt;
    &lt;id&gt;http://localhost:3001/cimi/machines/inst1&lt;/id&gt;
    &lt;name&gt;MockUserInstance&lt;/name&gt;
    &lt;description&gt;No description set for Machine MockUserInstance&lt;/description&gt;
    &lt;created&gt;2012-12-28T13:08:27+02:00&lt;/created&gt;
    &lt;property key="machine_image"&gt;http://localhost:3001/cimi/machine_images/img3&lt;/property&gt;
    &lt;property key="credential"&gt;http://localhost:3001/cimi/credentials&lt;/property&gt;
    &lt;state&gt;STARTED&lt;/state&gt;
    &lt;cpu&gt;1&lt;/cpu&gt;
    &lt;memory&gt;1782579&lt;/memory&gt;
    &lt;disks href="http://localhost:3001/cimi/machines/inst1/disks" /&gt;
    &lt;volumes href="http://localhost:3001/cimi/machines/inst1/volumes" /&gt;
    &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/restart"
        href="http://localhost:3001/cimi/machines/inst1/restart" /&gt;
    &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/stop"
        href="http://localhost:3001/cimi/machines/inst1/stop" /&gt;
    &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/capture"
        href="http://localhost:3001/cimi/machine_images" /&gt;
  &lt;/Machine&gt;
  &lt;operation rel="add" href="http://localhost:3001/cimi/machines" /&gt;
&lt;/Collection&gt;


</pre>

  </div>
  <div class="tab-pane" id="single-machine">

<h4>Retrieve a single Machine</h4>

<p>Example request:</p>

<pre>
GET /cimi/machines/inst0 HTTP/1.1
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
Content-Length: 1092
ETag: 2d57aa01f1a50b2d13c04f0c51f08ab9
Cache-Control: max-age=0, private, must-revalidate
Date: Fri, 28 Dec 2012 11:20:28 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;Machine xmlns="http://schemas.dmtf.org/cimi/1"
          resourceURI="http://schemas.dmtf.org/cimi/1/Machine"&gt;
  &lt;id&gt;http://localhost:3001/cimi/machines/inst0&lt;/id&gt;
  &lt;name&gt;Mock Instance With Profile Change&lt;/name&gt;
  &lt;description&gt;No description set for Machine Mock Instance With Profile Change&lt;/description&gt;
  &lt;created&gt;2012-12-28T13:20:28+02:00&lt;/created&gt;
  &lt;property key="machine_image"&gt;http://localhost:3001/cimi/machine_images/img1&lt;/property&gt;
  &lt;property key="credential"&gt;http://localhost:3001/cimi/credentials&lt;/property&gt;
  &lt;state&gt;STARTED&lt;/state&gt;
  &lt;cpu&gt;1&lt;/cpu&gt;
  &lt;memory&gt;12582912&lt;/memory&gt;
  &lt;disks href="http://localhost:3001/cimi/machines/inst0/disks" /&gt;
  &lt;volumes href="http://localhost:3001/cimi/machines/inst0/volumes" /&gt;
  &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/restart"
          href="http://localhost:3001/cimi/machines/inst0/restart" /&gt;
  &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/stop"
          href="http://localhost:3001/cimi/machines/inst0/stop" /&gt;
  &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/capture"
          href="http://localhost:3001/cimi/machine_images" /&gt;
&lt;/Machine&gt;


</pre>

  </div>

  <div class="tab-pane" id="create-machine">

<h4>Create a new Machine</h4>

<p>
The 'add' URI of the Machine Collection is used to create a new Machine. This is returned when retrieving the Machine Collection resource.
</p>

<p>Example request:</p>

<pre>
POST /cimi/machines HTTP/1.1
Authorization: Basic bW9ja3VzZXI6bW9ja3Bhc3N3b3Jk
User-Agent: curl/7.24.0 (i686-redhat-linux-gnu)
Host: localhost:3001
Content-Type: application/xml
Accept: application/xml
Content-Length: 370

&lt;MachineCreate xmlns="http://schemas.dmtf.org/cimi/1"&gt;
  &lt;name&gt; myMachine1 &lt;/name&gt;
  &lt;description&gt; my machine description &lt;/description&gt;
  &lt;machineTemplate&gt;
    &lt;machineConfig href="http://localhost:3001/cimi/machine_configurations/m1-small"&gt;
    &lt;/machineConfig&gt;
    &lt;machineImage href="http://localhost:3001/cimi/machine_images/img1"&gt;
    &lt;/machineImage&gt;
  &lt;/machineTemplate&gt;
&lt;/MachineCreate&gt;

</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 201 Created
Content-Type: application/xml
Location: http://localhost:3001/cimi/machines/inst3
CIMI-Specification-Version: 1.0.1
Content-Length: 1030
ETag: 360992481f1450f9d475f439e5105f9d
Cache-Control: max-age=0, private, must-revalidate
Date: Fri, 28 Dec 2012 11:47:58 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;Machine xmlns="http://schemas.dmtf.org/cimi/1" resourceURI="http://schemas.dmtf.org/cimi/1/Machine"&gt;
  &lt;id&gt;http://localhost:3001/cimi/machines/inst3&lt;/id&gt;
  &lt;name&gt; myMachine1 &lt;/name&gt;
  &lt;description&gt; my machine description &lt;/description&gt;
  &lt;created&gt;2012-12-28T13:47:58+02:00&lt;/created&gt;
  &lt;property key="machine_image"&gt;http://localhost:3001/cimi/machine_images/img1&lt;/property&gt;
  &lt;property key="credential"&gt;http://localhost:3001/cimi/credentials&lt;/property&gt;
  &lt;state&gt;STARTED&lt;/state&gt;
  &lt;cpu&gt;1&lt;/cpu&gt;
  &lt;memory&gt;1782579&lt;/memory&gt;
  &lt;disks href="http://localhost:3001/cimi/machines/inst3/disks" /&gt;
  &lt;volumes href="http://localhost:3001/cimi/machines/inst3/volumes" /&gt;
  &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/restart"
          href="http://localhost:3001/cimi/machines/inst3/restart" /&gt;
  &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/stop"
          href="http://localhost:3001/cimi/machines/inst3/stop" /&gt;
  &lt;operation rel="http://schemas.dmtf.org/cimi/1/action/capture"
          href="http://localhost:3001/cimi/machine_images" /&gt;
&lt;/Machine&gt;


</pre>


  </div>


  <div class="tab-pane" id="machine-action">

<h4>Perform a Machine Operation</h4>

<p>
The list of Machine operations is returned when the URI of a specific Machine resource is dereferenced. Examples of operations are 'stop', 'restart' and 'capture'. An 'Action' resource is used in the POST message body corresponding to the operation to be executed. The example below shows the 'stop' action.
</p>

<p>Example request:</p>
<pre>
POST /cimi/machines/inst3/stop HTTP/1.1
Authorization: Basic bW9ja3VzZXI6bW9ja3Bhc3N3b3Jk
User-Agent: curl/7.24.0 (i686-redhat-linux-gnu)
Host: localhost:3001
Content-Type: application/xml
Accept: application/xml
Content-Length: 125

&lt;Action xmlns="http://schemas.dmtf.org/cimi/1"&gt;
  &lt;action&gt; http://http://schemas.dmtf.org/cimi/1/action/stop &lt;/action&gt;
&lt;/Action&gt;
</pre>

<p>Server response:</p>
<pre>
HTTP/1.1 202 Accepted
CIMI-Specification-Version: 1.0.1
Content-Length: 0
Date: Fri, 28 Dec 2012 14:01:43 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife
</pre>


  </div>


</div>
