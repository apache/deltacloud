module Deltacloud
  module Database

    class MachineTemplate < Entity
      belongs_to :provider

      property :machine_config, String
      property :machine_image, String

    end

  end
end
