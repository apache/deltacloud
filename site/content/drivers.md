---
site_name: Deltacloud API
title: Drivers
---

<br/>

<div class="row">
  <div class="span8">

<h3>Deltacloud drivers</h3>

<p>
Deltacloud provides drivers for a growing number of popular IaaS <a href="#drivers">cloud providers</a>. This page contains notes relevant to specific cloud provider drivers, such as the <a href="#credentials">credentials</a> that should be used for a given cloud provider. Furthermore the information here outlines the mechanism through which any API call sent by a given client to a Deltacloud server instance may be routed to a specific driver, regardless of the 'default' driver that the Deltacloud server was invoked for.
</p>

<h4 id="switch">Dynamic driver switching</h4>

<p>
When the Deltacloud server is started it is passed a parameter that specifies the <strong>default</strong> driver to be used for API operations:
</p>


  </div>
  <div class="span4">

<ul class="nav nav-list well">
  <li class="nav-header">Drivers</li>
  <li class="active"><a href="#switch">Dynamic driver switching</a></li>
  <li><a href="#drivers">Driver functionality and credentials</a></li>
  <ul class="nav nav-list">
    <li><a href="#func">Compute driver functionality</a></li>
    <li><a href="#storage">Storage driver functionality</a></li>
    <li><a href="#credentials">Cloud provider credentials</a></li>
  </ul>
  <li><a href="#notes">Notes on specific drivers</a></li>
</ul>

  </div>
</div>

<pre>
$ deltacloudd -i ec2
</pre>

<p>
The above example shows how to start the Detlacloud server with the Amazon EC2 driver. It is possible to start a number of Deltacloud server instances for each cloud provider that you wish to connect to (e.g. on different ports). There is also a mechanism is with which you can instruct the server to use a specific driver, regardless of the current default. The Deltacloud API drivers collection (e.g. GET /api/drivers) provides a list of all currently supported cloud provider drivers.
</p>

<p>
Some drivers also support the notion of a provider. Changing the provider makes it possible to use the same driver against different instances of a cloud, for example different regions in EC2 or different installations of RHEV-M. The possible range of values for the provider is driver-specific, and it is listed in the notes for each driver below.
</p>

<p>
The driver and provider can be selected through the request headers <strong> X-Deltacloud-Driver</strong> and <strong>X-Deltacloud-Provider</strong>. For example, including the headers <strong>X-Deltacloud-Driver: ec2</strong> and <strong>X-Deltacloud-Provider: eu-west-1</strong> ensures that a request will be serviced by the EC2 driver, and that the driver will use the eu-west-1 region in EC2.
</p>

<h3 id="drivers">Driver functionality and Credentials</h3>

<h4 id="func">Compute Driver Functionality</h4>
<table class="table-bordered table-striped table-condensed">
  <thead>
    <tr>
      <th class='emptycell'>&nbsp;</th>
      <th>
        Create new instances
      </th>
      <th>
        Start stopped instances
      </th>
      <th>
        Stop running instances
      </th>
      <th>
        Reboot running instances
      </th>
      <th>
        Destroy instances
      </th>
      <th>
        List all/get details about hardware profiles
      </th>
      <th>
        List all/get details about realms
      </th>
      <th>
        List all/get details about images
      </th>
      <th>
        List all/get details about instances
      </th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class='provider'>
        <strong>Amazon EC2</strong>
      </td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">no</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      </p>
    </tr>
    <tr>
      <td class='provider'>
        <strong>Eucalyptus</strong>
      </td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">no</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>Fujitsu FGCP</strong>
      </td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">no</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>IBM SmartCloud</strong>
      </td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>GoGrid</strong>
      </td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">no</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>OpenNebula</strong>
      </td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>Rackspace</strong>
      </td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">no</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>RHEV-M</strong>
      </td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">no</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>RimuHosting</strong>
      </td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>Terremark</strong>
      </td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>vSphere</strong>
      </td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>OpenStack</strong>
      </td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>Aruba cloud.it</strong>
      </td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
    </tr>
  </tbody>
</table>

<br/>

<h4 id="storage">Storage Driver Functionality</h4>
<table class="table-bordered table-striped table-condensed">
  <thead>
    <tr>
      <th class='emptycell'>&nbsp;</th>
      <th>
        Create new buckets
      </th>
      <th>
        Update/delete buckets
      </th>
      <th>
        Create new blobs
      </th>
      <th>
        Update/delete blobs
      </th>
      <th>
        Read/write blob attributes
      </th>
      <th>
        Read/write individual blob attributes
      </th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class='provider'>
        <strong>Amazon S3</strong>
      </td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>Eucalyptus Walrus</strong>
      </td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>Rackspace CloudFiles</strong>
      </td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>Microsoft Azure</strong>
      </td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>Google Storage</strong>
      </td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
      <td style="text-align:center">yes</td>
    </tr>
  </tbody>
