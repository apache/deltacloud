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

import java.io.InputStream;
import java.text.MessageFormat;

import org.apache.deltacloud.client.DeltaCloudClientException;

/**
 * @author André Dietisheim
 *
 * @param <RESOURCE>
 */
public abstract class AbstractDeltaCloudObjectUnmarshaller<RESOURCE> implements IDeltaCloudObjectUnmarshaller<RESOURCE> {

	private Class<RESOURCE> type;

	public AbstractDeltaCloudObjectUnmarshaller(Class<RESOURCE> type) {
		this.type = type;
	}

	public RESOURCE create(InputStream inputStream) throws DeltaCloudClientException {

		try {
			return doCreate(inputStream);
		} catch (Exception e) {
			// TODO: internationalize strings
			throw new DeltaCloudClientException(
					MessageFormat.format("Could not unmarshall resource of type \"{0}\"", type), e);
		}
	}

	protected abstract RESOURCE doCreate(InputStream inputStream) throws Exception;

}
