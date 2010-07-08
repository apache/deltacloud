
require 'models/base_model'

module DCloud
    class StorageSnapshot < BaseModel

      xml_tag_name :storage_snapshot

      attribute :created
      attribute :state
      attribute :storage_volume

      def initialize(client, uri, xml=nil)
        super( client, uri, xml )
      end

      def load_payload(xml=nil)
        super(xml)
        unless xml.nil?
          @created = xml.text( 'created' )
          @state = xml.text( 'state' )
          storage_volumes = xml.get_elements( 'storage-volume' )
          if ( ! storage_volumes.empty? )
            storage_volume = storage_volumes.first
            storage_volume_href = storage_volume.attributes['href']
            if ( storage_volume_href ) 
              @storage_volume = StorageVolume.new( @client, storage_volume_href )
            end
          end
        end
      end
    end
end
