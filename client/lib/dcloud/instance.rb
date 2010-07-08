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
    class Instance < BaseModel

      xml_tag_name :instance

      attribute :name
      attribute :owner_id
      attribute :public_addresses
      attribute :private_addresses
      attribute :state
      attribute :actions
      attribute :image
      attribute :flavor
      attribute :realm
      attribute :action_urls

      def initialize(client, uri, xml=nil)
        @action_urls = {}
        super( client, uri, xml )
      end

      def to_plain
        sprintf("%-15s | %-15s | %-15s | %10s | %32s | %32s", 
          self.id ? self.id[0,15] : '-',
          self.name ? self.name[0,15] : 'unknown',
          self.image.name ? self.image.name[0,15] : 'unknown',
          self.state ? self.state.to_s[0,10] : 'unknown',
          self.public_addresses.join(',')[0,32],
          self.private_addresses.join(',')[0,32]
          )
      end

      def start!()
        url = action_urls['start']
        throw Exception.new( "Unable to start" ) unless url
        client.post_instance( url )
        unload
      end

      def reboot!()
        url = action_urls['reboot']
        throw Exception.new( "Unable to reboot" ) unless url
        client.post_instance( url )
        unload
      end

      def stop!()
        url = action_urls['stop']
        throw Exception.new( "Unable to stop" ) unless url
        client.post_instance( url )
        unload
      end

      def load_payload(xml=nil)
        super(xml)
        unless xml.nil?
          @owner_id = xml.text('owner_id')
          @name     = xml.text('name')
          @public_addresses = []
          xml.get_elements( 'public-addresses/address' ).each do |address|
            @public_addresses << address.text
          end
          @private_addresses = []
          xml.get_elements( 'private-addresses/address' ).each do |address|
            @private_addresses << address.text
          end
          image_uri = xml.get_elements( 'image' )[0].attributes['href']
          @image = Image.new( @client, image_uri )
          flavor_uri = xml.get_elements( 'flavor' )[0].attributes['href']
          @flavor = Flavor.new( @client, flavor_uri )
          # Only use realms if they are there
          if (!xml.get_elements( 'realm' ).empty?)
              realm_uri = xml.get_elements( 'realm' )[0].attributes['href']
              @realm = Realm.new( @client, realm_uri )
          end
          @state = xml.text( 'state' )
          @actions = []
          xml.get_elements( 'actions/link' ).each do |link|
            action_name = link.attributes['rel']
            if ( action_name )
              @actions << link.attributes['rel']
              @action_urls[ link.attributes['rel'] ] = link.attributes['href']
            end
          end
        end
      end
    end
end
