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

  def unknown?
    true if self.entity == :unknown
  end

  def add_property(name, values=nil)
    self.properties ||= []
    return self if self.properties.any? { |p| p.name == name }
    self.properties << Property.new(name, values)
    self
  end

  class Property
    attr_accessor :name, :values

    def initialize(name, values=nil)
      @name, @values = name, values
    end
  end

end
