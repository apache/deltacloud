module Deltacloud
  module Database

    class Provider
      include DataMapper::Resource

      property :id, Serial
      property :driver, String, :required => true
      property :url, Text

      has n, :entities
      has n, :machine_templates
      has n, :address_templates

      # This is a workaround for strange bug in Fedora MRI:
      #
      def machine_templates
        MachineTemplate.all(:provider_id => self.id)
      end

      def address_templates
        AddressTemplate.all(:provider_id => self.id)
      end

      def entities
        Entity.all(:provider_id => self.id)
      end

    end

  end
end
