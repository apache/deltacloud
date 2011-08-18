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

  module HWP

   class Property
      attr_reader :name, :unit, :value, :kind

      def initialize(xml, name)
        @name, @kind, @value, @unit = xml['name'], xml['kind'].to_sym, xml['value'], xml['unit']
        declare_ranges(xml)
        self
      end

      def present?
        ! @value.nil?
      end

      private

      def declare_ranges(xml)
        case xml['kind']
          when 'range' then
            self.class.instance_eval do
              attr_reader :range
            end
            @range = { :from => xml.xpath('range').first['first'], :to => xml.xpath('range').first['last'] }
          when 'enum' then
            self.class.instance_eval do
              attr_reader :options
            end
            @options = xml.xpath('enum/entry').collect { |e| e['value'] }
        end
      end

    end

    # FloatProperty is like Property but return value is Float instead of String.
    class FloatProperty < Property
      def initialize(xml, name)
        super(xml, name)
        @value = @value.to_f if @value
      end
    end
  end

end
