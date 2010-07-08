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


module DCloud
    class BaseModel

      def self.xml_tag_name(name=nil)
        unless ( name.nil? ) 
          @xml_tag_name = name
        end
        @xml_tag_name || self.class.name.downcase.to_sym
      end


      def self.attribute(attr)
        build_reader attr
      end

      def self.build_reader(attr)
        eval "
          def #{attr}
            check_load_payload
            @#{attr}
          end
        "
      end

      attr_reader :uri

      def initialize(client, uri=nil, xml=nil)
        @client      = client
        @uri         = uri
        @loaded      = false
        load_payload( xml )
      end

      def id()
        check_load_payload
        @id
      end

     
      protected

      attr_reader :client

      def check_load_payload()
        return if @loaded
        xml = @client.fetch_resource( self.class.xml_tag_name.to_sym, @uri )
        load_payload(xml)
      end

      def load_payload(xml=nil)
        unless ( xml.nil? )
          @loaded = true
          @id = xml.text( 'id' ) 
        end
      end

      def unload
        @loaded = false
      end

    end
end
