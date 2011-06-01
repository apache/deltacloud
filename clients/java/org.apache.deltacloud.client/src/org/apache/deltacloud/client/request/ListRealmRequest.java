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

package org.apache.deltacloud.client.request;

import org.apache.deltacloud.client.HttpMethod;
import org.apache.deltacloud.client.utils.UrlBuilder;

/**
 * Lists a realm on the deltacloud server
 *
 * @author André Dietisheim
 */
public class ListRealmRequest extends AbstractDeltaCloudRequest {

	private String realmId;

	public ListRealmRequest(String baseUrl, String realmId) {
		super(baseUrl, HttpMethod.GET);
		this.realmId = realmId;
	}

	@Override
	protected String doCreateUrl(UrlBuilder urlBuilder) {
		return urlBuilder.path("realms").path(realmId).toString();
	}
}
