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
import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.JAXBException;

import org.apache.deltacloud.client.DeltaCloudClientException;
import org.apache.deltacloud.client.HardwareProfile;
import org.apache.deltacloud.client.Property;
import org.apache.deltacloud.client.internal.test.fakes.HardwareProfileResponseFakes.HardwareProfile1Response;
import org.apache.deltacloud.client.internal.test.fakes.HardwareProfileResponseFakes.HardwareProfile2Response;
import org.apache.deltacloud.client.internal.test.fakes.HardwareProfileResponseFakes.HardwareProfilesResponse;
import org.apache.deltacloud.client.unmarshal.HardwareProfileUnmarshaller;
import org.apache.deltacloud.client.unmarshal.HardwareProfilesUnmarshaller;
import org.junit.Test;

/**
 * @author André Dietisheim
 */
public class HardwareProfileDomUnmarshallingTest {

	@Test
	public void HardwareProfilesCanBeUnmarshalled() throws MalformedURLException, JAXBException,
			DeltaCloudClientException {
		List<HardwareProfile> profiles = new ArrayList<HardwareProfile>();
		ByteArrayInputStream inputStream = new ByteArrayInputStream(HardwareProfilesResponse.response.getBytes());
		new HardwareProfilesUnmarshaller().unmarshall(inputStream, profiles);
		assertEquals(2, profiles.size());
	}

	@Test
	public void fixedPropertyHardwareProfileMayBeUnmarshalled() throws MalformedURLException, JAXBException,
			DeltaCloudClientException {
		HardwareProfile profile = new HardwareProfile();
		ByteArrayInputStream inputStream = new ByteArrayInputStream(HardwareProfile1Response.response.getBytes());
		new HardwareProfileUnmarshaller().unmarshall(inputStream, profile);
		assertNotNull(profile);
		assertEquals(HardwareProfile1Response.id, profile.getId());
		assertEquals(HardwareProfile1Response.propMemValue + ' ' + HardwareProfile1Response.propMemUnit,
				profile.getMemory());
		assertEquals(HardwareProfile1Response.propStorageValue + ' ' + HardwareProfile1Response.propStorageUnit,
				profile.getStorage());
		assertEquals(HardwareProfile1Response.propCPUValue, profile.getCPU());
		assertEquals(HardwareProfile1Response.propArchValue, profile.getArchitecture());
	}

	@Test
	public void mixedPropertiesHardwareProfileMayBeUnmarshalled() throws MalformedURLException, JAXBException,
			DeltaCloudClientException {
		HardwareProfile profile = new HardwareProfile();
		ByteArrayInputStream inputStream = new ByteArrayInputStream(HardwareProfile2Response.response.getBytes());
		new HardwareProfileUnmarshaller().unmarshall(inputStream, profile);
		assertNotNull(profile);
		assertEquals(HardwareProfile2Response.id, profile.getId());
		assertEquals(HardwareProfile2Response.propMemValue + ' ' + HardwareProfile2Response.propMemUnit,
				profile.getMemory());
		Property property = profile.getNamedProperty(Property.Names.MEMORY);
		assertNotNull(property);
		assertEquals(HardwareProfile2Response.propMemRangeFirst, property.getRange().getFirst());
		assertEquals(HardwareProfile2Response.propMemRangeLast, property.getRange().getLast());
		assertEquals(HardwareProfile2Response.propStorageValue + ' ' + HardwareProfile2Response.propStorageUnit,
				profile.getStorage());
		property = profile.getNamedProperty(Property.Names.STORAGE);
		assertNotNull(property);
		assertNotNull(property.getEnums());
		assertEquals(2, property.getEnums().size());
		assertEquals(HardwareProfile2Response.propStorageEnum1, property.getEnums().get(0));
		assertEquals(HardwareProfile2Response.propStorageEnum2, property.getEnums().get(1));
		assertEquals(HardwareProfile2Response.propCPUValue, profile.getCPU());
		assertEquals(HardwareProfile2Response.propArchValue, profile.getArchitecture());
	}

}
