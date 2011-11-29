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

class CIMI::Model::Volume < CIMI::Model::Base
  struct :capacity do
    scalar :quantity
    scalar :units
  end
  text :bootable
  text :supports_snapshots
  array :snapshots do
    scalar :ref
  end
  text :guest_interface
  array :meters do
    scalar :ref
  end
  href :eventlog
  array :operations do
    scalar :rel, :href
  end

  def self.find(id, context)
    volumes = []
    opts = ( id == :all ) ? {} : { :id => id }
    volumes = self.driver.storage_volumes(context.credentials, opts)
    volumes.collect!{ |volume| from_storage_volume(volume, context) }
    return volumes.first unless volumes.length > 1
    return volumes
  end

  def self.all(context); find(:all, context); end

  def self.create(params, context)
    volume_config = VolumeConfiguration.find(params[:volume_config_id], context)
    opts = {:capacity=>volume_config.capacity[:quantity], :snapshot_id=>params[:volume_image_id] }
    storage_volume = self.driver.create_storage_volume(context.credentials, opts)
    from_storage_volume(storage_volume, context)
  end

  private

  def self.from_storage_volume(volume, context)
    self.new( { :name => volume.id,
                :description => volume.id,
                :created => volume.created,
                :uri => context.volume_url(volume.id),
                :capacity => { :quantity=>volume.capacity, :units=>"gibibyte"  }, #FIXME... units will vary
                :bootable => "false", #fixme ... will vary... ec2 doesn't expose this
                :supports_snapshots => "true", #fixme, will vary (true for ec2)
                :snapshots => [], #fixme...
                :guest_interface => "",
                :eventlog => {:href=> "http://eventlogs"},#FIXME
                :meters => []
            } )
  end

end
