---
site_name: Deltacloud API
title: CIMI Resource Collections - Resource Metadata
---

<br/>

<div class="row">
  <div class="span9">

<h3 id="cimi-resource-metadata">Resource Metadata</h3>
<p>
<strong><em>
ResourceMetadata may be used to:
<ul>
<li>Express constraints on the existing CIMI defined resource attributes (e.g., express a maximum for
the 'cpu' attribute of the MachineConfiguration resource) </li>
<li> Introduce new attributes for CIMI defined resources together with any constraints governing these
(e.g., a new 'location' attribute for the Volume resource that takes values from a defined set of strings)</li>
<li> Introduce new operations for any of the CIMI defined resources (e.g., define a new 'compress'
operation for the Volume resource)</li>
<li> Express any Provider specific capabilities or features (e.g., the length of time that a Job resource
will be retained after Job completion and before this is deleted)</li>
</ul>

Implementations of this specification should allow for Consumers to discover the metadata associated
with each supported resource. Doing so allows for the discovery of Provider defined constraints on the
CIMI defined attributes as well as discovery of any new extension attributes or operations that the
Provider may have defined. ResourceMetadata can also be used to express any Provider specific
capabilities or features. The mechanism by which this metadata is made available will be protocol
specific.
</em></strong>
</p>

  </div>
  <div class="span3">


<ul class="nav nav-list well">
  <li class="nav-header">
    CIMI REST API
  </li>
  <li><a href="/cimi-rest.html">Introduction</a></li>
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
  <hr/>
  <li class="nav-header">
    Resource Metadata
  </li>

</ul>

  </div>

</div>


<ul class="nav nav-pills">
  <li class="active"><a href="#resource-metadata" data-toggle="tab">Retrieve the ResourceMetadata Collection</a></li>
  <li><a href="#resource-metadata-capabilities" data-toggle="tab">ResourceMetadata Capabilities</a></li>
</ul>


<div class="tab-content">
  <div class="tab-pane active" id="resource-metadata">

<h4>Retrieve the ResourceMetadata Collection</h4>

<p>Example request:</p>

<pre>
GET /cimi/resource_metadata HTTP/1.1
Authorization: Basic bW9ja3VzZXI6bW9ja3Bhc3N3b3Jk
User-Agent: curl/7.24.0 (i686-redhat-linux-gnu) libcurl/7.24.0 NSS/3.13.5.0 zlib/1.2.5 libidn/1.24 libssh2/1.4.1
Host: localhost:3001
Accept: application/xml
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 200 OK
Content-Type: application/xml
CIMI-Specification-Version: 1.0.1
Content-Length: 1675
ETag: 97a131617573093b156505f77202bf57
Cache-Control: max-age=0, private, must-revalidate
Date: Fri, 11 Jan 2013 15:29:14 GMT
Connection: keep-alive
Server: thin 1.5.0 codename Knife

&lt;Collection xmlns="http://schemas.dmtf.org/cimi/1"
          resourceURI="http://schemas.dmtf.org/cimi/1/ResourceMetadataCollection"&gt;
  &lt;id&gt;http://localhost:3001/cimi/resource_metadata&lt;/id&gt;
  &lt;count&gt;2&lt;/count&gt;
  &lt;ResourceMetadata&gt;
    &lt;id&gt;http://localhost:3001/cimi/resource_metadata/cloud_entry_point&lt;/id&gt;
    &lt;name&gt;CloudEntryPoint&lt;/name&gt;
    &lt;typeUri&gt;http://schemas.dmtf.org/cimi/1/CloudEntryPoint&lt;/typeUri&gt;
    &lt;attribute name="driver" namespace="http://deltacloud.org/cimi/CloudEntryPoint/driver"
          type="text" required="true" /&gt;
    &lt;attribute name="provider" namespace="http://deltacloud.org/cimi/CloudEntryPoint/provider"
          type="text" required="true" /&gt;
  &lt;/ResourceMetadata&gt;
  &lt;ResourceMetadata&gt;
    &lt;id&gt;http://localhost:3001/cimi/resource_metadata/machine&lt;/id&gt;
    &lt;name&gt;Machine&lt;/name&gt;
    &lt;typeUri&gt;http://schemas.dmtf.org/cimi/1/Machine&lt;/typeUri&gt;
    &lt;attribute name="realm" namespace="http://deltacloud.org/cimi/Machine/realm"
           type="text" required="false"&gt;
      &lt;constraint&gt;
        &lt;value&gt;us&lt;/value&gt;
      &lt;/constraint&gt;
      &lt;constraint&gt;
        &lt;value&gt;eu&lt;/value&gt;
      &lt;/constraint&gt;
    &lt;/attribute&gt;
    &lt;attribute name="machine_image"
          namespace="http://deltacloud.org/cimi/Machine/machine_image" type="URI"
          required="false" /&gt;
    &lt;capability name="DefaultInitialState"
          uri="http://schemas.dmtf.org/cimi/1/capability/Machine/DefaultInitialState"
          description="Indicates what the default initial state of a new Machine "&gt;
          STARTED
    &lt;/capability&gt;
    &lt;capability name="InitialStates"
          uri="http://schemas.dmtf.org/cimi/1/capability/Machine/InitialStates"
          description="Indicates the list of allowable initial states"&gt;
          STARTED,STOPPED
    &lt;/capability&gt;
  &lt;/ResourceMetadata&gt;
