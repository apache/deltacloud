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

package org.jboss.tools.deltacloud.client.request;

import org.jboss.tools.deltacloud.client.HttpMethod;
import org.jboss.tools.deltacloud.client.utils.UrlBuilder;

/**
 * A request for a hardware profile on a deltacloud server.
 * 
 * @author André Dietisheim
 */
public class ListHardwareProfileRequest extends AbstractDeltaCloudRequest {

	private String profileId;

	/**
	 * Instantiates a new type request.
	 *
	 * @param baseUrl the base url
	 * @param imageId 
	 */
	public ListHardwareProfileRequest(String baseUrl, String profileId) {
		super(baseUrl, HttpMethod.GET);
		this.profileId = profileId;
	}

	@Override
	protected String doCreateUrl(UrlBuilder urlBuilder) {
		return urlBuilder.path("hardware_profiles").path(profileId).toString();
	}
}
