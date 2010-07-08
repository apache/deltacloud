#
# Copyright (C) 2009  Red Hat, Inc.
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

# Model to store the hardware profile applied to an instance together with
# any instance-specific overrides
class InstanceProfile < BaseModel
  attr_accessor :memory
  attr_accessor :storage
  attr_accessor :architecture
  attr_accessor :cpu

  def initialize(hwp_name, args = {})
    opts = args.inject({ :id => hwp_name.to_s }) do |m, e|
      k, v = e
      m[$1] = v if k.to_s =~ /^hwp_(.*)$/
      m
    end
    super(opts)
  end

  def name
    id
  end

  def overrides
    [:memory, :storage, :architecture, :cpu].inject({}) do |h, p|
      if v = instance_variable_get("@#{p}")
        h[p] = v
      end
      h
    end
  end
end
