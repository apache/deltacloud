
require 'dcloud/base_model'

module DCloud
    class Image < BaseModel

      xml_tag_name :image

      attribute :description
      attribute :owner_id
      attribute :architecture

      def initialize(client, uri, xml=nil)
        super( client, uri, xml )
      end

      def load_payload(xml)
        super( xml )
        unless xml.nil?
          @description = xml.text( 'description' )
          @owner_id = xml.text( 'owner_id' )
          @architecture = xml.text( 'architecture' )
        end
      end

    end
end
