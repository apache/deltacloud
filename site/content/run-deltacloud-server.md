--- 
site_name: Deltacloud API
title: Run the Deltacloud server
---
<br/>
<h3> Quick-start guide</h3>
<p>This guide focuses on a linux environment. Some of the Deltacloud developers are running recent versions of <a href="http://fedoraproject.org/">Fedora</a>. However, you should be able to install Deltacloud on any OS that supports Ruby. If you are having any problems with installation, please <a href="/contact.html">let us know</a>, we'd love to hear from you!</p>

<h3>Running the Deltacloud server</h3>
<p>Start the server by typing <strong>deltacloudd -i driver_id</strong>.</p>
<p>The <strong>driver_id</strong> is the name of the cloud provider that you have an account with, for example <code>deltacloudd -i ec2</code>.</p>
<p>If you don't yet have an account with a cloud provider, you can still try the Deltacloud mock driver:</p> 
<pre>deltacloudd -i mock</pre>
<p>This will start the Deltacloud server on your local machine with the mock driver, accepting connections on port 3001 (default). From version 0.4.0 of Deltacloud, you can use the '-l' flag to see all available <strong>driver_ids</strong> that can be used with the <strong>deltacloudd</strong> executable:</p>
<pre>
$ deltacloudd -l

Available drivers:
* condor
* vsphere
* opennebula
* eucalyptus
* rhevm
* sbc
* azure
* gogrid
* mock
* rackspace
* rimuhosting
* terremark
* ec2
</pre>

<h3>Deltacloud HTML interface</h3>
<p>After you start the server, you are ready to use the Deltacloud HTML interface.</p>
<p>Open the address <strong>http://localhost:3001/api</strong> in your web browser:</p>

<p>To display the XML output from the server in the browser, append <strong>format=xml</strong> to each URL. On Webkit based browsers like Safari, you might need to instruct the server explicitly to <a href="http://www.gethifi.com/blog/webkit-team-admits-accept-header-error">return HTML</a>. Do this by appending <strong>format=html</strong> to each URL.</p>

<p>Your browser will prompt you for <a href="/drivers.html#credentials" >credentials</a> when you invoke an operation that requires authentication.</p>

<p>The '-h' flag will list all available options for <strong>deltacloudd</strong>. For example, to start the Deltacloud server with the Rackspace driver on <strong>port 10000</strong> you can use:</p>

<pre>$ deltacloudd -i rackspace -p 10000</pre>

<p>If you want to install the server on another machine and make Deltacloud available on your local network, you need to bind the Deltacloud server to an address other than 'localhost' (default). To start the server use the IP address of a machine where you installed and started Deltacloud. For instance:</p>

<pre>$ deltacloudd -i ec2 -p 5000 -r 192.168.10.200</pre>

<p>This will make the Deltacloud server available at the address <strong>http://192.168.10.200:5000/api.</strong> Instead of IP address you can also use the hostname to start the server on another machine.</p>

<h3>Using CIMI</h3>

<p>
To use <a href="http://dmtf.org/standards/cloud">CIMI</a>, first, go to the direcotry <strong>~/deltacloud/server/bin</strong> and start the Deltacloud server in the background:
</p>

<pre>
./deltacloudd -i mock --cimi &
</pre>

<p>
Then go to the directory <strong>~/deltacloud/clients/cimi</strong> and start the CIMI client server in the background:
</p>

<pre>
bin/start -u http://localhost:3001/cimi -r &lt;your_server_host_name&gt; &
</pre>

<p>
Use the -r option to make your client accessible from other machines different from the machine on which you are running both servers.
</p>

<p>
If there are some problems when you start up the servers, you may have missing dependencies. Check the <a href="/install-deltacloud.html#gem-list">RubyGems list</a> with the list above and make sure you don't have anything missing. If there are no problems with starting the servers, access the application using your browser by following URL:
</p>

<pre>
http://&lt;your_server_host_name&gt;:4001/cimi
</pre>

<p>
The browser will ask for credentials. To log in use mockuser and mockpassword as user ID and password.
</p>

<a class="btn btn-inverse btn-large" style="float: right" href="/usage.html">Use Deltacloud</a>

<br/>

