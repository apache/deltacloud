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

module DeltaCloud
  module PlainFormatter
    module FormatObject

      class Base
        def initialize(obj)
          @obj = obj
        end
      end

      class Image < Base
        def format
          sprintf("%-10s | %-20s | %-6s | %-20s | %15s",
              @obj.id[0,10],
              @obj.name ? @obj.name[0, 20]: 'unknown',
              @obj.architecture[0,6],
              @obj.description[0,20],
              @obj.owner_id[0,15]
          )
        end
      end

      class Realm < Base
        def format
          sprintf("%-10s | %-15s | %-5s | %10s GB",
            @obj.id[0, 10],
            @obj.name[0, 15],
            @obj.state[0,5],
            @obj.limit.to_s[0,10]
          )
        end
      end

      class HardwareProfile < Base
        def format
          sprintf("%-15s | %-6s | %10s | %10s ", @obj.id[0, 15],
            @obj.architecture.value[0,6], @obj.memory.value.to_s[0,10], @obj.storage.value.to_s[0,10])
        end
      end

      class Instance < Base
        def format
          sprintf("%-15s | %-15s | %-15s | %10s | %32s | %32s",
            @obj.id ? @obj.id[0,15] : '-',
            @obj.name ? @obj.name[0,15] : 'unknown',
            @obj.image.name ? @obj.image.name[0,15] : 'unknown',
            @obj.state ? @obj.state.to_s[0,10] : 'unknown',
            @obj.public_addresses.join(',')[0,32],
            @obj.private_addresses.join(',')[0,32]
          )
        end
      end

      class StorageVolume < Base
        def format
          sprintf("%-10s | %15s GB | %-10s | %-10s | %-15s",
            @obj.id[0,10],
            @obj.capacity ? @obj.capacity.to_s[0,15] : 'unknown',
            @obj.device ? @obj.device[0,10] : 'unknown',
            @obj.respond_to?('state') ? @obj.state[0,10] : 'unknown',
            @obj.instance ? @obj.instance.name[0,15] : 'unknown'
          )
        end
      end

      class StorageSnapshot < Base
        def format
          sprintf("%-10s | %-15s | %-6s | %15s",
            @obj.id[0,10],
            @obj.storage_volume.respond_to?('name') ? @obj.storage_volume.name[0, 15] : 'unknown',
            @obj.state ? @obj.state[0,10] : 'unknown',
            @obj.created ? @obj.created[0,19] : 'unknown'
          )
        end
      end

    end

    def format(obj)
      object_name = obj.class.name.classify.gsub(/^DeltaCloud::API::/, '')
      format_class = DeltaCloud::PlainFormatter::FormatObject.const_get(object_name)
      format_class.new(obj).format
    end

  end
end
