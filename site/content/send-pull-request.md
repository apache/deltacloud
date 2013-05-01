---
site_name: Deltacloud API
title: Send a Pull Request
---

<br/>

<ul class="breadcrumb">
  <li>
    <a href="/how-to-contribute.html#how">How to contribute?</a> <span class="divider">/</span>
  </li>
  <li class="active">Send a pull request</li>
</ul>

<h3>GIT Workflow and sending a pull request</h3>

<hr><h4>Basics</h4>

  <ul>
    <li>Deltacloud uses Github for pull requests and patch reviews.</li>
    <li>The deltacloud/deltacloud-core repository is just a mirror for the official ASF GIT repository.</li>
    <li>The mirror script runs every 2 minutes so please be patient.</li>
    <li>In order to have your patch accepted and pushed, you need to have signed the Apache Individual Contributor License Agreement</li>
    <li>We use the official ASF repository for pushing patches (you need to be an ASF contributor with push rights for this), or you need to ask somebody with push rights to do so. If you are not Deltacloud API ASF project member with push rights, please ignore this information and issue a pull request for someone to push for you.</li>
  </ul>

<hr><h4>Adding Deltacloud Github repository</h4>

<ul>
<li>
<b>Fork the "deltacloud/deltacloud-core"</b>
  <a href="https://github.com/deltacloud/deltacloud-core">repository</a>
  by click on the <b>Fork</b> tab at the top of the page
  <br/><br/><br/>

  <div class="span8">
    <img src="/assets/img/git-Fork.png" alt="git Fork diagram" align="center"/>
  </div><br/><br/><br/><br/>

</li>

<li>
<b>Clone your fork</b>
  <pre>
  $ git clone https://github.com/<i>your username</i>/deltacloud-core.git
  </pre>
</li>

<li>
<p><b>Configure remotes</b></p>
  <pre>
  $ cd deltacloud-core
  $ git remote add upstream https://github.com/deltacloud/deltacloud-core.git
  $ git fetch upstream
  </pre>
</li>

<li>
  <p>For more details on forking git repositories see:
  <a href="https://help.github.com/articles/fork-a-repo">The Official GitHub Help <b>Fork A Repo</b></a></p>
</li>
</ul>

<br/>
<br/>

<hr><h4>Basic GIT workflow</h4>

<ul>
<li>Commit some code changes
  <pre>
  $ git checkout -b <b>my branch</b>
  <i>Coding your changes</i></li>
  $ git commit -m "Commit message"
  </pre>
</li>

<li><p>
   <i><b>Tip:</b></i> If there is a <a href="https://issues.apache.org/jira/browse/DTACLOUD">JIRA</a>
   ticket associated with this work <b>please</b> include the JIRA ID
   in the commit message<br/>
   <b>For example:</b> <i>This change addresses: <b>DTACLOUD-123</b></i>
</p></li>

<li>Repeat the previous step until you finish the needed changes.</li>
</ul>

<hr><h4>Pushing your work</h4>
<p>
  <ul>
    <li>Update the original repo
    <br/><br/>
    <p>This will avoid possible merge conflicts and problems with applying your patches.</p>
    <pre>
    $ git checkout master
    $ git pull
    </pre>
    <li>Push to your fork.
    <pre>
    $ git checkout my_work_topic
    $ git rebase -i master (Tip: You can rename/squash commits at this point)
    $ git push origin my_work_topic
    </pre>
    </li>
  </ul>
</p>

<hr><h4>Issue the Pull request</h4>
<p>
  <ul>
    <li>Navigate to your forked Github repository <br/>
    <b>For example:</b>https://github.com/<i>your username</i>/deltacloud-core.git
    </li>
    <li>click the <i>Pull Request</i> tab</li>
    (Tip: You can use hub to automate this step)
    </li>
    <li>
      <p>For more details on using pull requests see:
      <a href="https://help.github.com/articles/using-pull-requests">The Official GitHub Help <b>For Using Pull Request</b></a></p>
    </li>
  </ul>
</p>

<hr><h4>Pull request / review process</h4>

<ul>
  <li>Your <b>pull request</b> will appear <a href="https://github.com/deltacloud/deltacloud-core/pulls">here</a>
  </li>
  <li>All subscribers will be notified by email that a new pull request has been issued.
  </li>
  <li>When doing a review please follow our <a href="https://cwiki.apache.org/confluence/display/DTACLOUD/Deltacloud+API+code+style+guidelines">coding guidelines</a>
  </li>
  <li>Reviewers can leave comments on your pull request directly on github.
  </li>
  <li>Help on reviewing github pull requests can be found <a href="https://help.github.com/articles/using-pull-requests#reviewing-proposed-changes">here</a>
  </li>
  <li>If your pullrequest is not being reviewed, please request one on the <b>#deltacloud</b> IRC channel on <b>irc.freenode.org</b>
  </li>
  <li>Once your pull request gets ACKed, the person who did the review should <b>close</b> the pull request <b>without merging it</b>.
  </li> 
  <li>The reviewer, or someone with push rights, should push the change to the official
  Apache GIT repository:<br/>
  <b>https://github.com/apache/deltacloud</b>
  </li>
  <li>No changes should be pushed to the mirror used to create your fork, <br/>
  <b>https://github.com/deltacloud/deltacloud-core</b>
  </li>
</ul>

<hr><h4>Contributors with push rights</h4>
<p>
  <ul>
    <li>Adding ASF as a remote branch
    <pre>
    $ git remote add apache https://git-wip-us.apache.org/repos/asf/deltacloud.git
    $ git fetch apache
    $ git checkout -b apache apache/master
    </pre>
    <li>Pushing patches
    <pre>
    $ git checkout topic_you_want_to_push
    $ git rebase -i apache
    $ git checkout apache
    $ git merge topic_you_want_to_push
    $ git push apache refs/heads/apache:master
    </pre>
    </li>
    <li>
    <b>Note:</b> Do not forget to git pull from the <i>apache</i> branch before merging changes
    </li>
    <li><p>Tip: To make all pull requests appear in your local GIT repository follow <a href="https://gist.github.com/piscisaureus/3342247">these</a> instructions.<br/><br/>
       Then to get all pull requests locally issue:
       <pre>
       $ git fetch origin
       </pre>

       <p>Then to checkout a single pull request directly issue:</p>
       <pre>
       $ git checkout pr/NUMBER
       </pre>
 
       <p>instead of issueing:</p>
       <pre>
       $ git checkout topic_you_want_to_push
       </pre>
    </li>
  </ul>
</p>
<br/><br/><br/>


  </div>
  <div class="modal-footer">
    <a href="#" class="btn btn-primary" data-dismiss="modal">Close</a>
  </div>
</div>
