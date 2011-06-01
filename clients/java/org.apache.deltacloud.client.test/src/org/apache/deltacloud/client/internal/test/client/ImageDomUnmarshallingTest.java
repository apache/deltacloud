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
package org.apache.deltacloud.client.internal.test.client;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import java.io.ByteArrayInputStream;
import java.util.ArrayList;
import java.util.List;

import org.apache.deltacloud.client.DeltaCloudClientException;
import org.apache.deltacloud.client.Image;
import org.apache.deltacloud.client.internal.test.fakes.ImageResponseFakes.ImageResponse;
import org.apache.deltacloud.client.internal.test.fakes.ImageResponseFakes.ImagesResponse;
import org.apache.deltacloud.client.unmarshal.ImageUnmarshaller;
import org.apache.deltacloud.client.unmarshal.ImagesUnmarshaller;
import org.junit.Test;

/**
 * @author André Dietisheim
 */
public class ImageDomUnmarshallingTest {

	@Test
	public void imageMayBeUnmarshalled() throws DeltaCloudClientException {
		Image image = new Image();
		ByteArrayInputStream inputStream = new ByteArrayInputStream(ImageResponse.response.getBytes());
		new ImageUnmarshaller().unmarshall(inputStream, image);
		assertNotNull(image);
		assertEquals(ImageResponse.id, image.getId());
		assertEquals(ImageResponse.name, image.getName());
		assertEquals(ImageResponse.ownerId, image.getOwnerId());
		assertEquals(ImageResponse.description, image.getDescription());
		assertEquals(ImageResponse.architecture, image.getArchitecture());
	}

	@Test
	public void imagesMayBeUnmarshalled() throws DeltaCloudClientException {
		ByteArrayInputStream inputStream = new ByteArrayInputStream(ImagesResponse.response.getBytes());
		List<Image> images = new ArrayList<Image>();
		new ImagesUnmarshaller().unmarshall(inputStream, images);
		assertEquals(2, images.size());

		Image image = images.get(0);
		assertEquals(ImagesResponse.id1, image.getId());
		assertEquals(ImagesResponse.name1, image.getName());

		image = images.get(1);
		assertEquals(ImagesResponse.id2, image.getId());
		assertEquals(ImagesResponse.name2, image.getName());
	}

}
