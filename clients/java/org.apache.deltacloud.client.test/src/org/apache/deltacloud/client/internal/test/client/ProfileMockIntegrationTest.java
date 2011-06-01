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
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.io.IOException;
import java.util.List;

import org.apache.deltacloud.client.DeltaCloudClientException;
import org.apache.deltacloud.client.DeltaCloudClientImpl;
import org.apache.deltacloud.client.HardwareProfile;
import org.apache.deltacloud.client.internal.test.context.MockIntegrationTestContext;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Integration tests for key related operations in delta cloud client.
 *
 * @author Andre Dietisheim
 *
 * @see DeltaCloudClientImpl#listProfiles()
 * @see DeltaCloudClientImpl#listProfie(String)
 */
public class ProfileMockIntegrationTest {

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
	public void canListProfiles() throws DeltaCloudClientException {
		List<HardwareProfile> hardwareProfiles = testSetup.getClient().listProfiles();
		assertNotNull(hardwareProfiles);
		assertTrue(hardwareProfiles.size() > 0);
	}

	@Test
	public void canGetProfile() throws DeltaCloudClientException {
		// get a profile seen in the web UI
		HardwareProfile profile = testSetup.getClient().listProfile("m1-small");
		assertNotNull(profile);
		assertHardWareProfile("i386", "1740.8 MB", "160 GB", "1", profile);
	}

	public void assertHardWareProfile(String architecture, String memory, String storage, String cpu, HardwareProfile profile) {
		assertEquals(architecture, profile.getArchitecture());
		assertEquals(memory, profile.getMemory());
		assertEquals(storage, profile.getStorage());
		assertEquals(cpu, profile.getCPU());
	}
}
