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

module Deltacloud::EC2

  class Converter

    def self.convert(builder, action, result)
      klass_name = ActionHandler::MAPPINGS[action][:method].to_s.camelize
      klass = Converter.const_get(klass_name)
      klass.new(builder, result).to_xml
    end

    class Base

      attr_reader :xml
      attr_reader :obj

      def initialize(builder, object)
        @xml = builder
        @obj = object
      end

    end

    class Realms < Base

      def to_xml
        xml.availabilityZoneInfo {
          obj.each do |item|
            xml.item {
              xml.zoneName item.id
              xml.zoneState item.state
              xml.regionName item.name
            }
          end
        }
      end

    end

    class Images < Base

      def to_xml
        xml.imagesSet {
          obj.each do |item|
            xml.item {
              xml.imageId item.id
              xml.imageState item.state.downcase
              xml.imageOwnerId item.owner_id
              xml.architecture item.architecture
              xml.imageType 'machine'
              xml.name item.name
              xml.description item.description
            }
          end
        }
      end

    end

    class CreateInstance < Base

      def to_xml
        xml.reservationId 'r-11111111'
        xml.ownerId @obj.owner_id
        xml.groupSet {
          xml.item {
            xml.groupId 'sg-11111111'
            xml.groupName 'default'
          }
        }
        Instances.new(@xml, [@obj]).instance_set
      end

    end

    class Instances < Base

      def instance_set
        xml.instancesSet {
          obj.each do |item|
            xml.item {
              xml.instanceId item.id
              xml.imageId item.image_id
              xml.instanceType item.instance_profile.name
              xml.launchTime item.launch_time
              xml.ipAddress item.public_addresses.first.address
              xml.privateIpAddress item.public_addresses.first.address
              xml.dnsName item.public_addresses.first.address
              xml.privateDnsName item.private_addresses.first.address
              xml.architecture item.instance_profile.architecture
              xml.keyName item.keyname
              xml.instanceState {
                xml.code '16'
                xml.name item.state.downcase
              }
              xml.placement {
                xml.availabilityZone item.realm_id
                xml.groupName
                xml.tenancy 'default'
              }
            }
          end
        }
      end

      def to_xml
        xml.reservationSet {
          xml.item {
            xml.reservationId 'r-11111111'
            xml.ownerId 'deltacloud'
            xml.groupSet {
              xml.item {
                xml.groupId 'sg-11111111'
                xml.groupName 'default'
              }
            }
            self.instance_set
          }
        }
      end

    end

  end

end
