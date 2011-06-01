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

package org.apache.deltacloud.client.transport;

import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.text.MessageFormat;

import org.apache.deltacloud.client.DeltaCloudAuthClientException;
import org.apache.deltacloud.client.DeltaCloudClientException;
import org.apache.deltacloud.client.DeltaCloudNotFoundClientException;
import org.apache.deltacloud.client.HttpStatusCode;
import org.apache.deltacloud.client.HttpStatusRange;
import org.apache.deltacloud.client.request.DeltaCloudRequest;

/**
 * @author André Dietisheim
 */
public abstract class AbstractHttpTransport implements IHttpTransport {

	private String username;
	private String password;

	public AbstractHttpTransport(String username, String password) {
		this.username = username;
		this.password = password;
	}

	@Override
	public final InputStream request(DeltaCloudRequest request) throws DeltaCloudClientException {
		try {
			return doRequest(request);
		} catch (MalformedURLException e) {
			throw new DeltaCloudClientException(MessageFormat.format(
					"Could not connect to \"{0}\". The url is invalid.", request.getUrlString()), e);
		} catch(DeltaCloudClientException e) {
			throw e;
		} catch (Exception e) {
			throw new DeltaCloudClientException(e);
		}
	}

	protected abstract InputStream doRequest(DeltaCloudRequest request) throws Exception;

	protected void throwOnHttpErrors(int statusCode, String statusMessage, URL requestUrl)
			throws DeltaCloudClientException {
		if (HttpStatusCode.OK.isStatus(statusCode)) {
			return;
		} else if (HttpStatusCode.UNAUTHORIZED.isStatus(statusCode)) {
			throw new DeltaCloudAuthClientException(
					MessageFormat.format("The server reported an authorization error \"{0}\" on requesting \"{1}\"",
									statusMessage, requestUrl));
		} else if (HttpStatusCode.NOT_FOUND.isStatus(statusCode)) {
			throw new DeltaCloudNotFoundClientException(MessageFormat.format(
					"The server could not find the resource \"{0}\"",
					requestUrl));
		} else if (HttpStatusRange.CLIENT_ERROR.isInRange(statusCode)
				|| HttpStatusRange.SERVER_ERROR.isInRange(statusCode)) {
			throw new DeltaCloudClientException(
					MessageFormat.format("The server reported an error \"{0}\" on requesting \"{1}\"",
									statusMessage, requestUrl));
		}
	}

	protected String getUsername() {
		return username;
	}

	protected String getPassword() {
		return password;
	}

}
