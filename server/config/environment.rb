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
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"


  #config.gem "activerecord-jdbc-adapter",
             #:lib=>'jdbc_adapter'

  #config.gem "torquebox-gem"

  #config.gem "torquebox-rails"
  #config.gem "right_aws"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]
  config.frameworks -= [ :active_record ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
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
