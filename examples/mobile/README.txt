Author: Eric Woods, woodstae@gmail.com
Date: 13 May 2011

This document explains how to deploy the DeltaCloud mobile application.  For questions, email DeltaCloud's mailing list at deltacloud-dev@incubator.apache.org and I or another developer will respond.

================
DEPLOYMENT STEPS
================
1) Install Apache DeltaCloud 0.3.0 
	a) Follow instructions here: http://incubator.apache.org/deltacloud/contribute.html
	b) If you have problems with rack, install a specific version: gem uninstall rack; gem ins -r rack --version '1.1.0'

2) Start the Apache DeltaCloud server by issuing a command like deltacloudd -i sbc.  Verify DeltaCloud is running at http://<host>:3001/api.  For example: http://localhost:3001/api.

3) Deploy the mobile application demo.  The mobile application is packaged as a WAR file.  Deploy this WAR using your favorite application server, such as Apache Tomcat 6.0.  The application MUST be deployed on the same host, but different port, as the DeltaCloud server.  Start the server and verify that the mobile application is running at http://<host>:<port>/mobiledemo/demo.html where <host> == the DeltaCloud server's host and <port> != 3001.  For example: http://localhost:8080/mobiledemo/demo.html.

4) Access the mobile application either from the same machine (localhost) or externally.  For example: http://1.234.5.67:8080/mobiledemo/demo.html

===========
OTHER NOTES
===========
* jQuery Mobile is the framework used for the native mobile look & feel.  This framework is currently in alpha, so workarounds were necessary to get the demo working smoothly.

* To view the demo's animations, use Safari or an iOS device.  I haven't tested on Android powered devices, but Firefox does not display the animations.

* For a video of the demo: https://docs.google.com/leaf?id=0B-zwcqgujo7CNDI3NGNhMzUtOTk0OC00ZDU2LWIyM2EtOGI3YWZjMjA4NzFi&hl=en&authkey=CIzPrI0F

* To bypass the restriction of cross-domain calls to the DeltaCloud REST API, a proxy servlet is used to redirect REST calls from the same domain (host + port) as the mobile app to the DeltaCloud server, which runs under a different port.  The servlet is configured in the WAR's web.xml. The proxy servlet is not currently configured to support REST calls to URLs containing dynamically supplied IDs (e.g. POST /api/instances/12345/reboot).  This is preventing 'reboot', 'destroy', etc from working.  It shouldn't be hard to set up a better proxy.

* To tweak the host/port configuration, refer to demo.html where I set the dc_server variable.  You may also have to tweak the proxy servlet configuration within web.xml.

* To extract the source code (HTML/JS) from the WAR file, you can use gzip, or simply change the .war extension to .zip, then use your favorite unzipper.