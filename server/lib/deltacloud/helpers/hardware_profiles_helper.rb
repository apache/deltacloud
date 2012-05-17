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

module HardwareProfilesHelper

  def format_hardware_property(prop)
    return "&empty;" unless prop
    u = hardware_property_unit(prop)
    case prop.kind
      when :range
      "#{prop.first} #{u} - #{prop.last} #{u} (default: #{prop.default} #{u})"
      when :enum
      prop.values.collect{ |v| "#{v} #{u}"}.join(', ') + " (default: #{prop.default} #{u})"
      else
      "#{prop.value} #{u}"
    end
  end

  def format_instance_profile(ip)
    o = ip.overrides.collect do |p, v|
      u = hardware_property_unit(p)
      "#{p} = #{v} #{u}"
    end
    if o.empty?
      nil
    else
      "with #{o.join(", ")}"
    end
  end

  #first by cpu - then by memory
  def order_hardware_profiles(profiles)
   #have to deal with opaque hardware profiles
   uncomparables = profiles.select{|x| x.cpu.nil? or x.memory.nil? }
   if uncomparables.empty?
      profiles.sort_by{|a| [a.cpu.default, a.memory.default] }
   else
      (profiles - uncomparables).sort_by{|a| [a.cpu.default, a.memory.default] } + uncomparables
   end
  end

  private

  def hardware_property_unit(prop)
    u = ::Deltacloud::HardwareProfile::unit(prop)
    u = "" if ["label", "count"].include?(u)
    u = "vcpus" if prop == :cpu
    u
  end
end
