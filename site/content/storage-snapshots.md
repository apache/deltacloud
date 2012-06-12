---
site_name: Deltacloud API
title: Storage snapshots
---

<br/>

<div class="row">
  <div class="span9">

<h3 id="snapshots">Storage snapshots</h3>

<p>
A storage snapshot captures the state of a storage volume at the exact moment in time. Each snapshot has
</p>

<ul>
  <li>a <strong>created timestamp</strong>; and</li>
  <li>a <strong>storage volume </strong>attribute referring to the volume from which the snapshot was made.</li>
</ul>

<br/>
<br/>

<ul class="nav nav-pills">
  <li class="active"><a href="#tab1" data-toggle="tab">Get a list of all snapshots</a></li>
  <li><a href="#tab2" data-toggle="tab">Get the details of a snapshot</a></li>
  <li><a href="#tab3" data-toggle="tab">Create/delete a snapshot</a></li>
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
  <li><a href="/storage-resources.html">Storage resources</a></li>
  <ul class="nav nav-list">
    <li><a href="/storage-resources.html#volumes">Storage volumes</a></li>
    <li class="active"><a href="#snapshots">Storage snapshots</a></li>
    <li><a href="/blob-storage.html">Blob storage</a></li>
  </ul>
</ul>

  </div>
</div>

<div class="tab-content">
  <div class="tab-pane active" id="tab1">
  
<h4>Get a list of all storage snapshots</h4>

<p>
To list all available storage snapshots use call <strong>GET /api/storage_snapshots</strong>. As concerns Amazon EC2, this list includes any snapshots that are available to the requesting client account, including those that may not have been created by that account. As this list is very long the example below shows only part of the response:
</p>

<p>
Example request:
</p>

<pre>
GET /api/storage_snapshots?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 200 OK
Content-Type: application/xml
Date: Thu, 28 Jul 2011 22:08:36 GMT
Content-Length: 156897

&lt;?xml version='1.0' encoding='utf-8' ?&gt;
&lt;storage_snapshots&gt;
  &lt;storage_snapshot href='http://localhost:3001/api/storage_snapshots/snap-45b8d024' id='snap-45b8d024'&gt;
    &lt;created&gt;Thu Jul 28 21:54:19 UTC 2011&lt;/created&gt;
    &lt;storage_volume href='http://localhost:3001/api/storage_volumes/vol-0bc0de60' id='vol-0bc0de60'&gt;&lt;/storage_volume&gt;
  &lt;/storage_snapshot&gt;
  &lt;storage_snapshot href='http://localhost:3001/api/storage_snapshots/snap-d5a1c9b4' id='snap-d5a1c9b4'&gt;
    &lt;created&gt;Thu Jul 28 21:46:12 UTC 2011&lt;/created&gt;
    &lt;storage_volume href='http://localhost:3001/api/storage_volumes/vol-99fbe5f2' id='vol-99fbe5f2'&gt;&lt;/storage_volume&gt;
  &lt;/storage_snapshot&gt;
  &lt;storage_snapshot href='http://localhost:3001/api/storage_snapshots/snap-dda6cebc' id='snap-dda6cebc'&gt;
    &lt;created&gt;Thu Jul 28 21:51:55 UTC 2011&lt;/created&gt;
    &lt;storage_volume href='http://localhost:3001/api/storage_volumes/vol-99fbe5f2' id='vol-99fbe5f2'&gt;&lt;/storage_volume&gt;
  &lt;/storage_snapshot&gt;
  &lt;storage_snapshot href='http://localhost:3001/api/storage_snapshots/snap-d010f6b9' id='snap-d010f6b9'&gt;
    &lt;created&gt;Mon Oct 20 18:23:59 UTC 2008&lt;/created&gt;
    &lt;storage_volume href='http://localhost:3001/api/storage_volumes/vol-351efb5c' id='vol-351efb5c'&gt;&lt;/storage_volume&gt;
  &lt;/storage_snapshot&gt;
  &lt;storage_snapshot href='http://localhost:3001/api/storage_snapshots/snap-a310f6ca' id='snap-a310f6ca'&gt;
    &lt;created&gt;Mon Oct 20 18:25:53 UTC 2008&lt;/created&gt;
    &lt;storage_volume href='http://localhost:3001/api/storage_volumes/vol-001efb69' id='vol-001efb69'&gt;&lt;/storage_volume&gt;
  &lt;/storage_snapshot&gt;
  (...)
&lt;/storage_snapshots&gt;
</pre>

  </div>
  <div class="tab-pane" id="tab2">

<h4>Get the details of a storage snaphsot</h4>

<p>
To get all details for a specified storage snapshot, as shown below, use call <strong>GET /api/storage_snapshots/:id</strong>.
</p>

<p>Example request:</p>

<pre>
GET /api/storage_snapshots/snap-45b8d024?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 200 OK
Content-Type: application/xml
Date: Thu, 28 Jul 2011 22:08:36 GMT
Content-Length: 329

&lt;?xml version='1.0' encoding='utf-8' ?&gt;
&lt;storage_snapshot href='http://localhost:3001/api/storage_snapshots/snap-45b8d024' id='snap-45b8d024'&gt;
  &lt;created&gt;Thu Jul 28 21:54:19 UTC 2011&lt;/created&gt;
  &lt;storage_volume href='http://localhost:3001/api/storage_volumes/vol-0bc0de60' id='vol-0bc0de60'&gt;&lt;/storage_volume&gt;
&lt;/storage_snapshot&gt;
</pre>

  </div>
  <div class="tab-pane" id="tab3">

<h4>Create a new storage snapshot</h4>

<p>
To create a new storage snapshot use call <strong>POST /api/storage_snapshots</strong>. Clients must specify the storage volume, which the snapshot is created from, by supplying the <strong>volume_id</strong> parameter. The Deltacloud server responds with <strong>HTTP 201 Created</strong> after a succesful operation and provides details of the new storage snapshot. Clients may specify operation parameters as multipart/form-data, or as application/x-www-form-urlencoded data:
</p>

<p>Example request:</p>

<pre>
POST /api/storage_snapshots?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
Content-Length: 22
Content-Type: application/x-www-form-urlencoded

volume_id=vol-99fbe5f2
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 201 Created
Date: Thu, 28 Jul 2011 21:46:48 GMT
Content-Length: 329

&lt;?xml version='1.0' encoding='utf-8' ?&gt;
&lt;storage_snapshot href='http://localhost:3001/api/storage_snapshots/snap-d5a1c9b4' id='snap-d5a1c9b4'&gt;
  &lt;created&gt;Thu Jul 28 21:46:12 UTC 2011&lt;/created&gt;
  &lt;storage_volume href='http://localhost:3001/api/storage_volumes/vol-99fbe5f2' id='vol-99fbe5f2'&gt;&lt;/storage_volume&gt;
&lt;/storage_snapshot&gt;
</pre>

<h4>Delete a storage snapshot</h4>

<p>
To delete the specified storagesnapshot use call <strong>DELETE /api/storage_snapshots/:id</strong>. The operation returns a <strong>HTTP 204 No Content</strong> after a succesful operation:
</p>

<p>Example request:</p>

<pre>
DELETE /api/storage_snapshots/snap-dda6cebc?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 204 No Content
Date: Thu, 28 Jul 2011 22:26:07 GMT
</pre>

  </div>
</div>

<a class="btn btn-inverse btn-large" style="float: right" href="/blob-storage.html">Blob storage <i class="icon-arrow-right icon-white" style="vertical-align:baseline"> </i></a>

<br/>
