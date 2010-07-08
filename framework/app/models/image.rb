
class Image < Base

  simple_attribute :description
  has_one :owner
  simple_attribute :architecture
  simple_attribute :platform

  def to_s
    self.id
  end

end
