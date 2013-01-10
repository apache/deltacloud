module Deltacloud
  module Database

    class VolumeTemplate < Entity
      belongs_to :provider

      property :volume_config, String
      property :volume_image, String
    end

  end
end
