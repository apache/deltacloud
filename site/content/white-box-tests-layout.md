---
site_name: Deltacloud API
title:  White Box Tests Source Description
---

<br/>

<ul class="breadcrumb">
  <li>
    <a href="white-box-tests.html">White Box Tests?</a> <span class="divider">/</span>
  </li>
  <li class="active">White Box Tests Source Description</li>
</ul>

<h3>Where Are The White Box Tests:</h3>

<p>The following depicts where in the deltacloud directory source structure the
white box tests are located:</p>
<div class="row">
  <div class="span1"></div>
  <div class="span10 offset1">
<pre>
deltacloud
|-----------------------------------------------------------------------------
|-d--> server
  |---------------------------------------------------------------------------
  |-d-->tests               Contains unit tests for drivers
  |---------------------------------------------------------------------------
    |-d-->cimi              Contains Frontend CIMI tests
    |-------------------------------------------------------------------------
    |-d-->deltacloud        Contains Frontend deltacloud tests
    |-------------------------------------------------------------------------
    |-d-->ec2               Contains Frontend ec2 tests
    |-------------------------------------------------------------------------
    |-d-->drivers           Contains Backend driver gem tests
    |-------------------------------------------------------------------------
      |-d-->base
      |-d-->ec2
      |-d-->fgcp
      |-d-->gogrid
      |-d-->google          Contains the varios driver tests
      |-d-->mock                and
      |-d-->models          VCR YAML fixtures
      |-d-->openstack
      |-d-->rhevm
    |-------------------------------------------------------------------------
    |-d-->helpers           Contains helper code common to multiple tests
    |-------------------------------------------------------------------------
    |-f-->test_helper.rb    Contains the common test helper routes
    |-------------------------------------------------------------------------
</pre>

  </div>
</div>

<br/>

<h3>Driver tests</h3>

<u><b>REPO</b>/deltacloud/server/tests/drivers</u>

<br/>

<p>
This directory provides all the <i><b>driver</b></i> tests. Each driver tests is
placed into a separate directory with the driver name.  Everything that touchs
the driver API goes here as well. It is good practice to divide the tests into
logical collections, in this case driver methods.
</p>

<p>
Driver tests use the Deltacloud::new method to create new instance of a driver.
This method is usually called in a <i>before</i> block and takes two parameters:
<i>driver name</i> and <i>credentials</i>. The driver methods can be called
directly on the instance of Deltacloud::new.
</p>

<p>
Some driver tests may use the <a href="https://github.com/vcr/vcr">VCR</a> gem
to record and then mock the real communication with the backend server. The fixtures
are maintained in the <i>tests/drivers/<b>DRIVER</b>/fixtures</i> directory.
</p>

<p>
For more informations about recording, look at the file: <i>tests/drivers/ec2/common.rb</i>,
<a href="why-update-vcr-test-fixtures-data.html">Why Updating the VCR Fixtures</a>
and <a href="update-vcr-test-fixtures-data-example.html">Updating VCR Fixtures Example</a>
</p>

<h3>Test Helpers</h3>

<u><b>REPO</b>/deltacloud/server/tests/helpers</u>

<br/>

<p>
The <i>base</i> directory contain tests for Deltacloud::Driver class and the Library
class.
</p>

<h3>Frontend tests</h3>

<p>
In addition to the default <i>deltacloud</i> frontend Deltacloud may also
operate using different frontends. In this case, instead of exposing the
DC API specification to the client, Deltacloud will provide its drivers
API through different frontends (like CIMI or Amazon EC2).
</p>

<p>
Some tests might use the Mock driver to call the <i>control</i> blocks in Rabbit
collections.  These tests are <b>not</b> driver tests, they just use the mock
driver to make sure the Rabbit operation <i>control blocks</i> works as expected
and they provide expected output.
</p>

<u><b>REPO</b>/deltacloud/server/tests/deltacloud</u>

<p>
This directory provides tests for Deltacloud API frontend. It contains tests
for collections that this frontend provides and also tests helpers that this
frontend use.
</p>

<u><b>REPO</b>/deltacloud/server/tests/ec2</u>

<p>
This directory provides tests for the EC2 frontend. Tests make sure that mapping
between EC2 actions and Deltacloud driver API works correctly. All tests
relevant to EC2 frontend tests should go here. **NOTE** this directory does not
provide Amazon EC2 driver tests.
</p>

<u><b>REPO</b>/deltacloud/server/tests/cimi</u>

<p>
This directory provides tests for the CIMI frotend. They make sure that
JSON/XML serialization of the CIMI models works correctly. Also there are tests
to make sure the output provided by CIMI collections is correct.
</p>

