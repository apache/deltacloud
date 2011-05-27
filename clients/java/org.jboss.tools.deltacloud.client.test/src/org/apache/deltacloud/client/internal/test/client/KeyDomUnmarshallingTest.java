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
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.JAXBException;

import org.jboss.tools.deltacloud.client.Action;
import org.jboss.tools.deltacloud.client.DeltaCloudClientException;
import org.jboss.tools.deltacloud.client.HttpMethod;
import org.jboss.tools.deltacloud.client.Key;
import org.jboss.tools.deltacloud.client.unmarshal.ActionUnmarshaller;
import org.jboss.tools.deltacloud.client.unmarshal.KeyUnmarshaller;
import org.jboss.tools.deltacloud.client.unmarshal.KeysUnmarshaller;
import org.jboss.tools.internal.deltacloud.client.test.fakes.KeyResponseFakes;
import org.jboss.tools.internal.deltacloud.client.test.fakes.KeyResponseFakes.KeyActionResponse;
import org.jboss.tools.internal.deltacloud.client.test.fakes.KeyResponseFakes.KeyResponse;
import org.jboss.tools.internal.deltacloud.client.test.fakes.KeyResponseFakes.KeysResponse;
import org.junit.Test;

/**
 * @author André Dietisheim
 */
public class KeyDomUnmarshallingTest {

	@Test
	public void keyActionMayBeUnmarshalled() throws MalformedURLException, JAXBException, DeltaCloudClientException {
		Action<Key> keyAction = new Action<Key>();
		ByteArrayInputStream inputStream = new ByteArrayInputStream(KeyActionResponse.keyActionResponse.getBytes());
		new ActionUnmarshaller<Key>().unmarshall(inputStream, keyAction);
		assertNotNull(keyAction);
		assertEquals(KeyActionResponse.name, keyAction.getName());
		assertEquals(KeyActionResponse.url, keyAction.getUrl().toString());
		assertEquals(KeyActionResponse.method.toUpperCase(), keyAction.getMethod().toString().toUpperCase());
	}

	@Test
	public void keyMayBeUnmarshalled() throws MalformedURLException, JAXBException, DeltaCloudClientException {
		Key key = new Key();
		ByteArrayInputStream inputStream = new ByteArrayInputStream(KeyResponse.keyResponse.getBytes());
		new KeyUnmarshaller().unmarshall(inputStream, key);
		assertNotNull(key);
		assertEquals(KeyResponseFakes.KeyResponse.id, key.getId());
		assertEquals(KeyResponse.fingerprint, key.getFingerprint());
		assertEquals(new URL(KeyResponse.url), key.getUrl());
		assertEquals(KeyResponse.pem, key.getPem());
		assertEquals(1, key.getActions().size());
		Action<Key> action = key.getActions().get(0);
		assertNotNull(action);
		assertEquals(KeyResponse.url, action.getUrl().toString());
		assertEquals(KeyResponse.name, action.getName());
		assertEquals(HttpMethod.valueOf(KeyResponse.method.toUpperCase()), action.getMethod());
	}

	@Test
	public void keysMayBeUnmarshalled() throws MalformedURLException, JAXBException, DeltaCloudClientException {
		ByteArrayInputStream inputStream = new ByteArrayInputStream(KeysResponse.keysResponse.getBytes());
		List<Key> keys = new ArrayList<Key>();
		new KeysUnmarshaller().unmarshall(inputStream, keys);
		assertEquals(2, keys.size());
		Key key = keys.get(0);
		assertEquals(KeysResponse.id1, key.getId());
		assertEquals(KeysResponse.fingerprint1, key.getFingerprint());
		assertEquals(new URL(KeysResponse.url1), key.getUrl());
		assertEquals(KeysResponse.pem1, key.getPem());
		assertEquals(1, key.getActions().size());
		Action<Key> action = key.getActions().get(0);
		assertNotNull(action);
		assertEquals(KeysResponse.url1, action.getUrl().toString());
		assertEquals(KeysResponse.name1, action.getName());
		assertEquals(HttpMethod.valueOf(KeysResponse.method1.toUpperCase()), action.getMethod());
	}
}
