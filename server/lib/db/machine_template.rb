module Deltacloud
  module Database

    class MachineTemplateEntity < Entity
      belongs_to :provider

      property :machine_config, String
      property :machine_image, String

    end

  end
end
