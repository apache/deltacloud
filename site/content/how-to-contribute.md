--- 
site_name: Deltacloud API
title: How Can I Contribute?
---
<br/>

<h3 id="contribute">Contribute to Deltacloud</h3>
Deltacloud project is a free open source software licensed under the <a href="http://www.apache.org/licenses/LICENSE-2.0">Apache Software Foundation</a> license. The developers community is open to anyone who wants to contribute. Contributors are required to sign an individual contributor <a href="http://www.apache.org/licenses/icla.txt">license agreement</a>. Do not hesitate to <a href="/contact.html">contact us</a> if you have any questions about contributing to the Deltacloud project.

<h4 id="how">How can I contribute?</h4>

<ul class="nav nav-list">
  <li class="nav-header"></li>
  <li>
    <a href="/send-patch.html">Send a patch</a>
  </li>
  <li>
    <a href="/write-new-driver.html">Write a provider driver</a>
  </li>
  <li>
    <a href="#bug">Report a bug</a>
  </li>
  <li>
    <a href="#idea">Propose an idea</a>
  </li>
  <li>
    <a href="#documentation">Write documentation</a>
  </li>
  <li>
    <a href="/white-box-tests.html">Validate contributions using the white box tests</a>
  </li>
</ul>

<br/>

<h3>Overview of the Deltacloud directory structure</h3>

<p>The following list contains paths to essential files and directories for developers. It is intended as a help with orientation in the project directory - for example to quickly identify where the Deltacloud cloud provider drivers are stored:</p>

<div class="row">
  <div class="span1"></div>
  <div class="span10 offset1">
<pre>
deltacloud
|-----------------------------------------------------------------------------------
|-d-->tests                           Contains Cucumber tests
|-----------------------------------------------------------------------------------
|-d-->site                            Files for this website
|-----------------------------------------------------------------------------------
|-d-->client                          Contains the Deltacloud ruby client
|-----------------------------------------------------------------------------------
|-d-->clients                         Contains other Deltacloud clients (e.g. java)
|-----------------------------------------------------------------------------------
|-d--> server
       |----------------------------------------------------------------------------
       |-d-->bin                      Contains the Deltacloud executable deltacloudd
       |----------------------------------------------------------------------------
       |-d-->views                    Contains haml views for each collection
       |----------------------------------------------------------------------------
       |-d-->tests                    Contains unit tests for drivers
       |----------------------------------------------------------------------------
       |-d-->lib
             |----------------------------------------------------------------------
             |-d-->sinatra            Contains rabbit DSL and various helpers
             |----------------------------------------------------------------------
             |-d-->deltacloud
                   |----------------------------------------------------------------
                   |-d-->models       Definition of each collection model
                   |----------------------------------------------------------------
                   |-d-->drivers      Contains the drivers for each cloud provider
                   |----------------------------------------------------------------
                   |-d-->helpers      Various helper methods used by the drivers
                   |----------------------------------------------------------------
                   |-d-->base_driver  Contains the Deltacloud base driver
                   |----------------------------------------------------------------
                   |-f-->server.rb                Contains the sinatra routes
                   |----------------------------------------------------------------
</pre>

  </div>
</div>

<br/>

<h3 id="bug">Reporting a bug</h3>
We track bugs in <a href="https://issues.apache.org/jira/browse/DTACLOUD">Apache JIRA</a>. When you discover a problem with Deltacloud functionality, check JIRA if someone has already reported the issue to the Deltacloud developers. Otherwise, <a href="https://issues.apache.org/jira/secure/CreateIssue!default.jspa">report it</a>.

<h3 id="idea">Proposing an idea</h3>
Have you found a way how to improve Deltacloud project? Do you miss a feature or a tool, which we could include into Deltacloud? Our <a href="http://teambox.com/projects/deltacloud">Teambox</a> page is a place where we keep the latest task lists and where you can add comments or suggest new features for the project.

<h3 id="documentation">Writing documentation</h3>
You can also contribute with a piece of documentation. There are still things which needs to be described. If you found one like that and you are interested in writing a couple of sentences about the particular issue, please, don't hesitate to do it and <a href="http://mail-archives.apache.org/mod_mbox/deltacloud-dev/">send us</a> your contribution. We really appreciate your help.



