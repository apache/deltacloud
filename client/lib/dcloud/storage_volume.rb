#
# Copyright (C) 2009  Red Hat, Inc.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

require 'dcloud/base_model'

module DCloud
    class StorageVolume < BaseModel

      xml_tag_name :storage_volume

      attribute :created
      attribute :state
      attribute :capacity
      attribute :device
      attribute :instance

      def initialize(client, uri, xml=nil)
        super( client, uri, xml )
      end

      def load_payload(xml=nil)
        super(xml)
        unless xml.nil?
          @created = xml.text( 'created' )
          @state = xml.text( 'state' )
          @capacity = xml.text( 'capacity' ).to_f
          @device = xml.text( 'device' )
          instances = xml.get_elements( 'instance' )
          if ( ! instances.empty? )
            instance = instances.first
            instance_href = instance.attributes['href']
            if ( instance_href ) 
              @instance = Instance.new( @client, instance_href )
            end
          end
        end
      end
    end
end
