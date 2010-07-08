
require 'models/base_model'

class Image < BaseModel

  attribute :description,  :string
  attribute :owner_id,     :string
  attribute :architecture, :string

  def initialize(client, uri, init=nil)
    super( client, uri, init )
  end

end
