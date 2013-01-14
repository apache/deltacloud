module Deltacloud
  module Database

    class MachineTemplate < Entity
      belongs_to :provider

      property :machine_config, String, :length => 255
      property :machine_image, String, :length => 255

    end

  end
end
