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

class CIMI::Model::MachineImage < CIMI::Model::Base

  acts_as_root_entity

  text :state
  text :type
  text :image_location
  href :related_image

  array :operations do
    scalar :rel, :href
  end

  def self.find(id, context)
    images = []
    if id == :all
      images = context.driver.images(context.credentials)
      images.map { |image| from_image(image, context) }
    else
      image = context.driver.image(context.credentials, :id => id)
      from_image(image, context)
    end
  end

  def self.from_image(image, context)
    stored_attributes = load_attributes_for(image)
    self.new(
      :id => context.machine_image_url(image.id),
      :name => stored_attributes[:name] || image.id,
      :description => stored_attributes[:description] || image.description,
      :state => image.state || 'UNKNOWN',
      :type => "IMAGE",
      :created => image.creation_time.nil? ? Time.now.xmlschema : Time.parse(image.creation_time.to_s).xmlschema,
      :image_location => (stored_attributes[:property] && stored_attributes[:property]['image_location']) ?
        stored_attributes[:property].delete('image_location') : 'unknown',
      :property => stored_attributes[:property]
    )
  end

  def self.create(request_body, context)
    # The 'imageLocation' attribute is mandatory in CIMI, however in Deltacloud
    # there is no way how to figure out from what Machine the MachineImage was
    # created from. For that we need to store this attribute in properties.
    #
    if context.grab_content_type(context.request.content_type, request_body) == :xml
      input = XmlSimple.xml_in(request_body.read, {"ForceArray"=>false,"NormaliseSpace"=>2})
      raise 'imageLocation attribute is mandatory' unless input['imageLocation']
      input['property'] ||= {}
      input['property'].kind_of?(Array) ?
        input['property'] << { 'image_location' => input['imageLocation'] } : input['property'].merge!('image_location' => input['imageLocation'])
    else
      input = JSON.parse(request_body.read)
      raise 'imageLocation attribute is mandatory' unless input['imageLocation']
      input['properties'] ||= []
      input['properties'] << { 'image_location' => input['imageLocation'] }
    end
    params = {:id => context.href_id(input["imageLocation"], :machines), :name=>input["name"], :description=>input["description"]}
    image = context.driver.create_image(context.credentials, params)
    store_attributes_for(image, input)
    from_image(image, context)
  end

  def self.delete!(image_id, context)
    context.driver.destroy_image(context.credentials, image_id)
    delete_attributes_for(::Image.new(:id => image_id))
  end

end
