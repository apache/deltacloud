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

class Metric < BaseModel

  attr_accessor :entity
  attr_accessor :properties

  MOCK_METRICS_NAMES = [
    'cpuUtilization',
    'diskReadRequestCount',
    'diskReadSector',
    'diskWriteRequestCount',
    'diskWriteSector',
    'nicInputByte',
    'nicInputPacket',
    'nicOutputByte',
    'nicOutputPacket'
  ]

  def unknown?
    self.entity == :unknown
  end

  def add_property(name, values=nil)
    self.properties ||= []
    return self if self.properties.any? { |p| p.name == name }
    self.properties << Property.new(name, values)
    self
  end

  def to_hash(context)
    {
      :id => self.id,
      :href => context.metric_url(self.id),
      :entity => entity,
      :properties => properties.map { |p| p.to_hash(context) }
    }
  end

  class Property
    attr_accessor :name, :values

    def initialize(name, values=nil)
      @name, @values = name, values
    end

    def to_hash(context)
      {
        :name => name,
        :values => values
      }
    end

    def generate_mock_values!
      generator = lambda { |name, kind|
        v = {
          :min => (1+(rand(49))),
          :max => (50+(rand(50)))
        }
        (name == 'cpuUtilization') ? v[kind].to_f/100 : v[kind]
      }
      @values = (0..5).map do |v_id|
        {
          :minimum => min = generator.call(@name, :min),
          :maximum => max = generator.call(@name, :max),
          :average => (min+max)/2,
          :timestamp => (Time.now-v_id).to_i,
          :unit => unit_for(@name)
        }
      end
    end

    private

    def unit_for(name)
      case name
        when /Utilization/ then 'Percent'
        when /Byte/ then 'Bytes'
        when /Sector/ then 'Count'
        when /Count/ then 'Count'
        when /Packet/ then 'Count'
        else 'None'
      end
    end

  end

end