</table>
<br/>
<p>
Deltacloud uses basic HTTP <a href="/rest-api.html#auth">authentication</a> to receive credentials from the client and passes them through to the particular back-end cloud. The credentials always consist of a username and password and they are never stored on the server. The exact credentials for logging into the server, and a place where you can find them, depends on the backend cloud that the server is talking to.
</p>

<p>
The following table gives details about the credentials that must be provided for each of the supported clouds. The entry from the Driver column needs to be passed as the -i option to the deltacloudd server daemon. Note that some of the drivers require additional information, e.g. API endpoint URL's. For more details see the <a href="#notes">Notes on specific drivers</a> section.
</p>

<style>
 table { table-layout: fixed; }
 table th, table td { overflow: hidden; }
</style>

<h4 id="credentials">Cloud provider credentials</h4>
<table class="table-bordered table-striped table-condensed">
  <thead>
    <tr>
      <th style="width:15%">Cloud</th>
      <th style="width:8%">Driver</th>
      <th style="width:20%">Username</th>
      <th style="width:10%">Password</th>
      <th style="width:47%">Notes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <strong>mock</strong>
      </td>
      <td>mock</td>
      <td>mockuser</td>
      <td>mockpassword</td>
      <td>The mock driver does not communicate with any cloud; it just pretends to be a cloud.</td>
    </tr>
    <tr>
      <td>
        <strong>Amazon EC2/S3</strong>
      </td>
      <td>ec2</td>
      <td>Access Key ID</td>
      <td>Secret Access Key</td>
      <td>Retrieve neccessary information from the <a href="http://aws-portal.amazon.com/gp/aws/developer/account/index.html?action=access-key">Security Credentials</a> page in your AWS account.</td>
    </tr>
    <tr>
      <td>
        <strong>Eucalyptus</strong>
      </td>
      <td>eucalyptus</td>
      <td>Access Key ID</td>
      <td>Secret Access Key</td>
      <td></td>
    </tr>
    <tr>
      <td>
        <strong>Fujitsu FGCP</strong>
      </td>
      <td>fgcp</td>
      <td>User certificate's folder name</td>
      <td>User certificate's passphrase</td>
      <td>
      <p>Set the environment variable FGCP_CERT_DIR to a folder where the folder with UserCert.p12 is stored or place UserCert.p12 in</p>
<p><code style="font-size:small; color:#606060">
~/.deltacloud/config/fgcp/&lt;Username&gt;/
</code>&nbsp; or</p>
<p><code style="font-size:small; color:#606060">
%USERPROFILE%\.deltacloud\config\fgcp\&lt;Username&gt;\
</code></p>
      <p style="margin-bottom:0px">in Windows. Then use Username to authenticate.</p>
      </td>
    </tr>
    <tr>
      <td>
        <strong>GoGrid</strong>
      </td>
      <td>gogrid</td>
      <td>API Key</td>
      <td>Shared Secret</td>
      <td>
      Go to <span style="font-size:small">My Account > API Keys</span> for <a href="https://my.gogrid.com/gogrid/com.servepath.gogrid.GoGrid/index.html">your account</a> and click on the key you want to use to find the Shared Secret.
      </td>
    </tr>
    <tr>
      <td>
        <strong>IBM SmartCloud</strong>
      </td>
      <td>sbc</td>
      <td>Username</td>
      <td>Password</td>
      <td></td>
    </tr>
    <tr>
      <td>
        <strong>Microsoft Azure (Storage Account only)</strong>
      </td>
      <td>azure</td>
      <td>Public Storage Account Name</td>
      <td>Primary Access Key</td>
      <td>
      The Storage Account Name is chosen when you create the service (e.g. name in <a href="http://name.blob.core.windows.net/">name.blob.core.windows.net</a>). The name and the access key are available from the service control panel.
      </td>
    </tr>
    <tr>
      <td>
        <strong>OpenNebula</strong>
      </td>
      <td>opennebula</td>
      <td>OpenNebula user</td>
      <td>OpenNebula password</td>
      <td>Set the environment variable OCCI_URL to the address on which OpenNebula's OCCI server is listening.</td>
    </tr>
    <tr>
      <td>
        <strong>OpenStack</strong>
      </td>
      <td>openstack</td>
      <td>OpenStack user</td>
      <td>OpenStack user password</td>
      <td>Set the environment variable API_PROVIDER to the URL of OpenStack API entrypoint.</td>
    </tr>
    <tr>
      <td>
        <strong>Rackspace Cloud Servers/Cloud Files</strong>
      </td>
      <td>rackspace</td>
      <td>Rackspace user name</td>
      <td>API Key</td>
      <td>Obtain the key from the <a href="https://manage.rackspacecloud.com/APIAccess.do">API Access</a> page in your control panel.</td>
    </tr>
    <tr>
      <td>
        <strong>RHEV-M</strong>
      </td>
      <td>rhevm</td>
      <td>
      <a href="http://markmc.fedorapeople.org/rhevm-api/en-US/html/chap-REST_API_Guide-Authentication.html">RHEV-M user name plus Windows domain</a>, e.g., admin@rhevm.example.com
      </td>
      <td>RHEV-M password</td>
      <td>Set the environment variable API_PROVIDER to the URL of the RHEV-M REST API endpoint. </td>
    </tr>
    <tr>
      <td>
        <strong>Rimuhosting</strong>
      </td>
      <td>rimuhosting</td>
      <td>not used (?)</td>
      <td>API Key</td>
      <td></td>
    </tr>
    <tr>
      <td>
        <strong>Terremark</strong>
      </td>
      <td>terremark</td>
      <td>Username</td>
      <td>Password</td>
      <td></td>
    </tr>
    <tr>
      <td>
        <strong>VMware vSphere</strong>
      </td>
      <td>vsphere</td>
      <td>vSphere user</td>
      <td>vSphere user password</td>
      <td>Set the environment variable API_PROVIDER to the hostname of the vSphere server and the Datastore.</td>
    </tr>
    <tr>
      <td>
        <strong>Aruba cloud.it</strong>
      </td>
      <td>aruba</td>
      <td>Username</td>
      <td>Password</td>
      <td></td>
    </tr>

  </tbody>
