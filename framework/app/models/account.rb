
class Account < Base

  has_many :images
  has_many :instances

  def to_s
    self.id
  end

end
