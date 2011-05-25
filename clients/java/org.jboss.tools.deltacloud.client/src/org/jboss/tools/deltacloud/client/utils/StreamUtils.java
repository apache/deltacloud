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

package org.jboss.tools.deltacloud.client.utils;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;

public class StreamUtils {

	/**
	 * Writes the content of the given input stream to the given output stream
	 * and returns and input stream that may still be used to read from.
	 * 
	 * @param outputStream the output stream to write to
	 * @param inputStream the input stream to read from
	 * @return a new, unread input stream
	 * @throws IOException
	 */
	public static InputStream writeTo(InputStream inputStream, OutputStream outputStream) throws IOException {
		List<Byte> data = new ArrayList<Byte>();
		for (int character = -1; (character = inputStream.read()) != -1;) {
			data.add((byte) character);
			outputStream.write(character);
		}
		byte[] byteArray = new byte[data.size()];
		for (int i = byteArray.length - 1; i >= 0; i--) {
			byteArray[i] = data.get(i);
		}
		return new ByteArrayInputStream(byteArray);
	}
}