</table>

<br/>

<h3 id="notes">Notes on specific drivers</h3>

<div class="accordion" id="specific">
  <div class="accordion-group">
    <div class="accordion-heading">
      <a class="accordion-toggle" data-toggle="collapse" data-parent="#specific" href="#ec2">
        EC2 driver
      </a>
    </div>
    <div id="ec2" class="accordion-body collapse in">
      <div class="accordion-inner">
      The providers for the EC2 driver correspond to AWS's regions, and currently support all EC2 regions.
      </div>
    </div>
  </div>
  <div class="accordion-group">
    <div class="accordion-heading">
      <a class="accordion-toggle" data-toggle="collapse" data-parent="#specific" href="#eucalyptus">
        Eucalyptus driver
      </a>
    </div>
    <div id="eucalyptus" class="accordion-body collapse">
      <div class="accordion-inner">
<p>
The Eucalyptus driver is based on the EC2 driver.
</p>

<p>
The driver allows selecting the Eucalyptus installation by setting a provider in the format
</p>

<p>
For example, for the Eucalyptus installation at 192.168.1.1:8773 and a Walrus installation at 192.168.1.2:8773, the driver can be pointed at that installation by passing the request headers
</p>

<pre>
X-Deltacloud-Driver: eucalyptus
X-Deltacloud-Provider: ec2=192.168.1.1:8773;s3=192.168.1.2:8773
</pre>
      </div>
    </div>
  </div>
  <div class="accordion-group">
    <div class="accordion-heading">
      <a class="accordion-toggle" data-toggle="collapse" data-parent="#specific" href="#ibm">
        IBM Smartcloud driver
      </a>
    </div>
    <div id="ibm" class="accordion-body collapse">
      <div class="accordion-inner">
      When using the IBM SmartCloud driver, the credentials passed in response to the HTTP 401 authentication challenge should be your IBM SmartCloud username and password.
      </div>
    </div>
  </div>
  <div class="accordion-group">
    <div class="accordion-heading">
      <a class="accordion-toggle" data-toggle="collapse" data-parent="#specific" href="#nebula">
        OpenNebula
      </a>
    </div>
    <div id="nebula" class="accordion-body collapse">
      <div class="accordion-inner">
<p>
When you use the <a href="http://www.opennebula.org/">OpenNebula</a> driver, the credentials passed in response to the HTTP 401 authentication challenge should be your OpenNebula user and password.
</p>

<p>
The address, on which the OCCI server is listening, needs to be defined in an environment variable called OCCI_URL.
</p>

