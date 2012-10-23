---
site_name: Deltacloud API
title: Images
---

<br/>

<div class="row">
  <div class="span9">

<h3 id="images">Images</h3>

<p>
Images are used to launch instances. Each image represents a virtual machine image in the back-end cloud, containing the root partition and initial storage for an instance operating system. An image has these attributes:
</p>

<ul>
  <li>a human-readable <strong>name</strong></li>
  <li>a <strong>description</strong></li>
  <li>an <strong>owner_id</strong></li>
  <li>an <strong>architecture</strong></li>
  <li>a <strong>state</strong></li>
</ul>

<p>
The <strong>owner_id</strong> identifies the user account to which the image belongs. The <strong>architecture</strong> attribute refers to whether the image will create an instance with 32 or 64-bit processor. The values that the Deltacloud server returns for this attribute are thus i386 and x86_64 respectively. The state attribute varies between back-end clouds (it depends on a cloud provider). For example, AWS EC2 image state can be one of AVAILABLE, PENDING or FAILED, whereas Rackspace Cloudservers image state can be one of UNKNOWN, PREPARING, ACTIVE, QUEUED or FAILED. Finally, each image also contains an <code>&lt;actions&gt;</code> attribute which specifies the URI to which a client may issue a <strong>HTTP POST</strong> for creation of an instance from the given image.
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
  <ul class="nav nav-list">
    <li><a href="/compute-resources.html#realms">Realms</a></li>
    <li><a href="/hardware-profiles.html">Hardware profiles</a></li>
    <li class="active"><a href="#images">Images</a></li>
    <li><a href="/instance-states.html">Instance states</a></li>
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

<br/>

<ul class="nav nav-pills">
  <li class="active"><a href="#tab1" data-toggle="tab">Get a list of all images</a></li>
  <li><a href="#tab2" data-toggle="tab">Get the details of an image</a></li>
  <li><a href="#tab3" data-toggle="tab">Create/delete an image</a></li>
</ul>

<hr>

<div class="tab-content">
  <div class="tab-pane active" id="tab1">

<h4>Get the list of all images</h4>

<p>
To return a list of all images available in the back-end cloud use call <strong>GET /api/images</strong>. By default this call will return all images that are available to the given user account. Optionally a client may restrict the list of images returned by specifying the <strong>owner_id</strong> or <strong>architecture</strong> parameters in the request (architecture is one of x86_64 for 64-bit processors or i386 for 32-bit processors). The example below restricts the image list to 64-bit architecture images belonging to owner_id 023801271342.
</p>

<p>Example request:</p>

<pre>
GET /api/images?owner_id=023801271342&architecture=x86_64&format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 200 OK
Content-Type: application/xml
Content-Length: 1971

&lt;?xml version='1.0' encoding='utf-8' ?&gt;
&lt;images&gt;
  &lt;image href='http://localhost:3001/api/images/ami-eea35787' id='ami-eea35787'&gt;
    &lt;name&gt;sles-10-sp3-v1.00.x86_64&lt;/name&gt;
    &lt;owner_id&gt;013907871322&lt;/owner_id&gt;
    &lt;description&gt;SUSE Linux Enterprise Server 10 Service Pack 3 for x86_64 (v1.00)&lt;/description&gt;
    &lt;architecture&gt;x86_64&lt;/architecture&gt;
    &lt;state&gt;&lt;/state&gt;
    &lt;actions&gt;
      &lt;link href='http://localhost:3001/api/instances;image_id=ami-eea35787' method='post' rel='create_instance' /&gt;
    &lt;/actions&gt;
  &lt;/image&gt;
  &lt;image href='http://localhost:3001/api/images/ami-6e649707' id='ami-6e649707'&gt;
    &lt;name&gt;sles-11-sp1-hvm-v1.00.x86_64&lt;/name&gt;
    &lt;owner_id&gt;013907871322&lt;/owner_id&gt;
    &lt;description&gt;SUSE Linux Enterprise Server 11 Service Pack 1 for HVM x86_64 (v1.00)&lt;/description&gt;
    &lt;architecture&gt;x86_64&lt;/architecture&gt;
    &lt;state&gt;&lt;/state&gt;
    &lt;actions&gt;
      &lt;link href='http://localhost:3001/api/instances;image_id=ami-6e649707' method='post' rel='create_instance' /&gt;
    &lt;/actions&gt;
  &lt;/image&gt;
  &lt;image href='http://localhost:3001/api/images/ami-e4a7558d' id='ami-e4a7558d'&gt;
    &lt;name&gt;sles-11-sp1-hvm-v1.01.x86_64&lt;/name&gt;
    &lt;owner_id&gt;013907871322&lt;/owner_id&gt;
    &lt;description&gt;SUSE Linux Enterprise Server 11 Service Pack 1 for HVM x86_64 (v1.01)&lt;/description&gt;
    &lt;architecture&gt;x86_64&lt;/architecture&gt;
    &lt;state&gt;&lt;/state&gt;
    &lt;actions&gt;
      &lt;link href='http://localhost:3001/api/instances;image_id=ami-e4a7558d' method='post' rel='create_instance' /&gt;
    &lt;/actions&gt;
  &lt;/image&gt;
  &lt;image href='http://localhost:3001/api/images/ami-e4a3578d' id='ami-e4a3578d'&gt;
    &lt;name&gt;sles-11-sp1-v1.00.x86_64&lt;/name&gt;
    &lt;owner_id&gt;013907871322&lt;/owner_id&gt;
    &lt;description&gt;SUSE Linux Enterprise Server 11 Service Pack 1 for x86_64 (v1.00)&lt;/description&gt;
    &lt;architecture&gt;x86_64&lt;/architecture&gt;
    &lt;state&gt;&lt;/state&gt;
    &lt;actions&gt;
      &lt;link href='http://localhost:3001/api/instances;image_id=ami-e4a3578d' method='post' rel='create_instance' /&gt;
    &lt;/actions&gt;
  &lt;/image&gt;
