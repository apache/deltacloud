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

module Deltacloud
  class Key < BaseModel

    attr_accessor :credential_type
    attr_accessor :fingerprint
    attr_accessor :username
    attr_accessor :password
    attr_accessor :pem_rsa_key
    attr_accessor :state

    def name
      super || @id
    end

    def is_password?
      @credential_type.eql?(:password)
    end

    def is_key?
      @credential_type.eql?(:key)
    end

    # Mock fingerprint generator
    # 1f:51:ae:28:bf:89:e9:d8:1f:25:5d:37:2d:7d:b8:ca:9f:f5:f1:6f
    def self.generate_mock_fingerprint
      (0..19).map { "%02x" % (rand * 0xff) }.join(':')
    end

    # Mock PEM file
    # NOTE: This is a fake PEM file, it will not work against SSH
    def self.generate_mock_pem
      chars = (('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + %w(= / + ))
      pem_material = (1..21).map do
        (1..75).collect{|a| chars[rand(chars.size)] }.join
      end.join("\n") + "\n" + (1..68).collect{|a| chars[rand(chars.size)] }.join
      "-----BEGIN RSA PRIVATE KEY-----\n"+pem_material+"-----END RSA PRIVATE KEY-----"
    end

    def to_hash(context)
      r = {
        :id => self.id,
        :href => context.key_url(self.id),
        :credential_type => credential_type,
        :username => username,
        :password => password,
        :state => state
      }
      r[:pem_rsa_key] = pem_rsa_key if pem_rsa_key
      r[:fingerprint] = fingerprint if fingerprint
      r[:username] = username if username
      r[:password] = password if password
      r
    end

  end
end
