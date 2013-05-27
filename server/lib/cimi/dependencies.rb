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

#this file defines all the required components for dmtf implementation.
#if new dependencies are needed, please make changes to this file.

require 'deltacloud/drivers'
require 'deltacloud/core_ext'
require 'deltacloud/base_driver'
require 'deltacloud/hardware_profile'
require 'deltacloud/state_machine'
require 'deltacloud/helpers'
require 'deltacloud/models/base_model'
require 'deltacloud/models/realm'
require 'deltacloud/models/image'
require 'deltacloud/models/instance'
require 'deltacloud/models/key'
require 'deltacloud/models/address'
require 'deltacloud/models/instance_profile'
require 'deltacloud/models/storage_snapshot'
require 'deltacloud/models/storage_volume'
require 'deltacloud/models/bucket'
require 'deltacloud/models/blob'
require 'deltacloud/models/load_balancer'
require 'deltacloud/models/firewall'
require 'deltacloud/models/firewall_rule'
require 'sinatra/rack_accept'
require 'sinatra/rack_cimi'
require 'sinatra/static_assets'
require 'sinatra/lazy_auth'
require 'deltacloud/helpers/blob_stream'
require 'sinatra/rack_driver_select'
require 'sinatra/rack_runtime'
require 'sinatra/rack_etag'
require 'sinatra/rack_date'
require 'sinatra/rack_matrix_params'
require 'sinatra/rack_syslog'
require 'sinatra/sinatra_verbose'
