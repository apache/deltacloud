---
site_name: Deltacloud API
title: White Box Tests
---

<br/>

<ul class="breadcrumb">
  <li>
    <a href="/how-to-contribute.html#how">How to contribute?</a> <span class="divider">/</span>
  </li>
  <li class="active">Validate Contributions Using the White Box Tests</li>
</ul>

<h3>Validate Contributions Using the White Box Tests</h3>

<p>
Deltacloud contains automated API tests, that are driven using pre-recorded
<a href="https://github.com/vcr/vcr">VCR</a> YAML files called <i>fixtures</i>.
The test source and fixtures are maintained in the deltacloud source tree
under: <i><b>REPO/deltacloud/server/tests</i>
</p>

<p>
In some cases it might be necessarey to re-record the VCR fixtures for
particular tests. For example, this could become necessarey, if new
functionality or a bug fix alters the exchange with the backend cloud
provider.
</p>

<p>
The process for updating the test data involves exercising the tests against a live
cloud provider and recording the live API exchange into the VCR fixtures YAML files.
After which the tests can more quickly and easily be run using the recorded VCR
fixtures without the need to accessess a live cloud provider.
</p>

<h4 id="how">Dealing With the White Box Test</h4>

<ul class="nav nav-list">
  <li class="nav-header"></li>
  <li>
    <a href="/white-box-tests-layout.html">White Box Tests Source Description</a>
  </li>
  <li>
    <a href="/running-the-white-box-tests.html">Running The White Box Tests</a>
  </li>
  <li>
    <a href="/why-update-vcr-test-fixtures-data.html">Why Update The VCR Fixtures?</a>
  </li>
  <li>
    <a href="/update-vcr-test-fixtures-data-example.html">Updating VCR Fixtures Example</a>
  </li>
</ul>

