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
 */
public class Image extends IdAware
{
	private static final long serialVersionUID = 1L;

	private String ownerId;

	private String name;

	private String description;

	private String architecture;

	public Image()
	{
	}

	public void setOwnerId(String ownerId)
	{
		this.ownerId = ownerId;
	}

	public void setName(String name)
	{
		this.name = name;
	}

	public void setDescription(String description)
	{
		this.description = description;
	}

	public void setArchitecture(String architecture)
	{
		this.architecture = architecture;
	}

	public String getOwnerId()
	{
		return ownerId;
	}

	public String getName()
	{
		return name;
	}

	public String getDescription() {
		return description;
	}

	public String getArchitecture()
	{
		return architecture;
	}

	@Override
	public String toString()
	{
		String s = "";
		s += "Image:\t\t" + getId() + "\n";
		s += "Owner:\t\t" + getOwnerId() + "\n";
		s += "Name:\t\t" + getName() + "\n";
		s += "Desc:\t\t" + getDescription() + "\n";
		s += "Arch:\t\t" + getArchitecture() + "\n";
		return s;
	}
}
