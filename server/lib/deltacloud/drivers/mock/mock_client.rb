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

# The mock client does a bunch of filesystem judo. It's mostly there to
# keep the driver from looking too ugly with all the File I/O

module Deltacloud::Drivers::Mock

  class Client
    def initialize(storage_root)
      @storage_root = storage_root
      @collections = []

      if ! File::directory?(@storage_root)
        FileUtils::rm_rf(@storage_root)
        FileUtils::mkdir_p(@storage_root)
        data = Dir[File::join(File::dirname(__FILE__), "data", "*")]
        FileUtils::cp_r(data, @storage_root)
      end
    end

    def dir(collection)
      result = File::join(@storage_root, collection.to_s)
      unless @collections.include?(collection)
        FileUtils::mkdir_p(result) unless File::directory?(result)
        @collections << collection
      end
      result
    end

    def file(collection, id)
      File::join(dir(collection), "#{id}.yml")
    end

    def files(collection)
      Dir[File::join(dir(collection), "*.yml")]
    end

    # Return the ID's of all members of +collection+
    def members(collection)
      files(collection).map { |f| File::basename(f, ".yml") }
    end

    def load(collection, id)
      fname = file(collection, id)
      begin
        YAML.load(File.read(fname))
      rescue Errno::ENOENT
        nil
      end
    end

    def store(collection, obj)
      raise "Why no obj[:id] ?" unless obj[:id]
      File::open(file(collection, obj[:id]), "w") { |f| YAML.dump(obj, f) }
    end

    # Return the object with id +id+ of class +klass+ from the collection
    # derived from the classes name
    def build(klass, id)
      klass.new(load(collection_name(klass), id))
    end

    # Return an array of hashes of all the resources in the collection
    def load_all(collection)
      members(collection).map { |id| load(collection, id) }
    end

    # Return an array of model objects of the resources in the collection
    # corresponding to class. The name of the collection is derived from
    # the name of the class
    def build_all(klass)
      load_all(collection_name(klass)).map { |hash| klass.new(hash) }
    end

    def destroy(collection, id)
      fname = file(collection, id)
      FileUtils.rm(fname) if File::exists?(fname)
    end

    private

    def collection_name(klass)
      klass.name.underscore.pluralize
    end
  end

end
