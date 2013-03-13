---
site_name: Deltacloud API
title: Updating VCR Fixtures Example
---

<br/>

<ul class="breadcrumb">
  <li>
    <a href="white-box-tests.html">White Box Tests?</a> <span class="divider">/</span>
  </li>
  <li class="active">Updating VCR Fixtures Example</li>
</ul>

<h3>An Example of Re-recording the VCR test fixtures.</h3>

<p>
Below is an example of recording new fixtures for the test:
<i><u><b>server/tests/drivers/rhevm/instance_test.rb</b></u></i>
tests.
</p>

<p>
More information can be found on the past recording of the
<a href="http://youtu.be/zTCGRDO_3dU">Deltacloud Community Call #12</a>
</p>


<ol>
  <li>
    <p> Create ${HOME}/.deltacloud/config</p>
    <br>
    <p> Create the deltacloud config file: ${HOME}/.deltacloud/config</p>
    to contain the credentials and provider resource UUIDs</p>

    <pre>
    rhevm:
      user:     'admin@internal'
      password: 'localpassword'
      provider: 'https://rhevm.example.com/api'
      preferred:
        datacenter: UUID of a datacenter/realm
        vm: UUID of an existing instance
        template: UUID of an existing template/image
    mock:
      user: mockuser
      password: mockpassword
      provider: compute
  </li>

  <li>
    <p>Set the VCR record mode to <i>all</i></p>
    <br>
    <p> Note: This does not cause <i>all</i> tests to be recorded.
    It instructs VCR to record new fixtures data for the test to
    be run in the next step.</p>

    <pre>
    % export VCR_RECORD="all"
    </pre>

  </li>

  <li>
    <p>Run the test in record mode</p>

    <pre>
    % cd YOUR-REPO/deltacloud/server

    # Record only the single test:
    % ruby tests/drivers/rhevm/instance_test.rb

    <b>or</b>

    # Record the drivers:rhevm tests:
    % rake test:drivers:rhevm

    <b>or</b>

    # Record all the tests:
    % rake test
    </pre>

  </li>

  <li>
    <p>Disable record mode.
    <br>
    <p>This will allow the test to be run in playback mode using the
    recorded  fixtures data.</p>

    <pre>
    % unset VCR_RECORD
    </pre>

  </li>
  <li>
    <p>Confirm all tests run in mock mode</p>

    <pre>
    % cd <REPO>/deltacloud/server

    # Run only the single tests that had been re-recorded
    % ruby tests/drivers/rhevm/instance_test.rb

      <b>and</b>

    # Run all tests in that section:
    % rake test:drivers:rhevm

      <b>and</b>

    # Record all the tests:
    % rake test
    </pre>
  </li>

</ol>
