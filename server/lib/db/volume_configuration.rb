module Deltacloud
  module Database

    class VolumeConfiguration < Entity
      belongs_to :provider

      property :format, String
      property :capacity, String
    end

  end
end
