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

module CIMIHelper

  def no_content_with_status(code=200)
    body ''
    status code
  end


  def href_id(href, entity)
    split_on = self.send(:"#{entity.to_s}_url")
    href.split("#{split_on}/").last
  end

end

class Array
  def to_xml_cimi_collection(_self)
    model_name = first.class.xml_tag_name
    XmlSimple.xml_out({
      "xmlns" => "http://www.dmtf.org/cimi",
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

