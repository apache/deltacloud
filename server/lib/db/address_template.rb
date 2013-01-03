module Deltacloud
  module Database

    class AddressTemplate < Entity
      belongs_to :provider

      property :ip, String
      property :hostname, String
      property :allocation, String, :default => 'dynamic'
      property :default_gateway, String, :default => 'unknown'
      property :dns, String, :default => 'unknown'
      property :protocol, String, :default => 'ipv4'
      property :mask, String, :default => 'unknown'
      property :network, String
    end

  end
end
