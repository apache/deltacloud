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
package org.jboss.tools.internal.deltacloud.client.test.fakes;

/**
 * @author André Dietisheim
 */
public class APIResponseFakes {

	public static class APIResponse {
		public static final String url = "http://localhost:3001/api/keys/test1292840175447";
		public static final String driver = "ec2";

		public static final String apiResponse = getApiResponseXML(url, driver);
		public static final String invalidDriverApiResponse = getApiResponseXML(url, "foo");
	}

	private static final String getApiResponseXML(String url, String driver) {
		return "<api driver='" + driver + "' version='0.1'>"
				+ "  <link href='" + url + "realms' rel='realms'>"
				+ "  </link>"
				+ "  <link href='" + url + "images' rel='images'>"
				+ "    <feature name='owner_id'></feature>"
				+ "  </link>"
				+ "  <link href='" + url + "instance_states' rel='instance_states'>"
				+ "  </link>"
				+ "  <link href='" + url + "instances' rel='instances'>"
				+ "    <feature name='user_data'></feature>"
				+ "    <feature name='authentication_key'></feature>"
				+ "    <feature name='public_ip'></feature>"
				+ "    <feature name='security_group'></feature>"
				+ "  </link>"
				+ "  <link href='" + url + "hardware_profiles' rel='hardware_profiles'>"
				+ "  </link>"
				+ "  <link href='" + url + "storage_snapshots' rel='storage_snapshots'>"
				+ "  </link>"
				+ "  <link href='" + url + "storage_volumes' rel='storage_volumes'>"
				+ "  </link>"
				+ "  <link href='" + url + "keys' rel='keys'>"
				+ "  </link>"
				+ "  <link href='" + url + "buckets' rel='buckets'>"
				+ "    <feature name='bucket_location'></feature>"
				+ "  </link>"
				+ "</api>";

	}

}
