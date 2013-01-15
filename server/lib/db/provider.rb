module Deltacloud
  module Database

    class Provider < Sequel::Model
      one_to_many :entities
      one_to_many :machine_templates
      one_to_many :address_templates
      one_to_many :volume_templates
      one_to_many :volume_configurations
    end

  end
end
