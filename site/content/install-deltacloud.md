--- 
site_name: Deltacloud API
title: Install Deltacloud
---
<br/>
<h3> Installation dependencies</h3>
<p>First of all, you have to install several dependecies. The Deltacloud server relies on a number of external rubygems and other libraries. The following packages are neccessary for running the Deltacloud server. The installation of dependencies slightly differs from distribution to distribution. You will need:</p>

<ul>
  <li>
  ruby and ruby-devel,
  </li>
  <li>
  gem (RubyGems),
  </li>
  <li>
  gcc-c++
  </li>
  <li>
  libxml2 and libxml2-devel,
  </li>
  <li>
  libxslt and libxslt-devel,
  </li>
  <li>
  sqlite and sqlite-devel
  </li>
  <li>
  rake
  </li>
</ul>

<br/>

<h3>Fedora and Red Hat Enterprise Linux</h3>

<h4>Ruby and Ruby-devel</h4>
<p>Check if you already have a <a href="http://www.ruby-lang.org/en/downloads/">Ruby installation</a> by typing the following command. You should see something that looks like:</p>

<pre>
$ ruby -v
ruby 1.8.7 (2010-08-16 patchlevel 302) [i686-linux]
</pre>

<p>Deltacloud requires at least Ruby 1.8.7. You need to install also the development headers (ruby-devel) because Deltacloud relies on some rubygems with C extensions. According to your package manager use commands: </p>

<pre>
$ sudo yum install ruby
$ sudo yum install ruby-devel
</pre>

<h4>RubyGems</h4>
<p>Deltacloud relies on a number of <a href="http://docs.rubygems.org/read/chapter/3">RubyGems</a>. You can check if you already have gem executable (similarly to ruby) by typing <code>$ gem -v</code>. Otherwise use your package manager for the installation: </p>

<pre>
$ sudo yum install rubygems
</pre>

<h4>GCC-C++, Libxml2, Libxml2-devel, Libxslt, Libxslt-devel, sqlite, sqlite-devel</h4>
<p>These libraries are required to build RubyGems that have C extensions (the last two are for the CIMI persistence layer). Use commands:</p>

<pre>
$ sudo yum install gcc-c++
$ sudo yum install libxml libxml2-devel
$ sudo yum install libxslt libxslt-devel
$ sudo yum install sqlite sqlite-devel
</pre>

<h4>Rake</h4>
<p><a href="http://rake.rubyforge.org/">Rake</a> is Ruby's Make and is itself a ruby gem. Once you have RubyGems installed you can get rake with:</p>

<pre>$ sudo gem install rake</pre>

<br/>

<h3>Debian and Ubuntu</h3>

<h4>Ruby and RubyGems</h4>
The following instructions focus on installing Ruby 1.9 (Deltacloud requires at least ruby 1.8.7.). Install ruby and rubygem by typing:

<pre>$ sudo apt-get install ruby1.9.1-full</pre>

Use the following command to check, whether the installation was successful. You should see a similar response:

<pre>
$ ruby -v
ruby 1.9.2p290 (2011-07-09 revision 32553) [i686-linux]
</pre>

You can check the installation of Rubygems the same way:

<pre>
$ gem -v
1.3.7
</pre>

<h4>g++, libxml2, libxml2-dev, libxslt, libxslt-dev, sqlite, sqlite-devel</h4>
<p>These libraries are required to build RubyGems that have C extensions (last two are for CIMI persistence layer). Use commands:</p>

<pre>
$ sudo apt-get install g++
$ sudo apt-get install libxml libxml2-dev
$ sudo apt-get install libxslt libxslt-dev
$ sudo apt-get install sqlite sqlite-dev
</pre>

<h4 id="gem-list">Gem dependecies</h4>
<p>Debian and Ubuntu distributions also require to install following gem dependencies:
<pre>
gem install thin sinatra rack-accept rest-client sinatra-content-for nokogiri
</pre>
Once these gems are installed, go to the directory (normally <strong>/var/lib/gems/1.9.1/gems</strong>), where gems are located and check that you have following gems listed. You may see more gems than you directly installed, because RubyGems install gem dependecies automaticly.
</p>

<br/>

<div class="row">
  <div class="span1"></div>
  <div class="span10 offset1">
    <blockquote>Aws-2.5.6, builder-3.0.0, bundler-1.1.3, daemons-1.1.8, eventmachine-0.12.10, haml-3.1.4, http_connection-1.4.1, json-1.6.6, mime-types-1.18, net-ssh-2.3.0, nokogiri-1.5.2, rack-1.4.1, rake-0.9.2.2, rack-accept-0.4.4, rack-protection-1.2.0, rest-client-1.6.7, sinatra-1.3.2, sinatra-content-for-0.1, thin-1.3.1, tilt-1.3.3, uuidtools-2.1.2, xml-simple-1.1.1
    </blockquote>
  </div>
</div>

<p>
You may have trouble with the installation, if the Makefile is missing. Then, you need to install make:
</p>

<pre>
$ sudo apt-get install make
</pre>

<br/>

<h3>OS X</h3>

Instructions on setting up Deltacloud on Apple's OS X can be found <a
href="https://cwiki.apache.org/confluence/display/DTACLOUD/Deltacloud+API+development+setup+on+OSX">on
the Wiki</a>. Note that they require using homebrew.

<h3>Installation of Deltacloud itself</h3>
<p>Once you've setup all the dependencies listed above, installing Deltacloud is as easy. Type:</p>

<pre>$ sudo gem install deltacloud-core</pre>

<p><strong>And thats it!</strong> The gem install command will automatically fetch and install all other gems that the Deltacloud server needs. As an alternative you can get the latest releases of Deltacloud from the <a href="http://www.apache.org/dist/deltacloud/">Apache website</a>.</p>

<p><span class="label">Note:</span> When installing and running Deltacloud on platforms with Ruby versions 1.8.x, the 'require_relative' gem needs to be installed. This gem should be automatically installed with the deltacloud-core gem however, if this does not occur, the follow error will be thrown when starting Deltacloud: </p>

<pre>/usr/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:31:in `gem_original_require': no such file to load -- require_relative (LoadError)</pre>

<p>The fix is to explicitly install the 'require_relative' gem: </p>

<pre>$ sudo gem install require_relative</pre>

<a class="btn btn-inverse btn-large" style="float: right" href="/run-deltacloud-server.html">Run Deltacloud</a>

<br/>
