# Copyright (C) 2009, 2010  Red Hat, Inc.
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

# FIXME: This should be moved into lib/ and be called Deltacloud::Drivers
# or some such
module Deltacloud
  DRIVERS = {
    :ec2 => { :name => "EC2" },
	:sbc => { :name => "SBC" },
    :rackspace => { :name => "Rackspace" },
    :gogrid => { :name => "Gogrid" },
    :rhevm => { :name => "RHEVM" },
    :rimuhosting => { :name => "RimuHosting"},
    :opennebula => { :name => "Opennebula", :class => "OpennebulaDriver" },
    :terremark => { :name => "Terremark"},
    :azure => { :name => "Azure" },
    :mock => { :name => "Mock" }
  }

  DEFAULT_COLLECTIONS = [
    :hardware_profiles,
    :images,
    :instances,
    :instance_states,
    :realms,
    :storage_volumes,
    :storage_snapshots
  ]

  DRIVER=ENV['API_DRIVER'] ? ENV['API_DRIVER'].to_sym : :mock

  def driver_symbol
    (Thread.current[:driver] || DRIVER).to_sym
  end

  def driver_name
    DRIVERS[:"#{driver_symbol}"][:name]
  end

  def driver_class
    basename = DRIVERS[:"#{driver_symbol}"][:class] || "#{driver_name}Driver"
    Deltacloud::Drivers.const_get(driver_name).const_get(basename)
  end

  def driver_source_name
    File.join("deltacloud", "drivers", "#{driver_symbol}", "#{driver_symbol}_driver.rb")
  end

  def driver_mock_source_name
    return File.join('deltacloud', 'drivers', "#{driver_symbol}",
                     "#{driver_symbol}_driver.rb") if driver_name.eql? 'Mock'
  end

  def driver
    require driver_source_name

    @driver ||= driver_class.new
  end
end
