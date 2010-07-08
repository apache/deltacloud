
require 'models/base_model'

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
    end
end
