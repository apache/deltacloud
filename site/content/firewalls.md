---
site_name: Deltacloud API
title: Firewalls
---

<br/>

<div class="row">
  <div class="span9">

<h3 id="firewalls">Firewalls</h3>

<p>
Firewalls represent sets of rules that govern the accessibility of a running instance over the public Internet. At present, only Amazon EC2 cloud (Amazon EC2 'Security Groups') and Fujitsu GCP support this collection. A firewall has these attributes:
</p>

<ul>
  <li>a <strong>name</strong></li>
  <li>a <strong>description</strong></li>
  <li>an <strong>owner_id</strong></li>
  <li>set of <strong>rules</strong></li>
</ul>

<p>
For Amazon EC2, an instance is launched into a firewall by specifying the <strong>firewalls1 ... firewallsN</strong> parameters in the <strong>POST /api/instances</strong> operation (see the <a href="/instances.html#instance">Create an instance</a> section).
</p>

<p>
Each <strong>firewall rule</strong> has a number of attributes describing the access granted to clients that want to communicate with the instance over the Internet. Each rule consists of
</p>

<ul>
  <li>an <strong>allow_protocol</strong> (tcp, udp or icmp);</li>
  <li>a <strong>port_from</strong> and a <strong>port_to</strong> that delimit the port range for access; and</li>
  <li>a <strong>sources</strong> list, which can contain firewalls (i.e. allow instances in another firewall to communicate with instances in the firewall in which this rule exists), or a number of IP addresses in CIDR format, or a mix of both.</li>
</ul>

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
    <li><a href="/images.html">Images</a></li>
    <li><a href="/instance-states.html">Instance states</a></li>
    <li><a href="/instances.html">Instances</a></li>
    <li><a href="/keys.html">Keys</a></li>
    <li class="active"><a href="#firewalls">Firewalls</a></li>
    <li><a href="/addresses.html">Addresses</a></li>
    <li><a href="/load-balancers.html">Load balancers</a></li>
  </ul>
  <li><a href="/storage-resources.html">Storage resources</a></li>
</ul>

  </div>
</div>

<p>
Each rule also specifies a <strong>direction</strong>, indicating whether it applies to ingress or egress traffic. A rule can also specify a <strong>rule_action</strong> (accept, deny), to indicate whether the firewall should accept or deny access for this traffic, and <strong>log_rule</strong> (true, false), to indicate whether an entry should be added to the log.

</p>

<p>
As Amazon EC2 has no notion of a firewall rule ID, the Deltacloud server constructs one ID for each rule as the concatenation of its attributes. The format used is: owner_id~protocol~from_port~to_port~@sources.
</p>

<p>
As explained above a source can be the <strong>address</strong> type in which case it defines an IP type (ipv4/ipv6), an IP address and routing prefix (CIDR netmask). Sources of type <strong>group</strong> have an owner_id and a name. The <strong>owner_id</strong> is the identifier of the account that created the specified firewall. The <strong>name</strong> defines the firewall to which the access is being granted.
</p>

<p>
An example of a rule id is:
</p>

<pre>
393485797142~tcp~22~22~@group,393485797142,default,@address,ipv4,10.1.2.3,24
          {owner_id~protocol~from_port~to_port~@sources}
</pre>

<p>
By creating the rule identifier abstraction, the Deltacloud API supports deletion of an entire firewall rule as one operation.
</p>

<br/>

<ul class="nav nav-pills">
  <li class="active"><a href="#tab1" data-toggle="tab">Get a list of all firewalls</a></li>
  <li><a href="#tab2" data-toggle="tab">Get the details of a firewall</a></li>
  <li><a href="#tab3" data-toggle="tab">Create/delete a firewall</a></li>
  <li><a href="#tab4" data-toggle="tab">Create/delete a firewall rule</a></li>
</ul>

<hr>

<div class="tab-content">
  <div class="tab-pane active" id="tab1">

<h4>Get a list of all firewalls</h4>

<p>
To retrieve a list of all firewalls use call <strong>GET /api/firewalls</strong>.
</p>

<p>Example request:</p>

<pre>
GET /api/firewalls?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 200 OK
Content-Type: application/xml
Date: Tue, 26 Jul 2011 15:56:04 GMT
Content-Length: 1640

