#
# Copyright (C) 2009  Red Hat, Inc.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

  config.gem 'right_aws'
  #config.gem 'compass'

  config.frameworks -= [ :active_record ]

  config.time_zone = 'UTC'

end

#DEFAULT_DRIVER=:ec2
DEFAULT_DRIVER=:mock
#DEFAULT_DRIVER=:rhevm


unless defined?( DRIVER )
  driver_env = ENV['DRIVER']
  ( driver_env = driver_env.to_sym ) if ( driver_env )
  DRIVER=driver_env if driver_env
end

unless defined?( DRIVER )
  if ( defined?( DEFAULT_DRIVER ) )
    DRIVER=DEFAULT_DRIVER
  else
    raise Exception.new( "DRIVER must be defined through environment variable or DEFAULT_DRIVER through config/environment.rb" )
  end
end


DRIVER_ROOT = File.dirname( __FILE__ ) + "/../../driver-#{DRIVER}"
$: << DRIVER_ROOT+'/lib'

case DRIVER
  when :mock
    DRIVER_CLASS_NAME = "Deltacloud::Drivers::Mock::MockDriver"
    mock_storage_root = File.dirname( __FILE__ ) + "/../../client/specs/data"
    puts "Using mock storage root of #{mock_storage_root}"
    MOCK_STORAGE_ROOT = mock_storage_root
  when :ec2
    DRIVER_CLASS_NAME = "Deltacloud::Drivers::EC2::EC2Driver"
  when :rackspace
    DRIVER_CLASS_NAME = "Deltacloud::Drivers::Rackspace::RackspaceDriver"
  when :rhevm
    DRIVER_CLASS_NAME = "Deltacloud::Drivers::RHEVM::RHEVMDriver"
end
