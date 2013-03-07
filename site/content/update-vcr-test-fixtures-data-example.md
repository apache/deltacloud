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

    <pre>
    rhevm:
      user:     'admin@internal'
      password: 'localpassword'
      provider: 'https://16.1.1.3/api;b9bb11c2-f397-4f41-a57b-7ac15a894779'
    mock:
      user: mockuser
      password: mockpassword
      provider: compute
  </li>

  <li>
    <p>Modify the test source to have the realm, instance, image & provider
       for a live cloud provider.</p>

    <pre>
    % vim server/tests/drivers/rhevm/instance_test.rb
    ...
    TST_REALM    = '12345678-123a-123b-123c-123456789abc'
    TST_INSTANCE = '23456781-23a1-23b1-23c1-23456789abce'
    TST_IMAGE    = '34567812-3a12-3b12-3c12-3456789abcef'
    ...
        @driver = Deltacloud::Test::config.driver(:rhevm,
          provider="https://16.1.1.3/api;b9bb11c2-f397-4f41-a57b-7ac15a894779")
    </pre>

  </li>

  <li>
    <p>Set the VCR record mode to :record => :all</p>

    <pre>
    % vim server/tests/drivers/rhevm/common.rb
    ...
    # Set :record to :all, when re-recording and between re-record attemps
    # be sure to clear fixtures/*.yml files which can be done with "git checkout".
    # e.g.:
    c.default_cassette_options = { :record => :all }
    # c.default_cassette_options = { :record => :none }
    ...
    </pre>

  </li>


  <li>
    <p>Run the test in record mode</p>

    <pre>
    % cd YOUR-REPO/deltacloud/server

    # Record only the single test
    % ruby tests/drivers/rhevm/instance_test.rb

    or

    # Record the drivers:rhevm tests:
    % rake test:drivers:rhevm

    or

    # Record all the tests:
    % rake test
    </pre>

  </li>

  <li>
    <p>Remove the user:password creds from the fixture.</p>

    <p>
    The recorded fixture will contain live creds. For security reasons
    it is best to either change the credentials on the cloud provider or
    remove them from the fixture YAML file. Removing them from the fixture
    YAML file can easily be accomplished using sed.
    </p>

    <pre>
    e.g.:
    for i in $(ls tests/drivers/rhevm/fixtures/test_0*.yml); do \
      echo $i; \
      cat $i | sed s/admin%40internal:localpassword/fakeuser:fakepassword/ > $i.new; \
      mv $i.new $i; \
    done
    </pre>

  </li>

  <li>
    <p>Remove ${HOME}/.deltacloud/config</p>

    <p>
    This is done to avoid using the credentials from the config file
    during non-recording test runs.
    </p>

    <pre>
    e.g.: (note it might be best to save it in ".ORIG" for future re-recordings.)
    mv ${HOME}/.deltacloud/config ${HOME}/.deltacloud/config.ORIG
    </pre>
  </li>

  <li>
    <p>Turn off record mode.

    <p>To turn off record mode set the record mode to { :record => :none }</p>

    <pre>
    % vim server/tests/drivers/rhevm/common.rb
    ...
    # Set :record to :all, when re-recording and between re-record attemps
    # be sure to clear fixtures/*.yml files which can be done with "git checkout".
    # e.g.:
    # c.default_cassette_options = { :record => :all }
    c.default_cassette_options = { :record => :none }
    ...
    </pre>

  </li>

  <li>
    <p>Remove trailing white space from the fixtures YAML files.</p>

    <p>
    Recording can place trailing white space in the fixtures YAML files
    which can be removed or ignored.
    </p>

    <p>There are many ways to accomplish this.</p>
  </li>

  <li>
    <p>Confirm all tests run in mock mode</p>

    <pre>
    % cd <REPO>/deltacloud/server

    # Run only the single tests that had been re-recorded
    % ruby tests/drivers/rhevm/instance_test.rb

      and

    # Run all tests in that section:
    % rake test:drivers:rhevm

      and

    # Record all the tests:
    % rake test
    </pre>
  </li>

</ol>
