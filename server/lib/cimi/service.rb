# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless require_relatived by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.
#

module CIMI::Service; end

require_relative './models'
require_relative './../db/provider'
require_relative './../db/entity'
require_relative './../db/machine_template'
require_relative './../db/address_template'
require_relative './../db/volume_configuration'
require_relative './../db/volume_template'

require_relative './service/base'
require_relative './service/machine'