<p>
The OpenNebula driver has been updated to support v3.x of the OpenNebula API. The driver is contributed by Daniel Molina who has also put together a <a href="http://wiki.opennebula.org/deltacloud">guide</a> for using OpenNebula through Deltacloud.
</p>
      </div>
    </div>
  </div>
  <div class="accordion-group">
    <div class="accordion-heading">
      <a class="accordion-toggle" data-toggle="collapse" data-parent="#specific" href="#fgcp">
        Fujitsu FGCP driver
      </a>
    </div>
    <div id="fgcp" class="accordion-body collapse">
      <div class="accordion-inner">
      <p>
      When you use the Fujitsu FGCP driver, do not authenticate with your FGCP Portal username. Use the name of the folder in which your UserCert.p12 is stored. UserCert.p12 can be issued from the Portal and it is the same as you use to access MyPortal.
      </p>
      <p>
      Set the enviroment variable FGCP_CERT_DIR to override the default path <strong>~/.deltacloud/config/fgcp/</strong> to locate the Username folder with the UserCert.p12 file.
      </p>
      </div>
    </div>
  </div>
  <div class="accordion-group">
    <div class="accordion-heading">
      <a class="accordion-toggle" data-toggle="collapse" data-parent="#specific" href="#open">
        OpenStack driver
      </a>
    </div>
    <div id="open" class="accordion-body collapse">
      <div class="accordion-inner">
      To connect to OpenStack API, you will need to set the API_provider environment variable or the 'X-Deltacloud-Provider' HTTP header to a valid OpenStack API entrypoint.
      </div>
    </div>
  </div>
  <div class="accordion-group">
    <div class="accordion-heading">
      <a class="accordion-toggle" data-toggle="collapse" data-parent="#specific" href="#rack">
        Rackspace driver
      </a>
    </div>
    <div id="rack" class="accordion-body collapse">
      <div class="accordion-inner">
      When you use the Rackspace-cloud driver (Rackspace cloud used to be called "Mosso") - the password in a HTTP 401 challenge should be your API key, NOT your Rackspace account password. You can get the API-key, or generate a new one, from the Rackspace console.
      </div>
    </div>
  </div>
  <div class="accordion-group">
    <div class="accordion-heading">
      <a class="accordion-toggle" data-toggle="collapse" data-parent="#specific" href="#rhev">
        RHEV-M driver
      </a>
    </div>
    <div id="rhev" class="accordion-body collapse">
      <div class="accordion-inner">
<p>
The RHEV-M driver supports latest release of Red Hat Enterprise Virtualization Manager (3.0 currently). In order to make the driver work with this provider, you need to set the API_PROVIDER environment variable or use the 'X-Deltacloud-Provider' request header to the URL of the RHEV-M REST API entry point. The usual URL looks like:
</p>

<pre>
API_PROVIDER="https://rhevm.hostname.com:8443/api;645e425e-66fe-4ac9-8874-537bd10ef08d"
</pre>

<p>
To make sure that you have right credentials, try to access https://rhevm.hostname.com:8443/rhevm-api in your browser. If you're able to authenticate within the browser, then the crendentials you used are valid Deltacloud credentials.
</p>

<p>
In order to make RHEV-M driver work properly, you need to set the RHEV-M Data Center UUID you want to speak with in API_PROVIDER url (see the example above). To obtain a list of all Data Centers you can choose from, start Deltacloud API without specifying a datacenter in the API_PROVIDER URL and do this request:
</p>

<pre>
GET /api/drivers/rhevm?format=xml
</pre>

<p>
The list of possible datacenters will appear in the 'providers' section.
</p>
      </div>
    </div>
  </div>
  <div class="accordion-group">
    <div class="accordion-heading">
      <a class="accordion-toggle" data-toggle="collapse" data-parent="#specific" href="#rimu">
        RimuHosting
      </a>
    </div>
    <div id="rimu" class="accordion-body collapse">
      <div class="accordion-inner">
      Further details coming soon.
      </div>
    </div>
  </div>
  <div class="accordion-group">
    <div class="accordion-heading">
      <a class="accordion-toggle" data-toggle="collapse" data-parent="#specific" href="#vmware">
        VMware vSphere driver
      </a>
    </div>
    <div id="vmware" class="accordion-body collapse">
      <div class="accordion-inner">
<p>
You can find the details on how to make the VMware vSphere driver work with Deltacloud API in <a href="https://www.aeolusproject.org/redmine/projects/aeolus/wiki/VSphere_Setup">vSphere Setup</a> in Aeolus project wiki.
</p>

<p>
In order to connect to vSphere, you need to set the API_PROVIDER environment variable or use the 'X-Deltacloud-Provider' HTTP header in the request to the vSphere host you want to use and the Datastore you want to speak to. For example:
</p>

<pre>API_PROVIDER="vsphere.hostname.com;DATASTORE-ID"</pre>

<p>
The username and password in 401 challenge should be the same as you use in the vSphere Control Center.
</p>
      </div>
    </div>
  </div>
</div>