&lt;?xml version='1.0' encoding='utf-8' ?&gt;
&lt;firewalls&gt;
  &lt;firewall href='http://localhost:3001/api/firewalls/default' id='default'&gt;
    &lt;name&gt;&lt;![CDATA[default]]&gt;&lt;/name&gt;
    &lt;description&gt;&lt;![CDATA[default group]]&gt;&lt;/description&gt;
    &lt;owner_id&gt;393485797142&lt;/owner_id&gt;
    &lt;rules&gt;
      &lt;rule id='393485797142~tcp~22~22~@address,ipv4,87.228.192.251,32'&gt;
        &lt;allow_protocol&gt;tcp&lt;/allow_protocol&gt;
        &lt;port_from&gt;22&lt;/port_from&gt;
        &lt;port_to&gt;22&lt;/port_to&gt;
        &lt;direction&gt;ingress&lt;/direction&gt;
        &lt;sources&gt;
          &lt;source address='87.228.192.251' family='ipv4' prefix='32' type='address'&gt;&lt;/source&gt;
        &lt;/sources&gt;
      &lt;/rule&gt;
    &lt;/rules&gt;
  &lt;/firewall&gt;
  &lt;firewall href='http://localhost:3001/api/firewalls/test' id='test'&gt;
    &lt;name&gt;&lt;![CDATA[test]]&gt;&lt;/name&gt;
    &lt;description&gt;&lt;![CDATA[this is just a test]]&gt;&lt;/description&gt;
    &lt;owner_id&gt;393485797142&lt;/owner_id&gt;
    &lt;rules&gt;
      &lt;rule id='393485797142~tcp~22~22~@group,393485797142,default,@address,ipv4,10.1.2.3,24'&gt;
        &lt;allow_protocol&gt;tcp&lt;/allow_protocol&gt;
        &lt;port_from&gt;22&lt;/port_from&gt;
        &lt;port_to&gt;22&lt;/port_to&gt;
        &lt;direction&gt;ingress&lt;/direction&gt;
        &lt;sources&gt;
          &lt;source name='default' owner='393485797142' type='group'&gt;&lt;/source&gt;
          &lt;source address='10.1.2.3' family='ipv4' prefix='24' type='address'&gt;&lt;/source&gt;
        &lt;/sources&gt;
      &lt;/rule&gt;
    &lt;/rules&gt;
  &lt;/firewall&gt;
  &lt;firewall href='http://localhost:3001/api/firewalls/new_firewall' id='new_firewall'&gt;
    &lt;name&gt;&lt;![CDATA[new_firewall]]&gt;&lt;/name&gt;
    &lt;description&gt;&lt;![CDATA[new_one]]&gt;&lt;/description&gt;
    &lt;owner_id&gt;393485797142&lt;/owner_id&gt;
    &lt;rules&gt;
    &lt;/rules&gt;
  &lt;/firewall&gt;
&lt;/firewalls&gt;</pre>

  </div>
  <div class="tab-pane" id="tab2">

<h4>Get the details of a specified firewall</h4>

<p>
To retrieve details of a single specified firewall use call <strong>GET /api/firewalls/:id</strong>.
</p>

<p>Example request:</p>

<pre>
GET /api/firewalls/test?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
</pre>

<p>Server reponse:</p>

<pre>
HTTP/1.1 200 OK
Content-Type: application/xml
Date: Wed, 27 Jul 2011 08:20:29 GMT
Content-Length: 835

&lt;?xml version='1.0' encoding='utf-8' ?&gt;
&lt;firewall href='http://localhost:3001/api/firewalls/test' id='test'&gt;
  &lt;name&gt;&lt;![CDATA[test]]&gt;&lt;/name&gt;
  &lt;description&gt;&lt;![CDATA[this is just a test]]&gt;&lt;/description&gt;
  &lt;owner_id&gt;393485797142&lt;/owner_id&gt;
  &lt;rules&gt;
    &lt;rule href='http://localhost:3001/api/firewalls/test/393485797142~tcp~22~22~@group,393485797142,default,@address,ipv4,10.1.2.3,24' id='393485797142~tcp~22~22~@group,393485797142,default,@address,ipv4,10.1.2.3,24'&gt;
      &lt;allow_protocol&gt;tcp&lt;/allow_protocol&gt;
      &lt;port_from&gt;22&lt;/port_from&gt;
      &lt;port_to&gt;22&lt;/port_to&gt;
      &lt;direction&gt;ingress&lt;/direction&gt;
      &lt;sources&gt;
        &lt;source name='default' owner='393485797142' type='group'&gt;&lt;/source&gt;
        &lt;source address='10.1.2.3' family='ipv4' prefix='24' type='address'&gt;&lt;/source&gt;
      &lt;/sources&gt;
    &lt;/rule&gt;
  &lt;/rules&gt;
&lt;/firewall&gt;
</pre>

  </div>
  <div class="tab-pane" id="tab3">

<h4>Create a new firewall</h4>

<p>
To create a new firewall use call <strong>GET /api/firewalls/:id</strong>. Clients must specify the firewall name and description as parameters to the request. The Deltacloud server will respond with <strong>HTTP 201 Created</strong> to a succesful completion and return details of the newly created firewall. As with other POST operations in the Deltacloud API, a client may specify parameters as multipart/form-data or using the application/x-www-form-urlencoded content-type.
</p>

