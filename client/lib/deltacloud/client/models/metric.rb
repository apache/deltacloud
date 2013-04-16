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
  class Metric < Base

    include Deltacloud::Client::Methods::Metric

    # Inherited attributes: :_id, :name, :description

    attr_reader :entity
    attr_reader :properties

    class Property

      attr_reader :name, :samples

      def initialize(name, samples=[])
        @name = name
        samples.each { |s| self << s }
      end

      def <<(values)
        @samples ||= []
        @samples << Sample.new(values)
      end

      class Sample
        attr_reader :values

        def initialize(values)
          @values = values || []
        end

      end

    end

    # Metric model methods
    #
    # def reboot!
    #   metric_reboot(_id)
    # end

    # Parse the Metric entity from XML body
    #
    # - xml_body -> Deltacloud API XML representation of the metric
    #
    def self.parse(xml_body)
      {
        :entity => xml_body.text_at(:entity),
        :properties => xml_body.xpath('properties/*').map { |p|
          Property.new(p.name, p.xpath('sample').map { |s|
            s.xpath('property').map { |v| [v['name'], v['value']] }
          })
        }
      }
    end
  end
end
