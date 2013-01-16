module Deltacloud
  module Database

    class AddressTemplate < Entity
      validates_presence_of :ip
      validates_presence_of :hostname
      validates_presence_of :allocation
      validates_presence_of :default_gateway
      validates_presence_of :dns
      validates_presence_of :protocol
      validates_presence_of :mask
    end

  end
end
