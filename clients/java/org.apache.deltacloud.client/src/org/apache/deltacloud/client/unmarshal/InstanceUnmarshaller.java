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

import java.util.ArrayList;
import java.util.List;

import org.apache.deltacloud.client.Action;
import org.apache.deltacloud.client.AddressList;
import org.apache.deltacloud.client.DeltaCloudClientException;
import org.apache.deltacloud.client.Instance;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * @author André Dietisheim
 */
public class InstanceUnmarshaller extends AbstractActionAwareUnmarshaller<Instance> {

	public InstanceUnmarshaller() {
		super("instance", Instance.class, "link");
	}

	protected Instance doUnmarshall(Element element, Instance instance) throws Exception {
		instance.setId(getAttributeText("id", element));
		instance.setName(getFirstElementText("name", element));
		instance.setOwnerId(getFirstElementText("owner_id", element));
		instance.setOwnerId(getFirstElementText("owner_id", element));
		instance.setImageId(getFirstElementAttributeText("image", "id", element));
		instance.setProfileId(getFirstElementAttributeText("hardware_profile", "id", element));
		instance.setRealmId(getFirstElementAttributeText("realm", "id", element));
		instance.setState(getFirstElementText("state", element));
		setKeyname(instance, element);
		instance.setActions(getActions(element, instance));
		instance.setPublicAddresses(getAddressList("public_addresses", element));
		instance.setPrivateAddresses(getAddressList("private_addresses", element));
		return instance;
	}

	private AddressList getAddressList(String elementName, Element element) {
		Element addressElement = getFirstElement(elementName, element);
		if (addressElement != null) {
			NodeList addressList = addressElement.getChildNodes();
			if (addressList != null) {
				List<String> addresses = new ArrayList<String>();
				for (int i = 0; i < addressList.getLength(); i++) {
					Node addressNode = addressList.item(i);
					if (addressNode != null) {
						String address = stripText(addressNode.getTextContent());
						if (address != null && address.length() > 0) {
							addresses.add(address);
						}
					}
				}
				return new AddressList(addresses);
			}
		}
		return new AddressList();
	}

	private void setKeyname(Instance instance, Element element) {
		Element authenticationElement = getFirstElement("authentication", element);
		if (authenticationElement != null) {
			Element loginElement = getFirstElement("login", authenticationElement);
			if (loginElement != null) {
				String keyname = getFirstElementText("keyname", loginElement);
				instance.setKeyId(keyname);
			}
		}
	}

	@Override
	protected Action<Instance> unmarshallAction(Element element) throws DeltaCloudClientException {
		Action<Instance> action = new Action<Instance>();
		new ActionUnmarshaller<Instance>().unmarshall(element, action);
		return action;
	}
}
