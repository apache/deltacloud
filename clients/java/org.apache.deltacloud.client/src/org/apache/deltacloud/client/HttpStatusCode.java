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
 * @author Andre Dietisheim
 */
public enum HttpStatusCode {

	OK(200), NOT_FOUND(404), FORBIDDEN(403), UNAUTHORIZED(401);

	private int code;

	private HttpStatusCode(int code) {
		this.code = code;
	}

	public int getCode() {
		return code;
	}

	public boolean isStatus(int statusCode) {
		return code == statusCode;
	}
}
