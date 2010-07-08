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
    class Realm < BaseModel

      xml_tag_name :realm

      attribute :name
      attribute :state
      attribute :limit

      def initialize(client, uri, xml=nil)
        super( client, uri, xml )
      end

      def load_payload(xml=nil)
        super(xml)
        unless xml.nil?
          @name = xml.text( 'name' )
          @state = xml.text( 'state' )
          @limit = xml.text( 'limit' )
          if ( @limit.nil? || @limit == '' )
            @limit = :unlimited
          else
            @limit = @limit.to_f
          end
        end
      end
    end
end
