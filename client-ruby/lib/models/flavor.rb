
require 'models/base_model'

class Flavor < BaseModel

  attribute :memory,       :float
  attribute :storage,      :float
  attribute :architecture, :string

  def initialize(client, uri, init=nil)
    super( client, uri, init )
  end

end
