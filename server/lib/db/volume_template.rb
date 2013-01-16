module Deltacloud
  module Database

    class VolumeTemplate < Entity
      validates_presence_of :volume_config
      validates_presence_of :volume_Image
    end

  end
end
