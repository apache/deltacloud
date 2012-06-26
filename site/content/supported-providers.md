---
site_name: Deltacloud API
title: Supported Providers
---
<br/>
<h3>Driver functionality and Credentials</h3>

<h4>Compute Driver Functionality</h4>
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
      <td>yes</td>
      <td>no</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      </p>
    </tr>
    <tr>
      <td class='provider'>
        <strong>Eucalyptus</strong>
      </td>
      <td>yes</td>
      <td>no</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>IBM SBC</strong>
      </td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>GoGrid</strong>
      </td>
      <td>yes</td>
      <td>no</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>OpenNebula</strong>
      </td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>Rackspace</strong>
      </td>
      <td>yes</td>
      <td>no</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>RHEV-M</strong>
      </td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>no</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>RimuHosting</strong>
      </td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>Terremark</strong>
      </td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>vSphere</strong>
      </td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>OpenStack</strong>
      </td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>FGCP</strong>
      </td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>no</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
    </tr>
  </tbody>
</table>
<br/>
<h4>Storage Driver Functionality</h4>
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
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>Eucalyptus Walrus</strong>
      </td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>Rackspace CloudFiles</strong>
      </td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>Microsoft Azure</strong>
      </td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
    </tr>
    <tr>
      <td class='provider'>
        <strong>Google Storage</strong>
      </td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
      <td>yes</td>
    </tr>
  </tbody>
</table>

<br/>

<h4 id="credentials">Cloud provider credentials</h4>
<table class="table-bordered table-striped table-condensed">
  <thead>
    <tr>
      <th>Cloud</th>
      <th>Driver</th>
      <th>Username</th>
      <th>Password</th>
      <th>Notes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align:left">
        <strong>mock</strong>
      </td>
      <td style="text-align:left"><span style="font-size:x-small">mock</span></td>
      <td style="text-align:left"><span style="font-size:x-small">mockuser</span></td>
      <td style="text-align:left"><span style="font-size:x-small">mockpassword</span></td>
      <td style="text-align:left">The mock driver doesn't talk to any cloud; it just pretends to be a cloud.</td>
    </tr>
    <tr>
      <td style="text-align:left">
        <strong>Amazon EC2/S3</strong>
      </td>
      <td style="text-align:left"><span style="font-size:x-small">ec2</span></td>
      <td style="text-align:left">Access Key ID</td>
      <td style="text-align:left">Secret Access Key</td>
      <td style="text-align:left">This information can be found on the <a href="http://aws-portal.amazon.com/gp/aws/developer/account/index.html?action=access-key">Security Credentials</a> page in your AWS account.</td>
    </tr>
    <tr>
      <td style="text-align:left">
        <strong>Eucalyptus</strong>
      </td>
      <td style="text-align:left"><span style="font-size:x-small">eucalyptus</span></td>
      <td style="text-align:left">Access Key ID</td>
      <td style="text-align:left">Secret Access Key</td>
      <td style="text-align:left"></td>
    </tr>
    <tr>
      <td style="text-align:left">
        <strong>GoGrid</strong>
      </td>
      <td style="text-align:left"><span style="font-size:x-small">gogrid</span></td>
      <td style="text-align:left">API Key</td>
      <td style="text-align:left">Shared Secret</td>
      <td style="text-align:left">Go to <span style="font-size:x-small">My Account > API Keys</span> for <a href="https://my.gogrid.com/gogrid/com.servepath.gogrid.GoGrid/index.html">your account</a> and click on the key you want to use to find the shared secret.</td>
    </tr>
    <tr>
      <td style="text-align:left">
        <strong>IBM SBC</strong>
      </td>
      <td style="text-align:left"><span style="font-size:x-small">sbc</span></td>
      <td style="text-align:left">Username</td>
      <td style="text-align:left">Password</td>
      <td style="text-align:left"></td>
    </tr>
    <tr>
      <td style="text-align:left">
        <strong>Microsoft Azure (Storage Account only)</strong>
      </td>
      <td style="text-align:left"><span style="font-size:x-small">azure</span></td>
      <td style="text-align:left">Public Storage Account Name</td>
      <td style="text-align:left">Primary Access Key</td>
      <td style="text-align:left">The Storage Account Name is chosen when you create the service (e.g. name in http://name.blob.core.windows.net/). This and the access key are available from the service control panel.</td>
    </tr>
    <tr>
      <td style="text-align:left">
        <strong>OpenNebula</strong>
      </td>
      <td style="text-align:left"><span style="font-size:x-small">opennebula</span></td>
      <td style="text-align:left">OpenNebula user</td>
      <td style="text-align:left">OpenNebula password</td>
      <td style="text-align:left">Set the environment variable OCCI_URL to the address on which OpenNebula's OCCI server is listening.</td>
    </tr>
    <tr>
      <td style="text-align:left">
        <strong>Rackspace Cloud Servers/Cloud Files</strong>
      </td>
      <td style="text-align:left"><span style="font-size:x-small">rackspace</span></td>
      <td style="text-align:left">Rackspace user name</td>
      <td style="text-align:left">API Key</td>
      <td style="text-align:left">Obtain the key from the <a href="https://manage.rackspacecloud.com/APIAccess.do">API Access</a> page in your control panel.</td>
    </tr>
    <tr>
      <td style="text-align:left">
        <strong>RHEV-M</strong>
      </td>
      <td style="text-align:left"><span style="font-size:x-small">rhevm</span></td>
      <td style="text-align:left"><a href="http://markmc.fedorapeople.org/rhevm-api/en-US/html/chap-REST_API_Guide-Authentication.html">RHEV-M user name plus Windows domain</a>, <span style="font-size:x-small"> e.g., admin@rhevm.example.com</span></td>
      <td style="text-align:left">RHEV-M password</td>
      <td style="text-align:left">Set environment variable API_PROVIDER to the URL of the RHEV-M REST API endpoint. </td>
    </tr>
    <tr>
      <td style="text-align:left">
        <strong>Rimuhosting</strong>
      </td>
      <td style="text-align:left"><span style="font-size:x-small">rimuhosting</span></td>
      <td style="text-align:left">not used (?)</td>
      <td style="text-align:left">API Key</td>
      <td style="text-align:left"></td>
    </tr>
    <tr>
      <td style="text-align:left">
        <strong>Terremark</strong>
      </td>
      <td style="text-align:left"><span style="font-size:x-small">terremark</span></td>
      <td style="text-align:left">Username</td>
      <td style="text-align:left">Password</td>
      <td style="text-align:left"></td>
    </tr>
    <tr>
      <td style="text-align:left">
        <strong>VMware vSphere</strong>
      </td>
      <td style="text-align:left"><span style="font-size:x-small">vsphere</span></td>
      <td style="text-align:left">vSphere user</td>
      <td style="text-align:left">vSphere user password</td>
      <td style="text-align:left">Set environment variable API_PROVIDER to the hostname of the vSphere server.</td>
    </tr>
    <tr>
      <td style="text-align:left">
        <strong>OpenStack</strong>
      </td>
      <td style="text-align:left"><span style="font-size:x-small">openstack</span></td>
      <td style="text-align:left">OpenStack user</td>
      <td style="text-align:left">OpenStack user password</td>
      <td style="text-align:left">Set environment variable API_PROVIDER to the URL of OpenStack API entrypoint.</td>
    </tr>
  </tbody>
</table>