<p>Example request:</p>

<pre>
POST /api/firewalls?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
Content-Length: 64
Content-Type: application/x-www-form-urlencoded

name=Devel_Group&description=Access%20for%20all%20development%20machines
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 201 Created
Content-Type: application/xml
Date: Wed, 27 Jul 2011 08:35:43 GMT
Content-Length: 296

&lt;?xml version='1.0' encoding='utf-8' ?&gt;
&lt;firewall href='http://localhost:3001/api/firewalls/Devel_Group' id='Devel_Group'&gt;
  &lt;name&gt;&lt;![CDATA[Devel_Group]]&gt;&lt;/name&gt;
  &lt;description&gt;&lt;![CDATA[Access for all development machines]]&gt;&lt;/description&gt;
  &lt;owner_id&gt;&lt;/owner_id&gt;
  &lt;rules&gt;
  &lt;/rules&gt;
&lt;/firewall&gt;
</pre>

<h4>Delete a firewall</h4>

<p>
To delete the specified firewall from the back-end cloud provider use call <strong>DELETE /api/firewalls/:id</strong>. The Deltacloud server will respond with <strong>HTTP 204 No Content</strong> after a successful deletion:
</p>

<p>Example request:</p>

<pre>
DELETE /api/firewalls/test?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
</pre>

<p>Client response:</p>

<pre>
HTTP/1.1 204 No Content
Date: Wed, 27 Jul 2011 09:47:43 GMT
</pre>

<p>
The rules governing the deletion of a firewall are back-end cloud specific.
</p>
<p>
For Fujitsu GCP, as this operation destroys the virtual system with it, all instances in the system, including the firewall need to be in the STOPPED state.
</p>
<p>
For Amazon EC2, it is permitted to delete a firewall that has rules defined within it, with two exceptions. You cannot delete a firewall if it is referenced by another firewall; for instance <strong>firewall_1</strong> has a rule giving access to <strong>firewall_2</strong>. An attempt to delete firewall_2 will result in the error <strong>InvalidGroup.InUse</strong>, as you can see in the example below. The second exception is that you cannot delete a firewall if there are currently any running instances within that firewall (i.e. instances that specified the given firewall when they were launched). The error message in that case would be <strong>InvalidGroup.InUse: There are active instances using security group</strong>. In both cases the error messages are propagated from the back-end cloud provider to the requesting client.
</p>

<p>
Example request (<strong>error deleting a firewall referenced by another firewall</strong>):
</p>

<pre>
DELETE /api/firewalls/firewall_2?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 502 Bad Gateway
Content-Type: application/xml
Content-Length: 626

&lt;error status='502' url='/api/firewalls/firewall_2?format=xml'&gt;
  &lt;kind&gt;backend_error&lt;/kind&gt;
  &lt;backend driver='ec2'&gt;
    &lt;code&gt;502&lt;/code&gt;
  &lt;/backend&gt;
  &lt;message&gt;&lt;![CDATA[InvalidGroup.InUse: Group 393485797142:firewall_2 is used by groups: 393485797142:firewall_1
  REQUEST=ec2.us-east-1.amazonaws.com:443/?AWSAccessKeyId=AGG332FWWR5A11F327Q&Action=DeleteSecurityGroup&GroupName=firewall_2&SignatureMethod=HmacSHA256&SignatureVersion=2&Timestamp=2011-07-27T08%3A50%3A50.000Z&Version=2010-08-31&Signature=g613223efwv5WAVhAosmPcrsfHqApAuw\nnwfYnZp0k3U%3D
  REQUEST ID=8591fa20-a6ee-4db7-b30f-3022ecc9a9f5]]&gt;&lt;/message&gt;
&lt;/error&gt;
</pre>

  </div>
  <div class="tab-pane" id="tab4">

<h4>Create a firewall rule</h4>

<p>
To create a new firewall rule within a specified firewall use call <strong>POST /api/firewalls/:id/rules</strong>. This operation of the firewalls collection is not supported by Fujitsu GCP. A client must supply the <strong>protocol</strong> (one of udp, tcp or icmp), <strong>port_from</strong> and <strong>port_to</strong> as parameters. Of course the client must also specify the <strong>sources</strong> to which the given rule is applied. IP addresses are specified in CIDR format sequentially: ip_address1=192.168.10.10/24, ip_address2=10.1.1.1/16 ... ip_addressN=.... The IP address '0.0.0.0/0' acts as a wildcard to specify any IP address. Source firewalls are also specified sequentially, but the <strong>owner_id</strong> of the firewall prepared for authorization must also be supplied (this is an Amazon EC2 requirement): group1=name1, group1owner=1234567890, group2=name2, group2owner=0987654321, ... groupN=nameN, groupNowner=...
</p>

