
class Instance < Base

  simple_attribute :state

  has_one :image
  has_one :owner

  simple_attribute :public_address
  simple_attribute :private_address

  action :stop
  action :reboot

  def to_s
    self.id
  end

end

