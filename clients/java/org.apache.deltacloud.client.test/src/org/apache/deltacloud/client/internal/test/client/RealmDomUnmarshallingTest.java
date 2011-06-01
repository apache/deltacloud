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

import java.io.ByteArrayInputStream;
import java.util.ArrayList;
import java.util.List;

import org.apache.deltacloud.client.DeltaCloudClientException;
import org.apache.deltacloud.client.Realm;
import org.apache.deltacloud.client.Realm.RealmState;
import org.apache.deltacloud.client.internal.test.fakes.RealmResponseFakes;
import org.apache.deltacloud.client.internal.test.fakes.RealmResponseFakes.RealmsResponse;
import org.apache.deltacloud.client.unmarshal.RealmUnmarshaller;
import org.apache.deltacloud.client.unmarshal.RealmsUnmarshaller;
import org.junit.Test;

/**
 * @author André Dietisheim
 */
public class RealmDomUnmarshallingTest {

	@Test
	public void realmMayBeUnmarshalled() throws DeltaCloudClientException {
		Realm realm = new Realm();
		ByteArrayInputStream inputStream = new ByteArrayInputStream(RealmResponseFakes.realmResponse.response.getBytes());
		new RealmUnmarshaller().unmarshall(inputStream, realm);
		assertNotNull(realm);
		assertEquals(RealmResponseFakes.realmResponse.id, realm.getId());
		assertEquals(RealmResponseFakes.realmResponse.name, realm.getName());
		assertEquals(RealmState.valueOf(RealmResponseFakes.realmResponse.state.toUpperCase()), realm.getState());
		assertEquals(RealmResponseFakes.realmResponse.getIntLimit(), realm.getLimit());
	}

	@Test
	public void emptyLimitSetsDefaultLimit() throws DeltaCloudClientException {
		Realm realm = new Realm();
		ByteArrayInputStream inputStream = new ByteArrayInputStream(RealmResponseFakes.invalidLimitRealmResponse.response.getBytes());
		new RealmUnmarshaller().unmarshall(inputStream, realm);
		assertNotNull(realm);
		assertEquals(Realm.LIMIT_DEFAULT, realm.getLimit());
	}

	@Test
	public void invalidStateSetsUNKNOWNState() throws DeltaCloudClientException {
		Realm realm = new Realm();
		ByteArrayInputStream inputStream = new ByteArrayInputStream(RealmResponseFakes.invalidLimitRealmResponse.response.getBytes());
		new RealmUnmarshaller().unmarshall(inputStream, realm);
		assertNotNull(realm);
		assertEquals(Realm.LIMIT_DEFAULT, realm.getLimit());
	}

	@Test
	public void realmsMayBeUnmarshalled() throws DeltaCloudClientException {
		ByteArrayInputStream inputStream = new ByteArrayInputStream(RealmsResponse.response.getBytes());
		List<Realm> realms = new ArrayList<Realm>();
		new RealmsUnmarshaller().unmarshall(inputStream, realms);
		assertEquals(2, realms.size());

		Realm realm = realms.get(0);
		assertEquals(RealmsResponse.id1, realm.getId());
		assertEquals(RealmsResponse.name1, realm.getName());

		realm = realms.get(1);
		assertEquals(RealmsResponse.id2, realm.getId());
		assertEquals(RealmsResponse.name2, realm.getName());
	}

}
