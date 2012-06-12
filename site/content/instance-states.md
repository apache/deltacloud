---
site_name: Deltacloud API
title: Instance states
---
<br/>

<div class="row">
  <div class="span9">

<h3 id="instance-states">Instance states</h3>

<p>
Each cloud defines a slightly different lifecycle model for instances. In some clouds, instances start running immediately after creation, in others, they enter a pending state and you need to start them explicitly.
</p>

<p>
Differences between clouds are modelled by expressing the lifecycle of an instance as a finite state machine and capturing it in an instance states entity.The API defines the following states for an instance:</p>

<table class="table table-condensed table-striped">
  <thead>
    <tr>
      <th>State</th>
      <th>Meaning</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>start</td>
      <td>an instance state before creation of an instance</td>
    </tr>
    <tr>
      <td>pending</td>
      <td>creation of an instance is in progress</td>
    </tr>
    <tr>
      <td>running</td>
      <td>an instance is running</td>
    </tr>
    <tr>
      <td>shutting-down</td>
      <td>an instance is stopped</td>
    </tr>
    <tr>
      <td>stopped</td>
      <td>an instance is stopped</td>
    </tr>
    <tr>
      <td>finished</td>
      <td>all resources for an instance have now been freed</td>
    </tr>
  </tbody>
</table>

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
    <li class="active"><a href="#instance-states">Instance states</a></li>
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

<p>
The details of a particular instance describes also the actions (state transitions) which can be performed on the instance. If the state transition is marked as <strong>auto</strong>, the transition from one state to another is done automatically. The possible instance actions are:
</p>


<table class="table table-condensed table-striped">
 <thead>
  <tr>
   <th>Action</th>
   <th>Meaning</th>
  </tr>
 </thead>
 <tbody>
  <tr>
   <td>start</td>
   <td>starts the instance</td>
  </tr>
  <tr>
   <td>stop</td>
   <td>stops (and for some providers shutdown) the instance</td>
  </tr>
  <tr>
   <td>reboot</td>
   <td>reboots the instance</td>
  </tr>
  <tr>
   <td>destroy</td>
   <td>stops the instance and completely destroys it</td>
  </tr>
 </tbody>
</table>


<h4>Get an instance states entity</h4>

To retrieve the instance states entity for a back-end cloud use call <strong>GET /api/instance_states</strong>. The instance states entity defines possible transitions between various states of an instance, specific for each back-end cloud. As a result, instance states defines the finite state machine for instances from the given cloud.

<p>Example request:</p>

<pre>
GET /api/instance_states?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3002
Accept: */*
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 200 OK
Content-Type: application/xml
Content-Length: 583

&lt;states&gt;
  &lt;state name='start'&gt;
    &lt;transition action='create' to='pending'&gt;&lt;/transition&gt;
  &lt;/state&gt;
  &lt;state name='pending'&gt;
    &lt;transition auto='true' to='running'&gt;&lt;/transition&gt;
  &lt;/state&gt;
  &lt;state name='running'&gt;
    &lt;transition action='reboot' to='running'&gt;&lt;/transition&gt;
    &lt;transition action='stop' to='shutting_down'&gt;&lt;/transition&gt;
  &lt;/state&gt;
  &lt;state name='shutting_down'&gt;
    &lt;transition auto='true' to='stopped'&gt;&lt;/transition&gt;
  &lt;/state&gt;
  &lt;state name='stopped'&gt;
    &lt;transition auto='true' to='finish'&gt;&lt;/transition&gt;
  &lt;/state&gt;
  &lt;state name='finish'&gt;
  &lt;/state&gt;
&lt;/states&gt;
</pre>

<a class="btn btn-inverse btn-large" style="float: right" href="/instances.html">Instances <i class="icon-arrow-right icon-white" style="vertical-align:baseline"> </i></a>

<br/>
