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

module CIMI
  module Helper

    def expand?(collection)
      params['$expand'] == '*' ||
        (params['$expand'] || '').split(',').include?(collection.to_s)
    end

    def no_content_with_status(code=200)
      body ''
      status code
    end

    # Set status to 201 and a Location header
    def headers_for_create(resource)
      status 201
      headers 'Location' => resource.id
    end

    def href_id(href, entity)
      split_on = self.send(:"#{entity.to_s}_url")
      href.split("#{split_on}/").last
    end

    def to_kibibyte(value, unit)
      #value may be a string. convert to_f
      value = value.to_f # not to_i because e.g. 0.5 GB
      case unit
      when "GB"
        (value*1024*1024).to_i
      when "MB"
        (value*1024).to_i
      else
        nil # should probably be exploding something here...
      end
    end

    #e.g. convert volume to GB for deltacloud driver
    def from_kibibyte(value, unit="GB")
      case unit
        when "GB" then ((value.to_f)/1024/1024)
        when "MB" then ((value.to_f)/1024)
        else nil
      end
    end

    def grab_content_type(request_content_type, request_body)
      case request_content_type
        when /xml$/i then :xml
        when /json$/i then :json
        else guess_content_type(request_body)
      end
    end

    def guess_content_type(request_body)
      xml = json = false
      body = request_body.read
      request_body.rewind
      begin
        XmlSimple.xml_in(body)
        xml = true
      rescue Exception
        xml = false
      end
      begin
        JSON.parse(body)
        json = true
      rescue Exception
        json = false
      end
      if (json == xml) #both true or both false
        raise CIMI::Model::BadRequest.new("Couldn't guess content type of: #{body}")
      end
      type = (xml)? :xml : :json
    end

  end
end

class Array
  def to_xml_cimi_collection(_self)
    model_name = first.class.xml_tag_name
    XmlSimple.xml_out({
      "xmlns" => "http://schemas.dmtf.org/cimi/1",
      "uri" => [ _self.send(:"#{model_name.underscore.pluralize}_url") ],
      "name" => [ "default" ],
      "created" => [ Time.now.to_s ],
      model_name => map { |model| { 'href' => model.uri } }
    }, :root_name => "#{model_name}Collection")
  end

  def to_json_cimi_collection(_self)
    model_name = first.class.xml_tag_name
    {
      "uri" => _self.send(:"#{model_name.underscore.pluralize}_url"),
      "name" => "default",
      "created" => Time.now.to_s,
      model_name.pluralize.uncapitalize => map { |model| { 'href' => model.uri } }
    }.to_json
  end

end
