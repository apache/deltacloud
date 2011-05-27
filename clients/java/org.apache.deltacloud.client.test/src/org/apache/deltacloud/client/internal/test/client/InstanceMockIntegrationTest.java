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
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.io.IOException;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.MalformedURLException;
import java.util.List;
import java.util.concurrent.ExecutionException;

import org.apache.deltacloud.client.Action;
import org.apache.deltacloud.client.DeltaCloudClient;
import org.apache.deltacloud.client.DeltaCloudClientException;
import org.apache.deltacloud.client.DeltaCloudClientImpl;
import org.apache.deltacloud.client.DeltaCloudNotFoundClientException;
import org.apache.deltacloud.client.HttpMethod;
import org.apache.deltacloud.client.Image;
import org.apache.deltacloud.client.Instance;
import org.apache.deltacloud.client.StateAware.State;
import org.apache.deltacloud.client.internal.test.context.MockIntegrationTestContext;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Integration tests for instance related methods in
 * {@link DeltaCloudClientImpl}.
 * 
 * @author Andre Dietisheim
 * 
 * @see DeltaCloudClientImpl#listInstances()
 * @see DeltaCloudClientImpl#createInstance(String)
 * @see DeltaCloudClientImpl#destroyInstance(String)
 * @see DeltaCloudClientImpl#startInstance(String)
 * @see DeltaCloudClientImpl#shutdownInstance(String)
 */
public class InstanceMockIntegrationTest {

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

	/**
	 * #listInstance contains the test instance created in {@link #setUp()}
	 * 
	 * @throws DeltaCloudClientException
	 *             the delta cloud client exception
	 */

	@Test
	public void listContainsTestInstance() throws DeltaCloudClientException {
		DeltaCloudClient client = testSetup.getClient();
		List<Instance> instances = client.listInstances();
		assertTrue(instances.size() > 0);
		Instance testInstance = testSetup.getTestInstance();
		assertNotNull(testSetup.getInstanceById(testInstance.getId(), client));
	}

	@Test
	public void listTestInstance() throws DeltaCloudClientException {
		Instance instance = testSetup.getClient().listInstances(testSetup.getTestInstance().getId());
		assertNotNull(instance);
		Instance testInstance = testSetup.getTestInstance();
		assertEquals(testInstance.getId(), instance.getId());
		assertInstance(
				testInstance.getName()
				, testInstance.getOwnerId()
				, testInstance.getImageId()
				, testInstance.getRealmId()
				, testInstance.getProfileId()
				, testInstance.getMemory()
				, testInstance.getPrivateAddresses()
				, testInstance.getPublicAddresses()
				, instance);
	}

	@Test(expected = DeltaCloudNotFoundClientException.class)
	public void listDestroyedInstanceThrowsException() throws DeltaCloudClientException {
		Instance testInstance = testSetup.getTestInstance();
		testSetup.quietlyDestroyInstance(testInstance);
		testSetup.getClient().listInstances(testInstance.getId());
	}

	private void assertInstance(String name, String owner, String ImageId, String realmId, String profile,
			String memory, List<String> privateAddresses, List<String> publicAddresses, Instance instance) {
		assertNotNull("instance " + name + " was not found", instance);
		assertEquals(name, instance.getName());
		assertEquals(owner, instance.getOwnerId());
		assertEquals(realmId, instance.getRealmId());
		assertEquals(profile, instance.getProfileId());
		assertEquals(memory, instance.getMemory());
		assertTrue(privateAddresses.equals(instance.getPrivateAddresses()));
		assertTrue(publicAddresses.equals(instance.getPublicAddresses()));
	}

	@Test(expected = DeltaCloudClientException.class)
	public void cannotDestroyIfNotAuthenticated() throws MalformedURLException, DeltaCloudClientException {
		DeltaCloudClientImpl unauthenticatedClient = new DeltaCloudClientImpl(
				MockIntegrationTestContext.DELTACLOUD_URL,
				"badUser", "badPassword");
		Image image = testSetup.getFirstImage(unauthenticatedClient);
		unauthenticatedClient.createInstance(image.getId());
	}

	@Test
	public void canCreateInstance() throws DeltaCloudClientException {
		Instance instance = null;
		try {
			Image image = testSetup.getFirstImage(testSetup.getClient());
			instance = testSetup.getClient().createInstance(image.getId());
			assertTrue(instance != null);
			assertEquals(image.getId(), instance.getImageId());
			assertEquals(State.RUNNING, instance.getState());
		} finally {
			testSetup.quietlyDestroyInstance(instance);
		}
	}

