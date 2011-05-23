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
package org.jboss.tools.deltacloud.client.transport;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.net.Authenticator;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.text.MessageFormat;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.jboss.tools.deltacloud.client.DeltaCloudNotFoundClientException;
import org.jboss.tools.deltacloud.client.HttpMethod;
import org.jboss.tools.deltacloud.client.request.DeltaCloudRequest;

public class URLConnectionTransport extends AbstractHttpTransport {

	private static final char USERNAME_PASSWORD_DELIMITER = ':';
	private static final String PROPERTY_AUTHORIZATION = "Authorization";
	private static final String PROPERTY_ACCEPT = "Accept";
	private static final String PREFIX_BASIC_AUTHENTICATION = "Basic ";
	private static final int TIMEOUT = 10 * 1024;

	public URLConnectionTransport(String username, String password) {
		super(username, password);
	}

	@Override
	protected InputStream doRequest(DeltaCloudRequest request) throws Exception {
		HttpURLConnection connection = null;
		try {
			URL url = request.getUrl();
			connection = (HttpURLConnection) url.openConnection();
			connection.setUseCaches(false);
			connection.setDoInput(true);
			connection.setAllowUserInteraction(false);
			connection.setConnectTimeout(TIMEOUT);
			connection.setRequestProperty(PROPERTY_ACCEPT, "application/xml;q=1");
			connection.setInstanceFollowRedirects(true);
			addCredentials(connection);
			setRequestMethod(request, connection);
			BufferedInputStream in = new BufferedInputStream(connection.getInputStream());
			return in;
		} catch (FileNotFoundException e) {
			/*
			 * thrown by #connect when server resonds with 404
			 */
			throw new DeltaCloudNotFoundClientException(
					MessageFormat.format("Could not find resource {0}", request.getUrlString()));
		} catch (IOException e) {
			/*
			 * thrown by #connect when server resonds with 401.
			 */
			HttpError httpError = HttpError.getInstance(e, connection);
			if (httpError != null) {
				throwOnHttpErrors(httpError.getStatusCode(), httpError.getStatusMessage(), request.getUrl());
			}
			throw e;
		}

	}

	private void setRequestMethod(DeltaCloudRequest request, HttpURLConnection connection) throws IOException {
		HttpMethod httpMethod = request.getHttpMethod();
		connection.setRequestMethod(httpMethod.name());
		switch (httpMethod) {
		case PUT:
		case POST:
			connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
			connection.setRequestProperty("Content-Length", "0");// String.valueOf(request.getParametersLength()));
			connection.setDoOutput(true);
			connection.getOutputStream().flush();
			break;
		case GET:
			connection.setDoOutput(false);
			break;
		}

	}

	/**
	 * Adds the credentials to the given http url connection.
	 * 
	 * The current implementation uses low level API. Alternatively
	 * {@link Authenticator#setDefault(Authenticator)} could be used which would
	 * then rule all url connections in the same jvm.
	 * 
	 * @param httpClient
	 *            the http client
	 * @return the default http client
	 * @throws IOException
	 */
	private void addCredentials(URLConnection urlConnection) throws IOException {
		String username = getUsername();
		String password = getPassword();
		if (username != null && password != null) {
			String credentials = new StringBuilder()
					.append(PREFIX_BASIC_AUTHENTICATION)
					.append(getAuthenticationValue(username, password))
					.toString();
			urlConnection.setRequestProperty(PROPERTY_AUTHORIZATION, credentials);
		}

	}

	private String getAuthenticationValue(String username, String password) throws IOException {
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		out.write(username.getBytes());
		out.write(USERNAME_PASSWORD_DELIMITER);
		out.write(password.getBytes());
		char[] encoded = Base64Coder.encode(out.toByteArray());
		return new String(encoded);
	}

	private static final class HttpError {

		private static final Pattern STATUS_REGEX = Pattern.compile(".+ HTTP response code: ([0-9]{3}) .+");
		private int statusCode;
		private String statusMessage;

		private HttpError(int statusCode, String statusMessage) {
			this.statusCode = statusCode;
			this.statusMessage = statusMessage;
		}

		public static HttpError getInstance(IOException ioe, HttpURLConnection connection) throws IOException {
			HttpError httpError = null;
			try {
				int statusCode = getStatusCode(ioe);
				if (statusCode > -1) {
					String statusMessage = connection.getResponseMessage();
					httpError = new HttpError(statusCode, statusMessage);
				}
			} catch (Exception e) {
				// ignore
			}
			return httpError;
		}

		public String getStatusMessage() {
			return statusMessage;
		}

		private static int getStatusCode(IOException e) {
			Matcher matcher = STATUS_REGEX.matcher(e.getMessage());
			if (matcher.matches()) {
				return getStatusCode(matcher.group(1));
			}
			return -1;
		}

		private static int getStatusCode(String statusCode) {
			try {
				return Integer.parseInt(statusCode);
			} catch (NumberFormatException e) {
				return -1;
			}
		}

		public int getStatusCode() {
			return statusCode;
		}
	}
}
