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
  class Address < Base
    include Deltacloud::Client::Methods::Address

    # Inherited attributes: :_id, :name, :description

    # Custom attributes:
    #
    attr_reader :ip
    attr_reader :instance_id

    # Address model methods
    #

    # Associate the IP address to the +Instance+
    #
    def associate(instance_id)
      associate_address(_id, instance_id)
    end

    # Disassociate the IP address from +Instance+
    #
    def disassociate
      disassociate_address(_id)
    end

    def destroy!
      destroy_address(_id)
    end

    # Parse the Address entity from XML body
    #
    # - xml_body -> Deltacloud API XML representation of the address
    #
    def self.parse(xml_body)
      {
        :ip => xml_body.text_at(:ip),
        :instance_id => xml_body.attr_at('instance', :id)
      }
    end
  end
end
