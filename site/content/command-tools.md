---
site_name: Deltacloud API
title: Command Line Tools
---

<br/>


<h3 id="command">deltacloudc is being deprecated</h3>

The deltacloudc command line tool is being deprecated. For now the code making up deltacloudc has been moved to the /deltacloud/clients/console directory but will ultimately be removed from the repo. If the command line client is important to you then please <a href="/contact.html">let us know</a>. A new command line client may be put onto the roadmap if there is demand for one.

The deltacloud core developers use (almost exclusively) <a href="http://curl.haxx.se/">cURL</a> as a command line client for working with a deltacloud server. You can find more information on working with cURL against deltacloud <a href="/curl-examples.html">here</a>.

<hr/>
<br/>
<h1> /deprecated: </h1>
<br/>
<hr/>
<br/>

<h3 id="command">Using Deltacloud command tool</h3>

<p>Installing the Deltacloud Ruby client also gives you the <strong>deltacloudc</strong> command line tool. This executable uses the Deltacloud client library to speak to the Deltacloud server through the <a href="/rest-api.html">Deltacloud REST API</a>. This means that you can control your cloud infrastructure from the command line. The general usage pattern for deltacloudc is:<p>

<pre>$ deltacloudc collection operation [options]</pre>

<dl>
  <dt>Collection</dt>
  <dd>
  refers to the Deltacloud object collections, such as Instances, Images, Buckets, Realms etc., as described in a greater detail in the <a href="/rest-api.html">Deltacloud REST API documentation</a>.
  </dd>
  <dt>Operation</dt>
  <dd>
  is collection dependant. All collections respond to 'index' and 'show' operations (retrieve details on all objects in a given collection or on a specific object). Some collections respond to 'create' and 'destroy' operations. The collection of instances (realized virtual servers) responds to operations for managing the instance lifecycle, such as 'stop' or 'reboot'.
  </dd>
  <dt>Options</dt>
  <dd>
  are listed by invoking <strong>deltacloudc -h</strong>. The important option is <strong>-u</strong>, which specifies the API_URL, where the Deltacloud server is running. The API_URL takes the form of <strong>http://[user]:[password]@[api_url]:[port]/[api]</strong>. Alternatively, you can set the API_URL environment variable (e.g., export API_URL=http://mockuser:mockpassword@localhost:3001/api). If your username or your password contains special characters, it's necessary to use options <strong>-U</strong> and <strong>-P</strong> in addition to the option <strong>-u</strong>. Check the <a href="/supported-providers.html#credentials"> list of credentials</a> you need for each back-end cloud provider.
  </dd>
</dl>

<p>
The following examples assume that the Deltacloud server is running on your local machine port 3001 (the <strong>deltacloudd</strong> server daemon defaults to 'localhost:3001') and that it was started with the 'mock' provider (i.e. deltacloudd -i mock ).</p>

<p> List all <strong>collections</strong> available in the current driver:</p>

<pre>$ deltacloudc -l -u http://mockuser:mockpassword@localhost:3001/api</pre>

<p>Get a list of all <strong>images</strong>:</p>

<pre>$ deltacloudc images index -u http://mockuser:mockpassword@localhost:3001/api</pre>

<p>List all operations for the <strong>buckets</strong> collection:</p>

<pre>$ deltacloudc buckets -l -u http://mockuser:mockpassword@localhost:3001/api</pre>

<p>Create a new <strong>blob</strong> in the bucket called 'bucket1':</p>

<pre>$ deltacloudc blob create -i 'my_new_blob' -b 'bucket1' -f /home/marios/file.txt</pre>

