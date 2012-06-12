---
site_name: Deltacloud API
title: Send a Patch
---

<br/>

<ul class="breadcrumb">
  <li>
    <a href="/how-to-contribute.html#how">How to contribute?</a> <span class="divider">/</span>
  </li>
  <li class="active">Send a patch</li>
</ul>

<h3>Formatting and sending patches</h3>

<p>
The Deltacloud community works with <a href="http://book.git-scm.com/">Git</a>. The process of contributing to the project we prefer contains these steps: <strong>local_branch → patch → review → accept → commit</strong> process for contributing to the project. This is how the typical workflow used by the core developers looks like:
</p>

<ol>
  <li>
  <p>
  Set the following settings inside the git configuration file. The config file is located in the root of the Deltacloud project in a hidden <strong>.git</strong> directory. Open the config file with your preferred editor:
  </p>

<pre>
$ vim deltacloud/.git/config
</pre>

  <p>
  Add the following information to the configuration file and replace the relevant values with your own ones:
  </p>

<pre>
[sendemail]
signedoffbycc = no
chainreplyto = no
smtpserver = your_smpt.server.address
thread = yes
from = your_email_address
suppresscc = all
to = dev@deltacloud.apache.org

[core]
whitespace = trailing-space,space-before-tab

[apply]
whitespace = error-all
</pre>

  </li>
  <li>
  <p>
  Get the latest HEAD of the Deltacloud git repo. You will gain one local branch called master:
  </p>

<pre>
$ git branch
* master
</pre>

  </li>
  <li>
  <p>
  Fetch the latest changes from the git repo:
  </p>

<pre>
$ git pull
</pre>

  </li>
  <li>
  <p>
  Create a new local branch for your edits and give it a name:
  </p>

<pre>
$ git checkout -b my_new_branch
</pre>

  </li>
  <li>
  <p>
  Make your changes and then check, what you've edited:
  </p>

<pre>
$ git status
</pre>

  </li>
  <li>
  <p>
  Commit these changes to your local branch:
  </p>

<pre>
$ git commit -a
</pre>
  
  <p>
  This will open an editor (e.g. vi). Enter a commit message. The message should be short and succinct and individual lines shouldn't be longer than 80 characters. See the recent commits with their commit messages to find an inspiration:</p>
  
<pre>
$ git log
</pre>

  <p>
  When you commit your changes to your local branch, the local branch will be different from your <strong>local master</strong> branch. Other developers may have already committed their changes to the <strong>remote master</strong> branch in the Apache git repo in the meantime. Thus, you need to fetch any new changes and merge them into your <strong>local master</strong>.
  </p>

  </li>
  <li>
  <p>
  Change to master and fetch upstream changes (it there are any):
  </p>
  
<pre>
$ git checkout master
$ git pull
</pre>
  
  <p>
  Your <strong>local</strong> master is now up-to-date with the <strong>remote</strong> master in the git repo.
  </p>
  </li>
  <li>
  <p>
  Rebase the local master onto the branch containing your changes:
  </p>
  
<pre>
$ git rebase master my_new_branch
</pre>
  
  <p>
  This allows you to make patches against master and send them to the Deltacloud mailing list.
  </p>
  
<pre>
$ git format-patch -o /path/to/where/you/keep/patches/ master
$ git send-email --compose --subject 'some subject'
  --thread /path/to/where/you/keep/patches/*
</pre>
  
  <p>
  The other members of the community will review your patches. The patch has to receive at least one <strong>ACK </strong>and no <strong>NACK</strong> to be approved. Then the patch will be committed by one of the Deltacloud developers with commit rights to the Apache repo. If noone is responding to your patch sent to mailing list, feel free to remind yourself after few days.
  </p>
  </li>
</ol>

<p>
You can also contribute to the project by reviewing patches sent by other contributors:
</p>

<ol>
  <li>
  <p>
  Make a new branch where you will apply the patches and test:
  </p>

<pre>
$ git checkout -b jsmith_patches
</pre>

  </li>
  <li>
  <p>
  Save the patches to a known location and make sure you're on the right branch . Then apply.
  </p>
  
<pre>
$ git checkout jsmith_patches

$ cat /path/to/patches/0001-name-of-patch.txt | git apply
</pre>
or
<pre>
$ git am /path/to/patches/0001-name-of-patch.eml
</pre>

  <p>
  You can use <strong>git am</strong> ("apply mail") to apply patches in mail format, or <strong>git apply</strong> for plain-text patches. If you use <strong>git apply</strong>, you will only apply the patches, whereas <strong>git am</strong> will also commit the patches to the local branch (preserving the author's commit messages). However, the difference between <strong>git am</strong> and <strong>git apply</strong> is insignificant for the purpose of reviewing patches. It depends on whether you want to save the patches as plain-text or in .mbox email format.
  </p>

  </li>
  <li>

<p>
If you think the patches are working correctly, send an <strong>ACK</strong> to the Deltacloud <a href="http://mail-archives.apache.org/mod_mbox/deltacloud-dev/">mailing list</a>. Similarly, if you think the patches could cause a problem, send a <strong>NACK</strong> and explain the issue you have found.
</p>
  </li>
</ol>

<p>
  <a class="btn btn-inverse btn-large" style="float: right" data-toggle="modal" href="#tests">Test the patch</a>
  <a class="btn btn-inverse btn-large" href="/how-to-contribute.html"><i class="icon-arrow-left icon-white" style="vertical-align:baseline"> </i> Back</a>
</p>

<div class="modal hide" id="tests">
  <div class="modal-header">
    <a class="close" data-dismiss="modal">×</a>
    <h3>Writing and running tests</h3>
  </div>
  <div class="modal-body">

<p>
You should add a test to every new feature or new driver you create to make sure, that everything is running as expected. There are two different directories in the Deltacloud project, where the tests are stored: <strong>/deltacloud/server/tests</strong> for Unit tests for drivers and <strong>/deltacloud/tests</strong> for Cucumber tests.
</p>

<p>Initiate the Unit tests:</p>

<pre>
$ cd /path/to/deltacloud/server
$ rake test
</pre>

<p>This will invoke all Unit tests defined in <strong>/deltacloud/server/tests</strong> by inspecting the Rakefile in <strong>/deltacloud/server</strong>. To invoke a specific driver tests type:</p>

<pre>
$ cd /path/to/deltacloud/server
$ rake test:rackspace
  _OR_
$ rake test:mock
  _etc_
</pre>

<p>Initiate the Cucumber tests:</p>

<pre>
$ cd /path/to/deltacloud/server
$ rake cucumber
</pre>

<p>Alternatively, you can invoke the cucumber tests directly without using Rakefile: </p>

<pre>
$ cd /path/to/deltacloud/server
$ cucumber ../tests/mock
  _OR_
$ cucumber ../tests/ec2
  _etc_
</pre>

  </div>
  <div class="modal-footer">
    <a href="#" class="btn btn-primary" data-dismiss="modal">Close</a>
  </div>
</div>