<p>
The Deltacloud server responds with a <strong>HTTP 201 Created</strong> after a successful operation and adds the details of the given firewall. The example client request below specifies the required parameters as multipart/form-data. However clients may also legitimately use the application/x-www-form-urlencoded to provide firewall rule parameters.
</p>

<p>Example request:</p>

<pre>
POST /api/firewalls/default/rules?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
Content-Length: 1005
Expect: 100-continue
Content-Type: multipart/form-data; boundary=----------------------------4c9e7fa0a35e

------------------------------4c9e7fa0a35e
Content-Disposition: form-data; name="protocol"

tcp
------------------------------4c9e7fa0a35e
Content-Disposition: form-data; name="port_from"

22
------------------------------4c9e7fa0a35e
Content-Disposition: form-data; name="port_to"

22
------------------------------4c9e7fa0a35e
Content-Disposition: form-data; name="group1"

devel_group
------------------------------4c9e7fa0a35e
Content-Disposition: form-data; name="group1owner"

393485797142
------------------------------4c9e7fa0a35e
Content-Disposition: form-data; name="group2"

outside
------------------------------4c9e7fa0a35e
Content-Disposition: form-data; name="group2owner"

393485797142
------------------------------4c9e7fa0a35e
Content-Disposition: form-data; name="ip_address1"

192.168.1.1/24
------------------------------4c9e7fa0a35e
Content-Disposition: form-data; name="ip_address2"

65.128.31.27/32
------------------------------4c9e7fa0a35e--
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 201 Created
Content-Type: application/xml
Date: Wed, 27 Jul 2011 10:18:51 GMT
Content-Length: 1143

&lt;firewall href='http://localhost:3001/api/firewalls/default' id='default'&gt;
  &lt;name&gt;&lt;![CDATA[default]]&gt;&lt;/name&gt;
  &lt;description&gt;&lt;![CDATA[default group]]&gt;&lt;/description&gt;
  &lt;owner_id&gt;393485797142&lt;/owner_id&gt;
  &lt;rules&gt;
    &lt;rule href='http://localhost:3001/api/firewalls/default/393485797142~tcp~22~22~@group,393485797142,devel_group,@group,393485797142,outside,@address,ipv4,192.168.1.1,24,@address,ipv4,65.128.31.27,32' id='393485797142~tcp~22~22~@group,393485797142,devel_group,@group,393485797142,outside,@address,ipv4,192.168.1.1,24,@address,ipv4,65.128.31.27,32'&gt;
      &lt;allow_protocol&gt;tcp&lt;/allow_protocol&gt;
      &lt;port_from&gt;22&lt;/port_from&gt;
      &lt;port_to&gt;22&lt;/port_to&gt;
      &lt;direction&gt;ingress&lt;/direction&gt;
      &lt;sources&gt;
        &lt;source name='devel_group' owner='393485797142' type='group'&gt;&lt;/source&gt;
        &lt;source name='outside' owner='393485797142' type='group'&gt;&lt;/source&gt;
        &lt;source address='192.168.1.1' family='ipv4' prefix='24' type='address'&gt;&lt;/source&gt;
        &lt;source address='65.128.31.27' family='ipv4' prefix='32' type='address'&gt;&lt;/source&gt;
      &lt;/sources&gt;
    &lt;/rule&gt;
  &lt;/rules&gt;
&lt;/firewall&gt;
</pre>

<h4 id="delete-rule">Delete a firewall rule</h4>

<p>
To delete the specified firewall rule use call <strong>DELETE /api/firewalls/:id/:rule_id</strong>. The Deltacloud server will respond with <strong>HTTP 204 No Content</strong> on completion of a successful delete operation:
</p>

<p>Example request:</p>

<pre>
DELETE /api/firewalls/default/393485797142~tcp~0~0~@group,393485797142,devel_group,@group,393485797142,outside,@address,ipv4,192.168.1.1,24,@address,ipv4,65.128.31.27,32?format=xml HTTP/1.1
Authorization: Basic AU1J3UB2121Afd1DdyQWxLaTYTmJMNF4zTXBoRGdhMDh2RUw5ZDAN9zVXVa==
User-Agent: curl/7.20.1 (i386-redhat-linux-gnu)
Host: localhost:3001
Accept: */*
</pre>

<p>Server response:</p>

<pre>
HTTP/1.1 204 No Content
Date: Wed, 27 Jul 2011 10:39:52 GMT
</pre>

  </div>
</div>

<a class="btn btn-inverse btn-large" style="float: right" href="/addresses.html">Addresses <i class="icon-arrow-right icon-white" style="vertical-align:baseline"> </i></a>

<br/>
