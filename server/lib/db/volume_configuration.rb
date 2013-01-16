module Deltacloud
  module Database

    class VolumeConfiguration < Entity
      validates_presence_of :format
      validates_presence_of :capacity
    end

  end
end
