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
    class Flavor < BaseModel

      xml_tag_name :flavor

      attribute :memory
      attribute :storage
      attribute :architecture

      def initialize(client, uri, xml=nil)
        super( client, uri, xml )
      end

      def load_payload(xml=nil)
        super(xml)
        unless xml.nil?
          @memory = xml.text( 'memory' ).to_f
          @storage = xml.text( 'storage' ).to_f
          @architecture = xml.text( 'architecture' )
        end
      end

      def to_plain
        sprintf("%-15s | %-6s | %10s GB | %10s GB", self.id[0, 15], self.architecture[0,6],
          self.memory.to_s[0,10], self.storage.to_s[0,10])
      end

    end
end
