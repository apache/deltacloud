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
 * An action that may be performed on a resource
 * 
 * @author André Dietisheim
 */
public class Action<OWNER> {

	public static final String START_NAME = "start";
	public static final String STOP_NAME = "stop";
	public static final String REBOOT_NAME = "reboot";
	public static final String DESTROY_NAME = "destroy";

	private String name;
	private String url;
	private HttpMethod method;
	private OWNER owner;

	public HttpMethod getMethod() {
		return method;
	}

	public void setMethodString(String method) {
		this.method = HttpMethod.valueOf(method.toUpperCase());
	}

	public void setMethod(HttpMethod method) {
		this.method = method;
	}

	public void setMethod(String method) {
		this.method = HttpMethod.valueOf(method.toUpperCase());
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getName() {
		return name;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public String getUrl() {
		return url;
	}

	public void setOwner(OWNER owner) {
		this.owner = owner;
	}

	public OWNER getOwner() {
		return owner;
	}

	public boolean isStart() {
		return START_NAME.equals(getName());
	}

	public boolean isStop() {
		return STOP_NAME.equals(getName());
	}

	public boolean isReboot() {
		return REBOOT_NAME.equals(getName());
	}

	public boolean isDestroy() {
		return DESTROY_NAME.equals(getName());
	}
}
