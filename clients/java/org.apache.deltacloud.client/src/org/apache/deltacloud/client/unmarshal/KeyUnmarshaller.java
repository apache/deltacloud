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

package org.apache.deltacloud.client.unmarshal;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;

import org.apache.deltacloud.client.Action;
import org.apache.deltacloud.client.DeltaCloudClientException;
import org.apache.deltacloud.client.Key;
import org.w3c.dom.Element;

/**
 * @author André Dietisheim
 */
public class KeyUnmarshaller extends AbstractActionAwareUnmarshaller<Key> {

	public KeyUnmarshaller() {
		super("key", Key.class, "link");
	}

	protected Key doUnmarshall(Element element, Key key) throws Exception {
		if (element != null) {
			key.setId(getAttributeText("id", element));
			key.setUrl(getAttributeText("href", element));
			key.setState(getFirstElementText("state", element));
			key.setFingerprint(getFirstElementText("fingerprint", element));
			key.setPem(trimPem(getPem(element))); //$NON-NLS-1$
			key.setActions(getActions(element, key));
		}
		return key;
	}

	private String getPem(Element element) {
		Element pemElement = getFirstElement("pem", element);
		if (pemElement != null) {
			return getFirstElementText("pem", pemElement);
		}
		return null;
	}

	private String trimPem(String pem) throws IOException {
		if (pem == null
				|| pem.length() <= 0) {
			return null;
		}
		StringBuffer sb = new StringBuffer();
		String line = null;
		BufferedReader reader = new BufferedReader(new StringReader(pem));
		while ((line = reader.readLine()) != null) {
			// We must trim off the white-space from the xml
			// Complete white-space lines are to be ignored.
			String trimmedLine = line.trim();
			if (trimmedLine.length() > 0) {
				sb.append(trimmedLine).append('\n');
			}
		}
		return sb.toString();
	}

	@Override
	protected Action<Key> unmarshallAction(Element element) throws DeltaCloudClientException {
		Action<Key> keyAction = new Action<Key>();
		new ActionUnmarshaller<Key>().unmarshall(element, keyAction);
		return keyAction;
	}
}