&lt;/Collection&gt;
</pre>

  </div>

  <div class="tab-pane" id="resource-metadata-capabilities">

<h4>ResourceMetadata Capabilities</h4>
<br/>
<p>
<strong><em>
The following table describes the capability URIs defined by this specification. Providers may define new
URIs and it is recommended that these URIs be dereferencable such that Consumers can discover the
details of the new capability. The "Resource Name" column contains the name of the resource that may
contain the specified capability within its ResourceMetadata. The "Capability Name" column contains the
name of the specified capability and shall be unique within the scope of the corresponding resource. Each
capability's URI shall be constructed by appending the "Resource Name", a slash(/), and the "Capability
Name" to "http://schemas.dmtf.org/cimi/1/capability/". For example, the Machine's "InitialState" capability
would have a URI of:

<pre> http://schemas.dmtf.org/cimi/1/capability/Machine/InitialState </pre>

Note that capabilities that apply to the Provider in general, and are not specific to any one resource, are
associated with the Cloud Entry Point resource (in case a capability would apply only to the
CloudEntryPoint resource itself, its definition would say so).
</em></strong>
</p>
<br/>

<table class="table-bordered table-striped table-condensed">
  <thead>
    <tr>
      <th>
        Resource Name
      </th>
      <th>
        Capability Name
      </th>
      <th>
        Description
      </th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>CloudEntryPoint  </td>
      <td>ExpandParameter  </td>
      <td> Indicated whether the $expand query parameter is
supported by the Provider.
</td>
    </tr>
    <tr>
      <td>CloudEntryPoint
 </td>
      <td>FilterParameter
 </td>
      <td>Indicates whether the $filter query parameter is
supported by the Provider.
 </td>
    </tr>
    <tr>
      <td>CloudEntryPoint
 </td>
      <td>firstParameter
 </td>
      <td>Indicates whether the $first and $last query parameters
are supported by the Provider. Note that either both
shall be supported or neither shall be supported.
 </td>
    </tr>
    <tr>
      <td>CloudEntryPoint
 </td>
      <td>SelectParameter
 </td>
      <td>Indicated whether the $select query parameter is
supported by the Provider.
 </td>
    </tr>
    <tr>
      <td>System
 </td>
      <td>SystemComponentTemplateByValue
 </td>
      <td>Indicates that the Provider supports specifying
Component Templates by-value in SystemTemplates.
 </td>
    </tr>
    <tr>
      <td>Machine
 </td>
      <td>DefaultInitialState
 </td>
      <td>Indicates what the default initial state of a new Machine
will be unless explicitly set by the "initialState" attribute
 </td>
    </tr>
    <tr>
      <td>Machine
 </td>
      <td>InitialStates
 </td>
      <td>Indicates the list of allowable initial states that
Consumer may choose from when creating a new
Machine.
 </td>
    </tr>
    <tr>
      <td>Machine
 </td>
      <td>MachineConfigByValue
 </td>
      <td>Indicates that the Provider supports specifying Machine
Configurations by-value in Machine create operations. If
true the MachineTemplateByValue capability shall also
be specified with a value of true.
 </td>
    </tr>
    <tr>
      <td>Machine
 </td>
      <td>MachineCredentialByValue
 </td>
      <td>Indicates that the Provider supports specifying
Credential by-value in Machine create operations. If true
the MachineTemplateByValue capability shall also be
specified with a value of true.
 </td>
    </tr>
    <tr>
      <td>Machine
 </td>
      <td>MachineImageByValue
 </td>
      <td>Indicates that the Provider supports specifying Machine
Images by-value in Machine create operations. If true
the MachineTemplateByValue capability shall also be
specified with a value of true.
 </td>
    </tr>
    <tr>
      <td>Machine
 </td>
      <td>MachineVolumeTemplatesByValue
 </td>
      <td>Indicates that the Provider supports specifying
