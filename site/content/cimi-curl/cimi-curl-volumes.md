---
site_name: Deltacloud API
title: CIMI cURL Examples - Volume Resources
---

<br/>

<div class="row">

  <div class="span8">

    <h3 id="command">cURL examples for CIMI Volume resources</h3>

<ul class="nav nav-pills">
  <li class="active"><a href="#volumes" data-toggle="tab">Working with Volumes</a></li>
  <li><a href="#volume-images" data-toggle="tab">Working with VolumeImages</a></li>
  <li><a href="#volume-configs" data-toggle="tab">Working with VolumeConfigurations</a></li>
  <li><a href="#volume-templates" data-toggle="tab">Working with VolumeTemplates</a></li>
</ul>


  </div>

  <div class="span4">

<ul class="nav nav-list well">
  <li class="nav-header">
    <a href="/cimi-curl.html">curl for CIMI Resources</a>
  </li>
  <ul class="nav nav-list">
    <li><a href="/cimi-curl/cimi-curl-machines.html">Machine</a></li>
    <li class="active"><a href="/cimi-curl/cimi-curl-volumes.html">Volume</a></li>
    <li><a href="/cimi-curl/cimi-curl-resource_metadata.html">ResourceMetadata</a></li>
  </ul>
  <br/>
</ul>

  </div>

</div>

