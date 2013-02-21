#
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

require_relative './collections/base'

module CIMI

  def self.collection_names
    @collections.map { |c| c.collection_name }
  end

  def self.collections
    @collections ||= []
  end

  module Collections

    def self.collection(name)
      CIMI.collections.find { |c| c.collection_name == name }
    end

    def self.cimi_modules
      @cimi_modules ||= []
    end

    Dir[File.join(File::dirname(__FILE__), "collections", "*.rb")].each do |collection|
      base_collection_name = File.basename(collection).gsub('.rb', '')
      next if base_collection_name == 'base'
      require collection
      cimi_module_class = CIMI::Collections.const_get(base_collection_name.camelize)
      cimi_modules << cimi_module_class
      unless cimi_module_class.collections.nil?
        cimi_module_class.collections.each do |c|
          raise "ERROR: CIMI collection #{c} already registred" if CIMI.collections.include? c
          CIMI.collections << c
        end
      else
        warn "WARNING: File %s placed in collections directory but does not have any collections defined" % base_collection_name
      end
    end

    def self.included(klass)
      klass.class_eval do
        CIMI::Collections.cimi_modules.each { |c| use c }
      end
    end

  end
end
