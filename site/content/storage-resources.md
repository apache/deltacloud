---
site_name: Deltacloud API
title: Storage resources
---

<br/>

<div class="row">
  <div class="span9">

<h3 id="resources">Storage resources</h3>

<p>
Storage resources are divided into two groups:
</p>

<ul>
  <li><strong>storage volumes</strong>, which can be attached to a running instance (accessible by the instance OS)</li>
  <li><strong>blob storage</strong>, which represents a generic 'key &lt;−−&gt; value' based data store, as implemented by Rackspace CloudFiles or Amazon S3</li>
</ul>

<p>
<strong>Storage snapshots</strong> represent a storage volume, a backup which is created at a particular point of time (a snapshot).
</p>

<h3 id="volumes">Storage Volumes</h3>

<p>
A storage volume has
</p>

  </div>
  <div class="span3">

<ul class="nav nav-list well">
  <li class="nav-header">
    REST API
  </li>
  <li><a href="/rest-api.html">Introduction</a></li>
  <li><a href="/api-entry-point.html">API entry point</a></li>
  <li><a href="/compute-resources.html">Compute resources</a></li>
  <li class="active"><a href="#resources">Storage resources</a></li>
  <ul class="nav nav-list">
    <li><a href="#volumes">Storage volumes</a></li>
    <li><a href="/storage-snapshots.html">Storage snapshots</a></li>
    <li><a href="/blob-storage.html">Blob storage</a></li>
  </ul>
</ul>

  </div>
</div>

<ul>
  <li>a <strong>capacity</strong> expressed in Gigabytes;</li>
  <li>a <strong>created</strong> timestamp;</li>
  <li>a <strong>realm_id</strong> specifying the realm in which the volume exists;</li>
  <li>a <strong>state</strong> (for Amazon EC2 this is one of creating, available, in-use, deleting, deleted, error); and </li>
  <li>a set of <strong>actions</strong>.</li>
</ul>

<p>
When attached to an instance, a storage volume will also expose a <strong>mount</strong> element
which contains the attributes <strong>instance </strong>and <strong>device</strong>, specifying the instance, to which the volume is attached, and the mount point (e.g. /dev/sdh), respectively.
</p>

<br/>

<ul class="nav nav-pills">
  <li class="active"><a href="#tab1" data-toggle="tab">Get a list of all volumes</a></li>
  <li><a href="#tab2" data-toggle="tab">Get the details of volume</a></li>
  <li><a href="#tab3" data-toggle="tab">Create/delete a volume</a></li>
  <li><a href="#tab4" data-toggle="tab">Attach/detach a volume</a></li>
</ul>

<hr>

<div class="tab-content">
  <div class="tab-pane active" id="tab1">

<h4>Get a list of all storage volumes</h4>

<p>
To list all storage volumes use call <strong>GET /api/storage_volumes</strong>.
</p>

<p>
Example request:
</p>

<pre>
GET /api/storage_volumes?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 200 OK
Content-Type: application/xml
Date: Thu, 28 Jul 2011 21:04:09 GMT
Content-Length: 1341