<div class="tab-content">

  <div class="tab-pane active" id="volumes">

    <hr/>

    <h4>Working with Volumes</h4>

    <p>Retrieve the Volume Collection in json format:</p>

    <pre> curl --user "user:pass" -H "Accept: application/json" http://localhost:3001/cimi/volumes </pre>

    <p>Retrieve a specific Volume in xml format: </p>

    <pre> curl --user "user:pass" -H "Accept: application/xml" http://localhost:3001/cimi/volumes/volume1 </pre>

    <p>Create Volume - with VolumeConfiguration by reference, XML body:</p>

    <pre>curl -v --user "mockuser:mockpassword" -H "Accept:application/xml" -X POST -d '&lt;VolumeCreate&gt;&lt;name&gt; marios_new_volume &lt;/name&gt; &lt;description&gt; a new volume &lt;/description&gt;&lt;volumeTemplate&gt;&lt;volumeConfig href="http://localhost:3001/cimi/volume_configurations/2"&gt; &lt;/volumeConfig&gt;&lt;/volumeTemplate&gt;&lt;/VolumeCreate&gt;' http://localhost:3001//cimi/volumes
     </pre>

    <p>Create Volume - with VolumeConfiguration by reference, JSON body:</p>

    <pre>curl -v --user "mockuser:mockpassword" -H "Accept:application/xml" -X POST -d '{"name": "marios_new_volume", "description": "a new volume", "volumeTemplate": { "volumeConfig": {"href":"http://localhost:3001/cimi/volume_configurations/2" }}}' http://localhost:3001//cimi/volumes
    </pre>

    <p>Create Volume - with VolumeConfiguration by value, XML body:</p>

    <pre>curl -v --user "mockuser:mockpassword" -H "Accept:application/xml" -X POST -d '&lt;VolumeCreate&gt;&lt;name&gt; marios_volume &lt;/name&gt;&lt;description&gt; a new volume &lt;/description&gt; &lt;volumeTemplate&gt;&lt;volumeConfig&gt;&lt;type&gt;http://schemas.dmtf.org/cimi/1/mapped&lt;/type&gt;&lt;capacity&gt; 1024 &lt;/capacity&gt;&lt;/volumeConfig&gt;&lt;/volumeTemplate&gt; &lt;/VolumeCreate&gt;' http://localhost:3001//cimi/volumes
    </pre>

    <p>Create Volume - with VolumeConfiguration by value, JSON body:</p>

    <pre>curl -v --user "mockuser:mockpassword" -H "Accept:application/xml"  -X POST -d '{"name": "marios_new_volume", "description": "a new volume", "volumeTemplate": { "volumeConfig": {"type":"http://schemas.dmtf.org/cimi/1/mapped", "capacity": 1024 }}}'   http://localhost:3001/cimi/volumes
    </pre>

    <p>Delete a Volume</p>

    <pre>curl -v --user "mockuser:mockpassword" -H "Accept: application/xml" -X DELETE http://localhost:3001/cimi/volumes/volume94275
    </pre>

  </div>

  <div class="tab-pane" id="volume-images">

    <hr/>

    <h4>Working with Volume Images</h4>

    <p>Retrieve the Volume Image Collection in xml format:</p>

    <pre> curl --user "user:pass" -H "Accept: application/xml" http://localhost:3001/cimi/volume_images</pre>

    <p>Retrieve a specific Volume Image in json format:</p>

    <pre> curl --user "user:pass" -H "Accept: application/json" http://localhost:3001/cimi/volume_images/vol_image1 </pre>

    <p>Create a Volume Image from an existing Volume, XML body:</p>

    <pre>curl -v --user "mockuser:mockpassword" -H "Content-Type: application/xml" -H "Accept: application/xml" -X POST -d '&lt;VolumeImage xmlns="http://schemas.dmtf.org/cimi/1"&gt;&lt;name&gt; my_vol_image &lt;/name&gt;&lt;description&gt; marios first volume image &lt;/description&gt;&lt;imageLocation href="http://localhost:3001/cimi/volumes/vol1"/&gt;&lt;/VolumeImage&gt;' http://localhost:3001/cimi/volume_images
    </pre>

    <p>Create a Volume Image from an existing Volume, JSON body:</p>

    <pre>curl -v --user "mockuser:mockpassword" -H "Content-Type: application/json" -H "Accept: application/xml" -X POST -d  '{ "resourceURI": "http://schemas.dmtf.org/cimi/1/VolumeImage","name": "some_name", "description": "marios first volume image", "imageLocation": { "href": "http://localhost:3001/cimi/volumes/vol1"}}' http://localhost:3001/cimi/volume_images</pre>

    <p>Delete a Volume Image:</p>

    <pre>curl -v -X DELETE --user "mockuser:mockpassword" http://localhost:3001/cimi/volume_images/store_snapshot_1358516615</pre>

  </div>


  <div class="tab-pane" id="volume-configs">

    <hr/>

    <h4>Working with Volume Configurations</h4>

    <p>Retrieve the Volume Configuration Collection in json format:</p>

    <pre> curl --user "user:pass" -H "Accept: application/json" http://localhost:3001/cimi/volume_configurations </pre>

    <p>Retrieve a specific Volume Configuration in xml format:</p>

    <pre> curl --user "user:pass" -H "Accept: application/xml" http://localhost:3001/cimi/volume_configurations/volume_config1 </pre>

    <p>Create a new Volume Configuration with XML body:</p>

    <pre>curl -v --user "mockuser:mockpassword" -H "Content-Type: application/xml" -H "Accept: application/xml" -X POST -d '&lt;VolumeConfigurationCreate&gt;&lt;name&gt;marios_volume_config&lt;/name&gt;&lt;description&gt;a volume configuration&lt;/description&gt;&lt;format&gt;qcow2&lt;/format&gt;&lt;type&gt;http://schemas.dmtf.org/cimi/1/mapped&lt;/type&gt; &lt;capacity&gt;10&lt;/capacity&gt;&lt;/VolumeConfigurationCreate&gt;' http://localhost:3001/cimi/volume_configurations
    </pre>

    <p>Create a new Volume Configuration with JSON body:</p>

   <pre>curl -v --user "mockuser:mockpassword" -H "Content-Type: application/json" -H "Accept: application/xml" -X POST -d '{ "resourceURI": "http://schemas.dmtf.org/cimi/1/VolumeConfiguration","name": "marios_volume_config", "description": "a volume configuration", "type": "http://schemas.dmtf.org/cimi/1/mapped", "format": "ext3", "capacity": 11}' http://localhost:3001/cimi/volume_configurations</pre>

    <p>Delete a Volume Configuration:</p>

    <pre>curl -v -X DELETE --user "mockuser:mockpassword" http://localhost:3001/cimi/volume_configurations/4 </pre>

  </div>


  <div class="tab-pane" id="volume-templates">

    <hr/>

    <h4>Working with Volume Templates</h4>

    <p>Retrieve the Volume Template Collection in json format:</p>

    <pre> curl --user "user:pass" -H "Accept: application/json" http://localhost:3001/cimi/volume_templates </pre>

    <p>Retrieve a specific Volume Template in xml format:</p>

    <pre> curl --user "user:pass" -H "Accept: application/xml" http://localhost:3001/cimi/volume_templates/vol_template123</pre>

    <p>Create a Volume Template with XML body:</p>

    <pre>curl --user "mockuser:mockpassword" -H "Content-Type: application/xml" -H "Accept: application/xml" -X POST -d '&lt;VolumeTemplate xmlns="http://schemas.dmtf.org/cimi/1"&gt; &lt;name&gt; marios_vol_template &lt;/name&gt; &lt;description&gt; my first volume template &lt;/description&gt; &lt;volumeConfig href="http://localhost:3001/cimi/volume_configs/1"&gt; &lt;/volumeConfig&gt; &lt;/VolumeTemplate&gt;' http://localhost:3001/cimi/volume_templates</pre>

    <p>Create a Volume Template with JSON body:</p>

    <pre>curl -v --user "mockuser:mockpassword" -H "Content-Type: application/json" -H "Accept: application/xml" -X POST -d '{ "resourceURI": "http://schemas.dmtf.org/cimi/1/VolumeTemplate","name": "marios_vol_template", "description": "my first volume template", "volumeConfig": { "href": "http://localhost:3001/cimi/volume_configs/1"} }' http://localhost:3001/cimi/volume_templates </pre>

    <p>Delete a Volume Template:</p>

    <pre>curl -v -X DELETE --user "mockuser:mockpassword" http://localhost:3001/cimi/volume_templates/vol_template123</pre>

  </div>
</div>
