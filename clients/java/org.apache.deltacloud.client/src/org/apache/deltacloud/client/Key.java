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

package org.apache.deltacloud.client;

import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;

import org.apache.deltacloud.client.unmarshal.KeyUnmarshaller;

/**
 * @author Andre Dietisheim
 */
public class Key extends StateAware<Key> {

	private static final long serialVersionUID = 1L;

	private URL url;
	private String pem;
	private String fingerprint;
	private String state;

	public Key() {
	}

	public void setUrl(URL url) {
		this.url = url;
	}

	public void setUrl(String url) throws MalformedURLException {
		this.url = new URL(url);
	}

	public void setPem(String pem) {
		this.pem = pem;
	}

	public void setFingerprint(String fingerprint) {
		this.fingerprint = fingerprint;
	}

	public URL getUrl() {
		return url;
	}

	public String getFingerprint() {
		return fingerprint;
	}

	public String getPem() {
		return pem;
	}

	@Override
	protected void doUpdate(InputStream in) throws DeltaCloudClientException {
		new KeyUnmarshaller().unmarshall(in, this);
	}

	@Override
	public String toString() {
		return "Key [url=" + url + ", pem=" + pem + ", fingerprint=" + fingerprint + ", state=" + state + ", actions="
				+ getActions() + ", toString()=" + super.toString() + "]";
	}
}
