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
import java.net.MalformedURLException;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.List;

import org.apache.deltacloud.client.API.Driver;
import org.apache.deltacloud.client.request.CreateInstanceRequest;
import org.apache.deltacloud.client.request.CreateKeyRequest;
import org.apache.deltacloud.client.request.DeltaCloudRequest;
import org.apache.deltacloud.client.request.ListHardwareProfileRequest;
import org.apache.deltacloud.client.request.ListHardwareProfilesRequest;
import org.apache.deltacloud.client.request.ListImageRequest;
import org.apache.deltacloud.client.request.ListImagesRequest;
import org.apache.deltacloud.client.request.ListInstanceRequest;
import org.apache.deltacloud.client.request.ListInstancesRequest;
import org.apache.deltacloud.client.request.ListKeyRequest;
import org.apache.deltacloud.client.request.ListKeysRequest;
import org.apache.deltacloud.client.request.ListRealmRequest;
import org.apache.deltacloud.client.request.ListRealmsRequest;
import org.apache.deltacloud.client.request.PerformActionRequest;
import org.apache.deltacloud.client.request.TypeRequest;
import org.apache.deltacloud.client.transport.IHttpTransport;
import org.apache.deltacloud.client.transport.URLConnectionTransport;
import org.apache.deltacloud.client.unmarshal.APIUnmarshaller;
import org.apache.deltacloud.client.unmarshal.HardwareProfileUnmarshaller;
import org.apache.deltacloud.client.unmarshal.HardwareProfilesUnmarshaller;
import org.apache.deltacloud.client.unmarshal.ImageUnmarshaller;
import org.apache.deltacloud.client.unmarshal.ImagesUnmarshaller;
import org.apache.deltacloud.client.unmarshal.InstanceUnmarshaller;
import org.apache.deltacloud.client.unmarshal.InstancesUnmarshaller;
import org.apache.deltacloud.client.unmarshal.KeyUnmarshaller;
import org.apache.deltacloud.client.unmarshal.KeysUnmarshaller;
import org.apache.deltacloud.client.unmarshal.RealmUnmarshaller;
import org.apache.deltacloud.client.unmarshal.RealmsUnmarshaller;

/**
 * @author Andre Dietisheim (based on prior implementation by Martyn Taylor)
 */
public class DeltaCloudClientImpl implements DeltaCloudClient {

	private String baseUrl;
	private IHttpTransport transport;

	public DeltaCloudClientImpl(String url) throws MalformedURLException, DeltaCloudClientException {
		this(url, null, null);
	}

	public DeltaCloudClientImpl(String url, String username, String password) throws MalformedURLException,
			DeltaCloudClientException {
		this(url, new URLConnectionTransport(username,	password));
	}

	public DeltaCloudClientImpl(String url, IHttpTransport transport) throws DeltaCloudClientException {
		this.baseUrl = url;
		this.transport = transport;
	}

	protected InputStream request(DeltaCloudRequest deltaCloudRequest) throws DeltaCloudClientException {
		return transport.request(deltaCloudRequest);
	}

	public Driver getServerType() {
		try {
			InputStream response = request(new TypeRequest(baseUrl));
			API api = new APIUnmarshaller().unmarshall(response, new API());
			return api.getDriver();
		} catch (DeltaCloudClientException e) {
			return Driver.UNKNOWN;
		}
	}

	@Override
	public Instance createInstance(String imageId) throws DeltaCloudClientException {
		try {
			InputStream response = request(new CreateInstanceRequest(baseUrl, imageId));
			return new InstanceUnmarshaller().unmarshall(response, new Instance());
		} catch (DeltaCloudClientException e) {
			throw e;
		} catch (Exception e) {
			throw new DeltaCloudClientException(e);
		}

	}

	public Instance createInstance(String name, String imageId, String profileId, String realmId, String memory,
			String storage) throws DeltaCloudClientException {
		return createInstance(name, imageId, profileId, realmId, null, memory, storage);
	}

	public Instance createInstance(String name, String imageId, String profileId, String realmId, String keyId,
			String memory, String storage) throws DeltaCloudClientException {
		try {
			InputStream response = request(
					new CreateInstanceRequest(baseUrl, name, imageId, profileId, realmId, keyId, memory, storage));
			Instance instance = new InstanceUnmarshaller().unmarshall(response, new Instance());
			// TODO: WORKAROUND for
			// https://issues.jboss.org/browse/JBIDE-8005
			if (keyId != null) {
				instance.setKeyId(keyId);
			}
			// TODO: WORKAROUND for
			// https://issues.jboss.org/browse/JBIDE-8005
			return instance;
		} catch (DeltaCloudClientException e) {
			throw e;
		} catch (Exception e) {
			throw new DeltaCloudClientException(e);
		}
	}

