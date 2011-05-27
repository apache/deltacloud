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
import java.util.List;

import org.apache.deltacloud.client.unmarshal.InstanceUnmarshaller;

/**
 * @author Martyn Taylor
 * @author Andre Dietisheim
 */
public class Instance extends StateAware<Instance> {

	private static final long serialVersionUID = 1L;

	private String ownerId;

	private String name;

	private String imageId;

	private String profileId;

	private String memory;

	private String storage;

	private String cpu;

	private String realmId;

	private String keyId;

	private AddressList publicAddresses;

	private AddressList privateAddresses;

	public Instance() {
	}

	public void setOwnerId(String ownerId) {
		this.ownerId = ownerId;
	}

	public void setName(String name) {
		this.name = name;
	}

	public void setImageId(String imageId) {
		this.imageId = imageId;
	}

	public void setProfileId(String profileId) {
		this.profileId = profileId;
	}

	protected void setMemory(String memory) {
		this.memory = memory;
	}

	protected void setStorage(String storage) {
		this.storage = storage;
	}

	protected void setCPU(String cpu) {
		this.cpu = cpu;
	}

	public void setRealmId(String realmId) {
		this.realmId = realmId;
	}

	public void setKeyId(String keyId) {
		this.keyId = keyId;
	}

	public String getKeyId() {
		return keyId;
	}

	public void setPrivateAddresses(AddressList privateAddresses) {
		this.privateAddresses = privateAddresses;
	}

	public void setPublicAddresses(AddressList publicAddresses) {
		this.publicAddresses = publicAddresses;
	}

	public String getOwnerId() {
		return ownerId;
	}

	public String getName() {
		return name;
	}

	public String getImageId() {
		return imageId;
	}

	public String getProfileId() {
		return profileId;
	}

	public String getMemory() {
		return memory;
	}

	public String getStorage() {
		return storage;
	}

	public String getCPU() {
		return cpu;
	}

	public String getRealmId() {
		return realmId;
	}

	public List<String> getPublicAddresses() {
		return publicAddresses.getAddress();
	}

	public List<String> getPrivateAddresses() {
		return privateAddresses.getAddress();
	}

	@Override
	protected void doUpdate(InputStream in) throws DeltaCloudClientException {
		new InstanceUnmarshaller().unmarshall(in, this);
	}

	
	@Override
	public String toString() {
		String s = "";
		s += "Instance:\t" + getId() + "\n";
		s += "Owner:\t\t" + getOwnerId() + "\n";
		s += "Image:\t\t" + getImageId() + "\n";
		s += "Realm:\t\t" + getRealmId() + "\n";
		s += "Profile:\t\t" + getProfileId() + "\n";
		if (getMemory() != null)
			s += "Memory:\t\t" + getMemory() + "\n";
		if (getStorage() != null) {
			s += "Storage:\t\t" + getStorage() + "\n";
		}
		if (getCPU() != null) {
			s += "CPU:\t\t" + getCPU() + "\n";
		}
		s += "State:\t\t" + getState() + "\n";

		List<Action<Instance>> actions = getActions();
		if (actions != null) {
			for (int i = 0; i < actions.size(); i++) {
				if (i == 0) {
					s += "Actions:\t" + actions.get(i) + "\n";
				} else {
					s += "\t\t" + actions.get(i) + "\n";
				}
			}
		}

		for (int i = 0; i < publicAddresses.getAddress().size(); i++) {
			if (i == 0) {
				s += "Public Addr:\t" + publicAddresses.getAddress().get(i) + "\n";
			} else {
				s += "\t\t" + publicAddresses.getAddress().get(i) + "\n";
			}
		}

		for (int i = 0; i < publicAddresses.getAddress().size(); i++) {
			if (i == 0) {
				s += "Private Addr:\t" + publicAddresses.getAddress().get(i) + "\n";
			} else {
				s += "\t\t" + privateAddresses.getAddress().get(i) + "\n";
			}
		}

		return s;
	}
}
