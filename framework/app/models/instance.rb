
class Instance < BaseModel

  attr_accessor :resource_id
  attr_accessor :owner_id
  attr_accessor :image_id
  attr_accessor :flavor_id
  attr_accessor :state
  attr_accessor :actions
  attr_accessor :public_addresses
  attr_accessor :private_addresses
  
end