&lt;/images&gt;
</pre>

  </div>
  <div class="tab-pane" id="tab2">

<h4>Get details of an image</h4>

<p>To retrieve the description of a specific image use call <strong>GET /api/images/:id</strong>.</p>

<p>Example request:</p>

<pre>
GET /api/images/14?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3002
Accept: */*
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 200 OK
Content-Type: application/xml
Content-Length: 433

&lt;?xml version='1.0' encoding='utf-8' ?&gt;
&lt;image href='http://localhost:3002/api/images/14' id='14'&gt;
  &lt;name&gt;Red Hat Enterprise Linux 5.4&lt;/name&gt;
  &lt;owner_id&gt;jsmith&lt;/owner_id&gt;
  &lt;description&gt;Red Hat Enterprise Linux 5.4&lt;/description&gt;
  &lt;architecture&gt;x86_64&lt;/architecture&gt;
  &lt;state&gt;ACTIVE&lt;/state&gt;
  &lt;actions&gt;
    &lt;link href='http://localhost:3002/api/instances;image_id=14' method='post' rel='create_instance' /&gt;
  &lt;/actions&gt;
&lt;/image&gt;
</pre>

  </div>
  <div class="tab-pane" id="tab3">

<h4>Create an image</h4>

<p>
To create a new image from an existing running instance use call <strong>POST /api/images</strong>. This operation is not available to all cloud providers and for some cloud providers this operation is not possible for all instances. For example, in the Amazon EC2 cloud, you can create a custom image from EBS backed instances but not from root-store instances.
</p>

<div class="alert alert-error">
  <a class="close" data-dismiss="alert" href="#">×</a>
  <strong>Note: </strong>
  <p>
  RHVE-M, vSphere and Fujitsu GCP providers allow you to create an image only from a stopped instance, not from a running instance.
  </p>
</div>

<p>
The Deltacloud API provides a mechanism with which clients can determine whether a given instance may be saved as a custom image. If an instance snapshot is possible, the instance XML <code>&lt;actions&gt;</code> list contains a <strong>create_image</strong> action. This action defines the client's URI which is used in creating the new image. For example:
</p>

<pre>
...
&lt;actions&gt;
  &lt;link href='http://localhost:3002/api/instances/20109341/reboot' method='post' rel='reboot' /&gt;
  &lt;link href='http://localhost:3002/api/instances/20109341/stop' method='post' rel='stop' /&gt;
  &lt;link href='http://localhost:3002/api/instances/20109341/run;id=20109341' method='post' rel='run' /&gt;
  &lt;link href='http://localhost:3002/api/images;instance_id=20109341' method='post' rel='create_image' /&gt;
&lt;/actions&gt;
...
</pre>

<p>
To create a new image the client must specify the <strong>instance_id</strong> of the running instance. Optionally, the client may also provide a <strong>name</strong> and a <strong>description</strong>. The parameters may be defined as multipart/form-data fields in the client POST.
</p>

<p>
Alternatively, clients may also specify parameters using a content-type of application/x-www-form-urlencoded. The Deltacloud server will respond to a successful operation with <strong>HTTP 201 Created</strong> and provide details of the newly created image.
</p>

<p>Example request:</p>

<pre>
POST /api/images?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3002
Accept: */*
Content-Length: 96
Content-Type: application/x-www-form-urlencoded

instance_id=20109341&name=customisedserver&description=jsmith%20cu
stomised%20web%20server%20July%2021%202011
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 201 Created
Content-Type: application/xml
Content-Length: 427

&lt;?xml version='1.0' encoding='utf-8' ?&gt;
&lt;image href='http://localhost:3002/api/images/12346145' id='12346145'&gt;
  &lt;name&gt;customisedserver&lt;/name&gt;
  &lt;owner_id&gt;mandreou&lt;/owner_id&gt;
  &lt;description&gt;customisedserver&lt;/description&gt;
  &lt;architecture&gt;x86_64&lt;/architecture&gt;
  &lt;state&gt;QUEUED&lt;/state&gt;
  &lt;actions&gt;
    &lt;link href='http://localhost:3002/api/instances;image_id=12346145' method='post' rel='create_instance' /&gt;
  &lt;/actions&gt;
&lt;/image&gt;
</pre>

<div class="alert alert-error">
  <a class="close" data-dismiss="alert" href="#">×</a>
  <strong>Note: </strong>
  <p>When you create an image from a stopped instance in <strong>vSphere</strong> cloud, this particular instance is marked as <strong>template</strong> and it is also removed from Instances.</p>

  <p>Unlike other providers, vSphere does not support assigning a <strong>name</strong> and a <strong>description</strong> to the image when you create an image from a stopped instance. The image created in vSphere ignores these attributes passed to the API during the creation.</p>
  <p><strong>Fujitsu GCP</strong> does not return an ID that can be used to track the state of the image
  creation. Poll the list of all images until your image appears. This will contain the
  proper image id that can be used in other image actions.
  </p>

</div>

<h4>Delete an image</h4>

<p>
To delete the specified image from the back-end cloud use call <strong>DELETE /api/images/:id</strong>. The Deltacloud server will return a <strong>HTTP 204 No Content</strong> after a succesful operation:
</p>

<p>Example request:</p>

<pre>
DELETE /api/images/12346145?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3002
Accept: */*
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 204 No Content
</pre>

  </div>
</div>


<a class="btn btn-inverse btn-large" style="float: right" href="/instance-states.html">Instance states <i class="icon-arrow-right icon-white" style="vertical-align:baseline"> </i></a>

<br/>
