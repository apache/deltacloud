/*************************************************************************
 * 
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.  The
 * ASF licenses this file to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the
 * License.  You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
 * License for the specific language governing permissions and limitations
 * under the License.
 * 
 *************************************************************************/
package org.jboss.tools.internal.deltacloud.client.utils.test;

import static org.junit.Assert.assertEquals;

import org.jboss.tools.deltacloud.client.utils.UrlBuilder;
import org.junit.Test;

public class UrlBuilderTest {

	@Test
	public void buildsHost() {
		String host = "jboss.org";
		assertEquals(host, new UrlBuilder(host).toString());
	}

	@Test
	public void buildsHostWithPort() {
		assertEquals(
				"jboss.org:8080",
				new UrlBuilder("jboss.org")
						.port(8080)
						.toString());
	}

	@Test
	public void buildsWithPath() {
		assertEquals(
				"jboss.org:8080/tools",
				new UrlBuilder("jboss.org")
						.port(8080)
						.path("tools")
						.toString());
	}

	@Test
	public void buildsWith2Paths() {
		assertEquals(
				"jboss.org:8080/tools/usage",
				new UrlBuilder("jboss.org")
						.port(8080)
						.path("tools")
						.path("usage")
						.toString());
	}

	@Test
	public void buildsWithParameters() {
		assertEquals(
				"jboss.org:8080/tools/usage?parameter=dummy",
				new UrlBuilder("jboss.org")
						.port(8080)
						.path("tools")
						.path("usage")
						.parameter("parameter", "dummy")
						.toString());
	}
}
