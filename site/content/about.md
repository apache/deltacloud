---
site_name: Deltacloud API
title: About
---
<div class="row">

<div class="span4">

<br/>

<h3>About Deltacloud</h3>
<br/>
<p>Deltacloud provides the API server and drivers necessary for connecting to cloud providers.</p>

<p>Deltacloud maintains <strong>long-term stability</strong> for scripts, tools and applications and <strong>backward compatibility</strong> across different versions.</p>

<p>Deltacloud enables management of resources in different clouds by the use of one of three supported APIs. The supported  APIs are the <a href="/rest-api.html">Deltacloud</a> classic API, the DMTF <a href="/cimi-rest.html">CIMI API</a> or even the EC2 API.</p>

<p>All of this means you can start an instance on an internal cloud and with the same code start another on EC2 or RHEV-M.</p>
</div>

<br/>

<div class="span8">
  <img src="/assets/img/diagram-soa.png" alt="Deltacloud API SOA diagram" align="center"/>
</div>

<div class="span12">

<br/>
<br/>
<h3>How does Deltacloud work?</h3>
<br/>
<p>Deltacloud contains a cloud abstraction API - whether the <a href="/rest-api.html">Deltacloud</a> classic API, the DMTF <a href="/cimi-rest.html">CIMI API</a> or even the EC2 API. The API works as a wrapper around a large number of clouds, abstracting their differences. For every cloud <a href="/drivers.html#drivers" rel="tooltip" title="currently supported providers">provider</a> there is a driver "speaking" that cloud provider's native API, freeing you from dealing with the particulars of each cloud's API.</p>

<p>Install Deltacloud and start the <strong>deltacloudd</strong> daemon server. You can use your favourite HTTP client to talk to the server using the <a href="/rest-api.html">Deltacloud REST API</a>, the DMTF <a href="/cimi-rest.html">CIMI API</a> or even the EC2 API. Deltacloud even comes with an HTML interface so you can simply use your web browser to control your cloud infrastructure straight out of the box. The HTML interface is written with the <a href="http://jquerymobile.com/">jQuery mobile</a> framework, so it is compatible with your mobile or tablet devices.</p>
<br/>

<img src="/assets/img/deltacloud_concept.gif" alt="Deltacloud concept scheme"/>

<br/>

<a class="btn btn-inverse btn-large" style="float: right" href="/install-deltacloud.html">Get Deltacloud</a>

</div>
</div>
