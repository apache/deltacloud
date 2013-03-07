---
site_name: Deltacloud API
title: Why Update The VCR Fixtures
---

<br/>

<ul class="breadcrumb">
  <li>
    <a href="white-box-tests.html">White Box Tests?</a> <span class="divider">/</span>
  </li>
  <li class="active">Why Update The VCR Fixtures</li>
</ul>

<p>
Deltacloud uses pre-recorded <a href="https://github.com/vcr/vcr">VCR</a> YAML
files called <i>fixtures</i> to allow test execution without the need for a live
cloud provider.
</p>

<p>
The <i>fixtures</i> YAML files are located under:
<u><b>REPO</b>/deltacloud/server/tests/drivers/<i>driver name</i>/fixtures</u>
</p>

<p>
A live cloud provider, with valid credentials, needs to be used in order to
<a href="https://www.relishapp.com/vcr/vcr/v/1-6-0/docs/record-modes">record</a>
the fixtures YAML files but once recorded the tests can then be executed without
a live cloud provider.
</p>

<p>
Because valid credentials are used to record the VCR fixtures data care must be
taken to either alter the credentials on the live cloud provider or remove them
from the fixtures data after doing the recording.
More on how to do this can be found in
<a href="update-vcr-test-fixtures-data-example.html">Updating VCR Fixtures Example</a>
</p>

<h3>Why VCR data May Need Updating:</h3>

<p>
In some cases you will need to re-record the VCR fixtures for particular test.
This happen when a request is made to the backend cloud provider that a
test does not yet exercise. <b>For Example:</b>
</p>

<ul>
  <li>
    <p>
    A bug is fixed in the EC2 driver, where <i>images()</i> method had not work properly.
    </p>
    <ol>
      <li>
        <p>Open <i>tests/drivers/ec2/images_tests.rb</i></p>
      </li>
      <li>
        <p>Add a new test to capture this bug.</p>
        <p>At the end of this file and add a the new code:</p>
        <pre>
        it 'should provide correct output' do
          # assertions go here
        end
        </pre>
      </li>
    </ol>
  </li>

  <li>
    <p>
    Scenario: You added new collection <i>oranges()</i> into RHEV-M driver.
    </p>
    <ol>
      <li>
        <p>Write all driver methods tests here: <i>tests/drivers/rhevm/oranges_tests.rb</i></p>
      </li>
      <li>
        <p>Create <i>tests/deltacloud/collections/oranges_collection_tests.rb</i></p>
      </li>
      <li>
        <p>Write all collection operations tests here ^^</p>
      </li>
    </ol>
  </li>

  <li>
    <p>
    A bug is fixed in the Deltacloud frontend where <i>/api/images/123/create</i>
    operation does not provide correct status code. You corrected it.
    </p>
    <ol>
      <li>
        <p>Open 'tests/deltacloud/collections/images_collection_test.rb'</p>
      </li>
      <li>
        <p>Locate this line: </p>
          <pre>
          it 'allow to create and destroy the new image' do</p>
          </pre>
      </li>
      <li>
        <p>Provide the correct value into 'status.must_equal' method</p>
      </li>
    </ol>
  </li>

</ul>

