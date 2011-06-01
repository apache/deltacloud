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

/**
 * @author André Dietisheim
 */
public interface DeltaCloudRequest {

	public static final char PATH_SEPARATOR = '/';
	public static final char PARAMETER_SEPARATOR = '?';
	public static final String API_PATH_SEGMENT = "api";

	public URL getUrl() throws MalformedURLException;

	public String getUrlString();

	public HttpMethod getHttpMethod();
}
