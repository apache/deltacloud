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

import java.io.IOException;
import java.io.InputStream;
import java.text.MessageFormat;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.apache.deltacloud.client.DeltaCloudClientException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

/**
 * @author André Dietisheim
 *
 * @param <DELTACLOUDOBJECT>
 */
public abstract class AbstractDOMUnmarshaller<DELTACLOUDOBJECT> {

	private Class<DELTACLOUDOBJECT> type;
	private String tagName;

	public AbstractDOMUnmarshaller(String tagName, Class<DELTACLOUDOBJECT> type) {
		this.type = type;
		this.tagName = tagName;
	}

	public DELTACLOUDOBJECT unmarshall(InputStream inputStream, DELTACLOUDOBJECT deltacloudObject) throws DeltaCloudClientException {
		try {
			Element element = getFirstElement(tagName, getDocument(inputStream));
			if (element == null) {
				return null;
			}
			return unmarshall(element, deltacloudObject);
		} catch (Exception e) {
			// TODO: internationalize strings
			throw new DeltaCloudClientException(
					MessageFormat.format("Could not unmarshall type \"{0}\"", type), e);
		}

	}

	protected Document getDocument(InputStream inputStream) throws ParserConfigurationException, SAXException, IOException {
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		DocumentBuilder documentBuilder = factory.newDocumentBuilder();
		return documentBuilder.parse(inputStream);
	}

	public DELTACLOUDOBJECT unmarshall(Element element, DELTACLOUDOBJECT resource) throws DeltaCloudClientException {
		try {
			return doUnmarshall(element, resource);
		} catch (Exception e) {
			// TODO: internationalize strings
			throw new DeltaCloudClientException(
					MessageFormat.format("Could not unmarshall type \"{0}\"", type), e);
		}
	}

	protected abstract DELTACLOUDOBJECT doUnmarshall(Element element, DELTACLOUDOBJECT resource) throws Exception;

	protected String getFirstElementAttributeText(String elementName, String attributeId, Element element) {
		Element firstElement = getFirstElement(elementName, element);
		if (firstElement == null) {
			return null;
		}
		return firstElement.getAttribute(attributeId);
	}

	protected String getFirstElementText(String elementName, Element element) {
		Element firstElement = getFirstElement(elementName, element);
		if (firstElement == null) {
			return null;
		}
		return firstElement.getTextContent();
	}

	protected Element getFirstElement(String elementName, Element element) {
		NodeList elements = element.getElementsByTagName(elementName);
		if (elements != null
				&& elements.getLength() > 0) {
			return (Element) elements.item(0);
		}
		return null;
	}

	protected Element getFirstElement(String elementName, Document document) {
		NodeList elements = document.getElementsByTagName(elementName);
		if (elements != null
				&& elements.getLength() > 0) {
			return (Element) elements.item(0);
		}
		return null;
	}

	protected String getAttributeText(String attributeName, Element element) {
		Node attribute = element.getAttributeNode(attributeName);
		if (attribute != null) {
			return attribute.getTextContent();
		}
		return null;
	}

	protected String stripText(String textContent) {
		if (textContent == null || textContent.length() == 0) {
			return textContent;
		}
		return textContent.trim();
	}

}