&lt;?xml version='1.0' encoding='utf-8' ?&gt;
&lt;storage_volumes&gt;
  &lt;storage_volume href='http://localhost:3001/api/storage_volumes/vol-0bc0de60' id='vol-0bc0de60'&gt;
    &lt;created&gt;Thu Jul 28 20:44:18 UTC 2011&lt;/created&gt;
    &lt;capacity unit='GB'&gt;10&lt;/capacity&gt;
        &lt;realm_id&gt;us-east-1c&lt;/realm_id&gt;
    &lt;state&gt;AVAILABLE&lt;/state&gt;
    &lt;actions&gt;
      &lt;link href='http://localhost:3001/api/storage_volumes/vol-0bc0de60/attach' method='post' rel='attach' /&gt;
      &lt;link href='http://localhost:3001/api/storage_volumes/vol-0bc0de60/detach' method='post' rel='detach' /&gt;
      &lt;link href='http://localhost:3001/api/storage_volumes/vol-0bc0de60' method='delete' rel='destroy' /&gt;
    &lt;/actions&gt;
  &lt;/storage_volume&gt;
  &lt;storage_volume href='http://localhost:3001/api/storage_volumes/vol-99fbe5f2' id='vol-99fbe5f2'&gt;
    &lt;created&gt;Thu Jul 28 20:56:07 UTC 2011&lt;/created&gt;
    &lt;capacity unit='GB'&gt;15&lt;/capacity&gt;
    &lt;realm_id&gt;us-east-1c&lt;/realm_id&gt;
    &lt;state&gt;AVAILABLE&lt;/state&gt;
    &lt;actions&gt;
      &lt;link href='http://localhost:3001/api/storage_volumes/vol-99fbe5f2/attach' method='post' rel='attach' /&gt;
      &lt;link href='http://localhost:3001/api/storage_volumes/vol-99fbe5f2/detach' method='post' rel='detach' /&gt;
      &lt;link href='http://localhost:3001/api/storage_volumes/vol-99fbe5f2' method='delete' rel='destroy' /&gt;
    &lt;/actions&gt;
  &lt;/storage_volume&gt;
&lt;/storage_volumes&gt;
</pre>

  </div>
  <div class="tab-pane" id="tab2">

<h4>Get the details of a storage volume</h4>

<p>
To retrieve the details for the specified storage volume use call <strong>GET /api/storage_volumes/:id</strong>.
</p>

<p>Example request:</p>

<pre>
GET /api/storage_volumes/vol-99fbe5f2?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 200 OK
Content-Type: application/xml
Date: Thu, 28 Jul 2011 21:06:39 GMT
Content-Length: 794
&lt;?xml version='1.0' encoding='utf-8' ?&gt;
&lt;storage_volume href='http://localhost:3001/api/storage_volumes/vol-99fbe5f2' id='vol-99fbe5f2'&gt;
  &lt;created&gt;Thu Jul 28 20:56:07 UTC 2011&lt;/created&gt;
  &lt;capacity unit='GB'&gt;15&lt;/capacity&gt;
  &lt;realm_id&gt;us-east-1c&lt;/realm_id&gt;
  &lt;state&gt;IN-USE&lt;/state&gt;
  &lt;mount&gt;
    &lt;instance href='i-b100b3d0' id='i-b100b3d0'&gt;&lt;/instance&gt;
    &lt;device name='/dev/sdh'&gt;&lt;/device&gt;
  &lt;/mount&gt;
  &lt;actions&gt;
    &lt;link href='http://localhost:3001/api/storage_volumes/vol-99fbe5f2/attach' method='post' rel='attach' /&gt;
    &lt;link href='http://localhost:3001/api/storage_volumes/vol-99fbe5f2/detach' method='post' rel='detach' /&gt;
    &lt;link href='http://localhost:3001/api/storage_volumes/vol-99fbe5f2' method='delete' rel='destroy' /&gt;
  &lt;/actions&gt;
&lt;/storage_volume&gt;
</pre>

  </div>
  <div class="tab-pane" id="tab3">

<h4>Create a new storage volume</h4>

<p>
To create a new storage volume use call <strong>POST /api/storage_volumes</strong>. A client may specify a <strong>snapshot_id</strong> from which the storage volume is instantiated though this is optional. The <strong>capacity</strong> parameter, expressed in Gigabytes, is also optional and its default size is 1 GB. Finally clients may also specify the <strong>realm_id</strong>, as a storage volume can typically only be attached to instances running within the specified realm. If the realm is not specified it will set it at the first realm returned by the cloud provider. A successful operation will return <strong>HTTP 201 Created</strong> with the details of the new storage volume.
</p>

<div class="alert alert-error">
  <a class="close" data-dismiss="alert" href="#">×</a>
  <strong>Note: </strong>
  <p>
    Fujitsu GCP requires the size to be a multiple of 10, so the specified capacity is rounded
    up to the nearest multiple of ten, making the default size 10 GB.
  </p>
</div>

