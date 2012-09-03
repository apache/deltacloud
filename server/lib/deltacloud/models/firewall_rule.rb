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

class FirewallRule < BaseModel
  attr_accessor :allow_protocol # tcp/udp/icmp
  attr_accessor :port_from
  attr_accessor :port_to
  attr_accessor :sources
  attr_accessor :direction #ingress egress
  attr_accessor :rule_action #Accept/Deny - initially added for FGCP
  attr_accessor :log_rule #log when rule triggered true/false - added for FGCP
end
