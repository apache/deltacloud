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
import java.util.ArrayList;
import java.util.List;

/**
 * @author Martyn Taylor
 * @author André Dietisheim
 */
public abstract class ActionAware<OWNER> extends IdAware {

	private List<Action<OWNER>> actions;

	public Action<OWNER> getAction(String name) {
		if (name == null) {
			return null;
		}

		for (Action<OWNER> action : getActions()) {
			if (name.equals(action.getName())) {
				return action;
			}
		}
		return null;
	}

	public List<String> getActionNames() {
		ArrayList<String> names = new ArrayList<String>();
		for (Action<OWNER> action : getActions()) {
			names.add(action.getName());
		}
		return names;
	}

	public boolean start(DeltaCloudClient client) throws DeltaCloudClientException {
		InputStream in = client.performAction(getAction(Action.START_NAME));
		update(in);
		return in != null;
	}

	public boolean stop(DeltaCloudClient client) throws DeltaCloudClientException {
		InputStream in = client.performAction(getAction(Action.STOP_NAME));
		update(in);
		return in != null;
	}

	public boolean destroy(DeltaCloudClient client) throws DeltaCloudClientException {
		InputStream in = client.performAction(getAction(Action.DESTROY_NAME));
		return in != null;
	}

	public boolean reboot(DeltaCloudClient client) throws DeltaCloudClientException {
		InputStream in = client.performAction(getAction(Action.REBOOT_NAME));
		update(in);
		return in != null;
	}

	protected void update(InputStream in) throws DeltaCloudClientException {
		if (in == null) {
			return;
		}
		
		doUpdate(in);
	}
	
	protected abstract void doUpdate(InputStream in) throws DeltaCloudClientException;

	public boolean canStart() {
		return getAction(Action.START_NAME) != null;
	}

	public boolean canStop() {
		return getAction(Action.STOP_NAME) != null;
	}

	public boolean canReboot() {
		return getAction(Action.REBOOT_NAME) != null;
	}

	public boolean canDestroy() {
		return getAction(Action.DESTROY_NAME) != null;
	}

	public void setActions(List<Action<OWNER>> actions) {
		this.actions = actions;
	}

	public List<Action<OWNER>> getActions() {
		return actions;
	}
}
