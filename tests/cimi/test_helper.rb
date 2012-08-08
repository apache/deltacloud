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

require 'rubygems'
require 'require_relative'
require_relative '../helpers/common.rb'

require 'singleton'

# Add CIMI specific config stuff
module CIMI
  module Test
    class Config

      include Singleton

      def initialize
        @hash = Deltacloud::Test::yaml_config
        @cimi = @hash["cimi"]
      end

      def cep_url
        @cimi["cep"]
      end

      def collections
        xml.xpath("/c:CloudEntryPoint/c:*[@href]", ns).map { |c| c.name }
      end

      def features
        {}
      end

      def ns
        { "c" => "http://www.dmtf.org/cimi" }
      end

      private
      def xml
        unless @xml
          @xml = RestClient.get(cep_url, "Accept" => "application/xml").xml
        end
        @xml
      end
    end

    def self.config
      Config::instance
    end
  end
end

module CIMI::Test::Methods

  module Global
    def api
      CIMI::Test::config
    end

    def cep(params = {})
      get(api.cep_url, params)
    end

    def get(path, params = {})
      RestClient.get path, headers(params)
    end

    private
    def headers(params)
      headers = {}
      if params[:accept]
        headers["Accept"] = "application/#{params.delete(:accept)}" if params[:accept]
      else #default to xml
        headers["Accept"] = "application/xml"
      end
      headers
    end
  end

  module ClassMethods
    def need_collection(name)
      before :each do
        unless api.collections.include?(name.to_sym)
          skip "Server at #{api.cep_url} doesn't support #{name}"
        end
      end
    end
  end

  def self.included(base)
    base.extend ClassMethods
    base.extend Global
    base.send(:include, Global)
  end
end
