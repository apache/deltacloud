--- 
site_name: Deltacloud API
title: Download
---
<br/>
<h3>Download</h3>
<p>
  Version <b>1.0.0</b> of Apache Deltacloud is available. See the
  <a href="https://git-wip-us.apache.org/repos/asf?p=deltacloud.git;a=blob;f=NEWS;h=2f113a2d2462fa7d45b4898932ca568d53820440;hb=HEAD">release notes</a>.
</p>
<p>
  Use the links below to download a distribution of Apache Deltacloud.
  Alternatively you can use one of the <a href="http://www.apache.org/dyn/closer.cgi?path=deltacloud">Apache mirrors</a>.
  It is good practice to <a href="#verify">verify the integrity</a> of the distribution files,
  especially if you are using one of our mirror sites. To do this, you must use the
  signatures from our <a href="http://www.apache.org/dist/deltacloud/">main distribution directory</a>.
</p>
<h3 id="mirrors">Current release</h3>
<table class="table">
  <tbody>
    <tr>
      <td><strong>server-gem</strong></td>
      <td>
        <a href="http://www.apache.org/dyn/closer.cgi?path=deltacloud/stable/deltacloud-core-1.0.0.gem">deltacloud-core-1.0.0.gem</a>
        (
        <a href="http://www.apache.org/dyn/closer.cgi?path=deltacloud/stable/deltacloud-core-1.0.0.gem.asc">PGP</a>
        <a href="http://www.apache.org/dyn/closer.cgi?path=deltacloud/stable/deltacloud-core-1.0.0.gem.md5">MD5</a>
        <a href="http://www.apache.org/dyn/closer.cgi?path=deltacloud/stable/deltacloud-core-1.0.0.gem.sha1">SHA1</a>
        )
      </td>
    </tr>
    <tr>
      <td><strong>server-sources</strong></td>
      <td>
        <a href="http://www.apache.org/dyn/closer.cgi?path=deltacloud/stable/deltacloud-core-1.0.0.tgz">deltacloud-core-1.0.0.tgz</a>
        (
        <a href="http://www.apache.org/dyn/closer.cgi?path=deltacloud/stable/deltacloud-core-1.0.0.tgz.asc">PGP</a>
        <a href="http://www.apache.org/dyn/closer.cgi?path=deltacloud/stable/deltacloud-core-1.0.0.tgz.md5">MD5</a>
        <a href="http://www.apache.org/dyn/closer.cgi?path=deltacloud/stable/deltacloud-core-1.0.0.tgz.sha1">SHA1</a>
        )
      </td>
    </tr>
    <tr>
      <td><strong>client-gem</strong></td>
      <td>
        <a href="http://www.apache.org/dyn/closer.cgi?path=deltacloud/stable/deltacloud-client-1.0.0.gem">deltacloud-client-1.0.0.gem</a>
        (
        <a href="http://www.apache.org/dyn/closer.cgi?path=deltacloud/stable/deltacloud-client-1.0.0.gem.asc">PGP</a>
        <a href="http://www.apache.org/dyn/closer.cgi?path=deltacloud/stable/deltacloud-client-1.0.0.gem.md5">MD5</a>
        <a href="http://www.apache.org/dyn/closer.cgi?path=deltacloud/stable/deltacloud-client-1.0.0.gem.sha1">SHA1</a>
        )
      </td>
    </tr>
    <tr>
      <td><strong>client-sources</strong></td>
      <td>
        <a href="http://www.apache.org/dyn/closer.cgi?path=deltacloud/stable/deltacloud-client-1.0.0.tgz">deltacloud-client-1.0.0.tgz</a>
        (
        <a href="http://www.apache.org/dyn/closer.cgi?path=deltacloud/stable/deltacloud-client-1.0.0.tgz.asc">PGP</a>
        <a href="http://www.apache.org/dyn/closer.cgi?path=deltacloud/stable/deltacloud-client-1.0.0.tgz.md5">MD5</a>
        <a href="http://www.apache.org/dyn/closer.cgi?path=deltacloud/stable/deltacloud-client-1.0.0.tgz.sha1">SHA1</a>
        )
      </td>
    </tr>
  </tbody>
</table>
<p></p>
<h4 id="archive">Old releases</h4>
<p>
  Older releases of Apache Deltacloud can be found <a href="http://archive.apache.org/dist/deltacloud/">here</a>. We highly recommend to <b>not use</b>
  those releases but upgrade to the latest release.
</p>
<p></p>
<h4 id="rubygems">Rubygems</h4>
<p>
  RubyGems.org is the Ruby community's gem hosting service. For most of the Ruby
  developers it is the most convenient way how to download Apache Deltacloud.
  We always push the major releases to Rubygems.org page. To download Apache
  Deltacloud from there you can use <code>gem fetch deltacloud-core</code> or
  <code>gem fetch deltacloud-client</code> commands. Please mind to <a
  href="#verify">verify</a> the downloaded sources.
</p>
<h3 id="sources">Getting the sources</h3>
<p>
  We provide an extensive amount of information about how to use the Apache
  <a href="https://git-wip-us.apache.org/repos/asf/deltacloud.git">Deltacloud GIT repository</a> on <a href="/getting-sources.html">this page</a>.
</p>
<h3 id="verify">Verify the integrity of the files</h3>
<p>
  <span class="label">Note:</span>
  When downloading from a mirror please check the <a
  href="http://www.apache.org/dev/release-signing#md5">md5sum</a> and verify the
  <a href="http://www.apache.org/dev/release-signing#openpgp">OpenPGP</a>
  compatible signature from the main <a href="http://www.apache.org/">Apache
  site</a>. Links are provided above (next to the release download link).
</p>
<p>
  The PGP signatures can be verified using PGP or GPG. First download the <a
  href="http://www.apache.org/dist/deltacloud/KEYS">KEYS</a> as well as the
  <code>asc</code> signature file for the relevant distribution. Make sure you get
  these files from the <a href="http://www.apache.org/dist/deltacloud/">main
  distribution directory</a>, rather than from a mirror. Then verify the
  signatures using:
</p>
<pre>
$ pgpk -a KEYS
$ pgpv deltacloud-core-1.0.0.tar.gz.asc
</pre>
or
<pre>
$ pgp -ka KEYS
$ pgp deltacloud-core-1.0.0.tar.gz.asc
</pre>
or
<pre>
$ gpg --import KEYS
$ gpg --verify deltacloud-core-1.0.0.tar.gz.asc
</pre>
