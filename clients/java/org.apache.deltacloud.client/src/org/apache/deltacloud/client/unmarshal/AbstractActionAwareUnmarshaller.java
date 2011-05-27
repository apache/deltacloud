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
import org.apache.deltacloud.client.DeltaCloudClientException;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * @author André Dietisheim
 *
 * @param <DELTACLOUDOBJECT>
 */
public abstract class AbstractActionAwareUnmarshaller<DELTACLOUDOBJECT> extends AbstractDOMUnmarshaller<DELTACLOUDOBJECT>{

	private String actionElementName;
	public AbstractActionAwareUnmarshaller(String tagName, Class<DELTACLOUDOBJECT> type, String actionElementName) {
		super(tagName, type);
		this.actionElementName = actionElementName;
	}

	protected List<Action<DELTACLOUDOBJECT>> getActions(Element element, DELTACLOUDOBJECT owner) throws DeltaCloudClientException {
		if (element == null) {
			return null;
		}
		List<Action<DELTACLOUDOBJECT>> actions = new ArrayList<Action<DELTACLOUDOBJECT>>();
		NodeList nodeList = element.getElementsByTagName(actionElementName);
		for (int i = 0; i < nodeList.getLength(); i++) {
			Node linkNode = nodeList.item(i);
			Action<DELTACLOUDOBJECT> action = createAction(linkNode);
			if (action != null) {
				action.setOwner(owner);
				actions.add(action);
			}
		}
		return actions;
	}

	protected Action<DELTACLOUDOBJECT> createAction(Node node) throws DeltaCloudClientException {
		if (!(node instanceof Element)) {
			return null;
		}
		return unmarshallAction((Element) node);
	}
	
	protected abstract Action<DELTACLOUDOBJECT> unmarshallAction(Element element) throws DeltaCloudClientException;
}
