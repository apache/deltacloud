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

class CIMI::Service::ResourceMetadata < CIMI::Service::Base

  def self.find(id, context)
    if id == :all
      service_array = []
      SERVICES.each_value do |svc_class|
        service_array << svc_class
      end
     
      service_array.each.map do |svc_class|
        resource_metadata_for(svc_class, context)
      end.reject { |metadata| metadata.none_defined? }
    else
      svc_class = CIMI::Service.const_get("#{id.camelize}")
      resource_metadata_for(svc_class, context)
    end
  end

  def self.resource_metadata_for(svc_class, context)
    cimi_resource = svc_class.name.split("::").last
    self.new(context, :values => {
      :id => context.resource_metadata_url(cimi_resource.underscore),
      :name => cimi_resource,
      :type_uri => svc_class.model_class.resource_uri,
      :attributes => svc_class.resource_attributes(context),
      :capabilities => svc_class.resource_capabilities(context),
      :actions => []
    })
  end

  def none_defined?
    capabilities.empty? && attributes.empty?
  end
end
