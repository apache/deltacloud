require 'models/base_model'

class StorageVolume < BaseModel

  attribute :created
  attribute :state
  attribute :capacity
  attribute :device
  attribute :instance

  def initialize(client, uri, xml=nil)
    super( client, uri, xml )
  end

  def load_payload(xml=nil)
    super(xml)
    unless xml.nil?
      @created = xml.text( 'created' )
      @state = xml.text( 'state' )
      @capacity = xml.text( 'capacity' ).to_f
      @device = xml.text( 'device' )
      instances = xml.get_elements( 'instance' )
      if ( ! instances.empty? )
        instance = instances.first
        instance_href = instance.attributes['href']
        if ( instance_href ) 
          @instance = Instance.new( @client, instance_href )
        end
      end
    end
  end
end
