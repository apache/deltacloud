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

import java.net.MalformedURLException;
import java.net.URL;

import org.apache.deltacloud.client.HttpMethod;
import org.apache.deltacloud.client.utils.UrlBuilder;

/**
 * @author André Dietisheim
 */
public abstract class AbstractDeltaCloudRequest implements DeltaCloudRequest {

	private String urlString;
	private URL url;
	private HttpMethod httpMethod;
	private UrlBuilder urlBuilder;

	protected AbstractDeltaCloudRequest(String baseURL, HttpMethod httpMethod) {
		this.httpMethod = httpMethod;
		this.urlBuilder = createUrlBuilder(baseURL);
	}

	protected abstract String doCreateUrl(UrlBuilder urlBuilder);

	protected UrlBuilder createUrlBuilder(String baseUrl) {
		return new UrlBuilder(baseUrl).path(API_PATH_SEGMENT);
	}

	public URL getUrl() throws MalformedURLException {
		if (url == null) {
			this.url = new URL(getUrlString());
		}
		return url;
	}

	public String getUrlString() {
		if (urlString == null) {
			this.urlString = doCreateUrl(urlBuilder);
		}
		return urlString;
	}

	public String toString() {
		return getUrlString();
	}

	public HttpMethod getHttpMethod() {
		return httpMethod;
	}
}
