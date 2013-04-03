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

module Deltacloud::Client
  class InstanceAddress

    attr_reader :type, :value

    def initialize(type, value)
      @type = type
      @value = value
    end

    def [](attr)
      instance_variable_get("@#{attr}")
    end

    def to_s
      @value
    end

    def self.convert(address_xml_block)
      address_xml_block.map do |addr|
        new(addr['type'].to_sym, addr.text)
      end
    end
  end
end
