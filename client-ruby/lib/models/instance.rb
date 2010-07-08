
require 'models/base_model'

class Instance < BaseModel

  xml_tag_name :instance

  attribute :owner_id
  attribute :public_addresses
  attribute :private_addresses
  attribute :state
  attribute :actions
  attribute :image
  attribute :flavor

  def initialize(client, uri, xml=nil)
    super( client, uri, xml )
  end

  def load_payload(xml=nil)
    super(xml)
    unless xml.nil?
      @owner_id = xml.text('owner_id')
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
      @state = xml.text( 'state' )
      @actions = []
      xml.get_elements( 'actions/link' ).each do |link|
        @actions << link.attributes['rel']
      end
    end
  end
end
