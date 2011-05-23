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
package org.jboss.tools.internal.deltacloud.client.test;

import org.jboss.tools.internal.deltacloud.client.test.client.ImageMockIntegrationTest;
import org.jboss.tools.internal.deltacloud.client.test.client.InstanceMockIntegrationTest;
import org.jboss.tools.internal.deltacloud.client.test.client.KeyMockIntegrationTest;
import org.jboss.tools.internal.deltacloud.client.test.client.ProfileMockIntegrationTest;
import org.jboss.tools.internal.deltacloud.client.test.client.RealmMockIntegrationTest;
import org.jboss.tools.internal.deltacloud.client.test.client.ServerTypeMockIntegrationTest;
import org.junit.runner.RunWith;
import org.junit.runners.Suite;

/**
 * @author Andre Dietisheim
 */
@RunWith(Suite.class)
@Suite.SuiteClasses({
	ImageMockIntegrationTest.class,
	InstanceMockIntegrationTest.class,
	KeyMockIntegrationTest.class,
	ServerTypeMockIntegrationTest.class,
	RealmMockIntegrationTest.class,
	ProfileMockIntegrationTest.class
})
public class DeltaCloudClientIntegrationTestSuite {
}
