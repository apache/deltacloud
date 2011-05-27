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

import org.jboss.tools.deltacloud.client.DeltaCloudClientException;
import org.jboss.tools.deltacloud.client.HardwareProfile;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 * @author André Dietisheim
 */
public class HardwareProfilesUnmarshaller extends AbstractDeltaCloudObjectsUnmarshaller<HardwareProfile> {

	public HardwareProfilesUnmarshaller() {
		super("hardware_profiles", "hardware_profile");
	}

	@Override
	protected HardwareProfile unmarshallChild(Node node) throws DeltaCloudClientException {
		return new HardwareProfileUnmarshaller().unmarshall((Element) node, new HardwareProfile());
	}
}
