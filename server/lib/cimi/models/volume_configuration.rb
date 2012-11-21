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

class CIMI::Model::VolumeConfiguration < CIMI::Model::Base

  acts_as_root_entity :as => "volumeConfigs"

  text :format

  text :capacity

  array :operations do
    scalar :rel, :href
  end

  def self.find(id, context)
    volume_configs = []
    if id == :all
      #ec2 ebs volumes can 1gb..1tb
      (1..1000).each do |size|
        volume_configs << create(size, context)
      end
    else
      volume_configs << create(id, context)
      return volume_configs.first
    end
    return volume_configs
  end


  def self.all(context); find(:all, context); end

  private

  def self.create(size, context)
    size_kib = context.to_kibibyte(size, "GB")
    self.new( {
                :id => context.volume_configuration_url(size),
                :name => "volume-#{size}",
                :description => "Volume configuration with #{size_kib} kibibytes",
                :created => Time.now.xmlschema,
                :capacity => size_kib,
                :supports_snapshots => "true"
                # FIXME :guest_interface => "NFS"
            } )
  end

end
