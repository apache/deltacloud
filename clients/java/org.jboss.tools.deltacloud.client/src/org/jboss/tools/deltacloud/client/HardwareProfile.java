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

package org.jboss.tools.deltacloud.client;

import java.util.ArrayList;
import java.util.List;

import org.jboss.tools.deltacloud.client.Property.Names;

/**
 * @author Martyn Taylor
 * @author André Dietisheim
 */
public class HardwareProfile extends IdAware {
	private static final long serialVersionUID = 1L;

	private List<Property> properties;

	public HardwareProfile() {
	}

	public void setProperties(List<Property> properties) {
		this.properties = properties;
	}

	public List<Property> getProperties() {
		if (properties == null)
			properties = new ArrayList<Property>();
		return properties;
	}

	public Property getNamedProperty(Names nameEnum) {
		if (nameEnum == null) {
			return null;
		}
		return getNamedProperty(nameEnum.name().toLowerCase());
	}

	public Property getNamedProperty(String name) {
		if (properties != null) {
			for (Property p : properties) {
				if (p.getName().equals(name))
					return p;
			}
		}
		return null;
	}

	public String getArchitecture() {
		Property p = getNamedProperty(Property.Names.ARCHITECTURE);
		if (p != null)
			return p.getValue();
		return null;
	}

	public String getMemory() {
		Property p = getNamedProperty("memory");
		if (p != null)
			return p.toString();
		return null;
	}

	public String getStorage() {
		Property p = getNamedProperty("storage");
		if (p != null)
			return p.toString();
		return null;
	}

	public String getCPU() {
		Property p = getNamedProperty("cpu");
		if (p != null)
			return p.getValue();
		return null;
	}

	@Override
	public String toString() {
		String s = "";
		s += "Hardware-profile:\t\t" + getId() + "\n";
		for (Property p : properties) {
			s += p.getName() + ":\t\t" + p.getValue() + "\n";
		}
		return s;
	}
}