<p>
As with the other POST operations in the Deltacloud API, clients may choose to specify operation parameters as multipart/form-data or as application/x-www-form-urlencoded data.
</p>

<p>Example request:</p>

<pre>
POST /api/storage_volumes?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
Content-Length: 31
Content-Type: application/x-www-form-urlencoded

capacity=10&realm_id=us-east-1c
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 201 Created
Date: Thu, 28 Jul 2011 20:44:27 GMT
Content-Length: 649

&lt;?xml version='1.0' encoding='utf-8' ?&gt;
&lt;storage_volume href='http://localhost:3001/api/storage_volumes/vol-0bc0de60' id='vol-0bc0de60'&gt;
  &lt;created&gt;Thu Jul 28 20:44:18 UTC 2011&lt;/created&gt;
  &lt;capacity unit='GB'&gt;10&lt;/capacity&gt;
  &lt;realm_id&gt;us-east-1c&lt;/realm_id&gt;
  &lt;state&gt;CREATING&lt;/state&gt;
  &lt;actions&gt;
    &lt;link href='http://localhost:3001/api/storage_volumes/vol-0bc0de60/attach' method='post' rel='attach' /&gt;
    &lt;link href='http://localhost:3001/api/storage_volumes/vol-0bc0de60/detach' method='post' rel='detach' /&gt;
    &lt;link href='http://localhost:3001/api/storage_volumes/vol-0bc0de60' method='delete' rel='destroy' /&gt;
  &lt;/actions&gt;
&lt;/storage_volume&gt;
</pre>

<h4>Delete a storage volume</h4>

<p>
To delete the specified storage volume use call <strong>DELETE /api/storage_volumes/:id</strong>. The operation will return a <strong>HTTP 204 No Content</strong> after a succesful operation.
</p>

<div class="alert alert-error">
  <a class="close" data-dismiss="alert" href="#">×</a>
  <strong>Note:</strong>
  <p> The operation will fail if the given storage_volume is currently attached to an instance. </p>
</div>

<p>Example request:</p>

<pre>
DELETE /api/storage_volumes/vol-0bc0de60?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 204 No Content
Date: Thu, 28 Jul 2011 22:34:29 GMT
</pre>

<p>Example request: (<strong>error deleting a volume currently attached to an instance</strong>)</p>

<pre>
DELETE /api/storage_volumes/vol-0bc0de60?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 502 Bad Gateway
Content-Type: application/xml
Date: Thu, 28 Jul 2011 22:30:07 GMT
Content-Length: 617

&lt;error status='502' url='/api/storage_volumes/vol-0bc0de60?format=xml'&gt;
  &lt;kind&gt;backend_error&lt;/kind&gt;
  &lt;backend driver='ec2'&gt;
    &lt;code&gt;502&lt;/code&gt;
  &lt;/backend&gt;
  &lt;message&gt;&lt;![CDATA[Client.VolumeInUse: Volume vol-0bc0de60 is currently attached to i-b100b3d0
  REQUEST=ec2.us-east-1.amazonaws.com:443/?AWSAccessKeyId=AKIAJATNOR5HKG3FK27Q&Action=DeleteVolume&SignatureMethod=HmacSHA256&SignatureVersion=2&Timestamp=2011-07-28T22%3A30%3A00.000Z&Version=2010-08-31&VolumeId=vol-0bc0de60&Signature=WnZTd9vFaUZEwfuifyo3%2FWa2HBEG1S7R8Iv%2FHqc%2BmqE%3D
  REQUEST ID=5dff67bb-d63a-4055-b550-f323fa16e185]]&gt;&lt;/message&gt;
&lt;/error&gt;
</pre>

  </div>
  <div class="tab-pane" id="tab4">

<h4>Attach a storage volume to a running instance</h4>

<p>
To attach the specified storage volume to a running instance use call <strong>POST /api/storage_volumes/:id/attach</strong>. Clients must specify the <strong>instance_id</strong> and the <strong>device</strong> as parameters. The device parameter is used as the <strong>mount point</strong>, that is the location at which the storage volume will be exposed to the given instance (e.g. /dev/sdh). The Deltacloud server will respond with a <strong>HTTP 202 Accepted</strong> after a succesful attach operation with details of the storage volume. In the example below, the state is reported as 'unknown' although the <strong>mount</strong> element is present. It is because the processing has not yet been completed (hence the 202 status code). Clients may specify the required parameters as multipart/form-data or as application/x-www-form-urlencoded data.
</p>

