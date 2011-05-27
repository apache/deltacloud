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
public class API extends IdAware {

	private static final long serialVersionUID = 1L;

	public static enum Driver {
		UNKNOWN, MOCK, EC2;

		public static Driver checkedValueOf(String name) {
			for (Driver driver : values()) {
				if (driver.name().equals(name)) {
					return driver;
				}
			}
			return UNKNOWN;
		}

	}

	private Driver driver;

	public API() {
	}

	public void setDriver(Driver driver) {
		this.driver = driver;
	}

	public void setDriver(String driver) {
		setDriver(Driver.checkedValueOf(driver.toUpperCase()));
	}

	public Driver getDriver() {
		return driver;
	}

	@Override
	public String toString() {
		return "API [driver=" + driver.name() + super.toString() + "]";
	}
}
