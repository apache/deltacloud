
class Instance < BaseModel

  attr_accessor :owner_id
  attr_accessor :image_id
  attr_accessor :flavor_id
  attr_accessor :state
  attr_accessor :actions
  attr_accessor :public_addresses
  attr_accessor :private_addresses
  
 def initialize(init=nil)
   super(init)
   self.actions = [] if self.actions.nil?
  end  
end
