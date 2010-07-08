
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
