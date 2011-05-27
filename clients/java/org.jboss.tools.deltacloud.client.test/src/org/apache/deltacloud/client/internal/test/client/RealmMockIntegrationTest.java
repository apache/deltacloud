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
package org.jboss.tools.internal.deltacloud.client.test.client;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.io.IOException;
import java.util.List;

import org.jboss.tools.deltacloud.client.DeltaCloudClientImpl;
import org.jboss.tools.deltacloud.client.DeltaCloudClientException;
import org.jboss.tools.deltacloud.client.Realm;
import org.jboss.tools.internal.deltacloud.client.test.context.MockIntegrationTestContext;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Integration tests for key related operations in delta cloud client.
 * 
 * @author Andre Dietisheim
 * 
 * @see DeltaCloudClientImpl#listRealms()
 * @see DeltaCloudClientImpl#listRealm(String)
 */
public class RealmMockIntegrationTest {

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
	public void canListRealms() throws DeltaCloudClientException {
		List<Realm> realms = testSetup.getClient().listRealms();
		assertNotNull(realms);
		assertTrue(realms.size() > 0);
	}

	@Test
	public void canGetProfile() throws DeltaCloudClientException {
		// get a profile seen in the web UI
		Realm realm = testSetup.getClient().listRealms("eu");
		assertNotNull(realm);
		assertRealm("Europe", Realm.RealmState.AVAILABLE, Realm.LIMIT_DEFAULT, realm);
	}

	public void assertRealm(String name, Realm.RealmState state, int limit, Realm realm) {
		assertEquals(name, realm.getName());
		assertEquals(state, realm.getState());
		assertEquals(limit, realm.getLimit());
	}
}
