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

module Deltacloud

  # Collection methods that every frontend need to provide.
  #
  module CollectionMethods

    # Return all collections provided by the current frontend
    #
    def collections
      module_klass::Collections.collections
    end

    # Return all collection names provided by the current frontend
    #
    def collection_names
      module_klass::Collections.collection_names
    end

    # Simple check if the collection is available in the current frontend
    #
    def collection_exists?(c)
      collections.include? c
    end

    private

    def module_klass
      @klass ||= self
    end

  end

  extend CollectionMethods

  module CollectionHelper

    def collection_names
      collections.map { |c| c.collection_name }
    end

    def collections
      @collections ||= []
    end

    def collection(name)
      collections.find { |c| c.collection_name == name }
    end


    def modules(frontend)
      case frontend
        when :cimi then @cimi_modules ||= []
        when :deltacloud then @deltacloud_modules ||= []
      end
    end

    # This method will load all collections from given directory.
    #
    # Syntax:
    #
    # load_collections_for :cimi, :from => DIRECTORY
    #
    def load_collections_for(frontend, opts={})
      frontend_module = (frontend == :cimi) ? CIMI : Deltacloud
      Dir[File.join(opts[:from], '*.rb')].each do |collection|
        base_collection_name = File.basename(collection).gsub('.rb', '')
        next if base_collection_name == 'base'
        require collection
        collection_module_class = frontend_module::Collections.const_get(
          base_collection_name.camelize
        )
        modules(frontend) << collection_module_class
        if collection_module_class.collections.nil?
          warn "WARNING: #{collection_module_class} does not include any collections"
        else
          collection_module_class.collections.each do |c|
            if frontend_module.collection_exists?(c)
              raise "ERROR: Collection already registred #{c}"
            end
            frontend_module.collections << c
          end
        end
      end
    end

  end
end

module CIMI
  extend Deltacloud::CollectionMethods
end
