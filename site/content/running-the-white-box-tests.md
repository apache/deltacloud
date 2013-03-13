---
site_name: Deltacloud API
title: Running the Whitebox Tests
---

<br/>

<ul class="breadcrumb">
  <li>
    <a href="white-box-tests.html">White Box Tests?</a> <span class="divider">/</span>
  </li>
  <li class="active">Running The White Box Tests</li>
</ul>

<h3>Running the white box tests</h3>

<p>After getting the source and <a href="getting-sources.html"> setting
up the development environment</a>, the tests can be executed in groups,
using tasks in the Rakefile, or individually using ruby directly.</p>

<ul>
  <li>
    <p>Examples using rake tasks to executed groups of tests.</p>
  </li>

  <ul>
    <li>
      <p>Rake task to run <b><u><i>all</i></u></b> the tests: </p>
      <pre>
      % cd <b>REPO</b>/deltacloud/server
      % rake test                 # Run all tests
      </pre>
    </li>

    <li>
      <p>Example of listing the available subtasks have available tests: </p>
      <pre>
      % cd <b>REPO</b>/deltacloud/server
      % rake -T test
      <i>output list or available tests</i>
      </pre>
    </li>

    <li>
      <p>Example rake task to run ec2 <b><u><i>frontend </i></u></b> tests: </p>
      <pre>
      % cd <b>REPO</b>/deltacloud/server
      % rake test:ec2             # Run tests for ec2
      </pre>
    </li>

    <li>
      <p>Example rake task to run the rhevm <b><u><i>driver </i></u></b>  tests: </p>
      <pre>
      % cd <b>REPO</b>/deltacloud/server
      % rake test:drivers:rhevm   # Run tests for rhevm
      </pre>
    </li>

  </ul>

  <li>
    <p>Example manually running an <b><u><i>individual</i></u></b> test: </p>
    <pre>
    % cd <b>REPO</b>/deltacloud/server
    % bundle exec ruby tests/drivers/ec2/realms_test.rb
    </pre>
  </li>

</ul>
