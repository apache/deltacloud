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

class CIMI::Service::Volume < CIMI::Service::Base

  def self.find(id, context)
    creds = context.credentials
    if id == :all
      volumes = context.driver.storage_volumes(creds)
      volumes.collect{ |volume| from_storage_volume(volume, context) }
    else
      volume = context.driver.storage_volumes(creds, :id => id).first
      raise CIMI::Model::NotFound unless volume
      from_storage_volume(volume, context)
    end
  end

  def self.all(context); find(:all, context); end

  def self.delete!(id, context)
    context.driver.destroy_storage_volume(context.credentials, {:id=>id} )
    new(context, :values => { :id => id }).destroy
  end

  def self.find_to_attach_from_json(json_in, context)
    json = JSON.parse(json_in)
    json["volumes"].map{|v| {:volume=>self.find(v["volume"]["href"].split("/volumes/").last, context),
                             :initial_location=>v["initialLocation"]  }}
  end

  def self.find_to_attach_from_xml(xml_in, context)
    xml = XmlSimple.xml_in(xml_in)
    xml["volume"].map{|v| {:volume => self.find(v["href"].split("/volumes/").last, context),
                           :initial_location=>v["initialLocation"] }}
  end

  def self.from_storage_volume(volume, context)
    self.new(context, :values => {
      :name => volume.name || volume.id,
      :created => volume.created.nil? ? nil : Time.parse(volume.created).xmlschema,
      :id => context.volume_url(volume.id),
      :capacity => context.to_kibibyte(volume.capacity, 'GB'),
      :bootable => "false", #fixme ... will vary... ec2 doesn't expose this
      :snapshots => [], #fixme...
      :type => 'http://schemas.dmtf.org/cimi/1/mapped',
      :state => volume.state == 'IN-USE' ? 'AVAILABLE' : volume.state,
      :meters => [],
      :operations => [{:href=> context.volume_url(volume.id), :rel => "delete"}]
    })
  end

  def self.collection_for_instance(instance_id, context)
    instance = context.driver.instance(context.credentials, :id => instance_id)
    volumes = instance.storage_volumes.map do |mappings|
      mappings.keys.map do |volume_id|
        from_storage_volume(context.driver.storage_volume(context.credentials, :id => volume_id), context)
      end
    end.flatten
    CIMI::Service::VolumeCollection.new(context, :values => {
      :id => context.url("/machines/#{instance_id}/volumes"),
      :name => 'default',
      :count => volumes.size,
      :description => "Volume collection for Machine #{instance_id}",
      :entries => volumes
    })
  end


end
