module Deltacloud
  module Database

    class MachineTemplate < Entity
      validates_presence_of :machine_config
      validates_presence_of :machine_image
    end

  end
end
