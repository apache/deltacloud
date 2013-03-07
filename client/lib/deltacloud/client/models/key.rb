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
  class Key < Base

    # Inherited attributes: :_id, :name, :description

    # Custom attributes:
    #
    attr_reader :state
    attr_reader :username
    attr_reader :password
    attr_reader :public_key
    attr_reader :fingerprint

    # Key model methods
    def pem
      @public_key
    end

    def destroy!
      destroy_key(_id)
    end

    # Parse the Key entity from XML body
    #
    # - xml_body -> Deltacloud API XML representation of the key
    #
    def self.parse(xml_body)
      {
        :state => xml_body.text_at(:state),
        :username => xml_body.text_at(:username),
        :password => xml_body.text_at(:password),
        :fingerprint => xml_body.text_at(:fingerprint),
        :public_key => xml_body.text_at(:pem)
      }
    end
  end
end
