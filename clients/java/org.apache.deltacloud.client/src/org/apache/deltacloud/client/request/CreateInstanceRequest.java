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
 * Creates a new instance
 *
 * @author André Dietisheim
 */
public class CreateInstanceRequest extends AbstractDeltaCloudRequest {

	private String name;
	private String imageId;
	private String profileId;
	private String realmId;
	private String keyname;
	private String memory;
	private String storage;

	public CreateInstanceRequest(String baseUrl, String imageId) {
		this(baseUrl, null, imageId, null, null, null, null, null);
	}

	public CreateInstanceRequest(String baseUrl, String name, String imageId, String profileId, String realmId,
			String keyId, String memory, String storage) {
		super(baseUrl, HttpMethod.POST);
		this.name = name;
		this.imageId = imageId;
		this.profileId = profileId;
		this.realmId = realmId;
		this.keyname = keyId;
		this.memory = memory;
		this.storage = storage;
	}

	@Override
	protected String doCreateUrl(UrlBuilder urlBuilder) {
		return urlBuilder.path("instances")
				.parameter("keyname", keyname)
				// WORKAROUND for JBIDE-8005, STEAM-303
				.parameter("key_name", keyname)
				// WORKAROUND for JBIDE-8005, STEAM-303
				.parameter("name", name)
				.parameter("image_id", imageId)
				.parameter("hwp_id", profileId)
				.parameter("realm_id", realmId)
				.parameter("hwp_memory", memory)
				.parameter("hwp_storage", storage)
				.parameter("commit", "create")
				.toString();
	}
}
