require 'models/base_model'

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
