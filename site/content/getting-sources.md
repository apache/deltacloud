--- 
site_name: Deltacloud API
title: Getting the Sources
---
<br/>

<h3>Setting up a developement environment</h3>

<h4>Installing dependencies</h4>
<p>
First, you will need all the installation dependencies for Deltacloud. Follow the steps in <a href="/install-deltacloud.html">Install Deltacloud</a> section to get these dependencies.
</p>

<h4>Getting the sources</h4>

The Deltacloud repository is hosted at the Apache Software Foundation, using the <a href="http://git-scm.com/">Git</a> version control system. If you don't have Git already, use the yum or apt package managers:

<pre>
$ sudo yum install git
</pre>
or
<pre>
$ sudo apt-get install git
</pre>

The canonical Deltacloud repository is located at <a href="https://git-wip-us.apache.org/repos/asf/deltacloud.git">https://git-wip-us.apache.org/repos/asf/deltacloud.git</a> with read-only mirrors at <strong>git://git.apache.org/deltacloud.git</strong> and <strong>git://github.com/apache/deltacloud</strong>.

Go to your root directory and run git to get the latest version of Deltacloud source code from git repository. You can also use a different directory, but remember, where you clone the code:

<pre>
$ git clone git://git.apache.org/deltacloud.git
</pre>

This will pull the latest version to the directory <strong>~/deltacloud</strong>.

<h4>Development dependencies</h4>
<p>
Apart from installation dependecies, you have to install some additional libraries, in order to develop for Deltacloud. The Deltacloud source includes a Gemfile: <strong>/path/to/deltacloud/server/Gemfile</strong>, which lists these development dependencies.
</p>

<p>
You can easily get all the development dependecies with <a href="http://gembundler.com/">Bundler</a>:
</p>

<p>Install Bundler (if you don't have it yet):</p>

<pre>$ gem install bundler</pre>

<p>Then, get the required dependencies:</p>

<pre>
$ cd /path/to/deltacloud/server
$ bundle
</pre>

<h4>Building from source and installing the Deltacloud gem</h4>

<p>
Build and install the Deltacloud server gem:
</p>

<pre>
$ cd path/to/DeltacloudProject/deltacloud/server
$ rake package
$ gem install pkg/deltacloud-core-&lt;version&gt;.gem
</pre>

<p>
Then install the Deltacloud client gem:
</p>

<pre>
$ cd path/to/DeltacloudProject/deltacloud/client
$ rake package
$ gem install pkg/deltacloud-client-&lt;version&gt;.gem
</pre>

<a class="btn btn-inverse btn-large" style="float: right" href="/how-to-contribute.html">Contribute</a>
<br/>
