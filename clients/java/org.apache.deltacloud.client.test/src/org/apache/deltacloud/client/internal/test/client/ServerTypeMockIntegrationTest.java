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
package org.apache.deltacloud.client.internal.test.client;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Collections;
import java.util.List;

import org.apache.deltacloud.client.DeltaCloudClientException;
import org.apache.deltacloud.client.DeltaCloudClientImpl;
import org.apache.deltacloud.client.DeltaCloudNotFoundClientException;
import org.apache.deltacloud.client.HttpMethod;
import org.apache.deltacloud.client.Image;
import org.apache.deltacloud.client.API.Driver;
import org.apache.deltacloud.client.internal.test.context.MockIntegrationTestContext;
import org.apache.deltacloud.client.internal.test.fakes.ServerFake;
import org.apache.deltacloud.client.request.DeltaCloudRequest;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Integration tests for {@link DeltaCloudClientImpl#getServerType()}.
 * 
 * @author Andre Dietisheim
 * 
 * @see DeltaCloudClientImpl#getServerType()
 */
public class ServerTypeMockIntegrationTest {

	private MockIntegrationTestContext testSetup;

	@Before
	public void setUp() throws IOException, DeltaCloudClientException {
		this.testSetup = new MockIntegrationTestContext();
		testSetup.setUp();
	}

	@After
	public void tearDown() {
		testSetup.tearDown();
	}

	@Test
	public void recognizesDeltaCloud() throws IOException {
		assertEquals(Driver.MOCK, testSetup.getClient().getServerType());
	}

	/**
	 * 
	 * #getServerType reports {@link DeltaCloudClient.DeltaCloudType#UNKNOWN) if it queries a fake server that responds with a unknown answer.
	 * 
	 * @throws IOException
	 *             Signals that an I/O exception has occurred.
	 * @throws DeltaCloudClientException 
	 */
	@Test
	public void reportsUnknownUrl() throws IOException, DeltaCloudClientException {
		ServerFake serverFake =
				new ServerFake(
						new URL(MockIntegrationTestContext.SERVERFAKE_URL).getPort(),
						"<dummy></dummy>");
		serverFake.start();
		try {
			assertEquals(
					Driver.UNKNOWN,
					new DeltaCloudClientImpl(
							MockIntegrationTestContext.SERVERFAKE_URL, MockIntegrationTestContext.DELTACLOUD_USER,
							MockIntegrationTestContext.DELTACLOUD_PASSWORD).getServerType());
		} finally {
			serverFake.stop();
		}
	}

	@Test(expected = DeltaCloudClientException.class)
	public void listImages_cannotListIfNotAuthenticated() throws MalformedURLException, DeltaCloudClientException {
		DeltaCloudClientImpl client = new DeltaCloudClientImpl(MockIntegrationTestContext.DELTACLOUD_URL, "badUser",
				"badPassword");
		client.listImages();
	}

	@Test
	public void throwsDeltaCloudClientExceptionOnUnknownResource() {
		try {
			DeltaCloudClientImpl errorClient = new DeltaCloudClientImpl(MockIntegrationTestContext.DELTACLOUD_URL) {
				@Override
				public List<Image> listImages() throws DeltaCloudClientException {
					request(new DeltaCloudRequest() {

						@Override
						public URL getUrl() throws MalformedURLException {
							return new URL(MockIntegrationTestContext.DELTACLOUD_URL + "/DUMMY");
						}

						@Override
						public HttpMethod getHttpMethod() {
							return HttpMethod.GET;
						}

						@Override
						public String getUrlString() {
							return null;
						}
					}
					);
					return Collections.emptyList();
				}
			};
			errorClient.listImages();
			fail("no exception catched");
		} catch (Exception e) {
			assertEquals(DeltaCloudNotFoundClientException.class, e.getClass());
		}
	}
}
