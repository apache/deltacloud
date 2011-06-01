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

/**
 * @author Martyn Taylor
 * @author André Dietisheim
 */
public class Realm extends IdAware {
	private static final long serialVersionUID = 1L;

	public static final int LIMIT_DEFAULT = -1;

	private String name;
	private RealmState state;
	private int limit;

	public static enum RealmState {
		AVAILABLE, UNAVAILABLE, UNKNOWN
	}

	public Realm() {
	}

	public void setName(String name) {
		this.name = name;
	}


	public void setLimit(int limit) {
		this.limit = limit;
	}

	public void setLimit(String limit) {
		try {
			this.limit = Integer.parseInt(limit);
		} catch (Exception e) {
			this.limit = LIMIT_DEFAULT;
		}
	}

	public int getLimit() {
		return limit;
	}

	public String getName() {
		return name;
	}

	public void setState(String state) {
		try {
			this.state = RealmState.valueOf(state.toUpperCase());
		} catch (Exception e) {
			this.state = RealmState.UNKNOWN;
		}
	}

	public RealmState getState() {
		return state;
	}

	@Override
	public String toString() {
		String s = "";
		s += "Realm:\t\t" + getId() + "\n";
		s += "Name\t\t" + getName() + "\n";
		s += "State:\t\t" + getState() + "\n";
		s += "Limit:\t\t" + getLimit() + "\n";
		return s;
	}
}
