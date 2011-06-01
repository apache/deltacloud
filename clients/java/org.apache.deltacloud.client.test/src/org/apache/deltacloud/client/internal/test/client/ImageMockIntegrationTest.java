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
import java.util.Collection;
import java.util.List;

import org.apache.deltacloud.client.DeltaCloudClientException;
import org.apache.deltacloud.client.DeltaCloudClientImpl;
import org.apache.deltacloud.client.Image;
import org.apache.deltacloud.client.internal.test.context.MockIntegrationTestContext;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * An integration test that test various image related operations in DeltaCloudClient
 *
 * @author Andre Dietisheim
 *
 * @see DeltaCloudClientImpl#listImages()
 * @see DeltaCloudClientImpl#listImages(String)
 *
 */
public class ImageMockIntegrationTest {

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

	@Test(expected = DeltaCloudClientException.class)
	public void cannotListIfNotAuthenticated() throws MalformedURLException, DeltaCloudClientException {
		DeltaCloudClientImpl client = new DeltaCloudClientImpl(MockIntegrationTestContext.DELTACLOUD_URL, "badUser", "badPassword");
		client.listImages();
	}

	@Test
	public void assertDefaultImages() throws DeltaCloudClientException {
		List<Image> images = testSetup.getClient().listImages();
		assertEquals(3, images.size());
		assertImage("img1", "Fedora 10", "fedoraproject", "Fedora 10", "x86_64", getImage("img1", images));
		assertImage("img2", "Fedora 10", "fedoraproject", "Fedora 10", "i386", getImage("img2", images) );
		assertImage("img3", "JBoss", "mockuser", "JBoss", "i386", getImage("img3", images));
	}

	private Image getImage(String id, Collection<Image> images) {
		for (Image image : images) {
			if (id.equals(image.getId())) {
				return image;
			}
		}
		fail("image " + id + " was not found");
		return null;
	}

	private void assertImage(String id, String name, String owner, String description, String architecture, Image image) {
		assertEquals(id, image.getId());
		assertEquals(name, image.getName());
		assertEquals(owner, image.getOwnerId());
		assertEquals(architecture, image.getArchitecture());
		assertEquals(description, image.getDescription());
	}
}
