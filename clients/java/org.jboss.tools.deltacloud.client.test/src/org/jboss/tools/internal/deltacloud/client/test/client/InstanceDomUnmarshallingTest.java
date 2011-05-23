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

import java.io.ByteArrayInputStream;
import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.JAXBException;

import org.jboss.tools.deltacloud.client.Action;
import org.jboss.tools.deltacloud.client.DeltaCloudClientException;
import org.jboss.tools.deltacloud.client.Instance;
import org.jboss.tools.deltacloud.client.unmarshal.ActionUnmarshaller;
import org.jboss.tools.deltacloud.client.unmarshal.InstanceUnmarshaller;
import org.jboss.tools.deltacloud.client.unmarshal.InstancesUnmarshaller;
import org.jboss.tools.internal.deltacloud.client.test.fakes.InstanceResponseFakes.InstanceActionResponse;
import org.jboss.tools.internal.deltacloud.client.test.fakes.InstanceResponseFakes.InstanceResponse;
import org.jboss.tools.internal.deltacloud.client.test.fakes.InstanceResponseFakes.InstancesResponse;
import org.junit.Test;

/**
 * @author André Dietisheim
 */
public class InstanceDomUnmarshallingTest {

	@Test
	public void instanceActionMayBeUnmarshalled() throws MalformedURLException, JAXBException, DeltaCloudClientException {
		Action<Instance> instanceAction = new Action<Instance>();
		ByteArrayInputStream inputStream = new ByteArrayInputStream(InstanceActionResponse.response.getBytes());
		new ActionUnmarshaller<Instance>().unmarshall(inputStream, instanceAction);
		assertNotNull(instanceAction);
		assertEquals(InstanceActionResponse.name, instanceAction.getName());
		assertEquals(InstanceActionResponse.url, instanceAction.getUrl().toString());
		assertEquals(InstanceActionResponse.method.toUpperCase(), instanceAction.getMethod().toString().toUpperCase());
	}

	@Test
	public void instanceMayBeUnmarshalled() throws DeltaCloudClientException {
		Instance instance = new Instance();
		ByteArrayInputStream inputStream = new ByteArrayInputStream(InstanceResponse.response.getBytes());
		new InstanceUnmarshaller().unmarshall(inputStream, instance);
		assertNotNull(instance);
		assertEquals(InstanceResponse.id1, instance.getId());
		assertEquals(InstanceResponse.name1, instance.getName());
		assertEquals(InstanceResponse.ownerId1, instance.getOwnerId());
		assertEquals(InstanceResponse.image1Id, instance.getImageId());
		assertEquals(InstanceResponse.hardwareProfile1Id, instance.getProfileId());
		assertEquals(InstanceResponse.realm1Id, instance.getRealmId());
		assertEquals(InstanceResponse.state, instance.getState());
		assertEquals(InstanceResponse.keyname1, instance.getKeyId());
		assertEquals(2, instance.getActions().size());
		assertEquals(InstanceResponse.actionNameStop, instance.getActions().get(0).getName());
		assertEquals(InstanceResponse.actionNameReboot, instance.getActions().get(1).getName());
		assertEquals(1, instance.getPublicAddresses().size());
		assertEquals(InstanceResponse.publicAddress1, instance.getPublicAddresses().get(0));
		assertEquals(1, instance.getPrivateAddresses().size());
		assertEquals(InstanceResponse.privateAddress1, instance.getPrivateAddresses().get(0));
		
	}

	@Test
	public void instancesMayBeUnmarshalled() throws MalformedURLException, JAXBException, DeltaCloudClientException {
		ByteArrayInputStream inputStream = new ByteArrayInputStream(InstancesResponse.response.getBytes());
		List<Instance> instances = new ArrayList<Instance>();
		new InstancesUnmarshaller().unmarshall(inputStream, instances);
		assertEquals(2, instances.size());

		Instance instance = instances.get(0);
		assertEquals(InstancesResponse.id1, instance.getId());
		assertEquals(InstancesResponse.name1, instance.getName());

		instance = instances.get(1);
		assertEquals(InstancesResponse.id2, instance.getId());
		assertEquals(InstancesResponse.name2, instance.getName());
		assertEquals(2, instance.getActions().size());
	}

}
