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

class CIMI::Service::MachineVolume < CIMI::Service::Base

  def self.find(instance_id, context, id=:all)
    if id == :all
      volumes = context.driver.storage_volumes(context.credentials)
      volumes.inject([]) do |attached, vol|
        id = context.machine_url(instance_id)+"/volumes/#{vol.id}"
        attached <<  self.new(context, :values => {
          :id => id,
          :name => vol.id,
          :description => "MachineVolume #{vol.id} for Machine #{instance_id}",
          :created => vol.created.nil? ? nil : Time.parse(vol.created).xmlschema,
          :initial_location => vol.device,
          :volume => {:href=>context.volume_url(vol.id)},
          :operations => [{:href=>id, :rel => "delete" }]
        }) if vol.instance_id == instance_id
        attached
      end
    else
      vol = context.driver.storage_volume(context.credentials, {:id=>id})
      id = context.machine_url(instance_id)+"/volumes/#{vol.id}"
      raise CIMI::Model::NotFound unless vol.instance_id == instance_id
      self.new(context, :values => {
        :id => id,
        :name => vol.id,
        :description => "MachineVolume #{vol.id} for Machine #{instance_id}",
        :created => vol.created.nil? ? nil : Time.parse(vol.created).xmlschema,
        :initial_location => vol.device,
        :volume => {:href=>context.volume_url(vol.id)},
        :operations => [{:href=>id, :rel => "delete" }]
      })
    end
  end

  def self.find_to_attach_from_xml(xml_in, context)
    xml = XmlSimple.xml_in(xml_in)
    vol_id = xml["volume"].first["href"].split("/").last
    location = xml["initialLocation"].first.strip
    [vol_id, location]
  end

  def self.find_to_attach_from_json(json_in, context)
    json = JSON.parse(json_in)
    vol_id = json["volume"]["href"].split("/").last
    location = json["initialLocation"]
    [vol_id, location]
  end


  def self.collection_for_instance(instance_id, context)
    machine_volumes = self.find(instance_id, context)
    volumes_url = context.url("/machines/#{instance_id}/volumes")
    # FIXME: Really ???
    attach_url = volumes_url.singularize+"_attach"
    CIMI::Model::MachineVolume.list(volumes_url, machine_volumes, :add_url => attach_url)
  end


end
