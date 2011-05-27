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
import java.util.List;

import org.apache.deltacloud.client.API.Driver;

/**
 * @author Martyn Taylor
 * @author Andre Dietisheim
 */
public interface DeltaCloudClient {

	/**
	 * Returns the server type this client is connected to.
	 * 
	 * @return the server type
	 * 
	 * @see DeltaCloudServerType
	 */
	public Driver getServerType();

	/**
	 * Returns a list of Delta Cloud Realms
	 * 
	 * @return List of Delta Cloud Realms
	 * @throws DeltaCloudClientException
	 */
	public List<Realm> listRealms() throws DeltaCloudClientException;

	/**
	 * Returns a single Delta Cloud Realm given its ID
	 * 
	 * @param realmId
	 * @return Delta Cloud Realm
	 * @throws DeltaCloudClientException
	 */
	public Realm listRealms(String realmId) throws DeltaCloudClientException;

	public List<HardwareProfile> listProfiles() throws DeltaCloudClientException;

	/**
	 * Returns a Delta Cloud Flavors
	 * 
	 * @param flavorId
	 * @return Delta Cloud Flavor
	 * @throws DeltaCloudClientException
	 */
	public HardwareProfile listProfile(String profileId) throws DeltaCloudClientException;

	/**
	 * Returns a List of Delta Cloud Images
	 * 
	 * @return List of Delta Cloud Images
	 * @throws DeltaCloudClientException
	 */
	public List<Image> listImages() throws DeltaCloudClientException;

	/**
	 * Returns a Delta Cloud Image given its ID
	 * 
	 * @param imageId
	 * @return
	 * @throws DeltaCloudClientException
	 */
	public Image listImages(String imageId) throws DeltaCloudClientException;

	/**
	 * Returns a list of all Instances from the Delta Cloud Provider
	 * 
	 * @return
	 * @throws DeltaCloudClientException
	 */
	public List<Instance> listInstances() throws DeltaCloudClientException;

	/**
	 * Returns an Instance from the Delta Cloud Provider given on the Instances
	 * ID
	 * 
	 * @param instanceId
	 * @return
	 * @throws DeltaCloudClientException
	 */
	public Instance listInstances(String instanceId) throws DeltaCloudClientException;

	/**
	 * Creates a new Delta Cloud Instance based on the Image specified by the
	 * Image ID. Default parameters are used for the Flavor, Realm and Name.
	 * These are specified by the Delta Cloud Provider
	 * 
	 * @param imageId
	 * @return The newly created Delta Cloud Instance
	 * @throws DeltaCloudClientException
	 */
	public Instance createInstance(String imageId) throws DeltaCloudClientException;

	/**
	 * Creates a new Delta Cloud Instance, the instance will be based on the
	 * Image specified by the instance ID. It will be of type flavor and in the
	 * location realm
	 * 
	 * @param imageId
	 * @param flavor
	 * @param realm
	 * @param name
	 * @return
	 * @throws DeltaCloudClientException
	 */
	public Instance createInstance(String name, String imageId, String profileId, String realmId, String memory, String storage)
			throws DeltaCloudClientException;

	public Instance createInstance(String name, String imageId, String profileId, String realmId, String keyname, String memory,
			String storage) throws DeltaCloudClientException;

	/**
	 * Creates a key for a given name on the deltacloud server.
	 * 
	 * @param keyname
	 *            the name of the key to retrieve from the server
	 * @param keyStoreLocation
	 *            the path to the file to store the key in
	 * @throws DeltaCloudClientException
	 *             the delta cloud client exception
	 */
	public Key createKey(String keyname) throws DeltaCloudClientException;

	/**
	 * Lists all keys available on the deltacloud server this client is
	 * connected to.
	 * 
	 * @return the keys that are available
	 * @throws DeltaCloudClientException
	 * 
	 */
	public List<Key> listKeys() throws DeltaCloudClientException;

	/**
	 * Returns a key with the given name if it is available on the server.
	 * Throws a DeltaCloudException if it is not available.
	 */
	public Key listKey(String id) throws DeltaCloudClientException;
	
	/**
	 * Performs the given action.
	 *
	 * @param action the action to execute
	 * @return true, if successful
	 * @throws DeltaCloudClientException the delta cloud client exception
	 * @see Action
	 */
	public InputStream performAction(Action<?> action) throws DeltaCloudClientException;
}
