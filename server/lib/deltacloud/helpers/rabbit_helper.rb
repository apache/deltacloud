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


Sinatra::Rabbit::Collection.class_eval do

  def self.standard_index_operation(opts={})
    collection_name = @collection_name
    operation :index, :with_capability => opts[:capability] || collection_name do
      control { filter_all collection_name }
    end
  end

  def self.standard_show_operation(opts={})
    collection_name = @collection_name
    operation :show, :with_capability => opts[:capability] || collection_name do
      control { show collection_name.to_s.singularize.intern }
    end
  end

end

module Sinatra::Rabbit

  module URLHelper
    def url_for(path); url(path); end
    def root_url; settings.root_url; end
    def base_uri; url_for('/').gsub(/\/$/,''); end
  end

  def self.URLFor(collections)
    collections.each do |c|
      c.operations.each do |operation|
        URLHelper.instance_eval(&generate_url_helper_for(c, operation)[0])
      end
    end
    URLHelper
  end

  def self.generate_url_helper_for(collection, operation)
    operation_name = operation.operation_name.to_s
    collection_name = collection.collection_name.to_s

    # Construct OPERATION_COLLECTION_URL helper
    # The :index and :create operation does not get any prefix
    #
    helper_method_name = case operation_name
                         when 'index' then collection_name
                         when 'show' then collection_name.singularize
                         else operation_name + '_' + collection_name.singularize
                         end

    helper_method_name += '_url'
    [Proc.new do
      define_method helper_method_name do |*args|
        if (opts = args.first).kind_of? Hash
          path = operation.full_path.convert_query_params(opts)
        elsif !args.empty? and (obj_id = args.first)
          path = operation.full_path.convert_query_params(:id => obj_id)
        else
          path = operation.full_path
        end
        path.slice!(root_url)
        url(path)
      end unless respond_to?(helper_method_name)
    end, helper_method_name]
  end

end
