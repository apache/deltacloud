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
package org.jboss.tools.internal.deltacloud.client.test.context;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.io.IOException;
import java.net.ConnectException;
import java.net.URL;
import java.net.URLConnection;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import org.jboss.tools.deltacloud.client.DeltaCloudClient;
import org.jboss.tools.deltacloud.client.DeltaCloudClientException;
import org.jboss.tools.deltacloud.client.DeltaCloudClientImpl;
import org.jboss.tools.deltacloud.client.Image;
import org.jboss.tools.deltacloud.client.Instance;
import org.jboss.tools.deltacloud.client.StateAware.State;

/**
 * A class that holds the integration test context
 * 
 * @author Andre Dietisheim
 * 
 */
public class MockIntegrationTestContext {

	public static final String DELTACLOUD_URL = "http://localhost:3001";
	public static final String SERVERFAKE_URL = "http://localhost:3002";
	public static final String DELTACLOUD_USER = "mockuser";
	public static final String DELTACLOUD_PASSWORD = "mockpassword";
	private static final long TIMEOUT = 5000;
	
	private DeltaCloudClient client;
	private Instance testInstance;

	private ExecutorService executor = Executors.newSingleThreadExecutor();

	public void setUp() throws IOException, DeltaCloudClientException {
		ensureDeltaCloudIsRunning();
		this.client = new DeltaCloudClientImpl(DELTACLOUD_URL, DELTACLOUD_USER, DELTACLOUD_PASSWORD);
		Image image = getFirstImage(client);
		this.testInstance = createTestInstance(image);
	}

	private Instance createTestInstance(Image image) throws DeltaCloudClientException {
		assertNotNull(image);
		Instance instance = client.createInstance(image.getId());
		return instance;
	}

	public void ensureDeltaCloudIsRunning() throws IOException {
		try {
			URLConnection connection = new URL(DELTACLOUD_URL).openConnection();
			connection.connect();
		} catch (ConnectException e) {
			fail("Local DeltaCloud instance is not running. Please start a DeltaCloud instance before running these tests.");
		}
	}

	public DeltaCloudClient getClient() {
		return client;
	}

	public Instance getTestInstance() {
		return testInstance;
	}

	public Image getFirstImage(DeltaCloudClient client) throws DeltaCloudClientException {
		List<Image> images = client.listImages();
		assertTrue(images.size() >= 1);
		Image image = images.get(0);
		return image;
	}

	public Instance getInstanceById(String id, DeltaCloudClient client) throws DeltaCloudClientException {
		for (Instance availableInstance : client.listInstances()) {
			if (id.equals(availableInstance.getId())) {
				return availableInstance;
			}
		}
		return null;
	}

	public void tearDown() {
		quietlyDestroyInstance(testInstance);
		executor.shutdownNow();
	}

	public void quietlyDestroyInstance(Instance instance) {
		if (instance != null) {
			try {
				if (instance.getState() == Instance.State.RUNNING) {
					instance.stop(client);
				}
				instance = waitForInstanceState(instance.getId(), Instance.State.STOPPED, TIMEOUT);
				assertNotNull("Could not stop instance " + instance.getName(), instance);
				assertTrue("Could not destroy instance " + instance.getName(), instance.destroy(client));
			} catch (Exception e) {
				// ignore
			}
		}
	}

	/**
	 * Waits for an instance to get the given state for a given timeout.
	 * 
	 * @param instanceId
	 *            the id of the instance to watch
	 * @param state
	 *            the state to wait for
	 * @param timeout
	 *            the timeout to wait for
	 * @return <code>true</code>, if the state was reached while waiting for
	 *         timeout, <code>false</code> otherwise
	 * @throws ExecutionException
	 * @throws InterruptedException
	 */
	public Instance waitForInstanceState(final String instanceId, final State state, final long timeout)
			throws InterruptedException, ExecutionException {
		final long startTime = System.currentTimeMillis();
		Callable<Instance> waitingCallable = new Callable<Instance>() {

			@Override
			public Instance call() throws Exception {
				try {
					while (System.currentTimeMillis() < startTime + timeout) {
						Instance instance = client.listInstances(instanceId);
						if (instance.getState() == state) {
							return instance;
						}
						Thread.sleep(200);
					}
					return null;
				} catch (Exception e) {
					e.printStackTrace();
					return null;
				}
			}
		};
		return executor.submit(waitingCallable).get();
	}
}
