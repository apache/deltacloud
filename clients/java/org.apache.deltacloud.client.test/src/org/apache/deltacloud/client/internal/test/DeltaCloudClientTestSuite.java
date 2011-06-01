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
package org.apache.deltacloud.client.internal.test;

import org.apache.deltacloud.client.internal.test.client.APIDomUnmarshallingTest;
import org.apache.deltacloud.client.internal.test.client.HardwareProfileDomUnmarshallingTest;
import org.apache.deltacloud.client.internal.test.client.ImageDomUnmarshallingTest;
import org.apache.deltacloud.client.internal.test.client.InstanceDomUnmarshallingTest;
import org.apache.deltacloud.client.internal.test.client.KeyDomUnmarshallingTest;
import org.apache.deltacloud.client.internal.test.client.RealmDomUnmarshallingTest;
import org.apache.deltacloud.client.internal.test.utils.UrlBuilderTest;
import org.junit.runner.RunWith;
import org.junit.runners.Suite;

/**
 * @author Andre Dietisheim
 */
@RunWith(Suite.class)
@Suite.SuiteClasses({
	KeyDomUnmarshallingTest.class,
	InstanceDomUnmarshallingTest.class,
	ImageDomUnmarshallingTest.class,
	HardwareProfileDomUnmarshallingTest.class,
	APIDomUnmarshallingTest.class,
	RealmDomUnmarshallingTest.class,
	UrlBuilderTest.class})
public class DeltaCloudClientTestSuite {
}