<p>Example request:</p>

<pre>
POST /api/storage_volumes/vol-0bc0de60/attach?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
Content-Length: 38
Content-Type: application/x-www-form-urlencoded

instance_id=i-b100b3d0&device=/dev/sdi
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 202 Accepted
Date: Thu, 28 Jul 2011 21:36:17 GMT
Content-Length: 709

&lt;?xml version='1.0' encoding='utf-8' ?&gt;
&lt;storage_volume href='http://localhost:3001/api/storage_volumes/vol-0bc0de60' id='vol-0bc0de60'&gt;
  &lt;capacity unit='GB'&gt;&lt;/capacity&gt;
  &lt;device&gt;/dev/sdi&lt;/device&gt;
  &lt;state&gt;unknown&lt;/state&gt;
  &lt;mount&gt;
    &lt;instance href='i-b100b3d0' id='i-b100b3d0'&gt;&lt;/instance&gt;
    &lt;device name='/dev/sdi'&gt;&lt;/device&gt;
  &lt;/mount&gt;
  &lt;actions&gt;
    &lt;link href='http://localhost:3001/api/storage_volumes/vol-0bc0de60/attach' method='post' rel='attach' /&gt;
    &lt;link href='http://localhost:3001/api/storage_volumes/vol-0bc0de60/detach' method='post' rel='detach' /&gt;
    &lt;link href='http://localhost:3001/api/storage_volumes/vol-0bc0de60' method='delete' rel='destroy' /&gt;
  &lt;/actions&gt;
&lt;/storage_volume&gt;
</pre>

<h4>Detach a storage volume from an instance</h4>

<p>
To detach the given storage volume from the instance to which it is currently attached use call <strong>POST /api/storage_volumes/:id/detach</strong>. A succesful operation will return <strong>HTTP 201 Accepted</strong> with details of the storage volume. Similarly to attach operation, in the example below, the <strong>state</strong> is reported as 'unknown' and the <strong>mount</strong> element is still present as the processing has not been completed yet (hence the 202 status code).
</p>

<p>Example request:</p>

<pre>
POST /api/storage_volumes/vol-0bc0de60/detach?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 202 Accepted
Content-Type: application/xml
Date: Thu, 28 Jul 2011 21:29:18 GMT
Content-Length: 709

&lt;?xml version='1.0' encoding='utf-8' ?&gt;
&lt;storage_volume href='http://localhost:3001/api/storage_volumes/vol-0bc0de60' id='vol-0bc0de60'&gt;
  &lt;capacity unit='GB'&gt;&lt;/capacity&gt;
  &lt;device&gt;/dev/sdi&lt;/device&gt;
  &lt;state&gt;unknown&lt;/state&gt;
  &lt;mount&gt;
    &lt;instance href='i-b100b3d0' id='i-b100b3d0'&gt;&lt;/instance&gt;
    &lt;device name='/dev/sdi'&gt;&lt;/device&gt;
  &lt;/mount&gt;
  &lt;actions&gt;
    &lt;link href='http://localhost:3001/api/storage_volumes/vol-0bc0de60/attach' method='post' rel='attach' /&gt;
    &lt;link href='http://localhost:3001/api/storage_volumes/vol-0bc0de60/detach' method='post' rel='detach' /&gt;
    &lt;link href='http://localhost:3001/api/storage_volumes/vol-0bc0de60' method='delete' rel='destroy' /&gt;
  &lt;/actions&gt;
&lt;/storage_volume&gt;
</pre>

  </div>
</div>

<a class="btn btn-inverse btn-large" style="float: right" href="/storage-snapshots.html">Storage snapshots <i class="icon-arrow-right icon-white" style="vertical-align:baseline"> </i></a>

<br/>

