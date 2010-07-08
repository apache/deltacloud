
require 'models/base_model'

class Instance < BaseModel

  attribute :owner_id,        :string
  attribute :public_address,  :string
  attribute :private_address, :string
  attribute :state,           :string

  has_one :image,             :Image 
  has_one :flavor,            :Flavor

  def initialize(client, uri, init=nil)
    super( client, uri, init )
  end

end
