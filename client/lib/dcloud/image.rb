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
    class Image < BaseModel

      xml_tag_name :image

      attribute :description
      attribute :owner_id
      attribute :architecture
      attribute :name

      def initialize(client, uri, xml=nil)
        super( client, uri, xml )
      end

      def load_payload(xml)
        super( xml )
        unless xml.nil?
          @description = xml.text( 'description' )
          @owner_id = xml.text( 'owner_id' )
          @name = xml.text( 'name' )          
          @architecture = xml.text( 'architecture' )
        end
      end

    end
end
