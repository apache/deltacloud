#
# Copyright (C) 2010  Red Hat, Inc.
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

module DeltaCloud
  class Documentation

    attr_reader :api, :description, :params, :collection_operations
    attr_reader :collection, :operation

    def initialize(api, opts={})
      @description, @api = opts[:description], api
      @params = parse_parameters(opts[:params]) if opts[:params]
      @collection_operations = opts[:operations] if opts[:operations]
      @collection = opts[:collection]
      @operation = opts[:operation]
      self
    end

    def operations
      @collection_operations.collect { |o| api.documentation(@collection, o) }
    end

    class OperationParameter
      attr_reader :name
      attr_reader :type
      attr_reader :required
      attr_reader :description

      def initialize(data)
        @name, @type, @required, @description = data[:name], data[:type], data[:required], data[:description]
      end

      def to_comment
        "   # @param [#{@type}, #{@name}] #{@description}"
      end

    end

    private

    def parse_parameters(params)
      params.collect { |p| OperationParameter.new(p) }
    end

  end

end
