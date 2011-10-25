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

# Methods added to this helper will be available to all templates in the application.

# this section defines constants used in the implementation.

#this method is to fixup the hash object to make sure it can be serialized into json
#as DMTF spec requires. as the spec keeps changing, this method may need to be revisited
#and modified again.
def fixup_content(hash_obj, key_name="content", attr_name="name")
  #this check is to make sure we are not handling nil values.
  if hash_obj
    hash_obj.each_pair do |key, value|
      if value.kind_of? Hash
        #We can only handle the element without any other attribute,
        #if the element also has other attribute, then we can not do fixups since it will lose information.
        if value[key_name] && value.size == 1
          hash_obj[key] = value[key_name]
        elsif value[key_name] && value[attr_name] && value.size == 2
          hash_obj[key] = { "#{value[attr_name]}" => value[key_name] }
        else
          fixup_content value, key_name, attr_name
        end
      end
    end
  end
end

module ApplicationHelper

  include Deltacloud

  def bread_crumb_ext
    s = "<ul class='breadcrumb'><li class='first'><a href='#{settings.root_url}'>&#948 home</a></li>"
    s+="<li class='docs'>#{link_to_documentation}</li>"
    s+="</ul>"
  end

  def respond_to_collection(collType)
    respond_to do |format|
      format.html do
        root_hash = XmlSimple.xml_in(File.join(STOREROOT, 'collections/' + collType),
                   { 'ForceArray' => false, 'KeepRoot'=>true, 'KeyAttr' => ['name']})

        @xml_root_node = root_hash.first[0]
        @dmtfitem = root_hash.first[1]
        haml :"collection/index"
      end
      format.xml do
        root_hash = XmlSimple.xml_in(File.join(STOREROOT, 'collections/' + collType),
                   { 'ForceArray' => true, 'KeepRoot'=>true, 'KeyAttr' => ['name']})
        col_item_name = root_hash.first[0]
        content_type get_response_content_type(col_item_name, 'xml'), :charset => 'utf-8'
        col_item_name = col_item_name.sub(/Collection/,'') #Remove the Collection at the end.
        col_item_name = col_item_name[0].downcase + col_item_name[1, col_item_name.length]

        urls = []
        @dmtf_col_items.map do |item|
          urls << {"href" => item["href"]}
        end

        root_hash.first[1][0]["#{col_item_name}"] = urls

        XmlSimple.xml_out(root_hash, { 'KeyAttr' => 'name', 'KeepRoot' => true, 'ContentKey' => 'content'})
      end
      format.json do
        root_hash = XmlSimple.xml_in(File.join(STOREROOT, 'collections/' + collType),
                   { 'ForceArray' => false, 'KeepRoot'=>true, 'KeyAttr' => ['name']})
        col_item_name = root_hash.first[0]
        content_type get_response_content_type(col_item_name, 'json'), :charset => 'utf-8'
        #Remove the Collection at the end.
        col_item_name = col_item_name.sub(/Collection/,'')
        col_item_name = col_item_name[0].downcase + col_item_name[1, col_item_name.length]

        urls = []
        @dmtf_col_items.map do |item|
          urls << {"href" => item["href"]}
        end

        root_hash.first[1]["#{col_item_name}"] = urls

        json_hash = root_hash.first[1]
        if json_hash.has_key?("xmlns")
          json_hash.delete "xmlns"
        end
        fixup_content json_hash
        res = json_hash.to_json
      end
    end
  end

  def get_response_content_type(coll_type, format="html")
    case format
    when "text/html"
      ""
    when "xml"
      "application/CIMI-" + coll_type + "+xml"
    when "json"
      "application/CIMI-" + coll_type + "+json"
    end
  end

  def get_resource_default(coll_type)
    file_path = File.join STOREROOT, "default_res/" + coll_type + ".col.xml"
    if File.exist?(file_path)
      root_hash = XmlSimple.xml_in(file_path, {'ForceArray'=>false, 'KeepRoot'=>true, 'KeyAttr'=>['name']})
      { "xml_root_node" => root_hash.first[0], "dmtfitem" => root_hash.first[1]}
    end
  end

  def show_resource(resource_path, content_type, replace_keys = nil)
    respond_to do |format|
      format.xml do
        content_type "application/CIMI-#{content_type}+xml", :charset => 'utf-8'
        haml :"#{resource_path}", :layout => false
      end
      format.html do
        haml :"#{resource_path}"
      end
      format.json do
        content_type "application/CIMI-#{content_type}+json", :charset => 'utf-8'
        engine = Haml::Engine.new(File.read(settings.views + "/#{resource_path}.xml.haml"))
        responseXML = engine.render self
        hash_response = XmlSimple.xml_in responseXML, {'ForceArray' => false, 'KeepRoot'=>true, 'KeyAttr' => ['name']}
        hash_response = hash_response.first[1]
        if hash_response.has_key?("xmlns")
          hash_response.delete "xmlns"
        end
        if replace_keys
          replace_key!(hash_response, replace_keys)
        end
        hash_response.to_json
      end
    end
  end

  def replace_key!(an_object, key_maps = nil)
    if an_object.kind_of?(Hash)
      key_maps.each do |key, value|
        if an_object.key?(key)
          an_object[value] = an_object.delete(key)
        end
      end
      an_object.each do |key, value|
        replace_key!(value, key_maps)
      end
    elsif an_object.kind_of?(Array)
      an_object.each do |value|
        replace_key!(value, key_maps)
      end
    end
  end
end
