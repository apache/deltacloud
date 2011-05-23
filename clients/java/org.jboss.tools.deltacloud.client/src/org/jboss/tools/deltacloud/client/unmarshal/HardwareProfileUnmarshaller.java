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

package org.jboss.tools.deltacloud.client.unmarshal;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.runtime.Assert;
import org.jboss.tools.deltacloud.client.HardwareProfile;
import org.jboss.tools.deltacloud.client.Property;
import org.jboss.tools.deltacloud.client.Property.Kind;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * @author André Dietisheim
 */
public class HardwareProfileUnmarshaller extends AbstractDOMUnmarshaller<HardwareProfile> {

	public HardwareProfileUnmarshaller() {
		super("hardware_profile", HardwareProfile.class);
	}

	@Override
	protected HardwareProfile doUnmarshall(Element element, HardwareProfile profile) throws Exception {
		profile.setId(getAttributeText("id", element));
		profile.setProperties(createProperties(element.getElementsByTagName("property")));
		return profile;
	}

	private List<Property> createProperties(NodeList propertiesList) {
		List<Property> properties = new ArrayList<Property>();
		for (int i = 0; i < propertiesList.getLength(); i++) {
			Property property = createProperty(propertiesList.item(i));
			properties.add(property);
		}
		return properties;
	}

	private Property createProperty(Node node) {
		Assert.isTrue(node instanceof Element);
		Element element = (Element) node;
		Property property = new Property();
		property.setName(element.getAttribute("name"));
		property.setId(element.getAttribute("id"));
		property.setUnit(element.getAttribute("unit"));
		property.setValue(element.getAttribute("value"));
		String kind = element.getAttribute("kind");
		Assert.isTrue(kind != null);
		kind = kind.toUpperCase();
		property.setKind(kind);
		if (Kind.RANGE.toString().equals(property.getKind())) {
			setRange(element, property);
		} else if (Kind.ENUM.toString().equals(property.getKind())) {
			setEnum(element, property);
		} else if (Kind.FIXED.toString().equals(property.getKind())) {
			// no special treatement
		}
		return property;
	}

	private void setRange(Element propertyElement, Property property) {
		Node node = propertyElement.getElementsByTagName("range").item(0);
		Assert.isLegal(node instanceof Element);
		Element rangeElement = (Element) node;
		property.setRange(rangeElement.getAttribute("first"), rangeElement.getAttribute("last"));
	}

	private void setEnum(Element propertyElement, Property property) {
		Node node = propertyElement.getElementsByTagName("enum").item(0);
		Assert.isLegal(node instanceof Element);
		Element enumElement = (Element) node;
		NodeList nodeList = enumElement.getElementsByTagName("entry");
		ArrayList<String> enumValues = new ArrayList<String>();
		for (int i = 0; i < nodeList.getLength(); i++) {
			Node entryNode = nodeList.item(i);
			Assert.isTrue(entryNode instanceof Element);
			Element entryElement = (Element) entryNode;
			enumValues.add(entryElement.getAttribute("value"));
		}
		property.setEnums(enumValues);
	}
	
}
