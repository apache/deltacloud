---
site_name: Deltacloud API
title: The Deltacloud Ruby Client
---
<br/>

<div class="row">
  <div class="span8">

<h3>Working with Deltacloud Ruby Client</h3>
<p>Each type of a resource has an associated model. Where resource refers to other resources, natural navigation across the object model is possible. For example:</p>

<pre>
puts instance.image.name
puts instance.hardware_profile.architecture
</pre>

<h4 id="realms">Listing realms</h4>
<p>Retrieve a complete list of realms available to you:</p>

<pre>realm = client.realms</pre>

</div>
  <div class="span4">
  
<ul class="nav nav-list well">
  <li class="nav-header">Deltacloud Ruby Client</li>
  <li class="active"><a href="#realms">Listing realms</a></li>
  <li><a href="#profiles">Listing hardware profiles</a></li>
  <li><a href="#images">Listing images</a></li>
  <li><a href="#instances1">Listing instances</a></li>
  <li><a href="#instances2">Lauching instances</a></li>
  <li><a href="#instances3">Manipulating instances</a></li>
  <li><a href="http://deltacloud.apache.org/ruby-client/doc/index.html">Client documentation</a></li>
</ul>

  </div>
</div>

<p>You can access a specific realm by adding its identifier:</p>

<pre>realm = client.realm( 'us' )</pre>

<h4 id="profiles">Listing hardware profiles</h4>

<p>Display a complete list of hardware profiles available for launching machines:</p>

<pre>hwp = client.hardware_profiles</pre>

<p>You can filter hardware profiles by architecture.</p>

<pre>hardware_profiles = client.hardware_profiles( :architecture=>'x86_64' )</pre>

<p>Retrieve a specific hardware profile by its identifier:</p>

<pre>hardware_profile = client.hardware_profile( 'm1-small' )</pre>

<h4 id="images">Listing images</h4>

<p>Return a complete list of images:</p>

<pre>images = client.images</pre>

<p>Retrieve a list of images owned by the currently authenticated user:</p>

<pre>images = client.images( :owner_id=>:self )</pre>

<p>You can also retrieve a list of images visible to you but owned by a specific user:</p>

<pre>images = client.images( :owner_id=>'daryll' )</pre>

<p>Access a specific image by its identifier:</p>

<pre>image = client.image( 'ami-8675309' )</pre>

<h4 id="instances1">Listing instances</h4>

<p>Get a list of all instances visible to you:</p>

<pre>instances = client.instances</pre>

<p>Retrieve a list of all running instances:</p>

<pre>instances = client.instances( :state =>:running )</pre>

<p>Look up the first instance in the list:</p>

<pre>instance = client.instances.first</pre>

<p>Find a specific instance by its identifier:</p>

<pre>instance = client.instance( 'i-90125' )</pre>

<h4 id="instances2">Launching instances</h4>

<p>Launch an instance using an image identifier:</p>

<pre>instance = client.create_instance(image_id)</pre>

<p>You may specify a hardware profile:</p>

<pre>instance = client.create_instance(image_id, :hwp_id => 'm1-small')</pre>

<p>To create new instance, you can also use the 'user_name' feature:</p>

<pre>instance = client.create_instance(image_id, :name => 'myinst1')</pre>

<h4 id="instances3">Manipulating instances</h4>

<p>Start an instance:</p>

<pre>instance.start!</pre>

<p>Execute the 'reboot' operation:</p>

<pre>instance.reboot!</pre>

<p>Destroy an instance:</p>

<pre>instance.destroy!</pre>

<br/>

<p>For more details on Deltacloud Ruby client see the full <a href="http://deltacloud.apache.org/ruby-client/doc/index.html">documentation</a>.</p>

<a class="btn btn-inverse btn-large" style="float: right" href="/usage.html#clients"><i class="icon-arrow-left icon-white" style="vertical-align:baseline"> </i> Back</a>

<br/>
