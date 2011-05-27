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

import java.util.List;

import org.apache.deltacloud.client.DeltaCloudClientException;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * @author André Dietisheim
 */
@SuppressWarnings("rawtypes")
public abstract class AbstractDeltaCloudObjectsUnmarshaller<CHILD> extends AbstractDOMUnmarshaller<List> {

	private String childTag;

	public AbstractDeltaCloudObjectsUnmarshaller(String parentTag, String childTag) {
		super(parentTag, List.class);
		this.childTag = childTag;
	}

	@SuppressWarnings("unchecked")
	protected List doUnmarshall(Element element, List children) throws Exception {
		if (element != null) {
			NodeList nodeList = element.getElementsByTagName(childTag);
			if (nodeList != null
					&& nodeList.getLength() > 0) {
				for (int i = 0; i < nodeList.getLength(); i++) {
					Node node = nodeList.item(i);
					if (node instanceof Element) {
						CHILD child = unmarshallChild(node);
						children.add(child);
					}
				}
			}
		}
		return children;
	}

	protected abstract CHILD unmarshallChild(Node node) throws DeltaCloudClientException;
}
