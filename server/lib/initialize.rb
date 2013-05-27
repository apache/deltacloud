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

# Deltacloud server initialization scripts:

require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'
require_relative './deltacloud/core_ext'

# Initialize dependencies
require_relative './initializers/dependencies_initialize'

# Initialize storage for mock and CIMI database
require_relative './initializers/mock_initialize'

# Configure available frontends
require_relative './initializers/frontend_initialize'

require_relative './initializers/drivers_initialize'

if Deltacloud::need_database?
  require_relative './initializers/database_initialize'
end