	@Override
	public HardwareProfile listProfile(String profileId) throws DeltaCloudClientException {
		try {
			InputStream response = request(new ListHardwareProfileRequest(baseUrl, profileId));
			return new HardwareProfileUnmarshaller().unmarshall(response, new HardwareProfile());
		} catch (DeltaCloudClientException e) {
			throw e;
		} catch (Exception e) {
			throw new DeltaCloudClientException(e);
		}
	}

	@Override
	public List<HardwareProfile> listProfiles() throws DeltaCloudClientException {
		try {
			InputStream response = request(new ListHardwareProfilesRequest(baseUrl));
			List<HardwareProfile> profiles = new ArrayList<HardwareProfile>();
			new HardwareProfilesUnmarshaller().unmarshall(response, profiles);
			return profiles;
		} catch (Exception e) {
			throw new DeltaCloudClientException(MessageFormat.format("could not get realms on cloud at \"{0}\"",
					baseUrl), e);
		}
	}

	@Override
	public List<Image> listImages() throws DeltaCloudClientException {
		InputStream response = request(new ListImagesRequest(baseUrl));
		List<Image> images = new ArrayList<Image>();
		new ImagesUnmarshaller().unmarshall(response, images);
		return images;
	}

	@Override
	public Image listImages(String imageId) throws DeltaCloudClientException {
		InputStream response = request(new ListImageRequest(baseUrl, imageId));
		return new ImageUnmarshaller().unmarshall(response, new Image());
	}

	@Override
	public List<Instance> listInstances() throws DeltaCloudClientException {
		InputStream inputStream = request(new ListInstancesRequest(baseUrl));
		List<Instance> instances = new ArrayList<Instance>();
		new InstancesUnmarshaller().unmarshall(inputStream, instances);
		return instances;
	}

	@Override
	public Instance listInstances(String instanceId) throws DeltaCloudClientException {
		try {
			InputStream response = request(new ListInstanceRequest(baseUrl, instanceId));
			return new InstanceUnmarshaller().unmarshall(response, new Instance());
		} catch (DeltaCloudClientException e) {
			throw e;
		} catch (Exception e) {
			throw new DeltaCloudClientException(e);
		}
	}

	@Override
	public List<Realm> listRealms() throws DeltaCloudClientException {
		try {
			InputStream inputStream = request(new ListRealmsRequest(baseUrl));
			List<Realm> realms = new ArrayList<Realm>();
			new RealmsUnmarshaller().unmarshall(inputStream, realms);
			return realms;
		} catch (Exception e) {
			throw new DeltaCloudClientException(
					MessageFormat.format("could not get realms on cloud at \"{0}\"", baseUrl), e);
		}
	}

	@Override
	public Realm listRealms(String realmId) throws DeltaCloudClientException {
		try {
			InputStream response = request(new ListRealmRequest(baseUrl, realmId));
			return new RealmUnmarshaller().unmarshall(response, new Realm());
		} catch (Exception e) {
			throw new DeltaCloudClientException(
					MessageFormat.format("could not get realms on cloud at \"{0}\"", baseUrl), e);
		}
	}

	public Key createKey(String keyname) throws DeltaCloudClientException {
		try {
			CreateKeyRequest keyRequest = new CreateKeyRequest(baseUrl, keyname);
			InputStream inputStream = request(keyRequest);
			Key key = new KeyUnmarshaller().unmarshall(inputStream, new Key());
			return key;
		} catch (DeltaCloudClientException e) {
			throw e;
		} catch (Exception e) {
			throw new DeltaCloudClientException(e);
		}
	}

	public List<Key> listKeys() throws DeltaCloudClientException {
		InputStream inputStream = request(new ListKeysRequest(baseUrl));
		List<Key> keys = new ArrayList<Key>();
		new KeysUnmarshaller().unmarshall(inputStream, keys);
		return keys;
	}

	public Key listKey(String id) throws DeltaCloudClientException {
		InputStream inputStream = request(new ListKeyRequest(baseUrl, id));
		Key key = new KeyUnmarshaller().unmarshall(inputStream, new Key());
		return key;
	}

	public InputStream performAction(Action<?> action) throws DeltaCloudClientException {
		InputStream in = null;
		if (action != null) {
			try {
				in = request(new PerformActionRequest(action.getUrl(), action.getMethod()));
			} catch (DeltaCloudClientException e) {
				throw e;
			} catch (Exception e) {
				throw new DeltaCloudClientException(e);
			}
		}
		return in;
	}
}