VolumeTemplates by-value in Machine create
operations. If true the MachineTemplateByValue
capability shall also be specified with a value of true.
 </td>
    </tr>
    <tr>
      <td>Machine
 </td>
      <td>MachineStopForce
 </td>
      <td>Indicates that the Provider supports specifying the
"force" option on the stop and restart operations.
 </td>
    </tr>
    <tr>
      <td>Machine
 </td>
      <td>MachineStopForceDefault
 </td>
      <td>Indicates the default way in which the Provider will
stop/restart a Machine. When set to "true", the Provider
will forcefully stop the Machine, as opposed to a value
of "false," which indicates that the Provider will attempt
to gracefully stop the Machine.
 </td>
    </tr>
    <tr>
      <td>Machine
 </td>
      <td>RestoreFromImage
 </td>
      <td>Indicates that the Provider supports restoring Machines
from Machine Images that are not SNAPSHOT Machine
Images.
 </td>
    </tr>
    <tr>
      <td>Machine
 </td>
      <td>UserData
 </td>
      <td>Indicates which userData injection method will be used.
See 5.14.1 for more information.
 </td>
    </tr>
    <tr>
      <td>Credential
 </td>
      <td>CredentialTemplateByValue
 </td>
      <td>Indicates that the Provider supports specifying
Credential Templates by-value in Credential create
operations.
 </td>
    </tr>
    <tr>
      <td>Volume
 </td>
      <td>SharedVolumeSupport
 </td>
      <td>Indicates that the Provider supports the sharing of
volume resources across Machines. The value specified
is of type "boolean."
 </td>
    </tr>
    <tr>
      <td>Volume
 </td>
      <td>VolumeConfigByValue
 </td>
      <td>Indicates that the Provider supports specifying Volume
Configurations by-value in the Volume create operation.
If true, the VolumeTemplateByValue capability shall
also be specified with a value of true.
 </td>
    </tr>
    <tr>
      <td>Volume
 </td>
      <td>VolumeImageByValue
 </td>
      <td>Indicates that the Provider supports specifying Volume
Images by-value in the Volume create operation. If true
the VolumeTemplateByValue capability shall also be
specified with a value of true.
 </td>
    </tr>
    <tr>
      <td>Volume
 </td>
      <td>VolumeSnapshot
 </td>
      <td>Indicates that the Provider supports creating a new
VolumeImage by referencing an existing Volume.
 </td>
    </tr>
    <tr>
      <td>Volume
 </td>
      <td>VolumeTemplateByValue
 </td>
      <td>Indicates that the Provider supports specifying Volume
Templates by-value in Volume create operations.
 </td>
    </tr>
    <tr>
      <td>Network
 </td>
      <td>NetworkConfigByValue
 </td>
      <td>Indicates that the Provider supports specifying Network
Configurations by-value in the Network create
operation.
 </td>
    </tr>
    <tr>
      <td>Network
 </td>
      <td>NetworkTemplateByValue
 </td>
      <td>Indicates that the Provider supports specifying Network
Templates by-value in the Network create operation.
 </td>
    </tr>
    <tr>
      <td>NetworkPort
 </td>
      <td>NetworkPortConfigByValue
 </td>
      <td>Indicates that the Provider supports specifying
NetworkPort Configurations by-value in the NetworkPort
create operation.
 </td>
    </tr>
    <tr>
      <td>NetworkPort
 </td>
      <td>NetworkPortTemplateByValue
 </td>
      <td>Indicates that the Provider supports specifying
NetworkPort Templates by-value in the NetworkPort
create operation.
 </td>
    </tr>
    <tr>
      <td>ForwardingGroup
 </td>
      <td>MixedNetwork
 </td>
      <td>Indicates whether ForwardingGroups can support both
private and public connection at the same time.
 </td>
    </tr>
    <tr>
      <td>Job
 </td>
      <td>JobRetention
 </td>
      <td>If the Provider supports Job resources as specified in
this document, this capability indicates in minutes how
long a job will live in the system before its deleted. In
this case, the value attribute provides the number of
minutes (e.g., 30 min). The value specified is of type
"integer."
 </td>
    </tr>
    <tr>
      <td>Meter
 </td>
      <td>MeterConfigByValue
 </td>
      <td>Indicates that the Provider supports specifying
MeterConfigurations by-value in the Meter create
operation.
 </td>
    </tr>
    <tr>
      <td>Meter
 </td>
      <td>MeterTemplateByValue
 </td>
      <td>Indicates that the Provider supports specifying Meter
Templates by-value in the Meter create operation.
 </td>
    </tr>
    <tr>
      <td>EventLog
 </td>
      <td>Linked
 </td>
      <td>Indicates that the Provider shall delete EventLogs that
are associated with resources when the resource is
deleted.
 </td>
    </tr>
  </tbody>
</table>

  </div>
</div>
