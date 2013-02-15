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


  def self.database(opts={})
    if ENV['API_VERBOSE']
      if Deltacloud.respond_to? :config
        opts[:logger] = Deltacloud.config[:cimi].logger
      else
        opts[:logger] = ::Logger.new($stdout)
      end
    end
    @db ||=  Sequel.connect(DATABASE_LOCATION, opts)
  end

  def self.initialize_database
    db = database

    db.create_table?(:providers) {
      primary_key :id

      column :driver, :string, { :null => false }
      column :url, :string
      index [ :url, :driver ] if !db.table_exists?(:providers)
    }

    db.create_table?(:entities) {
      primary_key :id

      unless db.table_exists?(:entities)
        foreign_key :provider_id, :providers, { :index => true, :null => false }
      end

      column :created_at, :timestamp

      # Base
      unless db.table_exists?(:entities)
        column :model, :string, { :index => true, :null => false, :default => 'entity' }
      end

      # Map Entity to Deltacloud model
      # (like: Machine => Instance)
      column :be_kind, :string
      column :be_id, :string

      # Entity
      column :name, :string
      column :description, :string
      column :ent_properties, :string, { :text => true }


      column :machine_config, :string
      column :machine_image, :string

      column :network, :string
      column :ip, :string
      column :hostname, :string
      column :allocation, :string
      column :default_gateway, :string
      column :dns, :string
      column :protocol, :string
      column :mask, :string

      column :format, :string
      column :capacity, :string

      column :volume_config, :string
      column :volume_image, :string
    }
  end

end