	@Test(expected = DeltaCloudClientException.class)
	public void cannotDestroyUnknownImageId() throws DeltaCloudClientException {
		testSetup.getClient().createInstance("dummy");
	}

	@Test(expected=DeltaCloudClientException.class)
	public void canDestroy() throws DeltaCloudClientException {
		Image image = testSetup.getFirstImage(testSetup.getClient());
		DeltaCloudClient client = testSetup.getClient();
		Instance instance = client.createInstance(image.getId());
		instance.stop(client);
		instance.destroy(client);
		client.listInstances(instance.getId());
	}

	@Test(expected = DeltaCloudClientException.class)
	public void destroyThrowsExceptionOnUnknowInstanceId() throws DeltaCloudClientException, IllegalArgumentException,
			InstantiationException, IllegalAccessException, InvocationTargetException, SecurityException,
			NoSuchMethodException {
		DeltaCloudClient client = testSetup.getClient();
		client.performAction(
				createInstanceAction(
						"destroy",
						MockIntegrationTestContext.DELTACLOUD_URL,
						HttpMethod.POST,
						new Instance()));
	}

	private Action<Instance> createInstanceAction(String name, String url, HttpMethod method, Instance instance) {
		Action<Instance> action = new Action<Instance>();
		action.setName(name);
		action.setMethod(method);
		action.setOwner(instance);
		return action;
	}

	@SuppressWarnings("unused")
	private class InstanceActionProxy implements InvocationHandler {

		@Override
		public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
			if (method.getName().equals("getUrl")) {
				return MockIntegrationTestContext.DELTACLOUD_URL;
			} else if (method.getName().equals("getMethod")) {
				return HttpMethod.POST;
			} else {
				return null;
			}
		}

	}

	@Test
	public void canShutdownInstance() throws DeltaCloudClientException {
		Instance testInstance = testSetup.getTestInstance();
		DeltaCloudClient client = testSetup.getClient();
		testInstance.stop(client);
		testInstance = client.listInstances(testInstance.getId()); // reload!
		assertEquals(State.STOPPED, testInstance.getState());
	}

	@Test
	public void canStartInstance() throws DeltaCloudClientException {
		Instance testInstance = testSetup.getTestInstance();
		DeltaCloudClient client = testSetup.getClient();
		if (testInstance.getState() == State.RUNNING) {
			testInstance.stop(client);
		}
		testInstance.start(client);
		testInstance = client.listInstances(testInstance.getId()); // reload!
		assertEquals(State.RUNNING, testInstance.getState());
	}

	@Test
	public void canStartInstanceByAction() throws DeltaCloudClientException {
		Instance testInstance = testSetup.getTestInstance();
		DeltaCloudClient client = testSetup.getClient();
		if (testInstance.getState() == State.RUNNING) {
			testInstance.stop(client);
		}
		assertTrue(testInstance.start(client));
		testInstance = client.listInstances(testInstance.getId()); // reload!
		assertEquals(State.RUNNING, testInstance.getState());
	}

	@Test
	public void cannotStartRunningInstance() throws DeltaCloudClientException {
		Instance testInstance = testSetup.getTestInstance();
		DeltaCloudClient client = testSetup.getClient();
		testInstance.start(client);
		assertFalse(testInstance.start(client));
	}

	@Test
	public void cannotStopStoppedInstance() throws DeltaCloudClientException {
		Instance testInstance = testSetup.getTestInstance();
		DeltaCloudClient client = testSetup.getClient();
		try {
			testInstance.stop(client);
			assertFalse(testInstance.stop(client));
		} finally {
			testInstance.start(client);
		}
	}

	@Test
	public void cannotDestroyRunningInstance() throws DeltaCloudClientException {
		Instance testInstance = testSetup.getTestInstance();
		DeltaCloudClient client = testSetup.getClient();
		testInstance = client.listInstances(testInstance.getId()); // reload
		assertTrue(testInstance.getState() == State.RUNNING);
		assertFalse(testInstance.destroy(client));
	}

	@Test
	public void cannotRebootStoppedInstance() throws DeltaCloudClientException, InterruptedException,
			ExecutionException {
		Instance testInstance = testSetup.getTestInstance();
		DeltaCloudClient client = testSetup.getClient();
		try {
			testInstance.stop(client);
			testInstance = client.listInstances(testInstance.getId()); // reload
			assertTrue(testInstance.getState() == State.STOPPED);
			assertFalse(testInstance.reboot(client));
		} finally {
			testInstance.start(client);
			client.listInstances(testInstance.getId()); // reload
		}
	}
}
