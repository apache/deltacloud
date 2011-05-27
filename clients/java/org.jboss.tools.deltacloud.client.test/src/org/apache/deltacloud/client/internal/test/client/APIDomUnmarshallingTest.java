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

import org.jboss.tools.deltacloud.client.API;
import org.jboss.tools.deltacloud.client.DeltaCloudClientException;
import org.jboss.tools.deltacloud.client.API.Driver;
import org.jboss.tools.deltacloud.client.unmarshal.APIUnmarshaller;
import org.jboss.tools.internal.deltacloud.client.test.fakes.APIResponseFakes.APIResponse;
import org.junit.Test;

/**
 * @author André Dietisheim
 */
public class APIDomUnmarshallingTest {

	@Test
	public void ec2DriverIsUnmarshalled() throws MalformedURLException, DeltaCloudClientException {
		API api = new API();
		ByteArrayInputStream inputStream = new ByteArrayInputStream(APIResponse.apiResponse.getBytes());
		new APIUnmarshaller().unmarshall(inputStream, api);
		assertNotNull(api);
		assertEquals(APIResponse.driver, api.getDriver().name().toLowerCase());
	}

	@Test
	public void invalidDriverUnmarshalledToUnknown() throws MalformedURLException, DeltaCloudClientException {
		API api = new API();
		ByteArrayInputStream inputStream = new ByteArrayInputStream(APIResponse.invalidDriverApiResponse.getBytes());
		new APIUnmarshaller().unmarshall(inputStream, api);
		assertNotNull(api);
		assertEquals(Driver.UNKNOWN, api.getDriver());
	}
}
