#
# Copyright (C) 2009  Red Hat, Inc.
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

$DELIM_BEGIN="<_OUTPUT>"
$DELIM_END="</_OUTPUT>"
$VM_PROPERTY_LIST="VmId", "Name", "Description", "TemplateId", "Domain", "Status", "OperatingSystem"
function beginOutput {
    echo $DELIM_BEGIN
}

function endOutput {
    echo $DELIM_END
}

function verifyLogin {
    param($username, $password, $domain)
    Login-User $username $password $domain
}
